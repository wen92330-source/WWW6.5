// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleStablecoin - 简单抵押型稳定币合约
/// @notice 用户可以抵押 ERC20 代币铸造 sUSD，并按抵押比例赎回
/// @dev 使用 Chainlink 价格预言机获取抵押品价格，支持可升级的抵押率和价格预言机地址

// 让这个合约本身变成一个 ERC20 代币，也就是 sUSD
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// 提供 onlyOwner 权限控制
import "@openzeppelin/contracts/access/Ownable.sol";
// 防止重入攻击
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// 更安全地操作 ERC20 转账
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// 提供角色权限控制
import "@openzeppelin/contracts/access/AccessControl.sol";
// 用来读取抵押代币的小数位
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
// Chainlink 价格预言机接口
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 这个合约同时具备：
// 1. ERC20 代币功能（sUSD）
// 2. owner 权限管理
// 3. 防重入保护
// 4. 角色权限管理
contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    // 让 IERC20 类型支持 safeTransfer / safeTransferFrom
    using SafeERC20 for IERC20;

    // ------------------------------
    // 角色定义
    // ------------------------------

    // 定义一个角色：价格预言机管理员
    // 拥有这个角色的人可以更新 priceFeed 地址
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");

    // ------------------------------
    // 状态变量
    // ------------------------------

    // 用户拿来抵押的 ERC20 代币，例如 WETH / USDC 等
    IERC20 public immutable collateralToken;

    // 抵押代币的小数位，例如 USDC 常见是 6，ETH 常见是 18
    uint8 public immutable collateralDecimals;

    // Chainlink 价格预言机合约
    // 用来获取“1 个抵押代币值多少 USD”
    AggregatorV3Interface public priceFeed;

    // 抵押率，150 表示 150%
    // 也就是想铸造 100 美元的 sUSD，需要至少 150 美元的抵押物
    uint256 public collateralizationRatio = 150;

    // ------------------------------
    // 事件定义
    // ------------------------------

    // 用户铸造 sUSD 时触发
    // user: 谁铸造
    // amount: 铸造了多少 sUSD
    // collateralDeposited: 存入了多少抵押物
    event Minted(address indexed user, uint256 amount, uint256 collateralDeposited);

    // 用户赎回 sUSD 时触发
    // user: 谁赎回
    // amount: 烧掉了多少 sUSD
    // collateralReturned: 返还了多少抵押物
    event Redeemed(address indexed user, uint256 amount, uint256 collateralReturned);

    // 更新价格预言机时触发
    event PriceFeedUpdated(address newPriceFeed);

    // 更新抵押率时触发
    event CollateralizationRatioUpdated(uint256 newRatio);

    // ------------------------------
    // 自定义错误
    // ------------------------------

    // 抵押代币地址无效
    error InvalidCollateralTokenAddress();

    // 价格预言机地址无效
    error InvalidPriceFeedAddress();

    // 铸造 / 赎回数量不能为 0
    error MintAmountIsZero();

    // 用户 sUSD 余额不足
    error InsufficientStablecoinBalance();

    // 抵押率不能低于 100%
    error CollateralizationRatioTooLow();

    // ------------------------------
    // 构造函数
    // ------------------------------

    // 部署时要传入：
    // _collateralToken: 抵押代币地址
    // _initialOwner: 初始 owner 地址
    // _priceFeed: Chainlink 价格预言机地址
    constructor(
        address _collateralToken,
        address _initialOwner,
        address _priceFeed
    )
        // 设置 ERC20 名字和 symbol
        ERC20("Simple USD Stablecoin", "sUSD")
        // 设置 owner
        Ownable(_initialOwner)
    {
        // 抵押代币地址不能是 0 地址
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();

        // 价格预言机地址不能是 0 地址
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();

        // 保存抵押代币地址
        collateralToken = IERC20(_collateralToken);

        // 读取抵押代币的小数位
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();

        // 保存价格预言机地址
        priceFeed = AggregatorV3Interface(_priceFeed);

        // 给初始 owner 默认管理员角色
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);

        // 给初始 owner 价格预言机管理角色
        _grantRole(PRICE_FEED_MANAGER_ROLE, _initialOwner);
    }

    // ------------------------------
    // 内部和外部方法
    // ------------------------------

    /// @notice 获取当前抵押品价格（USD计价）
    /// @return 当前价格，单位与预言机一致
    function getCurrentPrice() public view returns (uint256) {
        // latestRoundData() 会返回一组价格相关数据
        // 这里只关心第二个返回值 price
        (, int256 price, , , ) = priceFeed.latestRoundData();

        // 价格必须大于 0
        require(price > 0, "Invalid price feed response");

        // 转成 uint256 返回
        return uint256(price);
    }

    /// @notice 铸造稳定币
    /// @param amount 要铸造的 sUSD 数量（18位小数）
    function mint(uint256 amount) external nonReentrant {
        // 不能铸造 0
        if (amount == 0) revert MintAmountIsZero();

        // 1. 获取当前抵押物价格
        uint256 collateralPrice = getCurrentPrice();

        // 2. 计算这笔 sUSD 代表多少“美元价值”
        // 注意：这里又乘了一次 10**decimals()
        // 如果 amount 本身已经是 18 位精度，这里会把数放得更大
        // 这是这份代码当前的写法
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());

        // 3. 根据抵押率计算需要多少抵押物“价值”
        // 例如抵押率 150%，那就要多押 1.5 倍价值
        uint256 requiredCollateral =
            (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);

        // 4. 处理小数位差异
        // 抵押代币的小数位、价格预言机的小数位，可能和 sUSD 不一样
        // 所以这里要进行换算
        uint256 adjustedRequiredCollateral =
            (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        // 5. 把用户的抵押代币转进合约
        // 用户在调用前需要先 approve 给这个合约
        collateralToken.safeTransferFrom(msg.sender, address(this), adjustedRequiredCollateral);

        // 6. 给用户铸造对应数量的 sUSD
        _mint(msg.sender, amount);

        // 7. 记录事件
        emit Minted(msg.sender, amount, adjustedRequiredCollateral);
    }

    /// @notice 赎回稳定币并返还抵押品
    /// @param amount 要赎回的 sUSD 数量
    function redeem(uint256 amount) external nonReentrant {
        // 不能赎回 0
        if (amount == 0) revert MintAmountIsZero();

        // 用户必须至少有这么多 sUSD
        if (balanceOf(msg.sender) < amount) revert InsufficientStablecoinBalance();

        // 1. 获取当前抵押物价格
        uint256 collateralPrice = getCurrentPrice();

        // 2. 计算这些 sUSD 对应的美元价值
        // 同样，这里也做了 amount * 10**decimals() 的放大
        uint256 stablecoinValueUSD = amount * (10 ** decimals());

        // 3. 反向计算这笔 sUSD 可以换回多少抵押物
        // 因为系统是超额抵押的，所以赎回时只按对应比例返回
        uint256 collateralToReturn =
            (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);

        // 4. 处理小数位差异
        uint256 adjustedCollateralToReturn =
            (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        // 5. 先销毁用户手里的 sUSD
        _burn(msg.sender, amount);

        // 6. 再把抵押物转回给用户
        collateralToken.safeTransfer(msg.sender, adjustedCollateralToReturn);

        // 7. 记录事件
        emit Redeemed(msg.sender, amount, adjustedCollateralToReturn);
    }

    /// @notice 设置新的抵押率
    /// @param newRatio 新抵押率（百分比）
    function setCollateralizationRatio(uint256 newRatio) external onlyOwner {
        // 抵押率不能低于 100%
        // 否则就变成不足额抵押了
        if (newRatio < 100) revert CollateralizationRatioTooLow();

        // 更新抵押率
        collateralizationRatio = newRatio;

        // 记录事件
        emit CollateralizationRatioUpdated(newRatio);
    }

    /// @notice 更新价格预言机地址
    /// @param _newPriceFeed 新的 Chainlink 价格预言机
    function setPriceFeedContract(address _newPriceFeed) external onlyRole(PRICE_FEED_MANAGER_ROLE) {
        // 新地址不能是 0 地址
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();

        // 更新价格预言机
        priceFeed = AggregatorV3Interface(_newPriceFeed);

        // 记录事件
        emit PriceFeedUpdated(_newPriceFeed);

    }


    /// @notice 查看铸造指定数量稳定币所需抵押品
    /// @param amount sUSD 数量
    /// @return 所需抵押品数量
    function getRequiredCollateralForMint(uint256 amount) public view returns (uint256) {
        // 如果 amount 为 0，直接返回 0
        if (amount == 0) return 0;

        // 下面的计算逻辑和 mint 里一样
        uint256 collateralPrice = getCurrentPrice();
        uint256 requiredCollateralValueUSD = amount * (10 ** decimals());
        uint256 requiredCollateral =
            (requiredCollateralValueUSD * collateralizationRatio) / (100 * collateralPrice);
        uint256 adjustedRequiredCollateral =
            (requiredCollateral * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedRequiredCollateral;

    }

    /// @notice 查看赎回指定数量稳定币可获得的抵押品
    /// @param amount sUSD 数量
    /// @return 可获得抵押品数量
    function getCollateralForRedeem(uint256 amount) public view returns (uint256) {
        // 如果 amount 为 0，直接返回 0
        if (amount == 0) return 0;

        // 下面的计算逻辑和 redeem 里一样
        uint256 collateralPrice = getCurrentPrice();
        uint256 stablecoinValueUSD = amount * (10 ** decimals());
        uint256 collateralToReturn =
            (stablecoinValueUSD * 100) / (collateralizationRatio * collateralPrice);
        uint256 adjustedCollateralToReturn =
            (collateralToReturn * (10 ** collateralDecimals)) / (10 ** priceFeed.decimals());

        return adjustedCollateralToReturn;
    }

}