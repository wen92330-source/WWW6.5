// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//创建自己的代币
contract SimpleERC20 {
    string public name = "SimpleToken";
    string public symbol = "SIM";//symbol 是简短的交易代码（如"ETH"或"DAI"）
    uint8 public decimals = 18;//decimals 定义了它的可分割程度 n * 10^18 = 100000000000000000000
    uint256 public totalSupply; // 追踪当前存在的代币总数

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //铸造//构造函数在合约部署时只会运行一次，并且只会运行一次
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // transfer() 想象成前端按钮，而 _transfer() 是后端引擎
    //virtual:在“子合约”里重写（重新实现）“母合约”里的某个函数
    function transfer(address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        require(balanceOf[_from] >= _value, "Not enough balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
}

