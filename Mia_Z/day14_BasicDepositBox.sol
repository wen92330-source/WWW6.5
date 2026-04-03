//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

import "./day14_BaseDepositBox.sol";

/**
BaseDepositBox：抽象模板，提供通用保险箱逻辑，不实现 getBoxType()，不能部署。
BasicDepositBox：在 Base 之上只实现 getBoxType() => "Basic"，成为可部署的「基础版」保险箱；和 Base 的区别就是「抽象 vs 具体」以及「是否实现并填上类型名」。 */
contract BasicDepositBox is BaseDepositBox{

    function getBoxType() external pure override returns(string memory){
        return "Basic";
    }
}