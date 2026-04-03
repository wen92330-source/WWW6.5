// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MiniDexPair
 * @dev 这是一个简化版的去中心化交易所 (DEX) 交易对合约。
 * 实现了基于恒定乘积公式 (x * y = k) 的自动做市商 (AMM) 逻辑。
 * 支持添加流动性、移除流动性以及代币兑换（Swap）。
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MiniDexPair is ReentrancyGuard {
    // --- 状态变量 ---
    
    address public immutable tokenA;
    address public immutable tokenB;

    /// @notice 交易对中 Token A 的储备量
    uint256 public reserveA;
    /// @notice 交易对中 Token B 的储备量
    uint256 public reserveB;
    /// @notice 流动性凭证 (LP) 的总供应量
    uint256 public totalLPSupply;

    /// @notice 用户持有的 LP 余额映射
    mapping(address => uint256) public lpBalances;

    // --- 事件 ---
    
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);
    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);

    /**
     * @dev 初始化交易对，设定两种互换代币的地址
     */
    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != _tokenB, "Identical tokens");
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address");

        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // --- 内部数学工具 ---

    /// @dev 计算平方根，用于初始化流动性时计算 LP 数量
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /// @dev 返回两个数中的最小值
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev 同步当前合约持有的代币余额到储备量变量
     */
    function _updateReserves() private {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveB = IERC20(tokenB).balanceOf(address(this));
    }

    /**
     * @notice 添加流动性
     * @param amountA 存入 Token A 的数量
     * @param amountB 存入 Token B 的数量
     * @dev 逻辑：
     * 1. 如果是首次添加，LP = sqrt(a * b)
     * 2. 如果非首次，按存入资产占当前总储备的最小比例铸造 LP
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
        require(amountA > 0 && amountB > 0, "Invalid amounts");

        // 将用户的代币转入合约
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        uint256 lpToMint;
        if (totalLPSupply == 0) {
            // 初始流动性计算
            lpToMint = sqrt(amountA * amountB);
        } else {
            // 之后添加流动性需按现有比例，取两个代币注入比例的最小值，防止套利
            lpToMint = min(
                (amountA * totalLPSupply) / reserveA,
                (amountB * totalLPSupply) / reserveB
            );
        }

        require(lpToMint > 0, "Zero LP minted");

        lpBalances[msg.sender] += lpToMint;
        totalLPSupply += lpToMint;

        _updateReserves();

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
    }

    /**
     * @notice 移除流动性
     * @param lpAmount 想要销毁的 LP 凭证数量
     * @dev 逻辑：根据 LP 占比，等比例退回两种代币
     */
    function removeLiquidity(uint256 lpAmount) external nonReentrant {
        require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount");

        // 按 LP 比例计算应退回的代币数量
        uint256 amountA = (lpAmount * reserveA) / totalLPSupply;
        uint256 amountB = (lpAmount * reserveB) / totalLPSupply;

        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;

        // 将代币退还给用户
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        _updateReserves();

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
    }

    /**
     * @notice 计算兑换输出金额（基于 x * y = k 算法）
     * @param inputAmount 输入代币数量
     * @param inputToken 输入代币地址
     * @return outputAmount 扣除 0.3% 手续费后的输出代币数量
     * @dev 计算公式：dy = (y * 0.997 * dx) / (x + 0.997 * dx)
     */
    function getAmountOut(uint256 inputAmount, address inputToken) public view returns (uint256 outputAmount) {
        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");

        bool isTokenA = inputToken == tokenA;
        (uint256 inputReserve, uint256 outputReserve) = isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

        // 包含 0.3% 的手续费 (inputAmount * 997 / 1000)
        uint256 inputWithFee = inputAmount * 997;
        uint256 numerator = inputWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputWithFee;

        outputAmount = numerator / denominator;
    }

    /**
     * @notice 兑换代币 (Swap)
     * @param inputAmount 输入代币的数量
     * @param inputToken 输入代币的地址
     */
    function swap(uint256 inputAmount, address inputToken) external nonReentrant {
        require(inputAmount > 0, "Zero input");
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");

        address outputToken = inputToken == tokenA ? tokenB : tokenA;
        uint256 outputAmount = getAmountOut(inputAmount, inputToken);

        require(outputAmount > 0, "Insufficient output");

        // 执行兑换逻辑
        IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);
        IERC20(outputToken).transfer(msg.sender, outputAmount);

        _updateReserves();

        emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);
    }

    // --- 只读函数 ---

    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    function getLPBalance(address user) external view returns (uint256) {
        return lpBalances[user];
    }

    function getTotalLPSupply() external view returns (uint256) {
        return totalLPSupply;
    }
}