//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import "./day14_BaseDepositBox.sol";

contract premiumDepositBox is BaseDepositBox{
    string private metadat;
    event metadateUpdate(address indexed owner);

    function getBoxType() public pure override returns(string memory){
        return "Premium";
    }

    function setMetadata(string calldata _metadat) external onlyOwner{
        metadat = _metadat;
        emit metadateUpdate(msg.sender);
    }

    function getMetadata() external view onlyOwner returns(string memory){
        return metadat;
    }
}