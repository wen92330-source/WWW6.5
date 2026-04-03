// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {
    // advanced functions will go here
    // 幂运算: base^exponent；pure表明本地简单输出纯逻辑计算
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        if (exponent == 0) return 1;
        else return (base ** exponent);
    }

    //平方根
    function squareRoot(int256 number) public pure returns (int256) {

        require(number >= 0, "Cannot calculate square root of negative number"); //不为负

        int256 result = number/2; 
        for(uint256 i = 0; i<10; i++){
            result = (result + number / result)/2; // 牛顿迭代法的基础公约公式
        }

        return result;
    }
}
