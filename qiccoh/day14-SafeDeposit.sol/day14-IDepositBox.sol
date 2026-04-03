 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 接口——合约蓝图。
interface IDepositBox {
    function getOwner() external view returns (address);// 返回存款箱的当前所有者
    function transferOwnership(address newOwner) external;//所有权转移
    function storeSecret(string calldata secret) external;//秘密”
    function getSecret() external view returns (string memory);//检索存储的秘密
    function getBoxType() external pure returns (string memory);//存款箱类型
    function getDepositTime() external view returns (uint256);//返回存款箱的创建时间
}

