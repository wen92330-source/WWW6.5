// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ERC20接口（用来转账 token）
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 防重入攻击（防黑客反复调用）
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// 一个最小版 AMM（类似 Uniswap V2）
contract MiniDexPair is ReentrancyGuard {

    // 两个交易对 token（比如 ETH / USDC）
    address public immutable tokenA;
    address public immutable tokenB;

    // 当前池子里的储备量
    uint256 public reserveA;
    uint256 public reserveB;

    // LP 总量（流动性代币）
    uint256 public totalLPSupply;

    // 每个人持有多少 LP
    mapping(address => uint256) public lpBalances;

    // ===== 事件 =====
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpMinted);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 lpBurned);
    event Swapped(address indexed user, address inputToken, uint256 inputAmount, address outputToken, uint256 outputAmount);

    // ===== 构造函数 =====
    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != _tokenB, "Identical tokens"); // 不能是同一个token
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address");

        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // ===== 开平方（用于初始 LP 计算）=====
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

    // ===== 取最小值 =====
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // ===== 更新储备（根据真实余额）=====
    function _updateReserves() private {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveB = IERC20(tokenB).balanceOf(address(this));
    }

    // ===== 添加流动性 =====
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
        require(amountA > 0 && amountB > 0, "Invalid amounts");

        // 用户把 token 转进池子
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        uint256 lpToMint;

        if (totalLPSupply == 0) {
            // 第一次提供流动性
            lpToMint = sqrt(amountA * amountB);
        } else {
            // 后续按比例 mint LP
            lpToMint = min(
                (amountA * totalLPSupply) / reserveA,
                (amountB * totalLPSupply) / reserveB
            );
        }

        require(lpToMint > 0, "Zero LP minted");

        // 记录 LP
        lpBalances[msg.sender] += lpToMint;
        totalLPSupply += lpToMint;

        _updateReserves();

        emit LiquidityAdded(msg.sender, amountA, amountB, lpToMint);
    }

    // ===== 移除流动性 =====
    function removeLiquidity(uint256 lpAmount) external nonReentrant {
        require(lpAmount > 0 && lpAmount <= lpBalances[msg.sender], "Invalid LP amount");

        // 按比例取回 token
        uint256 amountA = (lpAmount * reserveA) / totalLPSupply;
        uint256 amountB = (lpAmount * reserveB) / totalLPSupply;

        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;

        // 转回用户
        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        _updateReserves();

        emit LiquidityRemoved(msg.sender, amountA, amountB, lpAmount);
    }

    // ===== 计算 swap 输出（含手续费 0.3%）=====
    function getAmountOut(uint256 inputAmount, address inputToken)
        public
        view
        returns (uint256 outputAmount)
    {
        require(inputToken == tokenA || inputToken == tokenB, "Invalid input token");

        bool isTokenA = inputToken == tokenA;

        // x*y = k
        (uint256 inputReserve, uint256 outputReserve) =
            isTokenA ? (reserveA, reserveB) : (reserveB, reserveA);

        // 收 0.3% fee
        uint256 inputWithFee = inputAmount * 997;

        uint256 numerator = inputWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputWithFee;

        outputAmount = numerator / denominator;
    }

    // ===== 交换 token =====
    function swap(uint256 inputAmount, address inputToken) external nonReentrant {
        require(inputAmount > 0, "Zero input");
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");

        address outputToken = inputToken == tokenA ? tokenB : tokenA;

        uint256 outputAmount = getAmountOut(inputAmount, inputToken);
        require(outputAmount > 0, "Insufficient output");

        // 用户给 input
        IERC20(inputToken).transferFrom(msg.sender, address(this), inputAmount);

        // 合约给 output
        IERC20(outputToken).transfer(msg.sender, outputAmount);

        _updateReserves();

        emit Swapped(msg.sender, inputToken, inputAmount, outputToken, outputAmount);
    }

    // ===== 查询 =====
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