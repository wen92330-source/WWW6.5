// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable {
address private owner;
//event 事件只能看不能改 记录所有权从谁转移到谁,有点像弹窗 前旧后新
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

// 部署者上位
constructor() {
    owner = msg.sender;
    emit OwnershipTransferred(address(0), msg.sender);
}


modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
}
// 检查当前所有者
function ownerAddress() public view returns (address) {
    return owner;
}

// 所有者转移所有权给其他人
function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Invalid address");
    address previous = owner;
    owner = _newOwner;
    emit OwnershipTransferred(previous, _newOwner);
}




}