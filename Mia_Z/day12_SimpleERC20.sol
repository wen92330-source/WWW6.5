// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//做一个标准的代币发布
contract SimpleERC20 {
    /**
     * @notice name = "SimpleToken"：代币全名
     * @notice symbol = "SIM"：代币简称
     * @notice decimals = 18：精度是 18 位，和 ETH / 大多数 ERC20 一样
     */
    string public name = "SimpleToken";
    string public symbol = "SIM";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    //像个二维数组？键中套键
    /**
     * @notice 它是“嵌套映射”。

        含义是：

        第一层 key：代币拥有者 owner
        第二层 key：被授权者 spender
        value：spender 还可以代替 owner 花多少钱
        例如：

        allowance[A][B] = 500;
        表示：

        A 授权 B
        B 最多可以从 A 的余额里转走 500 单位代币
     */
    mapping(address => mapping(address => uint256)) public allowance;

    //标准事件
    /**Transfer 和 Approval 是 ERC20 很重要的标准事件：
    Transfer：发生转账时发出
    Approval：发生授权时发出
    钱包、区块浏览器、前端页面，很多都是靠监听这些事件来显示代币变化的。 */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //初始化代币
    /**
     * 总量计算 转换单位 代币给部署者 并触发事件 标准from = address(0) 表示这些币是“凭空铸造出来”的
     */
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //转账
    //检查余额 内部函数扣减 触发事件
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    //批准 授权别人可花你的币
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //转账from ：代别人转账
    /**
     * 
     * @param _from ：代别人转账
     * @param _to ：转账给谁
     * @param _value ：转账金额
     * 
     * 调用者 msg.sender 不是在转自己的钱，而是在“使用别人给他的授权”。

        执行条件
        必须同时满足：

        _from 余额足够
        _from 给 msg.sender 的授权额度足够
        然后做两件事
        先扣掉授权额度
        再执行真正转账
        一个完整例子
        假设：

        A 有 1000 币
        A 调用 approve(B, 200)
        那么：

        allowance[A][B] = 200
        之后如果 B 调用：

        transferFrom(A, C, 50)
        结果会是：

        A 减少 50
        C 增加 50
        B 的授权额度从 200 变成 150
        这就是 DEX、质押、自动扣费等场景的基础机制。
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    //内部函数
    /**
     * 
     *这里是真正改余额的地方：
        禁止转给零地址
        从 _from 扣款
        给 _to 加款
        发出 Transfer 事件

     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}

