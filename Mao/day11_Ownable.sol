//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 一个简单的合约，定义谁是所有者，并为你提供可重用的 onlyOwner 检查来保护敏感函数。
//- 跟踪当前所有者
//- 限制对敏感函数的访问
//- 允许转移所有权
//- 发出事件，使所有权更改被公开记录
contract Ownable {
    address private owner;

  //我们记录所有权从谁转移到谁。
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function ownerAddress() public view returns (address) {
        return owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address previous = owner;
        owner = _newOwner;
       //触发这个事件
        emit OwnershipTransferred(previous, _newOwner);
    }
}

