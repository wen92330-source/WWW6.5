// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//通过接口实现标准化，借助抽象基础合约达成代码复用，并在其上构建清晰模块化的业务合约。
import {IDepositBox} from "./day14_IDepositBox.sol";
import {BasicDepositBox} from "./day14_BasicDepositBox.sol";
import {PremiumDepositBox} from "./day14_PremiumDepositBox.sol";
import {TimeLockedDepositBox} from "./day14_TimeLockedDepositBox.sol";

//这个VaultManager合约充当控制中心，供用户创建、命名、管理和与他们的存款箱交互。
//可以将其视为你的**金库应用后端**：
//- 它允许用户创建不同类型的存款箱（基础型、高级型、时间锁型）。
//- 它跟踪哪个用户拥有哪个存款箱。
//- 它强制执行所有权规则。
//- 它提供命名和检索存款箱信息的辅助函数
contract VaultManager {

    //将用户的地址映射到其拥有的所有存款箱（作为合约地址）
    mapping(address => address[]) private userDepositBoxes;
    //允许用户为每个邮箱分配自定义名称。按邮箱地址存储
    mapping(address => string) private boxNames;
    //每次用户创建新存款箱时触发
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    //当用户给他们的存款箱自定义名称时触发
    event BoxNamed(address indexed boxAddress, string name);
    
    //基础存款箱
    function createBasicBox() external returns (address) {
        //这行代码部署一个新的 BasicDepositBox 合约并将其地址存储在变量 box 中
        BasicDepositBox box = new BasicDepositBox();
        //将新存款箱添加到发送者拥有的存款箱列表中
        userDepositBoxes[msg.sender].push(address(box));
        //触发一个事件，以便 UI 可以跟踪此创建
        emit BoxCreated(msg.sender, address(box), "Basic");
        //返回新存款箱的地址以便于访问
        return address(box);
    }
    //高级型存储箱：存储额外元数据的存款箱
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }
    //时间锁存款箱
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }
    
    function nameBox(address boxAddress, string calldata name) external {
        //将通用地址转换为接口,这让我们可以在存款箱上调用 getOwner()，而无需知道它是什么类型
        IDepositBox box = IDepositBox(boxAddress);
        //确保只有合法的所有者可以重命名存款箱
        require(box.getOwner() == msg.sender, "Not the box owner");
        //重命名存款箱
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    function storeSecret(address boxAddress, string calldata secret) external {
        //调用接口中的 storeSecret() 函数，此函数的具体逻辑由每类存款箱自行实现
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret);
    }
    //将所有权转移给其他人
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        //接口转换和所有权检查
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        //告知存储箱合约，让其更新自己的内部 owner 状态
        box.transferOwnership(newOwner);
        //从发送者列表中移除存储箱
        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }
        //将存储箱添加到新所有者的列表
        userDepositBoxes[newOwner].push(boxAddress);
    }
    //查看用户拥有的所有存储箱
    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }
    //读取存款箱的自定义名称
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }
    //一次调用获取完整信息
    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        //接口转换
        IDepositBox box = IDepositBox(boxAddress);
        //返回所有关键细节
        return (
            //调用子合约的实现，并返回如下字符串 
            box.getBoxType(),
            //返回存款箱的当前所有者
            box.getOwner(),
            //返回存款箱的当前所有者
            box.getDepositTime(),
            //从 VaultManager 内部的 boxNames 映射中提取自定义名称（如果有）
            boxNames[boxAddress]
        );
    }
}
