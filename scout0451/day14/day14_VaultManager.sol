// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";
//统一方式与所有类型存款箱交互的接口
//以相同方式处理每个存款箱，遵循相同规则
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

contract VaultManager{

    mapping(address => address[]) private userDepositBoxes;
    mapping(address => string)private boxNames;//所有者自定义名称，按地址储存

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    function createBasicBox() external returns (address){

        //部署一个新的 BasicDepositBox 合约并将其地址存储在变量 box 中
        BasicDepositBox box = new BasicDepositBox();

        //为当前操作的用户存款箱列表数组末尾新增一个存款箱地址
        userDepositBoxes[msg.sender].push(address(box));

        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    function createPremiumBox() external returns (address){

        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    function createTimeLockedBox(uint256 lockDuration) external returns (address){
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Time Locked");
        return address(box);
    }

    function nameBox(address boxAddress, string memory name ) external{
        
        //将通用地址转换为接口
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");
        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);

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
        
        //获取发送者存储箱列表与数组中的最后一项交换；然后运用.pop()删除最后一项。
        address[] storage boxes = userDepositBoxes[msg.sender];
        for(uint i = 0; i < boxes.length; i++){
            if(boxes[i] == boxAddress){
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }
        userDepositBoxes[newOwner].push(boxAddress);
      
    }

    //仅返回属于特定用户的存款箱地址列表
    function getUserBoxes(address user) external view returns(address[] memory){
        return userDepositBoxes[user];
    }

    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
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
            boxNames[boxAddress]//从 VaultManager 内部的 boxNames 映射中提取自定义名称
        );
    }

}

    


    
