// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "./Day9-ScientificCalculator.sol";

contract Calculator{
    address public owner;
    address public ScientificCalculatorAddress;

    constructor(){
        owner = msg.sender;

    }

    modifier onlyOwner(){
        require(msg.sender == owner, "only owner can perform the action");
        _;

    }

    function setScientificCalculator(address _address)public onlyOwner{ //owner设置ScientificCalculator的address
        ScientificCalculatorAddress = _address;


    }

    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;

    }

    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;

    }

    function devide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!=0,"no zero here");
        uint256 result = a/b;
        return result;

    }

//调用ScientificCalculator的power（）
    function calculatePower(uint256 base, uint256 exponent)public view returns(uint256){   
        ScientificCalculator scientificCalc =  ScientificCalculator(ScientificCalculatorAddress);
        //external call 
        uint256 result = scientificCalc.power(base,exponent); //直接调用
        return result;
    }

    function calculateSquareRoot(int256 number)public returns(int256){//int 有符号整数
        require(number >= 0, "no negative number here");
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)",number); //把函数名和参数打包成调用信息
        (bool success, bytes memory returnData) = ScientificCalculatorAddress.call(data); //低级调用
        require(success, "external call failed");
        int256 result = abi.decode(returnData,(int256));
        return result;


 

    }












}


