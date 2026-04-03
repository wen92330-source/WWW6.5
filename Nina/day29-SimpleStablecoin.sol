// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // 标准代币功能——铸造、转账和管理余额
import "@openzeppelin/contracts/access/Ownable.sol"; // 所有权系统
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; // 保护重要函数免受"重入"攻击——恶意合约试图在第一次调用完成之前重复调用函数
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; // 确保所有代币操作要么成功完成，要么干净地失败
import "@openzeppelin/contracts/access/AccessControl.sol"; // 允许合约定义自定义角色。价格源管理器 角色——所以特定账户可以在没有完全管理员控制的情况下更新价格源。
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol"; // 获取关于抵押代币的额外信息，如它使用多少位小数。
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // 让我们的稳定币看到抵押代币的真实世界价格

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20; // 为我们与之交互的所有 IERC20 代币激活 SafeERC20

    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE"); 
        // 创建特殊角色，它控制谁可以更新价格源。
        // bytes32 被使用是因为 AccessControl 中的角色标识符总是期望正好 32 字节——这是一个标准化格式，使角色检查在以太坊虚拟机（EVM）内部快速高效。
        // 使用 keccak256("PRICE_FEED_MANAGER_ROLE") 生成它，这样角色就有一个独特的、加密强度的标识符，而不是只使用一个普通字符串。
    IERC20 public immutable collateralToken; // 抵押代币。以后永远不能更改，增加了额外的安全层。
    uint8 public immutable collateralDecimals;
    AggregatorV3Interface public priceFeed; // 在有人铸造或赎回稳定币时获取我们抵押代币的实时价格。
    uint256 public collateralizationRatio = 150; // 以百分比表示（150 = 150%） // **抵押率**——用户在铸造稳定币时必须始终存入其价值的 **150%** 的抵押品。安全缓冲，以保护系统免受抵押品价值突然下降的影响。

    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited); // 成功铸造稳定币。收到多少稳定币，存入多少抵押品。
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned); // 将稳定币赎回为抵押品。销毁多少稳定币，取回多少抵押品。
    event PriceFeedUpdated(address newPriceFeed); //价格源地址更新——对关键数据源的任何更改都是公开可见的。
    event CollateralizationRatioUpdated(uint256 newRatio);

    error InvalidCollateralTokenAddress(); // 自定义错误
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();

    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    ) ERC20("Simple USD Stablecoin", "sUSD") Ownable(_initialOwner) {
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();
        // sUSD继承 ERC20，官方实现的 decimals() 函数默认返回 18

        collateralToken = IERC20(_collateralToken);
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);

        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }

    function mint(uint256 amount) external nonReentrant { // 用户将抵押品存入合约并接收新铸造的稳定币作为回报 // amount输入想要铸造多少稳定币（10^18）
        if (amount == 0) revert MintAmountIsZero();

        uint256 adjustedRequiredCollateral=_calculateRequiredCollateralForMint(amount); 

        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral); // 安全地将所需数量的抵押品从用户转入合约
        _mint(msg.sender, amount); // 一旦抵押品安全存入，我们铸造请求数量的 sUSD 稳定币直接进入用户的钱包

        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    function redeem(uint256 amount) external nonReentrant { // 赎回是他们销毁他们的 sUSD 并取回他们的抵押品的方式。 // 想要销毁多少sUSD
        if (amount == 0) revert MintAmountIsZero();
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        uint256 adjustedCollateralToReturn=_calculateCollateralForRedeem(amount);

        _burn(msg.sender, amount);
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);

        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        if (newRatio < 100) revert CollateralizationRatioTooLow();
        collateralizationRatio = newRatio;
        emit CollateralizationRatioUpdated(newRatio);
    }

    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }

    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;
        return _calculateRequiredCollateralForMint(amount);
    }

    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;
        return _calculateCollateralForRedeem(amount);
    }

    function _calculateRequiredCollateralForMint(uint256 amount) internal view returns (uint256) {
        uint256 collateralPrice = getCurrentPrice();
        uint256 adjustedRequiredCollateral = (amount * collateralizationRatio * (10 ** collateralDecimals) * (10 ** priceFeed.decimals())) / ((10 ** decimals()) * 100 * collateralPrice);
            /** amount：用户想要的sUSD数量（单位是18位精度） - decimals()
                sUSD的USD价格为1.
                collateralPrice：Chianlink返回的抵押代币的USD价格，通常是8位精度 -  priceFeed.decimals()
                抵押代币的精度 - collateralDecimals

                核心公式：requiredCollateral = amount * price(sUSD) * ratio / price(collateral)
                调整精度：adjustedRequiredCollateral = amount/decimals() * 1 * 150% * 10^collateralDecimals / (collateralPrice/priceFeed.decimals())
                前端显示时除以10^collateralDecimals，得到需要的抵押代币数量
                另外注意solidity中先乘后除
             */
        
        return adjustedRequiredCollateral;
    }

    function _calculateCollateralForRedeem(uint256 amount) internal view returns (uint256) {
        // **应该返回多少抵押品价值**——基于抵押率和当前市场价格。例如：如果你以 150% 赎回 $100，你应该取回大约 $66.66 价值的抵押品。
        uint256 collateralPrice = getCurrentPrice();
        uint256 adjustedCollateralToReturn = (amount * 100 * (10 ** collateralDecimals) * (10 ** priceFeed.decimals())) / (10 ** decimals() * collateralizationRatio * collateralPrice); 

        return adjustedCollateralToReturn;
    }
}


