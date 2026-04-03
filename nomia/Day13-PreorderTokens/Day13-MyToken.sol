 //SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyToken{

    string public name = "Herstory";
    string public symbol = "HER";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address  => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply){
        totalSupply = _initialSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
        //emit Transfer(address(0), msg.sender, totalSupply);

    } 

//virtual 意思是这些函数以后可以被继承它的合约改写
    function _transfer(address _from, address _to, uint256 _value)internal virtual{
        require(_to != address(0), "Cannot transfer to the zero address");
        balanceOf[_from]-= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

    }


     function transfer(address _to, uint256 _value)public virtual returns (bool success){ 
        require(balanceOf[msg.sender] >= _value , "balance too low");
        _transfer(msg.sender, _to, _value);
        return true;
    
    }

    function transferFrom(address _from, address _to, uint256 _value)public virtual returns(bool){
        require(balanceOf[_from] >= _value, "balance too low");
        require(allowance[_from][msg.sender]>= _value, "Allowance too low");
        allowance[_from][msg.sender]-= _value;
        _transfer(_from, _to, _value);
        return true;

    }

    function approve(address _spender, uint256 _value)public returns(bool){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;


    }




}
