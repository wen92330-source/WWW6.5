// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ✅ 关键：导入第一个文件，路径必须完全匹配文件名（包括大小写和下划线）
import "./Day9_Calculator.sol";

/**
 * @title Day9_ScientificCalculator
 * @dev 科学计算器合约，继承自 Day9_Calculator
 *      功能：在基础四则运算上增加幂运算、平方根等功能
 */
contract Day9_ScientificCalculator is Day9_Calculator {

    /**
     * @dev 计算 a 的 b 次方 (a^b)
     */
    function power(uint256 a, uint256 b) public pure returns (uint256) {
        if (b == 0) return 1;
        uint256 result = 1;
        for (uint256 i = 0; i < b; i++) {
            result *= a;
        }
        return result;
    }

    /**
     * @dev 计算平方根的整数近似值 (使用牛顿迭代法)
     * @param n 待开方的数
     * @return sqrt n 的平方根整数部分
     */
    function squareRoot(uint256 n) public pure returns (uint256) {
        if (n == 0) return 0;
        uint256 x = n;
        uint256 y = (x + 1) / 2;
        while (y < x) {
            x = y;
            y = (x + n / x) / 2;
        }
        return x;
    }

    /**
     * @dev 取模运算 (a % b)
     * 虽然基础合约没写，但这里作为科学计算补充
     */
    function modulo(uint256 a, uint256 b) public pure returns (uint256) {
        require(b > 0, "Modulo by zero");
        return a % b;
    }

    /**
     * @dev 演示继承：调用父合约的 add 函数进行链式计算
     * 计算 (a + b) * c
     */
    function complexCalculation(uint256 a, uint256 b, uint256 c) public pure returns (uint256) {
        uint256 sum = super.add(a, b); // 显式调用父类函数
        return multiply(sum, c);       // 直接调用继承来的函数
    }
}