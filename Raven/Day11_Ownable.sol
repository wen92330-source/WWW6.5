//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract Ownable {
	address private owner;
	event TransferOwner(address indexed oldOwner, address indexed newOwner);
	constructor() {
		owner = msg.sender;
		emit TransferOwner(address(0), owner);
	}
	modifier onlyOwner() {
		require(msg.sender == owner, "Only owner has access to operate");
		_;
	}
	// Access private state variable
	function getOwnerAddress() public view returns (address) {
		return (owner);
	}
	function transferOwnership(address _newOwner) public onlyOwner() {
		require(_newOwner != address(0), "Invalid address");
		address oldOwner = owner;
		owner = _newOwner;
		emit TransferOwner(oldOwner, owner);
	}
}