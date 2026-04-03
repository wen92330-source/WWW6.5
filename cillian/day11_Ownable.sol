//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    
    address private owner; // 存储合约管理员地址的私有变量

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); // 记录权限变更的广播信号

    // 部署时执行：将部署者设为初始管理员 
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // 权限守卫：限制只有管理员能操作敏感函数 
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 外部查询：返回当前管理员地址 
    function ownerAddress() view public returns(address) {
        return owner;
    }

    // 核心逻辑：安全移交管理权给新地址 
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address previousOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

}