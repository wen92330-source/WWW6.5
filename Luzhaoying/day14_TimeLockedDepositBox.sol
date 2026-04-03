// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseDepositBox} from "./day14_BaseDepositBox.sol";

//添加了定时逻辑来控制秘密何时变得可访问
contract TimeLockedDepositBox is BaseDepositBox {
    //此变量存储了秘密可访问时的时间戳
    uint256 private unlockTime;
    //如果你传入 3600（1 小时），秘密将从部署起锁定 1 小时
    constructor(uint256 lockDuration) {
        unlockTime = block.timestamp + lockDuration;
    }
   //一个自定义修饰符，就像 onlyOwner 一样——但它会检查当前时间是否已超过解锁时间 
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Box is still time-locked");
        _;
    }
   //识别这是哪种存款箱
    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }
   //在解锁时间过去后，只有金库所有者可以查看秘密
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        return super.getSecret();
    }
   //解锁的确切时间
    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }
    //解锁钱的倒计时
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}
