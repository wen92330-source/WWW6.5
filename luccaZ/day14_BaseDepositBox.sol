//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDepositBox} from "./day14_IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox {
  address private owner;
  string private secret;
  uint256 private depositTime;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event SecretStored(address indexed owner);

  modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _;
  }
  constructor(address initialOwner) {
    require(initialOwner != address(0), "Owner cannot be the zero address.");
    owner = initialOwner;
    depositTime = block.timestamp;
  }

  function getOwner() public view override returns (address) {
    return owner;
  }

  function transferOwnership(address newOwner) external override onlyOwner {
    require(newOwner != address(0), "New owner cannot be the zero address.");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function storeSecret(string calldata _secret) external override onlyOwner {
    secret = _secret;
    emit SecretStored(owner);
  }

  function getSecret() public view virtual override returns (string memory) {
    return secret;
  }

  function getDepositTime() public view override returns (uint256) {
    return depositTime;
  }
}