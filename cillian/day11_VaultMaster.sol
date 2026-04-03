// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day11_Ownable.sol";

// 继承 Ownable，自动获得所有权管理逻辑
contract VaultMaster is Ownable {

    event DepositSuccessful(address indexed account, uint256 value); // 存款成功广播

    event WithdrawSuccessful(address indexed reciepient, uint256 value); // 提款成功广播

    // 查询金库总余额 
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // 向金库充值 
    function deposit() public payable {
        require(msg.value > 0, "Invalid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }

    // 管理员提现 
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        
        (bool success , ) = payable(_to).call{value: _amount}(""); //以太币会从合约地址的余额中扣除，并瞬间转移到 _to 地址的余额中
        require(success, "Transfer Failed");
        
        emit WithdrawSuccessful(_to, _amount);
    }

}