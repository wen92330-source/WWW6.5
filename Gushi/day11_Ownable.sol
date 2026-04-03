// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//母合约，子合约可以继承她的一切，事件/修饰符/函数等等
contract Ownable {
    address private owner; //private，只能从内部访问，外部无法直接访问这个合约部署者的地址

    //设置一个事件，后续可以被触发，让前端监听到，并且被记录在合约的日志中，永久留存，耗费低
    //设置的是所有权转换的事件，两个地址都用上了indexed，都可以被过滤
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);//部署者被设置为所有者，发出一个事件
    }


    modifier onlyOwner() { //设置一个修饰符，子合约可以用到
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }


    function ownerAddress() public view returns (address) {
        return owner; //所有人都可以通过这个函数知道合约所有者的地址
    }

    function transferOwnership(address _newOwner) public onlyOwner {
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner; //这里之前转移的时候没有过，这里把旧所有者的地址存放到previous里，后续事件触发就能通过previous找到她
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);

    }
}
