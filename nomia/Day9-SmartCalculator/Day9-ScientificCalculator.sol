// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract ScientificCalculator{
    //pure 不改变blockchain上的任何
    function power(uint256 base, uint256 exponent) public pure returns(uint256){
        if(exponent == 0) return 1; //0次方是1
        else return(base**exponent);
 
    }


    function squareRoot(int256 number) public pure returns(int256){ //int256 negative + positive number
        require(number >= 0, "cannot calculate negative number");
        if (number == 0) return 0;
        if (number == 1) return 1;

        int256 result = number/2; // 初始猜测
        for(int256 i = 0; i < 10; i++){
            result = (result + number / result)/2;
        }

        return result;

        




    }













}