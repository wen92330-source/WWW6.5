// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator{ //此科学计算器合约用于存放高级计算功能（比如指数运算和平方根计算）
    //用于计算幂的函数——返回“base的exponent次幂”的结果
    function power(uint256 base, uint256 exponent) public pure returns (uint256) { //pure，不读取或更改区块链上的任何内容，只进行数学运算
        if (exponent == 0) return 1; //如果指数为0，则返回1
        else return (base ** exponent);
    }
    
    //用于估算平方根的函数——牛顿法，通过重复逼近来找到平方根
    function squareRoot(uint256 number) public pure returns (uint256) {
        require (number >= 0, "Cannot calculate square root of negative number.");
        if (number == 0) return 0;

        uint256 result = number / 2; //将数字除以2，粗略估计实际近似值
        for (uint256 i = 0; i < 10; i ++) {
            result = (result + number / result) / 2;
        } //对估计的近似值进行十次精炼
        return result;
    }
}