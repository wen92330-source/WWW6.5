//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol"; //文件名要完整

contract Calculator {

    address public owner; // 管理员地址
    address public scientificCalculatorAddress; // 外部合约地址

    // 初始化合约部署者 
    constructor() {
        owner = msg.sender;
    }

    // 管理员权限 
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 设置科学计算器地址 
    function setScientificCalculator(address _address) public onlyOwner {
        require(_address != address(0), "Invalid address");
        scientificCalculatorAddress = _address;
    }

    // 加法运算, 使用pure代表不读取也不修改区块链上任何内容
    function add(uint256 a, uint256 b) public pure returns(uint256) {
        return a+b;
    }

    // 减法运算 
    function subtract(uint256 a, uint256 b) public pure returns(uint256) {
        return a-b;
    }

    // 乘法运算 
    function multiply(uint256 a, uint256 b) public pure returns(uint256) {
        return a*b;
    }

    // 除法运算 
    function divide(uint256 a, uint256 b) public pure returns(uint256) {
        require(b != 0, "Cannot divide by zero");
        return a/b;
    }

    // 幂运算（接口调用方式） 
    function calculatePower(uint256 base, uint256 exponent) public view returns(uint256) {
        ScientificCalculator scientificCalculator = ScientificCalculator(scientificCalculatorAddress);
        return scientificCalculator.power(base, exponent);
    }

    // 开方运算（底层编码调用方式） 
    function calculateSquareRoot(uint256 number) public returns(int256) {
        require(number >= 0 , "Cannot calculate square root of negative number");
        
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number); // 编码函数签名与参数
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data); // 发起底层调用并获取状态与原始数据
        require(success, "External call failed"); // 验证外部调用是否执行成功
        
        int256 result = abi.decode(returnData, (int256));
        return result; // 将返回的二进制数据解码为指定类型
    }

} 