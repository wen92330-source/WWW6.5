// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//接口定义类型
import "./day14-IDepositBox.sol";
//基础实现
import "./day14-BasicDepositBox.sol";
// 存储箱类型
import "./day14-PremiumDepositBox.sol";
// 时间锁
import "./day14-TimeLockedDepositBox.sol";

contract VaultManager {
    // 用户的地址映射到其拥有的所有存款箱（作为合约地址）???
    mapping(address => address[]) private userDepositBoxes;
    // 为每个邮箱分配自定义名称
    mapping(address => string) private boxNames;
// 每次用户创建新存款箱时触发
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
//    存储箱自定义
    event BoxNamed(address indexed boxAddress, string name);
// 用户为自己“铸造”一个新数字存款箱的方式
    function createBasicBox() external returns (address) {
        // 创建对象
        BasicDepositBox box = new BasicDepositBox();
        // 将新存款箱添加到发送者拥有的存款箱列表中
        userDepositBoxes[msg.sender].push(address(box));
        // 触发一个事件，以便 UI 可以跟踪此创建
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }
// 存储额外元数据??
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        // 使用 address(box) 将合约转换为其地址
        userDepositBoxes[msg.sender].push(address(box));
        // 创建存款箱的用\新合约的地址\哪种类型的存款箱
        emit BoxCreated(msg.sender, address(box), "Premium");
        // 返回新创建的存款箱的地址
        return address(box);
    }
// 时间锁存款箱
// 在此期间，所有者可以存储秘密，但他们在锁定到期之前无法查看它
// - 时间胶囊
// - 延迟显示消息
// - 未来的礼物或承诺
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        //  将存款箱保存在用户账户下
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }
// 重命名箱子
    function nameBox(address boxAddress, string calldata name) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }
// 存储秘密
    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret);
    }
// 移交存储箱???
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        // 接口转换和所有权检查
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(newOwner);

        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        userDepositBoxes[newOwner].push(boxAddress);
    }
// 查看所有存储箱
    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }
// 读取存款箱的自定义名称
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }
// 一次调用获取完整信息
    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}
