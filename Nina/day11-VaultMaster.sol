// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VaultMaster is Ownable{ // "VaultMaster 继承自 Ownable。" 这意味着 `VaultMaster` 现在**自动拥有** `Ownable` 的所有函数、变量和修饰符。


    event DepositSuccessful(address indexed account, uint256 value); // 当有人向合约发送 ETH 时触发。account是发送者的地址。
    event WithdrawSuccessful(address indexed reciepient, uint256 value); // 当所有者从合约提取 ETH 时触发。recipient是接收资金的地址。
    
    constructor() Ownable(msg.sender) {} // OpenZeppelin 版本的 Ownable 期望你在部署合约时传递初始所有者.

    function getBalance()public view returns(uint256){
        return address(this).balance; 
    }
    /* address(this).balance 是 Solidity 语言内置语法，它是以太坊虚拟机（EVM）提供的一种直接查询合约账户状态的方式。
    this: 这是一个关键字，代表当前合约实例。
    address(this): 这是一个强制类型转换。在 Solidity 中，合约类型和地址类型（address）是不同的。为了访问地址相关的属性（如余额），你需要先用 address() 将合约转换为地址类型。
    .balance: 这是所有 address 类型变量都自带的一个属性。它返回该地址在以太坊账本上当前拥有的以太币数量（以 wei 为单位）。*/

    function deposit()public payable{
        require(msg.value >0, "Enter a valid amount");
        emit DepositSuccessful(msg.sender, msg.value);
    }
    // 这个函数让任何人都可以向合约发送 ETH——它对公众开放。

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount <= getBalance(), "Insufficient balance");
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer Failed");
        emit WithdrawSuccessful(_to, _amount);
    }
    // 这个函数允许从合约中提取 ETH——但只有所有者有权限。
    // 关键在于 `onlyOwner` 修饰符。我们没有在这个合约内部定义它——我们从 `Ownable` 合约继承了它。
    /* public onlyOwner：可见性（谁能发起请求）vs. 权限控制（谁能成功执行）
        1. 为什么必须是 public？
            在 Solidity 中，public 定义了函数的访问范围。
                技术层面：如果你想从合约外部（比如通过 MetaMask 钱包、Etherscan 页面或你的前端 DApp 网页）点击“提现”按钮，这个函数必须是 public（或 external）。
                如果不写 public：如果你把它设为 private 或 internal，那么除了合约内部的其他函数，没有任何人能从外部看到或调用它。这就变成了一个“死函数”，钱永远提不出来。
        2. 为什么后面要加 onlyOwner？
            onlyOwner 的作用是“安检门”：
                第一步（公开入口）：任何人都可以尝试按下 withdraw 按钮（因为它是 public）。
                第二步（身份验证）：程序运行到 onlyOwner 时，会立刻检查：msg.sender（当前点击按钮的人）是不是 owner（合约管理员）？
                第三步（处理结果）：
                    如果是管理员：通过安检，继续执行后面的转账代码。
                    如果不是管理员：程序立即抛出异常并回滚（Revert）。攻击者不仅拿不到钱，还要白白浪费一点点 Gas 费。*/
    /*在函数内部：
        - 我们首先检查合约是否有足够的 ETH 可以提取。
        - 然后我们使用 `.call` 将指定数量发送到给定地址。
        - 如果转账成功，我们发出 `WithdrawSuccessful` 事件来记录该操作。*/

}