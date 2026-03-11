// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {
    function power(uint base, uint exponent) public pure returns (uint) {
        if (exponent == 0) return 1;
        else return (base ** exponent);
    }

    function squareRoot(uint number) public pure returns (uint) {
        require(number >= 0, "Can't calculatesquare root of negative number");
        if (number == 0) return 0;

        uint result = number/2;
        for(uint i =0; i < 10; i++){
            result = (result + number/result)/2;
        }

        return result;
    }
}