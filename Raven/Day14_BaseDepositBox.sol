// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day14_IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox {
	address private owner;
	string private secret;
	uint256 private depositTime;
	event OwnershipTransfer(address indexed oldOwner, address indexed newOwner);
	event SecretStore(address indexed owner);
	constructor() {
		owner = msg.sender;
		depositTime = block.timestamp;
	}
	modifier onlyOwner() {
		require(msg.sender == owner, "Only owner has access");
		_;
	}
	function getOwner() public view override returns (address) {
		return (owner);
	}
	function transferOwnership(address newOwner) external virtual override onlyOwner{
		require(newOwner != address(0), "Invalid address");
		emit OwnershipTransfer(owner, newOwner);
		owner = newOwner;
	}
	function storeSecret(string calldata _secret) external virtual override onlyOwner{
		secret = _secret;
		emit SecretStore(msg.sender);
	}
	function getSecret() public view virtual override onlyOwner returns (string memory) {
		return secret;
	}
	function getDepositTime() external view virtual override onlyOwner returns (uint256) {
		return (depositTime);
	}
}