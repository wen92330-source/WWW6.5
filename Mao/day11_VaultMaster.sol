//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day11_Ownable.sol";

//一个接受任何人 ETH 存款的金库，但只允许所有者提取。它不会重新编写所有权逻辑，而是简单地从 Ownable 继承它。
//VaultMaster 将继承 Ownable 的一切，无需重写任何一行逻辑
// indexed:  一个参数标记为 indexed 时，你使它变得可搜索。这意味着你可以在前端根据该特定值筛选日志。  

contract VaultMaster is Ownable{
    
   event DepositSuccessful(address indexed account, uint256 value);
   event WithdrawSuccessful(address indexed recipient, uint256 value);
   
   
function getBalance() public view returns (uint256) {
    return address(this).balance;
}


function deposit() public payable   {
    require(msg.value > 0, "Enter a valid amount");
    emit DepositSuccessful(msg.sender, msg.value);
}


function withdraw(address _to, uint256 _amount) public onlyOwner {
    require(_amount <= getBalance(), "Insufficient balance");

    (bool success, ) = payable(_to).call{value: _amount}("");
    require(success, "Transfer Failed");

    emit WithdrawSuccessful(_to, _amount);
}




}