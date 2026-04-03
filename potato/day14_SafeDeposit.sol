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
    string private secret;
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
    
    function getOwner() external view override returns (address) {
        return owner;
    }
    
    function storeSecret(string memory _secret) external override onlyOwner {
        secret = _secret;
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        owner = newOwner;
    }

    // 🌟 修复关键：将 external 改为 public。
    // public 满足了接口 external 的要求，同时允许子合约通过 super 内部调用。
    function getSecret() public view virtual override returns (string memory) {
        return secret;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }
    
    function getBoxType() external pure virtual override returns (string memory);
}

contract BasicDepositBox is BaseDepositBox {
    constructor(string memory _metadata) BaseDepositBox(_metadata) {}
    
    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
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
    
    // 🌟 修复关键：父类改成了 public，重写的子类也要改成 public
    function getSecret() public view override onlyOwner timeUnlocked returns (string memory) {
        // 现在这里使用 super 内部调用就不会报错了
        return super.getSecret();
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
}