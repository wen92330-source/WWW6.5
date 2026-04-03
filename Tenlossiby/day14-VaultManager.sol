// SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.0;
// 指定Solidity编译器版本为0.8.0或更高

import "./day14-IDepositBox.sol";
// 导入IDepositBox接口，用于与各种存款盒交互
import "./day14-BasicDepositBox.sol";
// 导入基础版存款盒合约
import "./day14-PremiumDepositBox.sol";
// 导入高级版存款盒合约
import "./day14-TimeLockedDepositBox.sol";
// 导入时间锁定版存款盒合约

contract VaultManager{
// VaultManager（保险箱管理器）合约
// 这是工厂模式+管理器的组合，负责创建和管理用户的各种存款盒

    mapping(address => address[]) private userDepositBoxes;
    // 映射：记录每个用户拥有的所有存款盒地址
    // key: 用户地址，value: 该用户的存款盒地址数组
    
    mapping(address => string)private boxNames;
    // 映射：记录每个存款盒的自定义名称
    // key: 存款盒地址，value: 用户设置的名称

    event BoxCreated(address indexed owner, address indexed boxAdress, string boxType);
    // 存款盒创建事件，当新存款盒被创建时触发
    // indexed字段可以按地址搜索
    
    event BoxNamed(address indexed boxAdress, string name);
    // 存款盒命名事件，当用户给存款盒设置名称时触发

    function createBasicBox() external returns (address){
    // 创建基础版存款盒
    // external表示只能从外部调用
        BasicDepositBox box = new BasicDepositBox();
        // 使用new关键字部署新的BasicDepositBox合约实例
        userDepositBoxes[msg.sender].push(address(box));
        // 将新创建的存款盒地址添加到用户的存款盒列表中
        emit BoxCreated(msg.sender, address(box), "Basic");
        // 触发创建事件，记录创建信息
        return address(box);
        // 返回新创建的存款盒地址
    }

    function createPremiumBox() external returns (address){
    // 创建高级版存款盒
        PremiumDepositBox box = new PremiumDepositBox();
        // 部署新的PremiumDepositBox合约实例
        userDepositBoxes[msg.sender].push(address(box));
        // 添加到用户的存款盒列表
        emit BoxCreated(msg.sender, address(box), "Premium");
        // 触发创建事件
        return address(box);
        // 返回存款盒地址
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address){
    // 创建时间锁定版存款盒
    // lockDuration: 锁定时长（秒）
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        // 部署新的TimeLockedDepositBox，传入锁定时长
        userDepositBoxes[msg.sender].push(address(box));
        // 添加到用户的存款盒列表
        emit BoxCreated(msg.sender, address(box), "Time Locked");
        // 触发创建事件
        return address(box);
        // 返回存款盒地址
    }

    function nameBox(address boxAddress, string memory name ) external{
    // 为存款盒设置名称
    // boxAddress: 存款盒地址，name: 自定义名称
        IDepositBox box = IDepositBox(boxAddress);
        // 将地址转换为IDepositBox接口类型，这样可以调用接口定义的函数
        require(box.getOwner() == msg.sender, "Not the box owner");
        // 检查调用者是否为该存款盒的所有者，只有所有者可以命名
        boxNames[boxAddress] = name;
        // 存储名称到映射中
        emit BoxNamed(boxAddress, name);
        // 触发命名事件

    }

    function storeSecret(address boxAddress, string calldata secret) external{
    // 向指定存款盒存储秘密
    // boxAddress: 目标存款盒地址，secret: 要存储的秘密
        IDepositBox box = IDepositBox(boxAddress);
        // 将地址转换为接口类型
        require(box.getOwner() == msg.sender, "Not the box owner");
        // 检查所有权，只有所有者可以存储秘密
        box.storeSecret(secret);
        // 调用存款盒的storeSecret函数存储秘密
    }

    function transferBoxOwnership(address boxAddress, address newOwner)  external{
    // 转移存款盒所有权
    // boxAddress: 要转移的存款盒地址，newOwner: 新所有者地址
        IDepositBox box = IDepositBox(boxAddress);
        // 将地址转换为接口类型
        require(box.getOwner() == msg.sender, "Not the box owner");
        // 检查调用者是否为当前所有者
        box.transferOwnership(newOwner);
        // 调用存款盒的transferOwnership函数转移所有权
        address[] storage boxes = userDepositBoxes[msg.sender];
        // 获取调用者的存款盒列表（storage表示引用，修改会影响原数据）
        for(uint i = 0; i < boxes.length; i++){
        // 遍历用户的存款盒列表
            boxes[i] = boxes[boxes.length - 1];
            // 将要删除的元素替换为数组最后一个元素
            boxes.pop();
            // 删除最后一个元素（实现数组元素的删除）
            break;
            // 找到并删除后立即退出循环
        }
        userDepositBoxes[newOwner].push(boxAddress);
        // 将存款盒地址添加到新所有者的列表中
      
    }

    function getUserBoxes(address user) external view returns(address[] memory){
    // 获取指定用户的所有存款盒地址
    // view表示不修改状态
        return userDepositBoxes[user];
        // 返回用户的存款盒地址数组
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
    // 获取存款盒的名称
    return boxNames[boxAddress];
    // 从映射中返回名称
}

    function getBoxInfo(address boxAddress)external view returns(
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ){
    // 获取存款盒的完整信息
    // 返回多个值：类型、所有者、存款时间、名称
        IDepositBox box = IDepositBox(boxAddress);
        // 将地址转换为接口类型
        return(
            box.getBoxType(),
            // 获取存款盒类型（Basic/Premium/TimeLocked）
            box.getOwner(),
            // 获取所有者地址
            box.getDepositTime(),
            // 获取创建时间
            boxNames[boxAddress]
            // 获取自定义名称
        );
    }

}
    


    

