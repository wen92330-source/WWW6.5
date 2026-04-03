// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
//这个合约跟踪谁是所有者，并使用 onlyOwner 修饰符保护敏感函数
contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    //将部署者（msg.sender）设置为初始所有者，并发出 OwnershipTransferred 事件来记录该更改
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    //确保只有所有者可以调用它
    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    //提供一个公共函数，这样任何人都可以检查当前所有者是谁
    function ownerAddress() public view returns (address) {
        return owner;
    }
    //允许当前所有者转移所有权给其他人
    function transferOwnership(address _newOwner) public onlyOwner {
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);

    }
}