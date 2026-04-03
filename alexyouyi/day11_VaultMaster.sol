//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./day11_Ownable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultMaster is Ownable{

    constructor() Ownable(msg.sender){}
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawalSuccessful(address indexed recipient, uint256 value);
   
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Withdrawal amount must be greater than zero");
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success, "Transfer failed");
        emit WithdrawalSuccessful(msg.sender, _amount);
    }
}