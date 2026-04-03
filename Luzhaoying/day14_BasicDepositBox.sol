//BasicDepositBox为我们提供了一个功能齐全、安全、由所有者控制的存款箱
//能够访问基础合约BaseDepositBox中定义的所有内容:
//-所有权管理- 秘密存储和检索- 存入时间跟踪- 访问控制修饰符- 事件

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseDepositBox} from "./day14_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {
    //可以简单地调用 getBoxType() 并获取一个人可读的标签
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}