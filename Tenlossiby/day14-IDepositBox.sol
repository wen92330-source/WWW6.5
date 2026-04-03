//SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本为0.8.0或更高

interface IDepositBox {
// 定义一个名为IDepositBox的接口
// 接口是一种规范，只声明函数签名而不实现函数体
// 任何实现此接口的合约都必须提供这些函数的具体实现

    function getOwner() external view returns(address);
    // 获取合约所有者的地址
    // external: 只能从外部调用
    // view: 不修改状态，只读取数据
    // returns(address): 返回地址类型

    function transferOwnership(address newOwner)external;
    // 转移合约所有权给新地址
    // external: 只能从外部调用
    // 参数newOwner: 新所有者的地址

    function storeSecret(string calldata secret)external;
    // 存储秘密信息
    // external: 只能从外部调用
    // calldata: 数据存储在调用数据中，比memory更省gas
    // 参数secret: 要存储的私密字符串

    function getSecret() external view returns (string memory);
    // 获取存储的秘密信息
    // external: 只能从外部调用
    // view: 不修改状态
    // returns(string memory): 返回字符串类型

    function getBoxType() external pure returns(string memory);
    // 获取存款盒的类型标识
    // external: 只能从外部调用
    // pure: 不读取也不修改状态，仅根据输入计算输出
    // returns(string memory): 返回类型名称字符串，如"Basic"

    function getDepositTime() external view returns(uint256);
    // 获取存款/合约创建的时间戳
    // external: 只能从外部调用
    // view: 不修改状态
    // returns(uint256): 返回无符号整数（Unix时间戳）
}
