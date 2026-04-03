// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day14_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
	string private metadata;
	event MetadataUpdate(address indexed owener);

	function getBoxType() external pure override returns (string memory) {
		return ("Premium");
	}
	function setMetadata(string calldata _meta) external onlyOwner {
		metadata = _meta;
		emit MetadataUpdate(msg.sender);
	}
	function getMetadata() external view onlyOwner returns (string memory) {
		return metadata;
	}
}