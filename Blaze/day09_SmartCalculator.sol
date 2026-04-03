// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day09_ScientificCalculator.sol";
contract SmartCalculator {
    address public owner;
    address public scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    //设置复杂运算合约地址地址
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    //基础加法运算
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a + b;
        return result;
    }

    //减法
    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a - b;
        return result;
    }

    //两数相乘
    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;
    }

    //两数相除
    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }

    //调用另外一个合约通信  将一个普通的以太坊地址（scientificCalculatorAddress）转换成一个可用的合约对象
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }

    //使用低级调用
    function calculateSquareRoot(uint256 number) public returns (uint256) {
        require(number >= 0, "Cannot calculate square root of negative number");
        
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);
        //.call(data) 将这些数据发送到存储在 scientificCalculatorAddress 中的地址
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");

        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }


}