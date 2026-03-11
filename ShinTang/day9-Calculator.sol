// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ScientificCalculator} from "./day9-ScientificCalculator.sol";
// 使用interface而不是import完整合约

contract Calculator {

    address public owner;
    address public scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        return a - b;
    }

    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        return a / b;
    }

    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        // external call
        return scientificCalc.power(base, exponent);
    }

    function calculateFactorial(uint256 n) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        // external call
        return scientificCalc.factorial(n);
    }

    // 低级调用
    function calculateSquareRoot(uint256 number) public returns (uint256) {
        require(number >= 0, "Cannot calculate square root of negative nmber");

        // 应用程序二进制接口 结果是字节数组
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");
        return abi.decode(returnData, (uint256));
    }

}
