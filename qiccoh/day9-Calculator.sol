// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9-ScientificCalculator.sol";

contract Calculator {
    // basic math functions
address public owner;
address public scientificCalculatorAddress;
// 部署合约的地址被存储为 有者
constructor() {
    owner = msg.sender;
}
modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
}

function setScientificCalculator(address _address) public onlyOwner {
    scientificCalculatorAddress = _address;
}
//加减乘除
function add(uint256 a, uint256 b) public pure returns (uint256) {
    uint256 result = a + b;
    return result;
}
function subtract(uint256 a, uint256 b) public pure returns (uint256) {
    uint256 result = a - b;
    return result;
}
function multiply(uint256 a, uint256 b) public pure returns (uint256) {
    uint256 result = a * b;
    return result;
}
function divide(uint256 a, uint256 b) public pure returns (uint256) {
    require(b != 0, "Cannot divide by zero");
    uint256 result = a / b;
    return result;
}

//调用其他库的东西
function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
    //以太坊地址转化
    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
    uint256 result = scientificCalc.power(base, exponent);
    return result;
}
//不导入源代码，只调用函数地址和名称-低级调用
function calculateSquareRoot(uint256 number) public returns (uint256) {
    require(number >= 0, "Cannot calculate square root of negative number");
// ABI 代表应用程序二进制接口
// "squareRoot(int256)" 是完整的函数签名（名称+参数类型）
    bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
    // returnData（一个字节数组，包含函数返回的内容），.call(data)-将这些数据发送到存储在 scientificCalculatorAddress 中的地址
    (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
    require(success, "External call failed");

    uint256 result = abi.decode(returnData, (uint256));
    return result;
}
    }