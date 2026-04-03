 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


contract SimpleERC20 {
    string public name = "HERSTORY";
    string public symbol = "HER"; //代币简称
    uint8 public decimals = 18; // 有18位小数精度 
    uint256 public totalSupply; 

    //每个地址对应的代币余额
    mapping(address => uint256) public balanceOf;
    //两层mapping the owner授权the spender可以花多少自己的代币
    mapping(address => mapping(address => uint256)) public allowance;

    //转账事件 从谁转出 转给谁 转了多少
    event Transfer(address indexed from, address indexed to, uint256 value);
    //授权事件 谁授权 授权给谁 授权多少
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //部署的时候设置初始发行量
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals)); //18位小数 所以要乘decimals
        balanceOf[msg.sender] = totalSupply; //部署者 全部代币
        emit Transfer(address(0), msg.sender, totalSupply); //触发transfer event 从address0传给部署者 从无到有

    }

//转账函数 internal内部工具函数 是给合约里的其他函数来用的
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }




    //当前调用者把自己的代币转给别人 _to收款地址 _value转账金额
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance"); //balance大于转账金额才可以转
        _transfer(msg.sender, _to, _value);
        return true; //转账成功

    }

    // 授权_spender最多可以帮自己花多少代币
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //日志记录j
        return true;

    }


    //帮别人转 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value, "not enough balance");
        require(allowance[_from][msg.sender] >= _value, "allowance too low"); //授权额度不足

        allowance[_from][msg.sender] -= _value;//扣掉用了的
        _transfer(_from, _to, _value);//执行transfer
        return true;

    }






}