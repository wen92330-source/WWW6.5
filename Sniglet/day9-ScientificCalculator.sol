// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract scientificCalculator {
    function power (uint256 base,uint256 exponent) public pure returns (uint256){
        uint256 result =1;
        for (uint256 i=0 ;i < exponent; i ++) {
            result *=base;
        }
        return result;
    }

function squareRoot (uint256 number) public pure returns (uint256){
    if(number==0) return 0;

    uint256 z =(number + 1) /2;
    uint256 y =number;
    while (z < y) {
       y = z;
       z = (number / z + z) / 2;
        }
        return y;

}
}