 //SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol";

contract Calculator {
    //用于存储合约所有者地址
    address public owner;
    //用于存储科学计算器合约地址
    address public scientificCalculatorAddress;

    constructor() {
        //将合约部署者的地址（msg.sender）赋值给 owner 变量，确定合约所有者 。
        owner = msg.sender;
    }
    
    //定义了一个名为 onlyOwner 的修饰器
    modifier onlyOwner() {
        //要求调用者地址（msg.sender）必须等于合约所有者地址（owner），否则抛出 “Not the owner” 错误。
        require(msg.sender == owner, "Not the owner");
        _;
    }

     // 新增：便捷调用 - 部署后直接初始化科学计算器地址（可选）
    // 功能：部署合约时直接设置，无需后续手动调用
    function initializeCalculator(address _scientificCalcAddr) public onlyOwner {
        setScientificCalculator(_scientificCalcAddr);
    }

    //设置科学计算机地址
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

      // 新增：calculatePower 函数（封装幂运算调用）
    // 功能：调用科学计算器合约的power方法，计算base的exponent次幂
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        // 校验科学计算器地址已设置
        require(scientificCalculatorAddress != address(0), "Calculator not set");
        // 校验指数非负（可选增强：防止无意义的计算）
        require(exponent >= 0, "Exponent cannot be negative");
        
        // 关联科学计算器合约
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        // 调用power方法并返回结果
        return scientificCalc.power(base, exponent);
    }

    //方式1：高级调用 - power
    //定义power函数，接受base和exponent两个uint256类型参数，是公共视图函数，返回uint256类型值
    function power(uint256 base, uint256 exponent) public view returns (uint256) {
        //scientificCalculatorAddress不等于空地址，否则抛出 “Calculator not set” 错误。
        require(scientificCalculatorAddress != address(0), "Calculator not set");
        //关联地址合约
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        //调用sc的power函数，传入base和expoent参数并返回结果
        return scientificCalc.power(base, exponent);
    }

    //方式2：低级调用 -squareRoot
    //scientificCalculatorAddress不等于空地址，否则抛出 “Calculator not set” 错误。
    function squareRoot(uint256 number) public view returns (uint256) {
        //ss不为空地址，否则抛出 “Calculator not set” 错误
        require(scientificCalculatorAddress != address(0), "Calculator not set");
        
        //使用abi.对square和number进行编码
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)",number);
        //通过sc地址发起静态调用stat，传入编码后的数据data，并将调用结果（success和返回数据return）赋值给对应的变量
        (bool success, bytes memory returnData) = scientificCalculatorAddress.staticcall(data);
        require(success,"Call failed");

        return abi.decode(returnData,(uint256));
    }

     // ========== 新增：测试/调用示例 ==========
    function exampleSetCalculator(address _scientificCalcAddr) external onlyOwner {
        // 直接调用setScientificCalculator函数
        setScientificCalculator(_scientificCalcAddr);
        // 验证设置是否成功
        require(scientificCalculatorAddress == _scientificCalcAddr, "Set failed");
    }
}