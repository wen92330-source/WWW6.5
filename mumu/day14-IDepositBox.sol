// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDepositBox{
    // 返回存款箱的当前所有者
    function getOwner() external view returns(address);
    // 允许将所有权转移给其他人
    function transferOwnership(address newOwner) external;
    // 一个用户将 密钥 保存在金库中的函数（。。。 这真的安全吗
    function storeSecret(string calldata secret)external;
    // 检索存储的秘密
    function getSecret() external view returns (string memory);
    // 获取存款箱的类型
    function getBoxType() external pure returns (string memory);
    // 获取存款箱的创建时间
    function getDepositTime() external view returns(uint256);
}

/**
Q:
1. external 的作用是啥来着？ 只能从合约外部调用，不能从合约内容调用
    internal 仅允许本合约内调用
    public 所有人都可以调用

2. calldata 修饰符的作用？          
 */