// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//使用自己编写的合约
//import "./day11_Ownable.sol";

//使用 OpenZeppelin 的 Ownable ：节省时间，减少错误
import "@openzeppelin/contracts/access/Ownable.sol";

//一个让用户存入 ETH 的金库，但只有所有者可以提取资金
contract VaultMaster is Ownable{

    //当有人向合约发送 ETH 时触发
    event DepositSuccessful(address indexed account, uint256 value);
    
    //当所有者从合约提取 ETH 时触发
    event WithdrawSuccessful(address indexed reciepient, uint256 value);

    //使用 OpenZeppelin 的构造函数将部署者设置为所有者
    constructor() Ownable(msg.sender) {}

    //返回合约当前持有的 ETH 数量
    function getBalance()public view returns(uint256){
        return address(this).balance;
    }
    //允许任何人向合约发送 ETH
    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }
    //关键在于 onlyOwner 修饰符,我们没有在这个合约内部定义它——我们从 Ownable 合约继承了它
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success , ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
        
    }

}