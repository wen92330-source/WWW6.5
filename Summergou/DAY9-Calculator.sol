// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DAY9-ScientificCalculator.sol";

contract Calculator {
    address public owner;
    address public scientificCalculatorAddress;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can do it.");
        _;
    }

    function setScientificCalculator(address _address) public onlyOwner{
        scientificCalculatorAddress = _address;
    }

    function add(uint256 a, uint256 b) public pure returns (uint256){
        return a+b;
    }

    function substract(uint256 a, uint256 b) public pure returns (uint256){
        return a-b;
    }

    function multiple(uint256 a, uint256 b) public pure returns (uint256){
        return a*b;
    }

    function divide(uint256 a, uint256 b) public pure returns (uint256){
        require(b != 0, "Cannot divide by zero");
        return a / b;
    }

    // 高级调用
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256){
        // 强制地址转换
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        // 调用函数返回结果
        return scientificCalc.power(base, exponent);
    }

    // 低级调用
    function calculateSquareRoot(uint256 number) public returns (uint256) {
    require(number >= 0, "Cannot calculate square root of negative number");

    // 编码函数调用（构建 EVM 在调用特定函数时期望的确切二进制格式）
    bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
    
    // 进行低级调用
    (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
    
    // 检查调用是否成功
    require(success, "External call failed");

    // 解码响应
    uint256 result = abi.decode(returnData, (uint256));
    return result;
    }
}
    
