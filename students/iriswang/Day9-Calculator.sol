// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day9-ScientificCalculator.sol";

contract Calculator {
    ScientificCalculator public sciCalc;

    constructor(address _scientificCalculator) {
        sciCalc = ScientificCalculator(_scientificCalculator);
    }

    function sqrt(uint256 x) public view returns (uint256) {
        return sciCalc.squareRoot(x);
    }

    function pow(uint256 base, uint256 exponent) public view returns (uint256) {
        return sciCalc.power(base, exponent);
    }

    function fact(uint256 n) public view returns (uint256) {
        return sciCalc.factorial(n);
    }

    function abs(int256 x) public view returns (uint256) {
        return sciCalc.absolute(x);
    }

    function greatestCommonDivisor(uint256 a, uint256 b) public view returns (uint256) {
        return sciCalc.gcd(a, b);
    }
}
