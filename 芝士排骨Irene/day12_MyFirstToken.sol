// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 简易 ERC-20 代币合约 - 实现代币的基本功能：转账、授权、授权转账
// ERC-20 是以太坊上最通用的代币标准，几乎所有代币（USDT、UNI、LINK 等）都遵循这个标准
contract SimpleToken {

    //代币元数据（代币的基本信息）

    // 代币名称，在钱包和交易所中显示
    string public name = "SimpleToken";

    // 代币符号（缩写），类似股票代码
    string public symbol = "SIM";

    // 小数位数 - 18 是以太坊的标准精度
    // 类似于 1 元 = 100 分，1 SIM = 10^18 个最小单位
    // 这样可以支持非常小的金额，比如 0.000000000000000001 SIM
    uint8 public decimals = 18;

    // 代币总供应量（单位是最小单位，即带 18 位小数的值）
    uint256 public totalSupply;

    //核心映射（代币的核心数据存储）

    // 余额映射：地址 => 该地址持有的代币数量
    // 类似于银行系统中的 "账户 => 余额" 记录
    mapping(address => uint256) public balanceOf;

    // 授权映射：代币持有者 => (被授权者 => 授权额度)
    // 这是一个嵌套映射（二维映射），记录 A 允许 B 代替自己花费多少代币
    // 典型场景：用户授权 DEX（去中心化交易所）合约花费自己的代币来完成交易
    mapping(address => mapping(address => uint256)) public allowance;

    //事件定义

    // 转账事件 - 任何代币转移都会触发，前端和区块浏览器通过监听此事件来追踪交易
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件 - 当用户授权他人使用自己的代币时触发
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //构造函数（部署时执行一次）

    // _initialSupply：初始发行量（用户输入的是"个数"，比如 1000000 表示一百万个代币）
    constructor(uint256 _initialSupply) {
        // 将用户输入的整数转换为带精度的实际数量
        // 例如：_initialSupply = 1000000
        // totalSupply = 1000000 * 10^18 = 1000000000000000000000000（实际存储的值）
        totalSupply = _initialSupply * (10 ** uint256(decimals));

        // 所有代币分配给合约部署者（即发币者拥有全部初始供应量）
        balanceOf[msg.sender] = totalSupply;

        // 触发转账事件：从零地址（表示"铸造/凭空产生"）转给部署者
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //核心功能函数

    // 直接转账 - 调用者将自己的代币转给目标地址
    // 这是最常用的代币转账方式，类似于"我给你转账"
    function transfer(address _to, uint256 _value) public returns (bool) {
        // 防止转账到零地址（零地址没有私钥，转进去的代币会永久丢失）
        require(_to != address(0), "Invalid address");

        // 调用内部转账函数执行实际逻辑
        _transfer(msg.sender, _to, _value);
        return true;  // 返回 true 表示转账成功（ERC-20 标准要求）
    }

    // 内部转账逻辑 - 被 transfer 和 transferFrom 共同调用
    // internal：仅合约内部和子合约可调用，外部无法直接访问
    // 抽取公共逻辑避免代码重复（DRY 原则）
    function _transfer(address _from, address _to, uint256 _value) internal {
        // 检查发送者余额是否充足
        require(balanceOf[_from] >= _value, "Insufficient balance");

        balanceOf[_from] -= _value;   // 发送者余额减少
        balanceOf[_to] += _value;     // 接收者余额增加

        // 触发转账事件
        emit Transfer(_from, _to, _value);
    }

    // 授权函数 - 允许另一个地址（通常是智能合约）代替自己花费指定额度的代币
    // 使用场景举例：
    //   1. 用户想在 Uniswap 卖出 100 SIM
    //   2. 用户先调用 approve(Uniswap合约地址, 100) 进行授权
    //   3. Uniswap 合约再调用 transferFrom 把用户的 100 SIM 转走
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Invalid address");

        // 设置授权额度：msg.sender 允许 _spender 花费 _value 数量的代币
        allowance[msg.sender][_spender] = _value;

        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 授权转账 - 被授权者调用此函数，从授权者的账户中转出代币
    // 调用者（msg.sender）是被授权的那个人/合约，而非代币持有者本人
    // 流程：A 授权给 B → B 调用 transferFrom 从 A 的账户转给 C
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // 检查调用者的授权额度是否足够
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        // 扣减授权额度（防止被授权者超额使用）
        allowance[_from][msg.sender] -= _value;

        // 执行实际转账
        _transfer(_from, _to, _value);
        return true;
    }
}