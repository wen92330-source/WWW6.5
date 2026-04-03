//SPDX-License-Identifier: MIT


/**
view / virtual / override
view：只读链上数据，不写存储。类比 C 里「不修改全局/结构体」的只读函数。
virtual：允许子合约重写。类比 C++ 的 virtual。
override：标记「这是实现/重写接口或父合约里的函数」。类比 C++ 的 override。 */

pragma solidity ^0.8.0; 
//像 C 的 头文件 或 函数指针表，只规定「有哪些函数、长什么样」，不写实现。
import "./day14_IDepositBox.sol";

//模块化金币系统，抽象合约，只实现接口，不实现具体功能
abstract contract BaseDepositBox is IDepositBox {

    address private owner;
    string private secret;
    uint256 private depositTime;

    //事件 所有权转移 秘密存储
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    //构造函数 初始化 所有者 存款时间
    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    //修饰符 仅所有者可以调用
    modifier onlyOwner(){
        require(owner == msg.sender, "Not the owner");
        _;
    }

    //获取所有者
    function getOwner() public view override returns (address){
        return owner;
    }

    //转移所有权
    function transferOwnership(address newOwner) external virtual override onlyOwner{
        require(newOwner != address(0), "Invalid Address");
        emit OwnershipTransferred(owner, newOwner); 
        owner = newOwner;
    }

    //存储秘密
    function storeSecret(string calldata _secret)external virtual override onlyOwner{
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    //获取秘密
    function getSecret() public view virtual override onlyOwner returns (string memory){
        return secret;
    }

    //获取存款时间
    function getDepositTime() external view virtual override onlyOwner returns (uint256) {
        return depositTime;
    }

    
   
    
    

}
