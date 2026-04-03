// SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.20;
// 指定Solidity编译器版本为0.8.20及以上，但小于0.9.0

// 导入Ownable合约，继承其所有权管理功能
import "./day11-Ownable.sol";

// 资金保险库合约，继承自Ownable
// 功能：存款、查询余额、提款（仅限所有者），这是一个简单的资金托管合约示例
contract VaultMaster is Ownable{

    // 存款成功事件
    event DepositSuccessful(address indexed account, uint256 value);
    // 提款成功事件
    event WithdrawSuccessful(address indexed reciepient, uint256 value);
    
    // 获取合约余额函数：返回合约当前持有的ETH数量（以wei为单位）
    // view修饰符表示此函数不修改状态，只读取数据
    // address(this).balance 获取当前合约地址的ETH余额
    function getBalance()public view returns(uint256){
        return address(this).balance;
    }

    // 存款函数：payable修饰符表示此函数可以接收ETH转账
    // 调用此函数时需要同时发送ETH，否则交易会失败
    function deposit()public payable{
        // 检查发送的ETH数量是否大于0
        require(msg.value >0, "Enter a valid amount");
        // 触发存款成功事件，记录这次存款
        emit DepositSuccessful(msg.sender, msg.value);
    }

    // 提款函数：onlyOwner修饰符确保只有合约所有者可以调用此函数
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        // 检查合约余额是否足够
        require(_amount <= getBalance(), "Insufficient balance");
        // 使用call方法向指定地址发送ETH
        // call是低级别的函数调用，返回(bool success, bytes memory data)
        // {value: _amount} 指定发送的ETH数量，"" 表示不发送任何数据
        (bool success , ) = payable(_to).call{value: _amount}("");
        // 检查转账是否成功
        require(success, "Transfer Failed");
        // 触发提款成功事件，记录这次提款
        emit WithdrawSuccessful(_to, _amount);
        
    }

}
