// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    //为我们与之交互的所有 IERC20 代币激活 SafeERC20
    using SafeERC20 for IERC20;

    //bytes32 被使用是因为 AccessControl 中的角色标识符总是期望正好 32 字节
    //PRICE_FEED_MANAGER_ROLE 是区块链 / DeFi 合约里的价格预言机管理角色权限，用于管控价格喂价（Price Feed）的配置、更新与治理。
    //使用 keccak256("PRICE_FEED_MANAGER_ROLE") 生成它，这样角色就有一个独特的、加密强度的标识符
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    //immutable确保只能设置一次——在部署时——并且以后永远不能更改
    IERC20 public immutable collateralToken;
    uint8 public immutable collateralDecimals;
    //公开的 Chainlink 预言机接口变量，用于让智能合约调用该接口，获取我们抵押代币的实时价格
    AggregatorV3Interface public priceFeed;
    uint256 public collateralizationRatio = 150; // 抵押率以百分比表示（150 = 150%）

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);
    event PriceFeedUpdated(address newPriceFeed);//价格源地址更新
    event CollateralizationRatioUpdated(uint256 newRatio);//抵押率更改

    //自定义错误
    error InvalidCollateralTokenAddress();//无效（零）抵押代币地址部署合约
    error InvalidPriceFeedAddress();//价格源地址无效
    error MintAmountIsZero();//铸造零稳定币
    error InsufficientStablecoinBalance();//赎回比他们实际余额更多的稳定币
    error CollateralizationRatioTooLow();//抵押率最低限度100%

    constructor(
        address _collateralToken,//抵押代币地址
        address _initialOwner,//初始所有者地址
        address _priceFeed//价格源地址
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) { //代币名称和符合；设置合约初始所有者
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        collateralToken = IERC20(_collateralToken);//用户在铸造稳定币时将存入什么代币
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();//获取并存储抵押代币的小数
        priceFeed = AggregatorV3Interface(_priceFeed);//将合约连接到 Chainlink 价格源

        //角色权限库（AccessControl） 内部方法，作用是给指定地址分配一个角色，是权限控制的基础操作。
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);//让所有者完全控制合约的角色系统
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);//让所有者在将来需要时更新价格源
    }

    //从 Chainlink 获取实时价格
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    //铸造稳定币
    function mint(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();

        uint256 collateralPrice = getCurrentPrice();//连接的 Chainlink 价格源获取抵押代币的当前实时价格
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals()); // 计算稳定币的 USD 价值，假设 sUSD 为 18 位小数
        //所需抵押品价值（以USD计） = （想要铸造的稳定币价值 × 抵押率）÷（100 × 抵押代币当前实时价格）
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());//换算小数位

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);//安全地将所需数量的抵押品从用户转入合约
        _mint(msg.sender, amount);//铸造请求数量的 sUSD 稳定币直接进入用户的钱包

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    //赎回稳定币
    function redeem(uint256 amount) external nonReentrant {
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();//检查用户实际拥有足够的 sUSD 来赎回

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        //应当返回的抵押品价值=(正在赎回的 sUSD 代币的 USD 价值x100)/(抵押率x抵押代币当前实时价格）
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        _burn(msg.sender, amount);
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    //更新抵押率
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        if (newRatio < 100) revert CollateralizationRatioTooLow();
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
    }

    //更新价格源地址
    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {  //受信任角色不仅仅是所有者更新
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);//更新内部 priceFeed 引用
        emit PriceFeedUpdated(_newPriceFeed);
    }

    //预览所需抵押品
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        uint256 requiredCollateral = (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral = (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;
    }

    //预览赎回时返回的抵押品
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn = (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn = (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }

}

