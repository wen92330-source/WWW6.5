// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day11_Ownable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// Declare inherited contract
contract VaultMaster is Ownable {
	event DepositSuccess(address indexed account, uint256 amount);
	event WithdrawSuccess(address indexed recipient, uint256 amount);
	// OpenZeppelin requires additional line for constructor
	// constructor() Ownable(msg.sender) {}
	function getBalance() public view returns (uint256) {
		return (address(this).balance);
	}
	function deposit() public payable {
		require(msg.value > 0, "Invalid payment");
		emit DepositSuccess(msg.sender, msg.value);
	}
	// Modifier is inherited
	function withdraw(address _to, uint256 _amount) public onlyOwner {
		require(_amount <= getBalance(), "Not enough to withdraw");
		(bool success, ) = payable(_to).call{value:_amount}("");
		require(success, "Withdraw failed");
		emit WithdrawSuccess(_to, _amount);
	}
}