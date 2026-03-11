// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day9_ScientificCalculator.sol";

contract Calculator {
    address public owner;
    address public scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;
    }

    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;
    }

    function divide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!= 0, "Cannot divide by zero");
        uint256 result = a/b;
        return result;
    }

    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    } 

    function calculatePower(uint base, uint exponent) public view returns(uint) {
        ScientificCalculator scientificCal = ScientificCalculator(scientificCalculatorAddress);
        uint result = scientificCal.power(base, exponent);
        return result;
    }

    function calculateSquareRoot(uint number) public returns(uint) {
        require(number >= 0, "Cannot calculate square root of negative number");

        //Encoding-Calling-Decoding
        bytes memory data = abi.encodeWithSignature("squareRoot(uint)", number);
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");
        uint result = abi.decode(returnData, (uint));

        return result;
    }
}