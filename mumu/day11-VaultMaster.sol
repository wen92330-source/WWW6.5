// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day11-Ownable.sol"; // 导入Ownable合约文件

// // 使用OpenZeppelin的Ownable合约，提供成熟的所有权管理功能
// import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @title ValutMaster
 * @author mumu
 * @notice 保险库管理器
 * @dev 一个让用户存入 ETH 的金库，但**只有所有者**可以提取资金。`VaultMaster` 将**继承** `Ownable` 的一切，无需重写任何一行逻辑
*/

contract VaultMaster is Ownable {
    uint256 public totalDeposits;

    struct WithdrawRecord {
        uint256 amount;
        uint256 timestamp;
    }
    
    // 每个用户的提款历史记录数组
    mapping(address => WithdrawRecord[]) public withdrawalHistory;

    // 事件：当用户存入资金时触发
    event Deposit(address indexed sender, uint256 amount, uint256 timestamp);
    // 事件：当所有者提取资金时触发
    event Withdrawal(address indexed owner, uint256 amount, uint256 timestamp);

    //  // 使用 OpenZeppelin 的构造函数将部署者设置为所有者
    // constructor() Ownable(msg.sender) {}

    // 存款函数，任何人都可以调用
    function deposit() public whenNotPaused payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp); // 记录存款事件
    }

    // 提款函数，只有所有者可以调用
    function withdraw(uint256 _amount) public onlyOwner whenNotPaused(){
        require(_amount <= getBalance(), "Insufficient balance");
        // 检查是否超过每日提款限额
        require(checkDailyWithdrawalLimit(msg.sender, _amount), "Exceeds daily withdrawal limit");

        // 记录提款历史
        withdrawalHistory[msg.sender].push(WithdrawRecord({
            amount: _amount,
            timestamp: block.timestamp
        }));

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, _amount, block.timestamp); // 记录提款事件
    }

    // 获取金库当前余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 检查用户每日提款限额
    function checkDailyWithdrawalLimit(address _user, uint256 _amount) internal view returns (bool) {
        uint256 totalWithdrawnToday = 0;
        uint256 startOfDay = block.timestamp - (block.timestamp % 1 days);

        WithdrawRecord[] memory records = withdrawalHistory[_user];
        for (uint256 i = 0; i < records.length; i++) {
            if (records[i].timestamp >= startOfDay) {
                totalWithdrawnToday += records[i].amount;
            } else {
                break; // 因为记录是按时间顺序存储的，遇到早于当天开始的记录就可以停止检查
            }   
        }
        return (totalWithdrawnToday + _amount) <= dailyWithdrawalLimit;
    }

    // 获取用户当天已提款总额
    function getTodayWithdrawnAmount(address _user) public view returns (uint256) {
        uint256 totalWithdrawnToday = 0;
        uint256 startOfDay = block.timestamp - (block.timestamp % 1 days);
        WithdrawRecord[] memory records = withdrawalHistory[_user];
        for (uint256 i = 0; i < records.length; i++) {
            if (records[i].timestamp >= startOfDay) {
                totalWithdrawnToday += records[i].amount;
            } else {
                break; // 因为记录是按时间顺序存储的，遇到早于当天开始的记录就可以停止检查
            }
        }
        return totalWithdrawnToday;
    }
}

/**
知识点：
1. 合约继承：
    - 子合约可以继承母合约的状态变量和函数，避免代码重复。
    - 母合约中使用virtual修饰符标记函数，允许子合约重写。 子合约使用override修饰符重写母合约函数，提供特定实现。
    - 子合约不能直接访问母合约的私有变量，但可以通过公共或内部函数间接访问。

2. 事件中的indexed
    -限制: 每个事件最多3个indexed参数

3. OpenZeppelin提供了经过审计的标准实现:
    import "@openzeppelin/contracts/access/Ownable.sol";

    contract MyContract is Ownable {
        constructor() Ownable(msg.sender) {}
        
        function restrictedFunction() public onlyOwner {
            // 只有owner能调用
        }
    }

1. 继承的深度理解 (Inheritance)
关键字： 使用 is 实现继承（例如 contract A is B）。

权限边界：
private 变量：子合约不可直接访问
。
internal 变量/函数：子合约可以访问（虽然本课示例用了 private）
。
重写逻辑： 必须成对出现：父合约 virtual + 子合约 override
。
2. 事件系统 (Events) 📢
核心用途： 链外通信。前端通过监听日志来更新 UI，而不是轮询合约状态
。
性能优化：
Gas 优势： 事件成本约为 375 gas，远低于存储变量的 20,000 gas
。
搜索过滤： 使用 indexed 关键字标记的参数可以被高效过滤。一个事件上限为 3个 indexed 参数
。
命名规范： 建议使用过去时（如 OwnershipTransferred），代表事情已经发生
。
3. 生产级开发：OpenZeppelin 🛡️
为什么使用： 经过审计、行业标准、减少重复造轮子
。
初始化： 继承 OZ 的 Ownable 时，必须在子合约构造函数中调用父类构造函数：constructor() Ownable(msg.sender) {}
。
4. 典型模式：VaultMaster (金库模式)
设计思路： 将“权限控制”与“业务逻辑”分离。Ownable 处理谁是老大，VaultMaster 处理存取款逻辑
。
安全关键点： 提取函数（withdraw）必须加上 onlyOwner 修饰符，防止资金被盗
。
 */