// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";

abstract contract BaseDepositBox is IDepositBox {

    address public owner;
    string internal secret;
    uint256 public depositTime;

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        depositTime = block.timestamp;
    }

    function getSecret() external view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    function getBoxType() external view virtual override returns (string memory);

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }

    function transferOwnership(address _newOwner) external override onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }
}
