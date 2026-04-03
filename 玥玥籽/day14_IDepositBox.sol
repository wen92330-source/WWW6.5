// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDepositBox {

    function storeSecret(string calldata _secret) external;

    function getSecret() external view returns (string memory);

    function getBoxType() external view returns (string memory);

    function getOwner() external view returns (address);

    function getDepositTime() external view returns (uint256);

    function transferOwnership(address _newOwner) external;
}
