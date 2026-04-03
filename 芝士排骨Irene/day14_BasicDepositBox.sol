// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入抽象合约
import "./day14_BaseDepositBox.sol";

// 基础保险箱合约 - 继承链的最终层，可以实际部署
contract BasicDepositBox is BaseDepositBox {

    // 返回保险箱类型 - 这是整个继承链中最后一个需要实现的函数
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}