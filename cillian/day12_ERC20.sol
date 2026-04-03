// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {
    // 代币基础信息
    string public name = "SimpleToken";
    string public symbol = "COM";
    uint8 public decimals = 18;
    uint256 public totalSupply; // 代币的总供应量

    mapping(address => uint256) public balanceOf; // 用户余额映射表
    mapping(address => mapping(address => uint256)) public allowance; // 代理转账额度映射表

    event Transfer(address indexed from, address indexed to, uint256 value); // 资产转移广播（含铸币逻辑）

    event Approval(address indexed owner, address indexed spender, uint256 value); // 授权额度变动广播

    // 构造函数：初始化总发行量并分配给部署者 
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 个人转账：用户自主发起资金转移 
    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权逻辑：批准第三方动用自己的代币额度 
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value; // 限制只能从发起者账户转账
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 代理转账：受托方在授权范围内划拨资金 
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    // 核心逻辑：底层余额更新与事件触发 
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}