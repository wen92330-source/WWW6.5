// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleERC20{
    // 定义了代币在钱包和交易所中的显示方式
    string public name = "SimpleToken";
    string public symbol = "SIM";
    uint8 public decimals = 18;

    // 追踪当前存在的代币总数
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // 铸造初始供应
    constructor(uint256 _initialSupply){
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_to != address(0), "Invalid Address!");
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }

    function transfer(address _to, uint256 _amount) public virtual returns (bool) {
        require(balanceOf[msg.sender] >= _amount, "Not enough");
        _transfer(msg.sender, _to, _amount);

        return true;
    } 

    // 允许授权另一个地址（通常是智能合约）代表你花费代币
    function approve(address _spender, uint256 _amount) public returns (bool){
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom (address _from, address _to, uint256 _amount) public virtual returns (bool){
        require(balanceOf[_from] >= _amount, "Not enough!");
        require(allowance[_from][msg.sender] >= _amount, "Allowance too low");

        allowance[_from][msg.sender] -= _amount;
        _transfer(_from, _to, _amount);
        return true;
    }
}

// 使用openzeppelin
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract MyToken is ERC20 {
//     constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
//         _mint(msg.sender, initialSupply * 10 ** decimals());
//     }
// }