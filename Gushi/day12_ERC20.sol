 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20 { //创建自己的代币，符合ERC20规则
    string public name = "GuudToken"; //设置我的代币名称，好货币
    string public symbol = "GDT"; //设置符号或代称
    uint8 public decimals = 18; //跟ETH一样设置为18位小数
    uint256 public totalSupply; //要有个总供应量

    mapping(address => uint256) public balanceOf; //映射：当前地址有多少余额
    mapping(address => mapping(address => uint256)) public allowance; //嵌套映射：allowance【所有人】【授权人】，即所有人给授权人授权了多少代币

    event Transfer(address indexed from, address indexed to, uint256 value); //事件：转移代币
    event Approval(address indexed owner, address indexed spender, uint256 value); //事件：授权代币

    constructor(uint256 _initialSupply) { //初始时设置总代币数量
        totalSupply = _initialSupply * (10 ** uint256(decimals)); //总供应量=初始值*10**18
        balanceOf[msg.sender] = totalSupply; //将总供应量全部给部署人
        emit Transfer(address(0), msg.sender, totalSupply); //触发转账事件，或者说是铸币事件，因为EVM默认货币来自空地址为铸币，同理，发给空地址货币的行为是销毁burn
    }

    function transfer(address _to, uint256 _value) public returns (bool) { //转账函数，转账人调用
        require(balanceOf[msg.sender] >= _value, "Not enough balance"); //验证调用人的余额
        _transfer(msg.sender, _to, _value); //调用_transfer这个内部函数，执行重复单一工作，它可复用在其他函数
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) { //授权函数，授权给她人的人调用；
        allowance[msg.sender][_spender] = _value; //所有者授权给授权人_value
        emit Approval(msg.sender, _spender, _value); //触发授权事件，记录在日志并被前端监听
        return true; //注意：这个函数不产生代币的转移，所以也没用到_transfer函数
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { //授权转账函数，授权人调用
        require(balanceOf[_from] >= _value, "Not enough balance"); //检查所有人的账户余额
        require(allowance[_from][msg.sender] >= _value, "Allowance too low"); //检查授权金额

        allowance[_from][msg.sender] -= _value; //授权金额减少
        _transfer(_from, _to, _value); //调用_transfer函数执行
        return true;
    }

    //_transfer这里用internal，表示这个函数是外部不能识别和调用的，只能合约内部的函数调用，避免外部躲过其他函数审查调用该函数，造成损失
    function _transfer(address _from, address _to, uint256 _value) internal { 
        require(_to != address(0), "Invalid address"); //前两个函数在这里核查接收账户是否空地址
        balanceOf[_from] -= _value; //减少转账人余额
        balanceOf[_to] += _value; //增加接收人余额
        emit Transfer(_from, _to, _value); //触发转账事件
    }
}
