// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SimpleERC20 {
    string public name="SimpleToken";
    string public symbol="SIM";
    uint8 public decimals = 18;//18 位小数
    uint256 public totalSupply;
    mapping (address=>uint256)public balanceOf; // 每个地址持有多少代币
    mapping(address=>mapping(address=>uint256))public allowance; // 第一个地址是token owner，第二个是sepender，（去使用拥有者多少额度）
    event Transfer(address indexed from, address indexed to, uint256 value); // Transfer 钱包和浏览器依赖这个事件来显示交易历史。
    event Approval(address indexed owner, address indexed spender, uint256 value);//有人授权另一个地址代表他们花费代币
    constructor (uint256 _initialSupply){ //只允许合约部署的时候开始造钱
    totalSupply=_initialSupply*(10**uint256 (decimals)); // why use uint8 of decimals instead of directly use uint256?
    balanceOf[msg.sender]=totalSupply;
    emit Transfer(address(0),msg.sender,totalSupply); //address(0)，这是一种特殊说法：铸造事件
    }
    function transfer(address _to, uint256 _value) public returns(bool){ //逻辑分离
        require (balanceOf[msg.sender] >= _value,"insuffcient balance");
        _transfer(msg.sender,_to,_value); //逻辑分离,内部辅助函数 _transfer() 用户只看到按钮transfer，但实际操作_transfer()在后台进行。
        return true;
    }
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to!=address(0),"invalid address"); //确保接收地址不是零地址——因为那样会实际销毁代币
        require (_value>0,"invalid value");
        balanceOf[_from]-=_value;
        balanceOf[_to]+=_value;
        emit Transfer(_from,_to,_value);
    }
    function Approve(address _spender, uint256 _value) public returns(bool){
        allowance[msg.sender][_spender]=_value; //[owner][授权的地址] A授权B
        emit Approval(msg.sender, _spender, _value);
        return true;

    }
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){ //
        require (balanceOf[_from] >= _value,"insuffcient balance");
        require (allowance[_from][msg.sender] >= _value,"insuffcient allowance of user"); // [token owner][spender]
        allowance[_from][msg.sender] -= _value;
        _transfer(_from,_to,_value); //逻辑分离, B调用A的钱转给C
        return true;
    }


//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//contract MyToken is ERC20 {
    //constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        //_mint(msg.sender, initialSupply * 10 ** decimals());
    //}
//}



}