//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./day14_IDepositeBox.sol";

abstract contract BaseDepositBox is IDepositBox{
    address private owner;
    string private secret;
    uint256 private depositTime;

    event ownershipTransfer(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
    //attention:don't forget the key word [override]
    function getOwner() public view override returns(address){
        return owner;
    }

    function transferOwnership(address _newOwner) external virtual override onlyOwner{
        require(_newOwner != address(0),"Invalid owner");
        emit ownershipTransfer(owner,_newOwner);
        owner = _newOwner;
    }

    function storeSecret(string calldata _secret) external virtual override onlyOwner{
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    function getSecret() public view virtual override onlyOwner returns(string memory){
        return secret;
    }

    function getDepositTime() external view virtual override onlyOwner returns(uint256){
        return depositTime;
    }



}