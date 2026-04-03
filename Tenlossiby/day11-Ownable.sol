// SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.20;
// 指定Solidity编译器版本为0.8.20及以上，但小于0.9.0

// 所有权管理合约：实现合约所有权的基本功能，包括所有权转移
// 这是一个常用的基础合约模式，被其他合约继承使用
contract Ownable {
    // 私有状态变量：存储合约所有者的地址
    // 使用private修饰符，只能通过合约内部函数访问
    address private owner;

    // 所有权转移事件：当所有权发生变更时触发此事件
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // 构造函数：在合约部署时执行，将合约部署者(msg.sender)设置为初始所有者
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }


    // onlyOwner修饰器：这是一个访问控制修饰器
    // 确保只有合约所有者才能调用被修饰的函数
    modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can perform this action");
        _;
    }


    // 获取所有者地址函数：这是一个view函数，不修改状态，只读取数据
    function ownerAddress() public view returns (address) {
        return owner;
    }

    // 转移所有权函数：只允许当前所有者调用此函数，会将合约所有权转移给新地址
    function transferOwnership(address _newOwner) public onlyOwner {
       // 检查新地址是否有效，不能是零地址
       require (_newOwner !=address(0), "Invalid address"); 
        // 保存当前所有者地址（用于事件）
        address previous = owner;
        // 更新所有者为新地址
        owner = _newOwner;
        // 触发所有权转移事件，记录这次变更
        emit OwnershipTransferred(previous, _newOwner);

    }
}
