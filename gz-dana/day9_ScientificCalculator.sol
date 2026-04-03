// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 直接声明接口，不 import
interface ICalculator {
    function multiply(uint256 a, uint256 b) external pure returns (uint256);
}

contract ScientificCalculator {
    address public owner;
    address public calculatorAddress;
    ICalculator public calculator;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
    
    constructor(address _calculatorAddress) {
        owner = msg.sender;
        calculatorAddress = _calculatorAddress;
        calculator = ICalculator(_calculatorAddress);
    }
    
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }
    
    function squareRoot(uint256 number) public pure returns (uint256) {
        if (number == 0) return 0;
        uint256 z = (number + 1) / 2;
        uint256 y = number;
        while (z < y) {
            y = z;
            z = (number / z + z) / 2;
        }
        return y;
    }
    
    function squareViaCalculator(uint256 x) external view returns (uint256) {
        return calculator.multiply(x, x);
    }
    
    function squareLowLevel(uint256 x) external view returns (uint256) {
        (bool success, bytes memory data) = calculatorAddress.staticcall(
            abi.encodeWithSignature("multiply(uint256,uint256)", x, x)
        );
        require(success, "call failed");
        return abi.decode(data, (uint256));
    }
}