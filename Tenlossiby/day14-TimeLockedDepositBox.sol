//SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本为0.8.0或更高

import "./day14-BaseDepositBox.sol";
// 导入BaseDepositBox抽象合约，本合约将继承其功能

contract TimeLockedDepositBox is BaseDepositBox{
// 定义TimeLockedDepositBox合约，继承自BaseDepositBox
// TimeLocked（时间锁定版）增加了时间锁功能，在锁定期内无法取出秘密

    uint256 private unlockTime;
    // 私有变量：存储解锁时间戳（Unix时间）
    // 只有到达这个时间后才能获取秘密

    constructor(uint256 lockDuration){
    // 构造函数，部署合约时执行
    // 参数lockDuration: 锁定时长（单位：秒）
        unlockTime = block.timestamp + lockDuration;
        // 计算解锁时间 = 当前区块时间 + 锁定时长
    }

    modifier timeUnlocked(){
    // 定义时间锁修饰器，用于限制函数只能在解锁后调用
        require(block.timestamp >= unlockTime, "Box is still locked");
        // 检查当前时间是否已超过解锁时间，如果未到则报错
        _;
        // 下划线表示被修饰函数的代码将在这里执行
    }

    function getBoxType() external pure override returns (string memory) {
    // 获取存款盒类型函数，重写父合约的虚函数
    // external表示只能从外部调用
    // pure表示不读取也不修改状态
    // override表示重写父合约中的函数
    return "TimeLocked";
    // 返回"TimeLocked"表示这是时间锁定版存款盒
}
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
    // 获取秘密函数，重写父合约的实现
    // 使用了两个修饰器：onlyOwner（只有所有者）和 timeUnlocked（已解锁）
    // 必须同时满足两个条件才能获取秘密
    return super.getSecret();
    // 调用父合约的getSecret函数获取秘密
    // super关键字用于访问父合约的函数
}

    function getUnlockTime() external view returns(uint256){
    // 获取解锁时间函数
    // external表示只能从外部调用
    // view表示不修改状态
        return unlockTime;
        // 返回解锁时间戳
    }

    function getRemainingLockTime() external view returns(uint256){
    // 获取剩余锁定时间函数
    // external表示只能从外部调用
    // view表示不修改状态
        if(block.timestamp >= unlockTime) return 0;
        // 如果当前时间已超过解锁时间，返回0（已解锁）
        return unlockTime - block.timestamp;
        // 否则返回剩余秒数
    }



}
