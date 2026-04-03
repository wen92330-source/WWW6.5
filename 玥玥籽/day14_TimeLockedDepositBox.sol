// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {

    uint256 public lockDuration;
    uint256 public unlockTime;

    constructor(uint256 _lockDuration) {
        lockDuration = _lockDuration;
        unlockTime = block.timestamp + _lockDuration;
    }

    function storeSecret(string calldata _secret) external override onlyOwner {
        secret = _secret;
        depositTime = block.timestamp;
        unlockTime = block.timestamp + lockDuration;
    }

    function getSecret() external view override onlyOwner returns (string memory) {
        require(block.timestamp >= unlockTime, "Box is still locked");
        return secret;
    }

    function isUnlocked() external view returns (bool) {
        return block.timestamp >= unlockTime;
    }

    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }
}
