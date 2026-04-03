// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 【考点 2：如何将外部的 Solidity 文件引入到当前文件中】
import "./day9_ScientificCalculator.sol";

contract Calculator {
    address public owner;
    address public scientificCalculatorAddress;
    
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
    
    // 方式1: 高级调用 - power
    function power(uint256 base, uint256 exponent) public view returns (uint256) {
        // 【考点 3：检查目标合约地址不能为“黑洞地址”（全0地址）】
        require(scientificCalculatorAddress != address(0), "Calculator not set");
        
        // 【考点 4：高级调用核心。将普通地址“包装/实例化”为目标合约类型的对象】
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);
        return scientificCalc.power(base, exponent);
    }
    
    // 方式2: 低级调用 - squareRoot
    function squareRoot(uint256 number) public view returns (uint256) {
        require(scientificCalculatorAddress != address(0), "Calculator not set");
        
        // 【考点 5：低级调用准备。将函数签名和参数打包编码为 bytes 数据】
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);
        
        // 【考点 6：低级调用执行。由于目标函数不改变状态（是 view 或 pure），推荐使用这种安全的低级调用方式】
        (bool success, bytes memory returnData) = scientificCalculatorAddress.staticcall(data);
        require(success, "Call failed");
        
        // 【考点 7：低级调用收尾。将返回的 bytes 类型数据解码为我们需要的 uint256 类型】
        return abi.decode(returnData, (uint256));
    }
}