// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入 OpenZeppelin 标准库（相当于现成工具箱）
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";        // ERC20代币标准
import "@openzeppelin/contracts/access/Ownable.sol";           // 管理员权限
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; // 防止重入攻击（黑客常用攻击方式）
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // 安全转账
import "@openzeppelin/contracts/access/AccessControl.sol";     // 更复杂的权限控制
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol"; // 获取代币精度
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    
    // 使用安全ERC20方法（避免转账出错）
    using SafeERC20 for IERC20;
    
    // 定义一个角色：可以修改价格预言机
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    
    // 抵押代币（比如WETH）
    IERC20 public collateralToken;
    
    // 抵押代币的小数位（比如ETH是18位）
    uint8 public collateralDecimals;
    
    // 价格预言机（获取ETH/USD价格）
    AggregatorV3Interface public priceFeed;
    
    // 抵押率（比如150% = 15000）
    uint256 public collateralizationRatio;  
    
    // ===== 事件（用于记录日志）=====
    event Minted(address indexed user, uint256 stablecoinAmount, uint256 collateralAmount);
    event Redeemed(address indexed user, uint256 stablecoinAmount, uint256 collateralAmount);
    event PriceFeedUpdated(address indexed newPriceFeed);
    event CollateralizationRatioUpdated(uint256 newRatio);
    
    // ===== 自定义错误（比require更省gas）=====
    error InvalidCollateralTokenAddress(); // 抵押代币地址错误
    error InvalidPriceFeedAddress();       // 价格预言机地址错误
    error MintAmountIsZero();              // 铸造数量为0
    error InsufficientStablecoinBalance(); // 稳定币余额不足
    error CollateralizationRatioTooLow();  // 抵押率太低
    
    // ===== 构造函数（部署时执行）=====
    constructor(
        address _collateralToken,   // 抵押代币地址
        address _priceFeed,        // 价格预言机地址
        uint256 _collateralizationRatio // 抵押率
    ) ERC20("Simple USD", "sUSD") Ownable(msg.sender) {
        
        // 基本检查
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();
        if (_collateralizationRatio < 10000) revert CollateralizationRatioTooLow(); // 必须>=100%
        
        // 设置抵押代币
        collateralToken = IERC20(_collateralToken);
        
        // 获取代币精度（比如18）
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        
        // 设置价格预言机
        priceFeed = AggregatorV3Interface(_priceFeed);
        
        // 设置抵押率
        collateralizationRatio = _collateralizationRatio;
        
        // 给部署者权限
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PRICE_FEED_MANAGER_ROLE, msg.sender);
    }
    
    // ===== 获取当前价格 =====
    function getCurrentPrice() public view returns (uint256) {
        
        // 从Chainlink获取价格
        (, int256 price, , , ) = priceFeed.latestRoundData();
        
        require(price > 0, "Invalid price");
        
        uint8 priceFeedDecimals = priceFeed.decimals();
        
        // 统一转换成18位精度（重要！）
        if (priceFeedDecimals < 18) {
            return uint256(price) * (10 ** (18 - priceFeedDecimals));
        } else if (priceFeedDecimals > 18) {
            return uint256(price) / (10 ** (priceFeedDecimals - 18));
        }
        
        return uint256(price);
    }
    
    // ===== 铸造稳定币（存抵押 → 得sUSD）=====
    function mint(uint256 stablecoinAmount) external nonReentrant {
        
        // 不允许铸造0
        if (stablecoinAmount == 0) revert MintAmountIsZero();
        
        // 计算需要多少抵押物
        uint256 requiredCollateral = getRequiredCollateralForMint(stablecoinAmount);
        
        // 把抵押物从用户转到合约
        collateralToken.safeTransferFrom(msg.sender, address(this), requiredCollateral);
        
        // 给用户铸造稳定币
        _mint(msg.sender, stablecoinAmount);
        
        // 记录事件
        emit Minted(msg.sender, stablecoinAmount, requiredCollateral);
    }
    
    // ===== 赎回（还sUSD → 拿回抵押）=====
    function redeem(uint256 stablecoinAmount) external nonReentrant {
        
        // 检查用户是否有足够sUSD
        if (balanceOf(msg.sender) < stablecoinAmount) {
            revert InsufficientStablecoinBalance();
        }
        
        // 计算可以拿回多少抵押物
        uint256 collateralToReturn = getCollateralForRedeem(stablecoinAmount);
        
        // 销毁稳定币（相当于还钱）
        _burn(msg.sender, stablecoinAmount);
        
        // 把抵押物还给用户
        collateralToken.safeTransfer(msg.sender, collateralToReturn);
        
        emit Redeemed(msg.sender, stablecoinAmount, collateralToReturn);
    }
    
    // ===== 计算需要多少抵押物 =====
    function getRequiredCollateralForMint(uint256 stablecoinAmount)
        public
        view
        returns (uint256)
    {
        uint256 collateralPrice = getCurrentPrice();
        
        // 计算基础抵押（按1:1）
        uint256 baseCollateral = (stablecoinAmount * 10 ** collateralDecimals) / collateralPrice;
        
        // 乘以抵押率（比如150%）
        uint256 requiredCollateral = (baseCollateral * collateralizationRatio) / 10000;
        
        return requiredCollateral;
    }
    
    // ===== 计算赎回多少抵押 =====
    function getCollateralForRedeem(uint256 stablecoinAmount)
        public
        view
        returns (uint256)
    {
        uint256 collateralPrice = getCurrentPrice();
        
        // 按1:1赎回
        uint256 collateralAmount = (stablecoinAmount * 10 ** collateralDecimals) / collateralPrice;
        
        return collateralAmount;
    }
    
    // ===== 修改抵押率（只有owner）=====
    function setCollateralizationRatio(uint256 _newRatio) external onlyOwner {
        if (_newRatio < 10000) revert CollateralizationRatioTooLow();
        collateralizationRatio = _newRatio;
        emit CollateralizationRatioUpdated(_newRatio);
    }
    
    // ===== 修改价格预言机 =====
    function setPriceFeedContract(address _newPriceFeed)
        external
        onlyRole(PRICE_FEED_MANAGER_ROLE)
    {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }
    
    // ===== 查看系统信息 =====
    function getSystemInfo() external view returns (
        address _collateralToken,
        uint256 _collateralizationRatio,
        uint256 _currentPrice,
        uint256 _totalSupply,
        uint256 _collateralBalance
    ) {
        return (
            address(collateralToken),
            collateralizationRatio,
            getCurrentPrice(),
            totalSupply(),
            collateralToken.balanceOf(address(this))
        );
    }
}
