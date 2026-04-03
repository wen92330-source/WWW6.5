// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MyFirstToken
 * @author mumu
 * @notice 我的第一个代币
 * @dev 目标：实现一个简单的ERC20代币合约，包含基本的代币功能，如转账、余额查询和总供应量。通过这个合约，学习ERC20标准的基本实现，理解代币的核心功能和事件机制。
*/

contract MyFisrtToken {
    string public name = "SimpleToken"; // 代币的名称
    string public symbol = "SIM"; // 代币富豪
    uint8 public decimals = 18; // 精确度

    // 代币总数
    uint256 public totalSupply;
    // 用户账户余额映射
    mapping(address=>uint256) public balanceOf;
    // allowance
    mapping(address => mapping(address=>uint256)) public allowance;

    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数
    constructor(uint256 _initialSupply){
        totalSupply = _initialSupply * 10 ** decimals;
        // 初始化总供应量
        balanceOf[msg.sender] = totalSupply;
        // 事件
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // internal _transfer; 将重复的逻辑抽出来
    function _transfer(address _from, address _to, uint256 _value)internal{
        // check the receiver address
        require(_to != address(0), "Invalid address of _to");
        require(balanceOf[_from]>=_value, "Not enough balance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    // the user who call this function will transfer _value to tagetUser.
    function transfer(address _to, uint256 _value)public virtual returns(bool){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // somebody give the sender allowance to make the deal.帮别人转帐
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool){
        // 检查allowance
        require(allowance[_from][msg.sender] >= _value, "Allowance too low");
        // 先扣除allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    // 给用户授权
    function Approve(address _spender,uint256 _value) public returns(bool){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

/**
Use Open Zeppelin

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}
 */
