// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day9_ScientificCalculator.sol";

contract Calculator {

    address public owner;
    address public Day9_ScientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    } 

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;

    }

    function setDay9_ScientificCalculator(address newaddress)public onlyOwner {
        Day9_ScientificCalculatorAddress = newaddress;
    }

    function add(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    function subtract(uint256 a, uint256 b) public pure returns(uint256) {
        uint256 result = a - b;
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

    function calculateSqureRoot(uint256 number) public returns(uint256){
        require(number >=0, "Number must be non-negative");

        bytes memory data = abi.encodeWithSignature("squareRoot(int256)",number);
        (bool success, bytes memory returnData) = Day9_ScientificCalculatorAddress.call(data);
        require(success, "External call failed");
        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }

}