// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day14_BaseDepositBox.sol";

contract TimeLockedDepositBox is BaseDepositBox {
	uint256 private unlockTime;
	constructor(uint256 duration) {
		unlockTime = block.timestamp + duration;
	}
	modifier timeUnlocked() {
		require(block.timestamp >= unlockTime, "Box is locked");
		_;
	}
	function getBoxType() external pure override returns (string memory) {
		return ("TimeLocked");
	}
	// Secret is private
	function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
		return super.getSecret();
	}
	function getUnlockTime() external view returns (uint256) {
		return unlockTime;
	}
	function getRemainingTime() external view returns (uint256) {
		if (block.timestamp >= unlockTime)
			return (0);
		return (unlockTime - block.timestamp);
	}
}