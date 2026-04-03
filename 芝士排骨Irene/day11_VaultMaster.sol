// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 Ownable 合约 - 通过继承获得所有权管理功能
import "./day11_Ownable.sol";

// 金库合约 - 一个简单的 ETH 保险箱
// "is Ownable" 表示继承，VaultMaster 自动拥有 Ownable 的所有功能：
//   - owner 状态变量
//   - onlyOwner 修饰符
//   - transferOwnership() 函数
//   - ownerAddress() 函数
contract VaultMaster is Ownable {

    //事件定义

    // 存款成功事件 - 当有人向金库存入 ETH 时触发
    event DepositSuccessful(address indexed account, uint256 value);

    // 取款成功事件 - 当所有者从金库提取 ETH 时触发
    event WithdrawSuccessful(address indexed recipient, uint256 value);

    //查询函数

    // 查询金库当前余额（即本合约地址持有的 ETH 数量，单位：wei）
    // 1 ETH = 10^18 wei
    function getBalance() public view returns (uint256) {
        // address(this) 表示当前合约自身的地址
        // .balance 是每个地址都有的属性，返回该地址持有的 ETH 余额
        return address(this).balance;
    }

    //写入函数

    // 存款函数 - 任何人都可以向金库存入 ETH
    // payable 关键字：允许此函数接收 ETH，没有 payable 的函数无法接收转账
    function deposit() public payable {
        // msg.value 是调用此函数时附带的 ETH 数量（单位：wei）
        require(msg.value > 0, "Must send ETH"); // 确保发送的 ETH 大于 0

        // ETH 已经自动转入合约地址，无需额外操作
        // 触发存款事件，记录谁存了多少
        emit DepositSuccessful(msg.sender, msg.value);
    }

    // 取款函数 - 仅合约所有者可以提取金库中的 ETH
    // onlyOwner 是从 Ownable 主合约继承来的修饰符，无需重新定义
    function withdraw(address _to, uint256 _amount) public onlyOwner {
    require(_amount <= address(this).balance, "Insufficient balance");

    // 使用 call 代替 transfer 发送 ETH（推荐写法）
    // call 返回两个值：success（是否成功）和 data（返回数据，这里不需要）
    (bool success, ) = payable(_to).call{value: _amount}("");
    require(success, "Transfer failed");  // 如果转账失败，回滚交易

    emit WithdrawSuccessful(_to, _amount);
    }
}