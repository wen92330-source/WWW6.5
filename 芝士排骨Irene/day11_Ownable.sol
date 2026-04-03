// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 所有权管理合约 - 提供基础的权限控制功能
contract Ownable {

    // 合约所有者地址（private：仅本合约内部可访问，子合约也无法直接读取）
    address private owner;

    // 所有权转移事件 - 当合约所有者发生变更时触发
    // indexed 关键字：允许前端通过这些字段进行高效的事件过滤和搜索
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // 构造函数 - 合约部署时自动执行，且仅执行一次
    constructor() {
        owner = msg.sender;  // 将部署合约的地址设为所有者
        // address(0) 即零地址（0x000...000），表示"从无到有"的初始转移
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // 仅所有者修饰符 - 限制函数只能由合约所有者调用
    // 其他地址调用带有此修饰符的函数时，交易会被回滚并提示 "Not the owner"
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner"); // 验证调用者身份
        _;  // 占位符，表示继续执行被修饰的函数体
    }

    // 查询合约所有者地址（view 函数，只读不消耗 gas）
    // 因为 owner 是 private 的，所以需要提供一个公开的查询接口
    function ownerAddress() public view returns (address) {
        return owner;
    }

    // 转移所有权 - 将合约控制权交给新地址
    // onlyOwner 修饰符确保只有当前所有者才能执行此操作
    function transferOwnership(address _newOwner) public onlyOwner {
        // 防止将所有权转给零地址（相当于永久放弃控制权，通常是误操作）
        require(_newOwner != address(0), "Invalid address");

        address previousOwner = owner;  // 暂存旧所有者地址，用于事件记录
        owner = _newOwner;              // 更新所有者为新地址

        // 触发所有权转移事件，记录从谁转移到谁
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
}