// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 简易 ERC-20 代币合约 - 实现代币的核心功能
// 与标准 ERC-20 的区别：transfer 和 transferFrom 加了 virtual，允许子合约重写
contract SimpleERC20 {

    // 代币元数据
    string public name = "SimpleToken";    // 代币名称
    string public symbol = "SIM";          // 代币符号
    uint8 public decimals = 18;            // 小数位数，18 是以太坊标准精度
    uint256 public totalSupply;            // 代币总供应量（最小单位）

    // 核心映射
    // 余额映射：记录每个地址持有多少代币
    mapping(address => uint256) public balanceOf;
    // 授权映射：记录 A 允许 B 花费多少代币（嵌套映射）
    mapping(address => mapping(address => uint256)) public allowance;

    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);    // 转账事件
    event Approval(address indexed owner, address indexed spender, uint256 value); // 授权事件

    // 构造函数 - 部署时铸造所有代币给部署者
    constructor(uint256 _initialSupply) {
        // 用户输入整数，乘以 10^18 转换为链上实际存储的值
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        // 从零地址转出，表示"铸造"新代币
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 内部转账逻辑 - 被 transfer 和 transferFrom 共同调用
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balanceOf[_from] >= _value, "Insufficient balance"); // 余额检查
        balanceOf[_from] -= _value;   // 发送者扣减
        balanceOf[_to] += _value;     // 接收者增加
        emit Transfer(_from, _to, _value);
    }

    // 直接转账 - 调用者将自己的代币转给目标地址
    // virtual 关键字：允许子合约用 override 重写这个函数
    // 如果不加 virtual，子合约无法覆盖此函数的行为
    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(_to != address(0), "Invalid address"); // 防止转到零地址（代币会永久丢失）
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权函数 - 允许 _spender 代替自己花费 _value 数量的代币
    // 典型场景：用户授权 DEX 合约操作自己的代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Invalid address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 授权转账 - 被授权者从授权者账户中转出代币
    // virtual：同样允许子合约重写，用于添加额外的限制逻辑（如代币锁定）
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded"); // 检查授权额度
        allowance[_from][msg.sender] -= _value;  // 扣减授权额度
        _transfer(_from, _to, _value);
        return true;
    }
}