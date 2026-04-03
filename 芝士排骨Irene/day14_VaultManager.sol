// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入接口和所有保险箱合约
import "./day14_IDepositBox.sol";
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

// 保险箱管理合约 - 统一管理所有类型保险箱的创建、命名、操作
contract VaultManager {

    // 用户地址 => 该用户拥有的所有保险箱地址列表
    mapping(address => address[]) private userDepositBoxes;

    // 保险箱地址 => 用户给保险箱起的名字（可选，方便识别）
    mapping(address => string) private boxNames;

    // 事件
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType); // 保险箱创建
    event BoxNamed(address indexed boxAddress, string name); // 保险箱命名

    // 工厂函数 - 创建基础保险箱
    // new BasicDepositBox()：在链上部署一个全新的 BasicDepositBox 合约实例
    // 每次调用都会生成一个独立的合约地址，互不干扰
    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box)); // 记录到用户的保险箱列表
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box); // 返回新建保险箱的合约地址
    }

    // 工厂函数 - 创建高级保险箱
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    // 工厂函数 - 创建时间锁保险箱，需传入锁定时长（秒）
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    // 给保险箱命名 - 方便用户区分自己的多个保险箱
    function nameBox(address boxAddress, string calldata name) external {
        // 通过接口类型访问保险箱 - 这就是接口的价值：
        // 不管传入的是 Basic、Premium 还是 TimeLocked，都用统一的 IDepositBox 来操作
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner"); // 验证调用者是保险箱所有者
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    // 通过管理合约向保险箱存入秘密
    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.storeSecret(secret);
    }

    // 转移保险箱所有权 - 同时更新管理合约中的记录
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        // 调用保险箱自身的所有权转移函数
        box.transferOwnership(newOwner);

        // 从原所有者的列表中移除该保险箱
        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1]; // 用末尾元素覆盖
                boxes.pop();                          // 删除末尾
                break;
            }
        }

        // 添加到新所有者的列表中
        userDepositBoxes[newOwner].push(boxAddress);
    }

    // 查询函数 - 获取某用户拥有的所有保险箱地址
    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    // 查询函数 - 获取保险箱的名字
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    // 查询函数 - 一次性获取保险箱的综合信息
    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),        // 返回 "Basic"、"Premium" 或 "TimeLocked"
            box.getOwner(),          // 保险箱所有者地址
            box.getDepositTime(),    // 创建时间
            boxNames[boxAddress]     // 用户给保险箱起的名字
        );
    }
}