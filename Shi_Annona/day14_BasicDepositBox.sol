//SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;

import "./day14_BaseDepositBox.sol";

contract basicDepositBox is BaseDepositBox{
    function getBoxType() external pure override returns(string memory){
        return "Basic";
    }
}