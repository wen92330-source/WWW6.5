// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 标准库（安全、成熟的合约组件）
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";       // ERC20 代币标准
import "@openzeppelin/contracts/access/Ownable.sol";         // 所有者权限控制
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; // 防重入攻击
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // 安全转账
import "@openzeppelin/contracts/access/AccessControl.sol";   // 角色权限控制
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol"; // 获取 token 小数位
//预言机的网址有问题，不知道怎么解决所以写了接口import "https://raw.githubusercontent.com/smartcontractkit/chainlink/v0.8/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80,
      int256,
      uint256,
      uint256,
      uint80
    );

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
// 主合约：一个简单的稳定币
contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {

    using SafeERC20 for IERC20;

    // 定义一个角色：可以更新价格预言机
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");

    // 抵押资产（例如 USDC / ETH）
    IERC20 public immutable collateralToken;

    // 抵押资产的小数位（例如 USDC 是 6）
    uint8 public immutable collateralDecimals;

    // Chainlink 价格预言机
    AggregatorV3Interface public priceFeed;

    // 抵押率（150% = 超额抵押）
    uint256 public collateralizationRatio = 150;

    // ===== 事件 =====
    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    event PriceFeedUpdated(address newPriceFeed);
    event CollateralizationRatioUpdated(uint256 newRatio);

    // ===== 错误定义（比 require 更省 gas）=====
    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();

    // ===== 构造函数 =====
    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    )
        ERC20("Simple USD Stablecoin", "sUSD") // 设置代币名和符号
        Ownable(_initialOwner)
    {
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        collateralToken = IERC20(_collateralToken);

        // 获取抵押 token 的 decimals
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();

        priceFeed = AggregatorV3Interface(_priceFeed);

        // 设置权限
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    // ===== 获取当前价格（来自 Chainlink）=====
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    // ===== 铸造稳定币 =====
    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();

        uint256 collateralPrice = getCurrentPrice();

        // 需要的美元价值（假设 sUSD = 18位）
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());

        // 按抵押率计算需要多少抵押物
        uint256 requiredCollateral =
            (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);

        // 调整不同 decimals（非常重要！）
        uint256 adjustedRequiredCollateral =
            (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        // 用户转入抵押物
        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);

        // 铸造稳定币
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    // ===== 赎回稳定币 =====
    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        uint256 collateralPrice = getCurrentPrice();

        uint256 stablecoinValueUSD = amount * (10 ** decimals());

        // 计算可以取回多少抵押物
        uint256 collateralToReturn =
            (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);

        uint256 adjustedCollateralToReturn =
            (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        // 销毁稳定币
        _burn(msg.sender, amount);

        // 返回抵押物
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    // ===== 修改抵押率 =====
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        if (newRatio < 100) revert CollateralizationRatioTooLow(); // 至少 100%
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
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

    // ===== 查询：铸造需要多少抵押 =====
    function getRequiredCollateralForMint(uint256 amount)
        public
        view
        returns (uint256)
    {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();

        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());

        uint256 requiredCollateral =
            (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);

        uint256 adjustedRequiredCollateral =
            (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;
    }

    // ===== 查询：赎回能拿回多少抵押 =====
    function getCollateralForRedeem(uint256 amount)
        public
        view
        returns (uint256)
    {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();

        uint256 stablecoinValueUSD = amount * (10 ** decimals());

        uint256 collateralToReturn =
            (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);

        uint256 adjustedCollateralToReturn =
            (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }
}