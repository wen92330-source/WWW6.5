//SPDX-License-Identifier:MIT

//this is an interface contract
pragma solidity ^0.8.30;

interface IDepositBox{
    function getOwner() external view returns(address);
    function transferOwnership(address newOwner) external;
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns(string memory); //only read
    function getBoxType() external pure returns(string memory); //no read no write
    function getDepositTime() external view returns(uint256);
}