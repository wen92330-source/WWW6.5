// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14-IDepositBox.sol";
// 核心:特定类型的存款箱——如基础型、高级型和时间锁型
// abstract is-->抽象合约,接口,其他合约的模板或地基,里面没有把接口里规定的所有功能都写完整
// 只处理通用逻辑
abstract contract BaseDepositBox is IDepositBox {
    address private owner;
    string private secret;
    uint256 private depositTime;
// 当有人转移存款箱的所有权时触发
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
//   当存储新秘密时触发
    event SecretStored(address indexed owner);
// 访问限制
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the box owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }
// getter 函数——并且是 IDepositBox 接口所要求的  override
    function getOwner() public view override returns (address) {
        return owner;
    }
// 所有权转
    function transferOwnership(address newOwner) external virtual  override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
//  将所有者将字符串存储在金库中
//  calldata，因为在传递字符串参数时，它在 gas 上更便宜
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        emit SecretStored(msg.sender);
    }
// 此函数允许所有者检索存储的秘密
    function getSecret() public view virtual override onlyOwner returns (string memory) {
        return secret;
    }
// 返回金库部署的时间
    function getDepositTime() external view virtual  override returns (uint256) {
        return depositTime;
    }
}
