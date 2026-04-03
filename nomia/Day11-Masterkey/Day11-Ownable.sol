// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//可重复使用的访问控制
contract Ownable {
    address private owner;

    //主人身份变化时发出日志消息 indexed 方便被搜索和filtered 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        //合约从空地址转移给部署者 
        emit OwnershipTransferred(address(0), msg.sender);

    }


    modifier onlyOwner() {
         require(msg.sender == owner, "only owner can perform this action");
        _;


    }

//查询owner地址
    function ownerAddress() public view returns (address) {
        return owner;

    }

    function transferOwnership(address _newOwner) public onlyOwner {
       require (_newOwner !=address(0), "Invalid address"); 
        address previous = owner; //保存当前owner
        owner = _newOwner;
        emit OwnershipTransferred(previous, _newOwner);


    }

    

    
}