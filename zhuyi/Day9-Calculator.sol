// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Day9-ScientificCalculator.sol";

contract Calculator {

    address public owner; // 存储部署此合约的地址
    address public scientificCalculatorAddress; //部署的 ScientificCalculator 地址的地方

    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 设置科学计算器地址
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    //加法
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a + b;
        return result;
    }

    //减法
    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a - b;
        return result;
    }

    //乘法
    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;
    }

    //除法：b 不为0
    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }

    //调用合约：一个普通的以太坊地址转换成一个可用的合约对象
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }

    //低级调用：只知道想调用的函数的地址和名称；不导入源代码
    function calculateSquareRoot(uint256 number) public returns (uint256) {
        require(number >= 0, "Cannot calculate square root of negative number");
        //底层调用的核心， ABI函数调用
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);

        //> “将我们刚刚创建的编码数据通过这个地址发送一个原始调用。”
        //`.call(data)` 将这些数据发送到存储在 `scientificCalculatorAddress` 中的地址。
        //返回两件事：
        //        - `success`（一个布尔值，告诉我们调用是否成功）
        //        - `returnData`（一个字节数组，包含函数返回的内容）
        //这就像通过后门手动调用函数一样——你需要确保一切完全正确。
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");

        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }


}
