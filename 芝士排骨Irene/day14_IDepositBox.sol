//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

// 保险箱接口 - 定义了保险箱合约必须实现的所有功能
interface IDepositBox {

    // 查询保险箱的所有者地址
    // external：只能从合约外部调用（比其他合约或前端调用）
    // view：只读函数，不修改状态
    function getOwner() external view returns (address);

    // 转移保险箱的所有权给新地址
    // 实现时通常会加权限检查，确保只有当前所有者能调用
    function transferOwnership(address newOwner) external;

    // 存入秘密信息（比如密码、助记词备注等）
    // calldata：比 memory 更省 gas 的数据位置，适用于 external 函数的只读参数
    // 数据直接从交易的 calldata 中读取，不会复制到内存
    function storeSecret(string calldata secret) external;

    // 读取保险箱中存储的秘密信息
    // 返回值用 memory 是因为 string 是动态类型，返回时需要在内存中构造
    // 实现时通常会限制只有所有者才能查看
    function getSecret() external view returns (string memory);

    // 获取保险箱类型（如 "Basic"、"Premium" 等）
    // pure：既不读取也不修改链上状态，返回值完全由函数内部逻辑决定
    // 通常直接 return 一个硬编码的字符串
    function getBoxType() external pure returns (string memory);

    // 查询秘密信息的存入时间（时间戳）
    function getDepositTime() external view returns (uint256);
}