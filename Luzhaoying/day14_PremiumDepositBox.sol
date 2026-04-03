// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseDepositBox} from "./day14_BaseDepositBox.sol";
//现在我们给存款箱**一些额外的东西**：一个叫做 `metadata` 的数据片段
//可以将其视为一个个性化的标签、标记或信息字段，所有者可以设置它。它可以描述秘密的内容、应该在何时访问，或者任何你想要附加的注释
contract PremiumDepositBox is BaseDepositBox {
    //引入了一个新的状态变量，称为metadata
    string private metadata;
    event MetadataUpdated(address indexed owner);
    //识别金库类型
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
    //为所有者提供了一种可以将注释、类别或标签附加到他们的金库上的方法
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }
    //允许所有者检索他们之前存储的元数据
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}
