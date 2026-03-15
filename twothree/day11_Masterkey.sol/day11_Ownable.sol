// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable { //定义合约
    address private Owner;//告诉这是一个私有变量，存合约所有者地址

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    //定义为事件，记录所有权转移，参数为前所有者和新所有者地址

    constructor() { //将合约所有者弄成合约构建者
        Owner = msg.sender; //触发所有权转移事件
        emit OwnershipTransferred(address(0), msg.sender);//指定事件参数，旧所有者为零地址，新所有者为合约创建者
    }

    modifier onlyOwner() { //是一个条件判断，要求消息发送是合约所有者，否则抛出错误
        require(msg.sender == Owner, "Only Owner can perform this action");
        _;
    }

    function owerAddress() public view returns (address) {//定义了合约，功能是返回合约所有者的地址
        return Owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {//要求新所有者地址不为零地址，否则抛出错误
        require (_newOwner !=address(0), "Invailed address");//保存旧的所有者地址
        address previous = Owner;//把新地址给owner
        Owner =_newOwner;//触发所有权转移事件
        emit OwnershipTransferred(previous, _newOwner);//将合约所有者更新为所新所有者地址
    
    }

    
}