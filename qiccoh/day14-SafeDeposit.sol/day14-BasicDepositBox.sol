// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-BaseDepositBox.sol";
// 它继承了 BaseDepositBox 的所有内容
// contract 子合约 is 母合约{} 
contract BasicDepositBox is BaseDepositBox {
    // 识别金库类型
    // 此合约定义的唯一函数，它是为了履行对 IDepositBox 接口的承诺
    // 将其自身金库类型报告为 "Basic"
    function getBoxType() external pure override returns (string memory) {
    //   external 仅用于从合约外部调用,pure 不读取或写入任何存储,返回硬编码的字符串
    // override：它（当前函数）正在重写
        return "Basic";
    }
}
