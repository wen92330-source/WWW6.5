//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract mySimpleToken{
    string public name = "ICECREAM";
    string public symbol = "ICE";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint amount);

    constructor(uint256 _initialSupply){
        totalSupply = _initialSupply * (10**decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function _transfer(address _from, address _to,uint256 _value) internal virtual{
        require(_to!=address(0),"Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public virtual returns(bool){
        require(balanceOf[msg.sender]>=_value,"Insufficienct balance");
        _transfer(msg.sender,_to,_value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool){
        require(balanceOf[_from] >= _value,"insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "indufficient allowance");
        allowance[_from][msg.sender]  -= _value;
        _transfer(_from,_to,_value);

        return true;
    }

    function approval(address _spender, uint256 _amount) public returns(bool){
        allowance[msg.sender][_spender] += _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function getBalance(address _user) public view returns(uint256){
        return balanceOf[_user];
    }
}
