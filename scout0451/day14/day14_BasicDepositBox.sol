//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./day14_BaseDepositBox.sol";

//继承BaseDepositBox合约中所有逻辑
contract BasicDepositBox is BaseDepositBox{

    //识别金库功能
    function getBoxType() external pure override returns(string memory){
        return "Basic";
    }
}