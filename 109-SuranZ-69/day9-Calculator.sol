// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9-ScientificCalculator.sol"; //当需要使用高级运算时，将会使用科学计算器合约
//import的“./XXX.sol”部分告诉solidity，查看当前文件在的相同目录，找到其中的XXX.sol文件——因此两个sol文件必须在同一文件夹

contract Calculator { //此合约用于处理加减乘除等基础运算
    //定义状态变量
    address public owner;
    address public scientificCalculatorAddress; //存放已部署的ScientificCalculator合约的地址

    //构造函数
    constructor () {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require (msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    //允许owner链接到ScientificCalculator合约的地址
    function setScientificCalculator (address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    //基础数学运算函数
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
        uint256 result = a / b;
        return result;
    }

    //使用科学计算器合约计算幂函数（与另一个智能合约进行通信）
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator (scientificCalculatorAddress); //地址强制类型转换，将一个地址转换为一个合约引用（前提是必须在前面导入了含有此合约的对应的sol文件）
        uint256 result = scientificCalc.power(base, exponent); //调用对应合约中的对应函数power
        return result;
    }

    //使用低级调用——不导入源代码也可以进行交互（当只知道想要调用的函数的地址和名称的时候）
    function calculateSquareRoot (uint256 number) public returns (uint256) { //Question：这里没有限制view是为什么？
        require (number >= 0, "Cannot calculate square root of negative number.");

        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number); //abi代表应用程序二进制接口，是一方合约调用另一方时数据必须如何结构化的“通信协议”。当使用如上的“otherContract.someFunction()”的高级函数调用时，solidity会为你处理abi编码；当低级调用时则需要自己手动处理
        //在“abi.encodeWithSignature("squareRoot(uint256)", number)”中，“squareRoot(uint256)”是完整的函数签名（名称+参数类型）；number作为参数传递的值；bytes memory代表结果是字节数组
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data); //将数据发送到存储在scientificCalculatorAddress中的地址
        require (success, "External call failed."); //检查调用是否成功

        uint256 result = abi.decode(returnData, (uint256)); //将原始返回数据进行解码
        return result;
    }
}