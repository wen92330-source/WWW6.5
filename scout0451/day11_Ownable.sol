// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); //indexed关键字日志快速查找，但不是储存完整数据

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);  //记录所有权从空地址转移到部署者地址的变更事件
    }


    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }


    function ownerAddress() public view returns (address) {
        return owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner;  //把当前的owner值赋格previous变量，再把新地址赋给owner
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);

    }
}