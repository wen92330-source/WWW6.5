// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day11-ownable.sol"; 
//import "@openzeppelin/contracts/access/Ownable.sol";
contract VaultMaster is Ownable{ //VaultMaster 现在自动拥有 Ownable 的所有函数、变量和修饰符。
    event DepositSuccessful( address indexed account, uint256 value);
    event WithdrawSuccessful( address indexed account, uint256 value);
    //constructor() Ownable(msg.sender) {}
    function getBalance()public view returns (uint256) {
        return address(this).balance;//返回VaultMaster合约当前持有的 ETH 数量
    }
    function deposit()public payable {
        require(msg.value>0, "amount need >0");

        emit DepositSuccessful( msg.sender, msg.value);
    }
    function withdraw(address _to,uint256 _amount)public onlyOwner { //只有合约主人可以提取
        require(_amount<=getBalance(), "Insufficient balance");
        (bool success,)= payable(_to).call{value:_amount}(""); // left one boolean, right returns 2 value, add","
        require (success, "tranfer failed");
        emit WithdrawSuccessful( _to, _amount);
    }

}