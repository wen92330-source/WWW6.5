// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract scientificcalculator {
    //scientific functions
    function power(uint256 base, uint256 expoenet) public pure returns(uint256){
        if (expoenet ==0) return 1;
        else return (base ** expoenet);

    }
    function squareRoot (uint256 number)public pure returns(uint256){
        require (number>=0, "cannot calculate nagetive number");
        if (number ==0) return 0;
        uint256 result = number / 2;
        for (uint256 i=0; i<10;i++){
            result = (result +number/result)/2;//Xn+1=Xn-F(x)/F'(X), Xn+1=Xn-
        } 
        return result;
    }
}