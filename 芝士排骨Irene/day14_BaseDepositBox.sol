// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入保险箱接口
import "./day14_IDepositBox.sol";

// 保险箱基础抽象合约 - 实现了接口中大部分功能，但留出扩展空间
abstract contract BaseDepositBox is IDepositBox {

    // 状态变量（都是 private，子合约无法直接访问，只能通过函数间接操作）
    address private owner;           // 保险箱所有者
    string private secret;           // 存储的秘密信息
    uint256 private depositTime;     // 秘密存入时间

    // 事件
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); // 所有权转移
    event SecretStored(address indexed owner); // 秘密信息存入（不记录内容本身，保护隐私）

    // 仅所有者可调用的修饰符
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }

    // 构造函数 - 部署者成为保险箱所有者，记录创建时间
    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    // 查询所有者
    // override：实现接口 IDepositBox 中声明的函数
    // public 而非 external：允许子合约内部也能调用此函数
    function getOwner() public view override returns (address) {
        return owner;
    }

    // 转移所有权
    // virtual + override：既实现了接口的要求（override），又允许子合约进一步重写（virtual）
    // 这种组合意味着"我实现了接口，但子合约还可以在我基础上加逻辑"
    function transferOwnership(address newOwner) external virtual override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address"); // 防止转给零地址
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // 存入秘密信息 - 仅所有者可操作
    // calldata：输入参数的只读存储位置，比 memory 省 gas
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;               // 将秘密存储到链上（注意：链上数据并非真正私密，矿工和节点可以读取）
        emit SecretStored(msg.sender);   // 只记录谁存了秘密，不暴露内容
    }

    // 读取秘密信息 - 仅所有者可查看
    // public view：只读且合约内外都能调用
    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    // 查询存入时间
    function getDepositTime() external view virtual override returns (uint256) {
        return depositTime;
    }
}