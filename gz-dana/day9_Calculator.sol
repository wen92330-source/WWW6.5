// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Calculator {
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }
    
    function subtract(uint256 a, uint256 b) external pure returns (uint256) {
        require(a >= b, "negative result");
        return a - b;
    }
    
    function multiply(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b;
    }
    
    function divide(uint256 a, uint256 b) external pure returns (uint256) {
        require(b > 0, "division by zero");
        return a / b;
    }
}