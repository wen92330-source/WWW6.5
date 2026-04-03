// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable {
    address private owner;//写了private只有owner可以修改数据

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);//设定转移所有权事件，previous上一任的

    constructor(){
        owner = msg.sender;//=是赋值，==是比较判断
        emit OwnershipTransferred(address(0), msg.sender);//原本地址是0，现在是msg.sender
    }

    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    //查询owner是谁
    function ownerAddress()public view returns(address){
        return owner;
    }

    function transferOwnership(address _newOwner)public onlyOwner{
        require(_newOwner != address(0), "Invalid address");
        address previous = owner;//先设定地址状态变量为previous，方便之后触发事件
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);
    }
}