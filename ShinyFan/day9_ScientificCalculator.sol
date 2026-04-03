//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator{

    function power(uint256 base, uint256 exponent)public pure returns(uint256){//base是底数，exponent是指数
        if(exponent == 0)return 1;//return是一个指令，不是变量，所以return 1就是直接返回1
        else return (base ** exponent);
    }

    function squareRoot(int256 number)public pure returns(int256){//pure是指只进行数学运算，不在区块链上进行读取，写入
        require(number >= 0, "Cannot calculate square root of negative number");
        if(number == 0)return 0;

        //运用牛顿法估算一个数的平方根
        int256 result = number/2;
        for(uint256 i = 0; i<10; i++){
            result = (result + number / result)/2;
        }

        return result;

    }
}