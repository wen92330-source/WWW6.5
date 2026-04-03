// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScientificCalculator {

    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        if (exponent == 0) {
            return 1;
        }

        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }

        return result;
    }

    function squareRoot(uint256 number) public pure returns (uint256) {
        if (number == 0) {
            return 0;
        }

        if (number <= 3) {
            return 1;
        }

        uint256 x = number;
        uint256 y = (x + 1) / 2;

        while (y < x) {
            x = y;
            y = (x + number / x) / 2;
        }

        return x;
    }
}
