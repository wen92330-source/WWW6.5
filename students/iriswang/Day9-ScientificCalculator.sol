// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {
    // 整数平方根（巴比伦算法）
    function squareRoot(uint256 number) public pure returns (uint256) {
        if (number == 0) return 0;
        uint256 z = (number + 1) / 2;
        uint256 y = number;
        while (z < y) {
            y = z;
            z = (number / z + z) / 2;
        }
        return y;
    }

    // 幂运算（整数指数）
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        if (exponent == 0) return 1;
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }

    // 阶乘
    function factorial(uint256 n) public pure returns (uint256) {
        if (n == 0) return 1;
        uint256 result = 1;
        for (uint256 i = 1; i <= n; i++) {
            result *= i;
        }
        return result;
    }

    // 绝对值
    function absolute(int256 x) public pure returns (uint256) {
        return x >= 0 ? uint256(x) : uint256(-x);
    }

    // 最大公约数（欧几里得算法）
    function gcd(uint256 a, uint256 b) public pure returns (uint256) {
        while (b != 0) {
            uint256 temp = b;
            b = a % b;
            a = temp;
        }
        return a;
    }
}
