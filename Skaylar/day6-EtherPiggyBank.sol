// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract EtherPiggyBank{

    // 谁是经理,谁是成员，成员的金钱记账
    address public bankManager;
    address[] members;
    mapping(address => bool) public registeredMembers;
    mapping(address => uint256) balance;

    //经理默认管理者，拥有最高权限
    constructor() {
        bankManager = msg.sender;
        members.push(msg.sender);
    }
    //修正，再次确认权限
    modifier onlyManager(){
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        _;
    }
    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Member not registered");
        _;
    }
    //所有人可查询
    function getMembers() public view returns(address[] memory){
        return members;
    }

    //存钱
    function depositAmountEther() public payable onlyRegisteredMember{
        require(msg.value > 0, "Invalid amount");
        balance[msg.sender] = balance[msg.sender]+msg.value;
    }

    //取钱
    function withdrawAmount(uint256 _amount) public onlyRegisteredMember{
        require(_amount > 0, "Invalid amount");
        require(balance[msg.sender] >= _amount, "Insufficient balance");
        balance[msg.sender] = balance[msg.sender]-_amount;
    }

    //查账户

    function getBalance(address _member) public view returns (uint256){
        require(_member != address(0), "Invalid address");
        return balance[_member];
    }
}