// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Day9_Calculator
 * @dev 基础计算器合约，支持加减乘除
 */
contract Day9_Calculator {
    
    // ✅ 标记为 virtual，允许子类重写（虽然四则运算通常不需要重写，但为了架构扩展性）
    function add(uint256 a, uint256 b) public pure virtual returns (uint256) {
        return a + b;
    }

    function subtract(uint256 a, uint256 b) public pure virtual returns (uint256) {
        require(a >= b, "Subtraction result cannot be negative");
        return a - b;
    }

    function multiply(uint256 a, uint256 b) public pure virtual returns (uint256) {
        return a * b;
    }

    function divide(uint256 a, uint256 b) public pure virtual returns (uint256) {
        require(b > 0, "Division by zero");
        return a / b;
    }
}