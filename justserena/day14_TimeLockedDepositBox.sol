// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day14_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {
    uint256 public unlockTime;
    
    constructor(uint256 _lockDuration) {
        unlockTime = block.timestamp + _lockDuration;
    }
    
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Still locked");
        _;
    }
    
    function getSecret() public view override timeUnlocked returns (string memory) {
        return super.getSecret();
    }
    
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }
}