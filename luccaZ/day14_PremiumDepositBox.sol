//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseDepositBox} from "./day14_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
  string private metadata;

  constructor(address initialOwner) BaseDepositBox(initialOwner) {}
  
  event MetadataUpdated(address indexed owner);

  function getBoxType() public pure override returns (string memory) {
    return "Premium";
  }

  function setMetadata(string calldata _metadata) external onlyOwner {
    metadata = _metadata;
    emit MetadataUpdated(msg.sender);
  }

  function getMetadata() external view returns (string memory) {
    return metadata;
  }
}