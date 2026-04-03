// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day14_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
    mapping(string => string) public metadata;
    
    function setMetadata(string memory key, string memory value) external onlyOwner {
        metadata[key] = value;
    }
    
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
}