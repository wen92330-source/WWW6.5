//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

//tell the solidity compiler to import the code from file day9_scientificCaculator.sol. And this file need to be in the same folder as this contract.
//tell this contract to the "menu" of the scientificCaculator contract, so we can use its functions.
//such like when you want to order food in a restaurant, you need know the menu.
import {scientificCalculator} from "./day9_ScientificCaculator.sol";

contract calculator{

    //we need: owner address,subcontract address(we use that later).
    address public owner;
    address public scientificCalculatorAddress;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner ,"Only owner can perfom this action");
        _;
    }

    //get the address of the contract named scientificCaculator.It's like when you want to order food in a restaurant, you need know the phone number..
    function AddscientificCalculatorAddress(address _scientificCalculatorAddress) public onlyOwner{
        scientificCalculatorAddress = _scientificCalculatorAddress;
    }

    //add, subtract, multiply, divide
    function add(uint256 a, uint256 b) public pure returns(uint256){
        return a+b;
    }

    function subtract(uint256 a, uint256 b) public pure returns(uint256){
        return a-b;
    }

    function multiply(uint256 a, uint256 b) public pure returns(uint256){
        return a*b;
    }

    function divide(uint256 a, uint256 b) public pure returns(uint256){
        uint256 result = a/b;
        return result;
    }

    //call the function in scientificCaculator contract
    function caculatePower(uint256 base, uint256 exponent) public view returns(uint256){
        //create an instance of the scientificCaculator contractor
        scientificCalculator sc = scientificCalculator(scientificCalculatorAddress);
        return sc.power(base, exponent);
    }

    //use "call" to caculate the square root of a number. "call" is a low-level function in solidity, it can call any function in any contract, but it doesn't check the function signature, so we need to encode the function signature and the parameters.
    //what does "it doesn't check the function signature" mean?
    //it means: 1.at the compile time, the solidity compiler doesn't verify whether or not you call the correct function in the called contract.
    //2.At runtime, "call" doesn't care about whewher or not the contract can handle the data.
    //so we need to verify the contract address,encode the function signature and the parameters, and then decode the result.
    function cacluateSquareRoot(uint256 number) public returns(uint256){
        //verify the contract address
        require(scientificCalculatorAddress != address(0), "scientific calculator address is not set");
        //encode the function signature(fucntion's name and the parameters) , the argument
        //abi = keccak256
        //abi.encodeWithSignature is a convenience function provided by Solidity. Internally, it automatically performs the entire process of "Keccak256 hash → extract selector → encode parameters."
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)",number);
        (bool success, bytes memory retrunAta) = scientificCalculatorAddress.call(data);
        require(success,"External call failed");
        uint256 result = abi.decode(retrunAta,(uint256));
        return result;
    }


}
