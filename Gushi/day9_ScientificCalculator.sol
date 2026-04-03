//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScientificCalculator{ //声明一个科学计算器的合约，以便母合约调用

    function power(uint256 base, uint256 exponent)public pure returns(uint256){ //view函数只读取不修改，pure函数更加严格，不读不改，只用传入的参数做计算，完全不碰其他数据
        if(exponent == 0)return 1; //if判断，任何数的0次方都等于1
        else return (base ** exponent); //否则计算底数的幂次方，** 代表幂次方的计算
    }
    
    //写函数之前要考虑到可能发生的情况，用require和if来分别探讨
    function squareRoot(int256 number)public pure returns(int256){ 
        require(number >= 0, "Cannot calculate square root of negative number"); //负数没有平方根，所以要判断一下
        if(number == 0)return 0; //if判断，0的平方根是0

        int256 result = number/2; //用的是牛顿法估算，二分法猜一个值，往下代入计算，10次以内就会算出比较精确的结果
        for(uint256 i = 0; i<10; i++){ //从i=0开始逐次运算10次
            result = (result + number / result)/2; // 牛顿法公式
        }

        return result;

    }
}
