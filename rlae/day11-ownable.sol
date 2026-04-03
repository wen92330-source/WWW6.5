// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Ownable{
    address private owner;// 只能在合约内部访问
    event OwnershipTransferred (address indexed previousOwner, address indexed newOwner);

    constructor(){
        owner=msg.sender;
        emit OwnershipTransferred (address(0),msg.sender);// 把部署着msgsender视为初始拥有者，仅在部署合约的时候运行一次
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    function ownerAddress()public view returns (address){
        return owner; // 前面的owner是私密的，这个可以查询当前的拥有着
    }
    function transerOwnership(address _newowner) public onlyOwner{
       require(_newowner != address(0), "Invalid address");
        address previous= owner;
        owner=_newowner;
        emit OwnershipTransferred (previous,_newowner);
    
    }
}