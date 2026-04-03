// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//为了继承用
contract Ownable {
    //地址 私有变量
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender); //初始化事件
    }

    //定义修饰函数
    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    //view的返回
    function ownerAddress() public view returns (address) {
        return owner;
    }
    //转移所有权
    function transferOwnership(address _newOwner) public onlyOwner {
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);

    }
}