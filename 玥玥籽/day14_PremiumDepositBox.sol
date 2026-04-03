// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

contract PremiumDepositBox is BaseDepositBox {

    string[] private secrets;

    function storeSecret(string calldata _secret) external override onlyOwner {
        secrets.push(_secret);
        depositTime = block.timestamp;
    }

    function getSecret() external view override onlyOwner returns (string memory) {
        require(secrets.length > 0, "No secrets stored");
        return secrets[secrets.length - 1];
    }

    function getAllSecrets() external view onlyOwner returns (string[] memory) {
        return secrets;
    }

    function getSecretCount() external view returns (uint256) {
        return secrets.length;
    }

    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
}
