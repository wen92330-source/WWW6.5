// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day11_Ownable.sol";

contract VaultMaster is Ownable {

    uint256 public treasureAmount;

    function depositTreasure() public payable {
        treasureAmount += msg.value;
    }

    function withdrawTreasure(uint256 _amount) public onlyOwner {
        require(_amount <= treasureAmount, "Insufficient treasure");
        require(_amount <= address(this).balance, "Insufficient balance");

        treasureAmount -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
