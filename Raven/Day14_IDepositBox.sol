// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
// Using external because functions will be call outside contracts
// Using calldata(read-only) when external to save gas
interface IDepositBox {
	function getOwner() external view returns(address);
	function transferOwnership(address newOwner) external;
	function storeSecret(string calldata secret) external;
	function getSecret() external view returns (string memory);
	function getBoxType() external pure returns (string memory);
	function getDepositTime() external view returns (uint256);
}