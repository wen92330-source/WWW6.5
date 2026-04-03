//SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;
import "./day14_BaseDepositBox.sol";

contract timeLockedDepositBox is BaseDepositBox{
    
    uint256 private unlockTime;
    
    constructor(uint256 lockDuration){
        unlockTime = block.timestamp+lockDuration;
    }

    modifier timeUnlocked(){
        require(block.timestamp >= unlockTime,"Box is still locked");
        _;
    }

    function getBoxType() public pure override returns(string memory){
        return "TimeLocked ";
    }

    function getSecret() public view override onlyOwner timeUnlocked returns(string memory){
        return super.getSecret();
    }

    function getUnlockTime() external view returns(uint256){
        return unlockTime;
    }

    function getRemainingLockTime() external view returns(uint256){
        return unlockTime - block.timestamp;
    }
}