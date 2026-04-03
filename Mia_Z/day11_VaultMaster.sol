// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//导入Ownable合约
import "./day11_Ownable.sol";

contract VaultMaster is Ownable{
    //继承Ownable合约

    //定义事件 又是index
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed reciepient, uint256 value);
    

    //查看余额
    function getBalance()public view returns(uint256){
        return address(this).balance;
    }

    //存款
    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        //又是这个语法
        (bool success , ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
        
    }

}