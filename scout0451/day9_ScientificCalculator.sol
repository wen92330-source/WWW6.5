//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScientificCalculator{

    function power(uint256 base, uint256 exponent)public pure returns(uint256){  //pure纯函数，不触及区块链状态
        if(exponent == 0)return 1;
        else return (base ** exponent);  //底数按指数次幂运算
    }

    function squareRoot(int256 number)public pure returns(int256){
        require(number >= 0, "Cannot calculate square root of negative number");
        if(number == 0)return 0;

        // 迭代公式逼近平方根真实值
        int256 result = number/2;
        for(uint256 i = 0; i<10; i++){  //设置循环条件，从0开始小于10时，每次循环增加1
            result = (result + number / result)/2;
        }

        return result;

    }
}