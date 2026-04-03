// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day11_Ownable.sol";
//可以使用openzeppelin合约库，import "@openzeppelin/contracts/access/Ownable.sol";
//使用库时要加上构造函数，constructor() Ownable(msg.sender) {}

contract VaultMaster is Ownable{//新的合约继承Ownable的所有内容
    event DepositSuccessful (address indexed account,uint256 value);//存钱成功事件
    event WithdrawSuccessful(address indexed reciepient,uint256 value);//取钱成功事件
    //一个用account，一个用reciepient是因为方便人阅读，其实用account都可以，但用reciepient别人就知道是取钱

    //查询金库里还有多少钱
    function getBalance()public view returns (uint256){//因为这里查的合约里有多少钱，所以不用传参数
        return address(this).balance;//this是合约/机器自己
    }

    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");//insufficient：不充分的
        (bool success , ) = payable(_to).call{value: _amount}("");//固定格式，call就是发送指令，冒号是传参数，
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
        
    }
}