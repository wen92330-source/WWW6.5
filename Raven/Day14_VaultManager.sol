// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day14_IDepositBox.sol";
import "./Day14_BasicDepositBox.sol";
import "./Day14_PremiumDepositBox.sol";
import "./Day14_TimeLockedDepositBox.sol";

contract VaultManager {
	mapping(address => address[]) private userDepositBox;
	mapping(address => string) private boxName;
	event BoxCreate(address indexed owner, address indexed boxAddress, string boxType);
	event BoxName(address indexed boxAddress, string name);
	function createBasicBox() external returns (address) {
		BasicDepositBox box = new BasicDepositBox();
		userDepositBox[msg.sender].push(address(box));
		emit BoxCreate(msg.sender, address(box), "Basic");
		return (address(box));
	}
	function createPremiumBox() external returns (address) {
		PremiumDepositBox box = new PremiumDepositBox();
		userDepositBox[msg.sender].push(address(box));
		emit BoxCreate(msg.sender, address(box), "Premium");
		return (address(box));
	}
	function createTimeLockedBox(uint256 duration) external returns (address) {
		TimeLockedDepositBox box = new TimeLockedDepositBox(duration);
		userDepositBox[msg.sender].push(address(box));
		emit BoxCreate(msg.sender, address(box), "TimeLocked");
		return (address(box));
	}
	 function nameBox(address boxAddress, string memory name ) external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        boxName[boxAddress] = name;
        emit BoxName(boxAddress, name);
    }
    function storeSecret(address boxAddress, string calldata secret) external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.storeSecret(secret);
    }
    function transferBoxOwnership(address boxAddress, address newOwner)  external{
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        box.transferOwnership(newOwner);
        address[] storage boxes = userDepositBox[msg.sender];
        for(uint i = 0; i < boxes.length; i++){
            if (boxes[i] == boxAddress) {
				boxes[i] = boxes[boxes.length - 1];
            	boxes.pop();
            	break;
			}
        }
        userDepositBox[newOwner].push(boxAddress);
    }
    function getUserBoxes(address user) external view returns(address[] memory){
        return userDepositBox[user];
    }
    function getBoxName(address boxAddress) external view returns (string memory) {
    	return boxName[boxAddress];
	}
    function getBoxInfo(address boxAddress)external view returns(
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ){
        IDepositBox box = IDepositBox(boxAddress);
        return(
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxName[boxAddress]
        );
    }
}