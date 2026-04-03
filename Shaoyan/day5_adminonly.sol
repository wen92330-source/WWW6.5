// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    // === 状态变量 ===
    address public owner;
    uint256 public treasureAmount;
    mapping(address => uint256) public withdrawalAllowance;
    mapping(address => bool) public hasWithdrawn;

    // === 修饰器 ===
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // === 初始化 (构造函数) ===
    constructor() {
        owner = msg.sender;
    }

    // === 管理员功能 ===
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }

    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Not enough treasure available");
        withdrawalAllowance[recipient] = amount;
    }

    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }

    // === 用户功能 ===
    function withdrawTreasure(uint256 amount) public {
        if (msg.sender == owner) {
            require(amount <= treasureAmount, "Not enough treasury available");
            treasureAmount -= amount;
        } else {
            require(withdrawalAllowance[msg.sender] > 0, "You don't have any treasure allowance");
            require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure");
            require(amount <= treasureAmount, "Not enough treasure in the chest");
            require(amount <= withdrawalAllowance[msg.sender], "Cannot withdraw more than you are allowed");

            hasWithdrawn[msg.sender] = true;
            treasureAmount -= amount;
            withdrawalAllowance[msg.sender] -= amount;
        }
    }
}
