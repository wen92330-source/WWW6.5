// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9-ScientificCalculator.sol";
contract Calculator{
    address public  owner;
    address public  scientificCalculatorAddress;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    // 允许合约 owner 设置 、 更新 scientificCalculator 合约地址
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }
    // 加法
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a + b;
        return result;
    }
    // 减法
    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a - b;
        return result;
    }
    // 乘法
    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;
    }
    // 除法，被除数不能为0
    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }
    // 调用外部合约
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }

    function calculateSquareRoot(uint256 number) public returns (uint256) {
        require(number >= 0, "Cannot calculate square root of negative number");

        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");

        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }
    
}