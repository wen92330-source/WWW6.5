//整个系统流程：
//流动性提供者：
//存入TokenA + TokenB
//→ 获得LP Token（凭证）
//→ 赚取交易手续费 💰

//交易者：
//用TokenA换TokenB
//→ 支付0.3%手续费
//→ 价格由公式自动决定

//流动性提供者取回：
//归还LP Token
//→ 取回TokenA + TokenB + 手续费收益
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 自动做市商合约
// 继承ERC20 = 流动性代币（LP Token）
// 提供流动性的人会收到LP Token作为凭证
contract AutomatedMarketMaker is ERC20 {

    IERC20 public tokenA;  // 交易对的第一个代币
    IERC20 public tokenB;  // 交易对的第二个代币

    uint256 public reserveA;  // 池子里tokenA的数量
    uint256 public reserveB;  // 池子里tokenB的数量

    address public owner;

    // 事件记录
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);   // 添加流动性
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity); // 移除流动性
    event TokensSwapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut); // 交换代币

    // 部署时设置两个代币地址和LP Token名称
    constructor(address _tokenA, address _tokenB, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    // 添加流动性
    // 用户存入tokenA和tokenB，获得LP Token
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // 从用户账户转入代币
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 liquidity;
        if (totalSupply() == 0) {
            // 第一次添加流动性：LP Token = √(A*B)
            liquidity = sqrt(amountA * amountB);
        } else {
            // 之后添加：按比例计算LP Token
            // 取两个比例中较小的，防止不等比添加
            liquidity = min(
                amountA * totalSupply() / reserveA,
                amountB * totalSupply() / reserveB
            );
        }

        _mint(msg.sender, liquidity);  // 铸造LP Token给用户

        // 更新储备量
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB, liquidity);
    }

    // 移除流动性
    // 用户归还LP Token，取回tokenA和tokenB
    function removeLiquidity(uint256 liquidityToRemove) external returns (uint256 amountAOut, uint256 amountBOut) {
        require(liquidityToRemove > 0, "Liquidity to remove must be > 0");
        require(balanceOf(msg.sender) >= liquidityToRemove, "Insufficient liquidity tokens");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "No liquidity in the pool");

        // 按比例计算能取回多少代币
        // 比如：你占总LP的10% → 取回10%的tokenA和tokenB
        amountAOut = liquidityToRemove * reserveA / totalLiquidity;
        amountBOut = liquidityToRemove * reserveB / totalLiquidity;

        require(amountAOut > 0 && amountBOut > 0, "Insufficient reserves for requested liquidity");

        // 更新储备量
        reserveA -= amountAOut;
        reserveB -= amountBOut;

        _burn(msg.sender, liquidityToRemove);  // 销毁LP Token

        // 把代币还给用户
        tokenA.transfer(msg.sender, amountAOut);
        tokenB.transfer(msg.sender, amountBOut);

        emit LiquidityRemoved(msg.sender, amountAOut, amountBOut, liquidityToRemove);
        return (amountAOut, amountBOut);
    }

    // 用tokenA换tokenB
    function swapAforB(uint256 amountAIn, uint256 minBOut) external {
        require(amountAIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 收取0.3%手续费
        // 997/1000 = 99.7% → 0.3%给流动性提供者
        uint256 amountAInWithFee = amountAIn * 997 / 1000;

        // 用公式计算能换多少tokenB
        // x * y = k 公式推导出来的
        uint256 amountBOut = reserveB * amountAInWithFee / (reserveA + amountAInWithFee);

        require(amountBOut >= minBOut, "Slippage too high");
        // minBOut = 最少能接受多少tokenB
        // 防止滑点太大！

        tokenA.transferFrom(msg.sender, address(this), amountAIn);  // 收取tokenA
        tokenB.transfer(msg.sender, amountBOut);                     // 发出tokenB

        // 更新储备量
        reserveA += amountAInWithFee;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    // 用tokenB换tokenA（跟上面相反）
    function swapBforA(uint256 amountBIn, uint256 minAOut) external {
        require(amountBIn > 0, "Amount must be > 0");
        require(reserveA > 0 && reserveB > 0, "Insufficient reserves");

        // 同样收取0.3%手续费
        uint256 amountBInWithFee = amountBIn * 997 / 1000;

        // 计算能换多少tokenA
        uint256 amountAOut = reserveA * amountBInWithFee / (reserveB + amountBInWithFee);

        require(amountAOut >= minAOut, "Slippage too high");

        tokenB.transferFrom(msg.sender, address(this), amountBIn);  // 收取tokenB
        tokenA.transfer(msg.sender, amountAOut);                     // 发出tokenA

        // 更新储备量
        reserveB += amountBInWithFee;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    // 查询池子储备量
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    // 工具函数：返回两个数中较小的
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // 工具函数：巴比伦法开平方根
    // 用于计算第一次添加流动性时的LP Token数量
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;  // 不断逼近平方根
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
