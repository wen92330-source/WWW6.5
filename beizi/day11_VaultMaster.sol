// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

//VaultMaster 继承自 Ownable
contract VaultMaster is Ownable{
    //记录存钱和取钱
event DepositSuccessful(address indexed account, uint256 value);
event WithdrawSuccessful(address indexed recipient, uint256 value);

constructor() Ownable(msg.sender) {}

function getBalance() public view returns (uint256) {
    return address(this).balance;
}

//这个函数让任何人都可以向合约发送 ETH——它对公众开放
function deposit() public payable   {
    require(msg.value > 0, "Enter a valid amount");
    emit DepositSuccessful(msg.sender, msg.value);
}

 function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success , ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
        
    }  
}
