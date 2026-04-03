// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @author mumu
 * @notice 控制合约
 * @dev 目标：作为母合约提供基本的所有权管理功能，子合约通过继承获得访问控制能力。事件记录所有权变更，增强透明度和安全性。
*/

contract Ownable {
    address public owner;
    // 添加pause功能，允许所有者暂停合约
    bool public paused = false;
    // 添加提取限额:每天最多提取一定数量
    uint256 public dailyWithdrawalLimit; // 每日提取限额

    // 事件：当所有权发生转移时触发
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, uint256 timestamp);
    // 事件：当合约被暂停或恢复时触发
    event Paused(address indexed owner, uint256 timestamp);

    constructor() {
        owner = msg.sender; // 部署合约的地址成为初始所有者
        emit OwnershipTransferred(address(0), owner, block.timestamp); // 记录初始所有权
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Ownable: paused");
        _;
    }

    // 转移所有权给新地址
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner, block.timestamp); // 记录所有权转移
        owner = newOwner;
    }
    
    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function setDailyWithdrawalLimit(uint256 _limit) public onlyOwner {
        dailyWithdrawalLimit = _limit;
    }
}

/**
知识点：
1. 合约继承：
    - 子合约可以继承母合约的状态变量和函数，避免代码重复。
    - 母合约中使用virtual修饰符标记函数，允许子合约重写。 子合约使用override修饰符重写母合约函数，提供特定实现。

拓展：
实现多重签名:需要多个owner确认才能提取
添加提取限额:每天最多提取一定数量

使用OpenZeppelin的AccessControl实现角色管理

 */