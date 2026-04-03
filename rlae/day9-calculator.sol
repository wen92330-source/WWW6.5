// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day9-scientificcalculator.sol";
contract calculator {
    //base functions
    address public owner;
    address public scientificcalculatoraddress;
    constructor() {
        owner=msg.sender;
    }
    modifier onlyOwner() {
        require (msg.sender == owner ," you are not owner" );
        _;
    }
    function setscientificcalculator(address _address ) public onlyOwner{
        scientificcalculatoraddress =_address;
    }
    function add (uint256 a, uint256 b)public pure returns(uint256){
        uint256 result= a+b;
        return result;
    }
    function substract (uint256 a, uint256 b)public pure returns(uint256){
    uint256 result= a-b;
    return result;
    }
    function multiply (uint256 a, uint256 b)public pure returns(uint256){
    uint256 result= a*b;
    return result;
    }
    function divide (uint256 a, uint256 b)public pure returns(uint256){
    require (b!=0,"cannot devide by 0");
    uint256 result= a/b;
    return result;
    }
    function calculatePower (uint256 base, uint256 exponent)public view returns(uint256){
    scientificcalculator scientificalc=scientificcalculator(scientificcalculatoraddress); // 1) Frist word tell the type, which is contact name, 2) name 3) confrim the type 4) address
    uint256 result= scientificalc.power(base, exponent);
    return result;
    }
    function calculatesquareRoot(uint256 number)public returns(uint256){
        require (number>=0, "cannot calculate nagetive number");
        bytes memory data=abi.encodeWithSignature("squareRoot(uint256)",number); // abi.to tell when encounter "squareroot(uint256)" with param,  get result of byte memory information
        (bool success, bytes memory returnData)=scientificcalculatoraddress.call(data); // call the function in scientific calculator contract
        require(success,"Externel call failed");
        uint256 result=abi.decode(returnData, (uint256));// return decode data to uint256
        return result;

    }

}