// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//所有超出基础范围的所有数学运算
contract ScientificCalculator {
    //次幂运算，pure，因为它不读取或更改区块链上的任何内容。它只是进行数学运算。
    function power(uint256 base,uint256 exponent) public  pure returns (uint256){
    if(exponent==0)return 1;
    else return (base**exponent);
    }
//平方运算
    function squareRoot(uint256 number) public pure returns (uint256){
        require (number>=0,"Cannot calculate square root of negative number");
        if (number==0) return 0;
        uint256 result = number/2;//result是变量的名字
        for (uint256 i=0;i<10;i++){
            result = (result + number / result)/ 2;
        }
        return result;
    }
    
}
