// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Day13_SimpleErc20
 * @dev 一个简单的 ERC20 代币实现，包含基础转账和授权功能
 */
contract Day13_SimpleErc20 {
    string public name = "PreOrderToken";
    string public symbol = "PRE";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    // 映射：地址 -> 余额
    mapping(address => uint256) public balanceOf;
    // 映射：所有者 ->  spender -> 额度
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    // 内部转账逻辑
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(_from, _to, _value);
    }
    
    // 公开转账函数 (virtual 允许子类重写，用于添加锁仓逻辑)
    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    // 授权函数
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Invalid address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    // 授权转账函数 (virtual 允许子类重写)
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        
        return true;
    }
}