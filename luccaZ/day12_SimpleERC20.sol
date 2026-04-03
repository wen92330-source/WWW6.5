//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC20 {
    string public name = "SimpleToken";
    string public symbol = "SIM";
    uint8 public decimals = 18; //how divisible it is
    uint256 public totalSupply; //total tokens exist

    mapping(address => uint256) public balanceOf; //how many tokens each addr holds
    mapping(address => mapping(address => uint256)) public allowance; //what allow to spend tokens on behalf of whom

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals)); //100tokens = 100*10^18
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply); //tokens were created
    }

    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance.");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    //give another address permission to spend tokens on my behalf
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _value) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][_spender];
        require(currentAllowance >= _value, "Decreased allowance below zero.");

        allowance[msg.sender][_spender] -= currentAllowance - _value;
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

    //let someone approved move tokens on someone's behave
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance.");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low.");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address.");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

}