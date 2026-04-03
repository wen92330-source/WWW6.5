// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string memory secret) external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}

abstract contract BaseDepositBox is IDepositBox {
    address public owner;
    string public metadata;
    string private secret; // private 变量，外部无法直接访问
    uint256 public depositTime;
    
    constructor(string memory _metadata) {
        owner = msg.sender;
        metadata = _metadata;
        depositTime = block.timestamp;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
    
    function getOwner() external view override returns (address) {
        return owner;
    }
    
    function storeSecret(string memory _secret) external override onlyOwner {
        secret = _secret;
    }
    
    // ✅ 修改点 1: 增加一个 internal 函数来访问 private 变量
    // 这样子类可以通过 super._getSecret() 安全地获取数据
    function _getSecret() internal view returns (string memory) {
        return secret;
    }
    
    // 外部函数调用 internal 辅助函数
    function getSecret() external view virtual override returns (string memory) {
        return _getSecret();
    }
    
    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }
    
    // 抽象函数，子类必须实现
    function getBoxType() external pure virtual override returns (string memory);
}

contract BasicDepositBox is BaseDepositBox {
    constructor(string memory _metadata) BaseDepositBox(_metadata) {}
    
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
    
    // 基础箱子不需要重写 getSecret，直接使用父类逻辑
}

contract TimeLockedDepositBox is BaseDepositBox {
    uint256 public unlockTime;
    
    constructor(string memory _metadata, uint256 _lockDuration) 
        BaseDepositBox(_metadata) 
    {
        unlockTime = block.timestamp + _lockDuration;
    }
    
    modifier timeUnlocked() {
        require(block.timestamp >= unlockTime, "Still locked");
        _;
    }
    
    // ✅ 修改点 2: 重写 getSecret，添加修饰符，并调用 super._getSecret()
    // 而不是 super.getSecret()，避免 external 函数调用的潜在问题
    function getSecret() external view override onlyOwner timeUnlocked returns (string memory) {
        return super._getSecret(); 
    }
    
    function getBoxType() external pure override returns (string memory) {
        return "Time-Locked";
    }
}

contract VaultManager {
    struct BoxInfo {
        address boxAddress;
        string boxType;
        string metadata;
    }
    
    mapping(address => BoxInfo[]) public userBoxes;
    
    function createTimeLockedBox(string memory _metadata, uint256 _lockDuration) 
        external returns (address) 
    {
        TimeLockedDepositBox newBox = new TimeLockedDepositBox(_metadata, _lockDuration);
        newBox.transferOwnership(msg.sender);
        
        userBoxes[msg.sender].push(BoxInfo({
            boxAddress: address(newBox),
            boxType: "Time-Locked",
            metadata: _metadata
        }));
        
        return address(newBox);
    }
    
    function storeSecret(address boxAddress, string memory secret) external {
        IDepositBox(boxAddress).storeSecret(secret);
    }
    
    function getUserBoxCount(address user) external view returns (uint256) {
        return userBoxes[user].length;
    }
    
    function getUserBoxInfo(address user, uint256 index) 
        external view returns (address, string memory, string memory) 
    {
        require(index < userBoxes[user].length, "Index out of bounds");
        BoxInfo memory info = userBoxes[user][index];
        return (info.boxAddress, info.boxType, info.metadata);
    }
}