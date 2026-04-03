// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入抽象合约
import "./day14_BaseDepositBox.sol";

// 高级保险箱合约 - 在基础保险箱的基础上增加了"附加信息"功能
contract PremiumDepositBox is BaseDepositBox {

    // 额外的状态变量 - 存储附加的元数据信息
    // 可以用来存备注、标签、描述等补充信息
    // private：仅本合约内部可访问，需通过下面的 getter 函数来读取
    string private metadata;

    // 元数据更新事件（同样不记录内容，只记录谁更新了）
    event MetadataUpdated(address indexed owner);

    // 返回保险箱类型为 "Premium"
    // 与 BasicDepositBox 唯一的区别：返回值不同
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }

    // 设置元数据 - Premium 独有的功能，Basic 版没有
    // onlyOwner：继承自 BaseDepositBox 的修饰符，仅所有者可操作
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }

    // 读取元数据 - 仅所有者可查看
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}