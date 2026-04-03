//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable{
    address private owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;

    }
    
    modifier onlyOwner() virtual{
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");
        _;
    }
   
   function ownerAddress() public view returns (address){
     return owner;
   }

   function transferOwnership(address _newOwner) virtual public onlyOwner {
     require(_newOwner != address(0), "Invalid address: New owner cannot be the zero address");
     address previous = owner;
     owner = _newOwner;
     emit OwnershipTransferred(previous, _newOwner);
   }
   
}