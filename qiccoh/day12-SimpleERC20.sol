// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract  SimpleERC20{
    string public name = "SimpleToken";
    // 简短的交易代码
string public symbol = "SIM";
uint8 public decimals = 18;//可分割程度

uint256 public totalSupply;

mapping(address => uint256) public balanceOf;//每个地址持有多少代币
mapping(address => mapping(address => uint256)) public allowance;//嵌套映射,追踪谁被允许代表谁花费代币
//每当代币从地址转移时，事件被触发。钱包和浏览器依赖这个事件来显示交易历史。
event Transfer(address indexed from, address indexed to, uint256 value);
// 授权另一个地址代表他们花费代币?事件是自定义的吗?还是预定义?
event Approval(address indexed owner, address indexed spender, uint256 value);

// 造钱--->构造参数含参数,子类调用需要改!!
constructor(uint256 _initialSupply) {
    // _initialSupply * 10^18 = 初始代币
    totalSupply = _initialSupply * (10 ** uint256(decimals));
    // 代币给部署者
    balanceOf[msg.sender] = totalSupply;
    // 凭空创造了代币,不来自其他用户
    emit Transfer(address(0), msg.sender, totalSupply);
}
// 允许用户将他们的代币发送到另一个地址
// 父合约virtual 的标记代表这个函数是可以被重新修改
function transfer(address _to, uint256 _value) public virtual returns (bool) {
    // 发送者（msg.sender）
    require(balanceOf[msg.sender] >= _value, "Not enough balance");
    // 代币转移
    _transfer(msg.sender, _to, _value);

    return true;

}

function _transfer(address _from, address _to, uint256 _value) internal {
    require(_to != address(0), "Invalid address");
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    emit Transfer(_from, _to, _value);
}

function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
    require(balanceOf[_from] >= _value, "Not enough balance");
    require(allowance[_from][msg.sender] >= _value, "Allowance too low");

    allowance[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
}
// 允许你授权另一个地址（通常是智能合约）代表你花费代币
function approve(address _spender, uint256 _value) public returns (bool) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
}


} 