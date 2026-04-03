//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseDepositBox} from "./day14_BaseDepositBox.sol";

contract BasicDepositBox is BaseDepositBox {
  constructor(address initialOwner) BaseDepositBox(initialOwner) {}
  function getBoxType() public pure override returns (string memory) {
    return "Basic";
  }
}