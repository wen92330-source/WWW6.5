// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 接口一般定义在单独的文件里

// 为ScientificCalculator定义接口
interface IScientificCalculator {
    function power(uint256 base, uint256 exponent) external view returns (uint256);
    function squareRoot(uint256 number) external view returns (uint256);
    function factorial(uint256 n) external view returns (uint256);
    function divide(uint256 dividend, uint256 divisor) external view returns (uint256 quotient, uint256 remainder);
}