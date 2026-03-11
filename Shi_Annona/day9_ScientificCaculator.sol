//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

//this contract doesn't have an owner, anyone can call the function in this contract
contract scientificCalculator{
    //new: Pure
    function power(uint256 base, uint256 exponent) public pure returns(uint256){
        //I tried to use (uint result)
        if(exponent == 0) return 1;
        else return (base**exponent);
    }

    function squareRoot(uint256 number) public pure returns(uint256){
        require(number > 0, "cann't calculate the square root of nagetive number");
        if(number == 0) {
            return 0;
        }
        
        else {
            uint256 result = number/2;
            for(uint256 i=0;i<10;i++){
                result = (result + number / result) / 2;
            }
            return result;
        }
    }
}