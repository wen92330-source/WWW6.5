
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

//interface 接口
//必须实现这些函数
interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}
