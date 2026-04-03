// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./day11_Ownable.sol";

contract VaultMaster is Ownable{
//VaultMaster合约继承自Ownable合约，可以使用Ownable中定义的如所有权相关的变量和函数等 

    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed reciepient, uint256 value);
    

    function getBalance()public view returns(uint256){
        return address(this).balance;
        //获取当前合约自身的余额
    }

    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    //将地址 _to 转换为可接收 ETH 的 payable 地址类型
    function withdraw(address _to, uint256 _amount) public onlyOwner { 
    //仅所有者可执行该函数继承自ownable合约
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success , ) = payable(_to).call{value: _amount}(""); //bool接收call的转账是否成功返回值
        //.call用于向另一个地址发送ETH;("")表示调用目标地址的 “空函数”（只转账 ETH，不执行目标地址的任何代码）
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
        
    }

}


//import "@openzeppelin/contracts/access/Ownable.sol";（使用官方 OpenZeppelin 版本）
//使用 OpenZeppelin 的构造函数将部署者设置为所有者   constructor() Ownable(msg.sender) {}