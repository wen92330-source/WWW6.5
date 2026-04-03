// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./Day11_Ownable.sol";

contract VaulMaster is Day11_Ownable {

    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function deposit() public payable {
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdraw(address newto, uint256 newamount) public onlyOwner{
        require(newamount <= getBalance(), "Insufficient balance");
        (bool success,) = payable (newto).call{value:newamount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(newto, newamount);

    }
}