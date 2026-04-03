 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {
    //name 是代币的全名
    string public name = "Web3 Compass";
    //symbol 是简短的交易代码（如"ETH"或"DAI"）
    string public symbol = "COM";
    //decimals 定义了它的可分割程度
    uint8 public decimals = 18;
    //用于追踪当前存在的代币总数
    uint256 public totalSupply;
    //balanceOf 告诉你每个地址持有多少代币
    mapping(address => uint256) public balanceOf;
    //allowance是一个嵌套映射，用于追踪谁被允许代表谁花费代币——以及花费多少
    mapping(address => mapping(address => uint256)) public allowance;
    //每当代币从一个地址转移到另一个地址时，这个事件就会触发。钱包和浏览器依赖这个事件来显示交易历史
    event Transfer(address indexed from, address indexed to, uint256 value);
    //当有人授权另一个地址代表他们花费代币时，这个事件就会触发
    event Approval(address indexed owner, address indexed spender, uint256 value);
    //这个构造函数在合约部署时只会运行一次，并且只会运行一次
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    //它确保发送者（msg.sender）有足够的代币，使用 require(balanceOf[msg.sender] >= _value)
    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }
    //允许你授权另一个地址（通常是智能合约）代表你花费代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    //允许已获批准的人代为转移代币
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    //实际移动代币
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    
}
