// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 {

string public name = "SimpleToken";
string public symbol = "SIM";//是简短的交易代码
uint8 public decimals = 18;//decimals 定义了它的可分割程度,大多数代币使用 18 位小数
uint256 public totalSupply;//用于追踪当前存在的代币总数

mapping(address => uint256) public balanceOf; //告诉你每个地址持有多少代币
mapping(address => mapping(address => uint256)) public allowance;//用于追踪谁被允许代表谁花费代币——以及花费多少

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);//我（Owner）允许我的好朋友（Spender）去图书馆帮我借 3 本书

constructor(uint256 _initialSupply){  //_initialSupply是约定俗成，可以换成abc
    totalSupply = _initialSupply * (10 ** uint256(decimals));
    balanceOf[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);
}
//internal（内部的）：这意味着这个函数是合约的私密帮手，不管是哪一个交易都会给这个 _transfer 引擎来处理，这样逻辑更清晰，不容易写错
 function _transfer(address _from, address _to, uint256 _value) internal virtual {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);//然后它发出一个 Transfer 事件，以便钱包和前端可以反映这一变化
}

function transfer(address to, uint256 value) public virtual returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
}

function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
    require(balanceOf[_from] >= _value, "Not enough balance");
    require(allowance[_from][msg.sender] >= _value, "Allowance too low");

    allowance[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
}
//virtual 关键字用于标记母合约中的函数，意思是：“这个函数允许被我的子合约修改或重写
function approve(address _spender, uint256 _value) public virtual returns (bool) {
    allowance[msg.sender][_spender] = _value;//这是老板正在签发一张面值为 _value 的新支票
    emit Approval(msg.sender, _spender, _value);
    return true;
}

}
