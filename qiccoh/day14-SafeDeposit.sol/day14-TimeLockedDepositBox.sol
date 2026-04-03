// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-BaseDepositBox.sol";
// 时间锁
contract TimeLockedDepositBox is BaseDepositBox {
    uint256 private unlockTime;
// 设置锁定时间
    constructor(uint256 lockDuration) {
        unlockTime = block.timestamp + lockDuration;
    }
// 检查当前时间是否已超过解锁时间,受时间锁保护的函数用这个修饰符
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }
// 返回这个存款箱的类别
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }
// 重写getSecret,两个访问限制:onlyOwner timeUnlocked
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
    //    super.getSecret() 从基础合约中检索实际秘密。super->母合约
        return super.getSecret();
    }

    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }
// 倒计时
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        
        return unlockTime - block.timestamp;
    }
}
