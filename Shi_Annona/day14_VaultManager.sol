//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./day14_IDepositeBox.sol";
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

contract VaultManager {
    mapping(address => address[]) private userPrivateBoxes;
    mapping(address => string) private BoxName;

    event BoxCreated(address indexed owner, address indexed BoxAddress, string boxType);
    event BoxNamed(address indexed BoxAddress,string boxName);

    function createBasicBox()external returns(address){
        basicDepositBox box = new basicDepositBox();
        userPrivateBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender,address(box),"Basic");
        return address(box);
    }

    function createPremiumBox()external returns(address){
        premiumDepositBox box = new premiumDepositBox();
        userPrivateBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender,address(box),"Basic");
        return address(box);
    }

    function createPremiumBox(uint256 _lockDuration)external returns(address){
        timeLockedDepositBox box = new timeLockedDepositBox(_lockDuration);
        userPrivateBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender,address(box),"Time Locked");
        return address(box);
    }

    function nameBox(address _boxAddress, string memory _boxName) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(msg.sender == box.getOwner(),"Not owner");
        BoxName[_boxAddress] = _boxName;
        emit BoxNamed(_boxAddress,_boxName);
    }

    function storeSecret(address _boxAddress, string calldata _secret) external {
        IDepositBox box = IDepositBox(_boxAddress);
        require(msg.sender == box.getOwner(),"Not owner");
        box.storeSecret(_secret);
        
    }

    function transferBoxOwner(address _boxAddress,address _newOwner) external{
        IDepositBox box = IDepositBox(_boxAddress);
        require(msg.sender == box.getOwner(),"Not owner");
        box.transferOwnership(_newOwner);
        address[] storage boxes = userPrivateBoxes[msg.sender];//attention
        for(uint256 i = 0; i<boxes.length; i++){
            if(boxes[i]==_boxAddress){
                boxes[i] = boxes[boxes.length-1];
                boxes.pop();
                break;
            }
            
        }
        userPrivateBoxes[_newOwner].push(_boxAddress);

    }

    function getUserBoxes(address _user) external view returns(address[] memory){
        return userPrivateBoxes[_user];
    }

    function getBoxName(address _boxAddress) external view returns(string memory){
        return BoxName[_boxAddress];
    }

    function getBoxInfo(address _boxAddress)external view returns(
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ){
        IDepositBox box = IDepositBox(_boxAddress);
        return(
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            BoxName[_boxAddress]
        );
    }

    
}