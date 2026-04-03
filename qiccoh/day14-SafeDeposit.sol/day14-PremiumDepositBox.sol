// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {
    string private metadata;
// 更新元数据
    event MetadataUpdated(address indexed owner);
// 识别金库类型
    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
// 合约所有者给金库打标签
    function setMetadata(string calldata _metadata) external onlyOwner {
        metadata = _metadata;
        emit MetadataUpdated(msg.sender);
    }
// 所有者检索元数据
    function getMetadata() external view onlyOwner returns (string memory) {
        return metadata;
    }
}
