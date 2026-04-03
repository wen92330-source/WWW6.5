// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入抽象合约
import "./day14_BaseDepositBox.sol";

// 时间锁保险箱 - 在基础保险箱上增加了时间锁定机制
contract TimeLockedDepositBox is BaseDepositBox {

    // 解锁时间（时间戳）- 在此时间之前，秘密信息不可读取
    uint256 private unlockTime;

    // 构造函数 - 传入锁定时长（秒），计算出解锁时间
    constructor(uint256 lockDuration) {
        unlockTime = block.timestamp + lockDuration; // 当前时间 + 锁定时长 = 解锁时间
    }

    // 时间锁修饰符 - 只有到达解锁时间后才允许执行
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }

    // 返回保险箱类型
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }

    // 重写父合约的 getSecret - 增加时间锁限制
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret();
    }

    // 查询解锁时间（时间戳）
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    // 查询距离解锁还剩多少秒
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0; // 已解锁返回 0
        return unlockTime - block.timestamp;
    }
}