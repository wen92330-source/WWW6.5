// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {BaseDepositBox} from "./day14-BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {

    // external：此函数仅用于从合约外部调用（例如，从另一个合约或前端）。
    // pure：它不读取或写入任何存储——它只是返回一个硬编码的字符串。
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }

}
