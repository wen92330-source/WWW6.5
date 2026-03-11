// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9-ScientificCalculator.sol"; // 导入ScientificCalculator合约文件
import "./day9-CalculatorInterface.sol"; // 导入接口文件

/**
 * @title Calculator
 * @author mumu
 * @notice 智能计算器
 * @dev Calculator合约将复杂的数学运算委托给ScientificCalculator合约。这展示了合约的模块化设计,每个合约专注于特定功能。
*/

contract Calculator {
    address public calculatorAddress; // 记录calculator合约地址
    address public owner;
    
    // 构造函数，初始化ScientificCalculator合约地址
    // 决定了部署顺序：先部署ScientificCalculator，获取地址后再部署Calculator
    constructor(address _calculatorAddress) {
        owner = msg.sender;

        // 记录calculator合约地址
        calculatorAddress = _calculatorAddress;
    }

    // 调用ScientificCalculator的power函数
    function calculatePower(uint256 _base, uint256 _exponent) public view returns (uint256) {
        require(calculatorAddress != address(0), "Invalid calculator address");

        ScientificCalculator scientificCalc = ScientificCalculator(calculatorAddress);
        uint256 result = scientificCalc.power(_base, _exponent);
        return result;
    }

    // 调用ScientificCalculator的squareRoot函数
    function calculateSquareRoot(uint256 number) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(calculatorAddress);
        uint256 result = scientificCalc.squareRoot(number);
        return result;
    }

    // 拓展功能：调用ScientificCalculator的factorial函数
    function calculateFactorial(uint256 n) public view returns (uint256) {
        ScientificCalculator scientificCalc = ScientificCalculator(calculatorAddress);
        uint256 result = scientificCalc.factorial(n);
        return result;
    }

    // 实现批量计算功能（一次调用多个计算）
    function batchCalculate(uint256[] memory bases, uint256[] memory exponents) public view returns (uint256[] memory) {
        ScientificCalculator scientificCalc = ScientificCalculator(calculatorAddress);
        require(bases.length == exponents.length, "Input arrays must have the same length");
        uint256[] memory results = new uint256[](bases.length);
        // 如何确定调用哪个函数？
        for (uint256 i = 0; i < bases.length; i++) {
            results[i] = scientificCalc.power(bases[i], exponents[i]);
        }
        return results;
    }

    // 批量计算功能(可能调用不同函数)
    function batchCalculateMixed(uint256[] memory numbers) public view returns (uint256[] memory) {
        ScientificCalculator scientificCalc = ScientificCalculator(calculatorAddress);
        uint256[] memory results = new uint256[](numbers.length);
        for (uint256 i = 0; i < numbers.length; i++) {
            if (i % 3 == 0) {
                results[i] = scientificCalc.power(numbers[i], 2); // 平方
            } else if (i % 3 == 1) {
                results[i] = scientificCalc.squareRoot(numbers[i]); // 平方根
            } else {
                results[i] = scientificCalc.factorial(numbers[i]); // 阶乘
            }
        }
        return results;
    }

    // 使用interface而不是import完整的合约, 1以power函数为例
    function calculatePowerWithInterface(uint256 _base, uint256 _exponent) public view returns (uint256) {
        IScientificCalculator calc = IScientificCalculator(calculatorAddress);
        uint256 result = calc.power(_base, _exponent);
        return result;
    }

    // divide
    function calculateDivide(uint256 dividend, uint256 divisor) public view returns (uint256 quotient, uint256 remainder) {
        IScientificCalculator calculatorInterface = IScientificCalculator(calculatorAddress);
        (quotient, remainder) = calculatorInterface.divide(dividend, divisor);
        return (quotient, remainder);
    }
    
    // 增加低级调用示例
    function calculatePowerLowLevel(uint256 _base, uint256 _exponent) public view returns (uint256) {
        require(calculatorAddress != address(0), "Invalid calculator address");
        (bool success, bytes memory data) = calculatorAddress.staticcall(
            abi.encodeWithSignature("power(uint256,uint256)", _base, _exponent)
        );
        require(success, "Low-level call failed");
        uint256 result = abi.decode(data, (uint256));
        return result;  
    }
}

/**
知识点：
1. 掌握合约通信的两种方式
    // 方式1: 高级调用 (类型安全,推荐)
    ScientificCalculator calc = ScientificCalculator(calculatorAddress);
    uint256 result = calc.power(2, 10);
    // 创建合约实例，并通过实例调用函数，编译器会检查函数签名和参数类型，确保调用的正确性。

    // 方式2: 低级调用 (灵活,但需要手动编码)
    (bool success, bytes memory data) = calculatorAddress.call(
        abi.encodeWithSignature("power(uint256,uint256)", 2, 10)
    );
    uint256 result = abi.decode(data, (uint256));
    // 直接使用call函数进行调用，需要手动编码函数签名和参数，并且需要手动解码返回值，容易出错。

2. 导入其他合约
    相对路径:./File.sol
    绝对路径:@openzeppelin/...
    导入后可以使用文件中的合约

3. pure、view、normal
    pure: 不读取也不修改状态变量，不能访问区块信息和msg等全局变量
    view: 读取但不修改状态变量，不能访问区块信息和msg等全局变量
    normal: 可以读取和修改状态变量，可以访问区块信息和msg等全局变量

4. call vs staticcall vs delegatecall
    call: 可以修改被调用合约的状态
    staticcall: 只读,不能修改状态(相当于view)
    delegatecall: 在调用者的上下文中执行(用于代理模式)

5. 函数选择器
    bytes4 selector = bytes4(keccak256("power(uint256,uint256)"));
<<<<<<< HEAD
    // 结果: 0x617ec7e4； 实际是函数签名的哈希值的前4字节，用于标识函数。

    // 或者使用编译器提供了更简洁的方式获取函数选择器：
    bytes4 selector = ScientificCalculator.power.selector;

    // 通过函数选择器进行低级调用
    (bool success, bytes memory data) = calculatorAddress.call(
        abi.encodeWithSelector(selector, 2, 10)
    );

    几种常用用法：
    1. 使用函数签名
    // 你写：我要调用transfer函数
    abi.encodeWithSignature("transfer(address,uint256)", to, amount)
    // Solidity自动翻译成：暗号(0xa9059cbb) + 参数

    2. 使用函数选择器
    bytes4 selector = bytes4(keccak256("transfer(address,uint256)"));
    abi.encodeWithSelector(selector, to, amount)
    // Solidity自动翻译成：暗号(0xa9059cbb) + 参数

    // 3. 获取函数选择器的更简洁方式
    bytes4 selector = ERC20.transfer.selector;


=======
    // 结果: 0x617ec7e4

    // 或者使用
    bytes4 selector = ScientificCalculator.power.selector;

>>>>>>> upstream/master
todo: 如何添加事件记录
 */