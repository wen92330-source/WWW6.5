// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ScientificCalculator {
    // 幂运算: base^exponent
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }
    
    // 平方根(整数)
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

    // 拓展功能
    // 阶乘函数
    function factorial(uint256 n) public pure returns (uint256) {
        if (n == 0) return 1; 
        uint256 result = 1;
        for (uint256 i = 1; i <= n; i++) {
            result *= i;
        }
        return result;
    }

    // divide 函数，除法运算，返回商和余数
    function divide(uint256 dividend, uint256 divisor) public pure returns (uint256 quotient, uint256 remainder) {
        require(divisor != 0, "Divisor cannot be zero");
        quotient = dividend / divisor;
        remainder = dividend % divisor;
        
        return (quotient, remainder);
    }

    // 获取调用方地址
    function getCaller() public view returns (address) {
        return msg.sender;
    }
}

/**
知识点：
5. 使用接口比import更加轻量
    // IScientificCalculator.sol
    interface IScientificCalculator {
        function power(uint256 base, uint256 exponent) external pure returns (uint256);
        function squareRoot(uint256 number) external pure returns (uint256);
    }

    // 在Calculator中使用
    IScientificCalculator calc = IScientificCalculator(calculatorAddress);
    calc.power(2, 10);
 */