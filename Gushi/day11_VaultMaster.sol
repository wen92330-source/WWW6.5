// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./day11_Ownable.sol"; //import母合约，以便这个合约继承她的一切

contract VaultMaster is Ownable{ //这里代表的是1，声明了一个叫VaultMaster的合约，2，她继承了Ownable合约


    event DepositSuccessful(address indexed account, uint256 value); //存放成功是一个事件，会在后面的函数中被触发，可以通过address过滤
    event WithdrawSuccessful(address indexed reciepient, uint256 value); //提取成功是一个事件，会在后面的函数中被触发，可以通过address过滤
    

    function getBalance()public view returns(uint256){ //任何人都可以读取当前这个合约的余额
        return address(this).balance;  //仍是address(this).balance，代表当前这个合约地址的余额
    }

    function deposit()public payable{ //用了payable，代表可以接收提取ETH
        require(msg.value >0, "Enter a valid amount"); 
        emit DepositSuccessful(msg.sender, msg.value); //存放成功就会触发一个事件，说明什么地址向这个合约存放了多少货币
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner { //onlyowner没有在这个合约里被声明，继承自母合约
        require(_amount <= getBalance(), "Insufficient balance"); //调用getbalance(),跟要提取的金额比较一下
        (bool success , ) = payable(_to).call{value: _amount}(""); //仍是用call函数发送ETH，payable确保能接受发送ETH
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount); //触发成功提取事件记录该操作
        
    }

}
