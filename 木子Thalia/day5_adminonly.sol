// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdmminOnly {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TreasureAdded(uint256 amount);
    event WithdrawalApproved(address indexed recipient, uint256 amount);
    event TreasureWithdrawn(address indexed recipient, uint256 amount);
    event WithdrawalStatusReset(address indexed user);
    event CooldownUpdated(uint256 newCooldownDuration);


    //State variables
    address public owner;

    constructor() {
        owner = msg.sender; //谁部署了这个合约，谁就是合约的拥有者。

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only the owner can perform this action.");
        _;
    }

    uint256 public treasureAmount;

    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
        emit TreasureAdded(amount);
    }

    mapping(address => uint256) public withdrawalAllowance;
    mapping(address => uint256) public maxWithdrawalLimit;

    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Insufficient treasure amount.");
        withdrawalAllowance[recipient] = amount;
        emit WithdrawalApproved(recipient, amount);
    }     

    function setMaxWithdrawalLimit(address user, uint256 limit) public onlyOwner {
        maxWithdrawalLimit[user] = limit;
    }

    mapping(address => bool) public hasWithdrawn;
    uint256 public constant COOLDOWN_DURATION = 5 minutes;
    mapping(address => uint256) private lastWithdrawalTimes;

    function withdrawTreasure(uint256 amount) public {
        //拥有者自己取宝
        if (msg.sender == owner) {
            require(amount <= treasureAmount, "Not enough treasure avliable for this action.");
            treasureAmount -= amount;
            return;
        }
        //普通用户取宝
        uint256 allowance = withdrawalAllowance[msg.sender];

        require(allowance > 0, "You don't have any treasure allowance.");
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure.");
        require(allowance <= treasureAmount, "Not enough treasure in the chest.");
        require(block.timestamp >= lastWithdrawalTimes[msg.sender] + COOLDOWN_DURATION, "You must wait before withdrawing again.");
        require(allowance <= maxWithdrawalLimit[msg.sender], "Withdrawal amount exceeds your limit.");

        hasWithdrawn[msg.sender] = true;
        treasureAmount -= allowance;
        withdrawalAllowance[msg.sender] = 0;
        lastWithdrawalTimes[msg.sender] = block.timestamp;
        emit TreasureWithdrawn(msg.sender, allowance);
 
    }

    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;
        emit WithdrawalStatusReset(user);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }

    // 用户查询函数
    function getWithDrawalStatus() public view returns (bool _isApproved, bool _hasWithdrawn, uint256 _allowance) {
        _isApproved = withdrawalAllowance[msg.sender] > 0;
        _hasWithdrawn = hasWithdrawn[msg.sender];
        _allowance = withdrawalAllowance[msg.sender];
    }

}

