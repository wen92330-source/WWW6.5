 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ScientificCalculator {
    //幂运算：base^exponent
    //定义了一个名为 power 的函数，有两个 uint256 类型参数 base 和 exponent，函数是公开的纯函数，返回值类型为 uint256
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        uint256 result = 1;
        //声明一个 uint256 类型的变量 result 并初始化为 1
        //初始化一个 uint256 类型变量 i 为 0，循环条件是 i 小于 exponent，每次循环后 i 自增 1
        for (uint256 i = 0; i < exponent ; i++) {
            //将变量 result 乘以 base，即累乘计算，更新 result 的值
            result *= base;
        }
        return result;
    }
    //平方根（整数）
    //声明一个 uint256 类型的变量 z，其初始值为 (number + 1) / 2 
    function squareRoot(uint256 number) public pure returns (uint256) {
        //这行代码表示如果 number 的值等于 0，就返回 0 
        if (number == 0) return 0;
    //声明一个 uint256 类型的变量 y，并将 number 的值赋给它。
        uint256 z = (number +1 ) / 2;
        //声明了一个 uint256 类型的变量 y，并将变量 number 的值赋给 
        uint256 y = number;
        //23 行是计算并赋值，z 的值为 (number + 1) / 24 行是直接赋值，将 number 的值赋给 y 

        //28 行是将 z 的值赋给 y
        while (z < y) {
            //通过计算 (number /z+z) / 2 更新 z 的值，用于逐步逼近平方根
            y = z;
            z = (number / z+z) / 2;
        }
        return y;
    }
}