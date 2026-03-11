// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    address public owner;  // 合约所有者   所以说，比如我是这个合约的编写者，那么在我部署的时候，这个时候这个构造函数运行了，那么我这个地址就是owner了
    uint256 public treasureAmount;  // 宝藏总量
    
    // 映射:记录每个地址的提取额度
    mapping(address => uint256) public withdrawalAllowance;  //这里就是其他的的用户，因为地址不一样，则没有权限
    // 映射:记录地址是否已提取
    mapping(address => bool) public hasWithdrawn;      
    
    // 构造函数:部署时设置owner
    constructor() {
        owner = msg.sender;       //这里的意思，就是合约的发起者就是owner
    }
    
    // 修饰符:只允许owner调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");      //这个很精妙，一下子就节约了很多会重复性验证的问题
        _;
    }
    
    // 只有owner能添加宝藏
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;                 //其实也可以改成用户也可以添加，只要得到owner通过
    }
    
    // 只有owner能批准提取额度
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        withdrawalAllowance[recipient] = amount;
    }
    
    // 任何人都可以提取(如果有额度)
    function withdrawTreasure(uint256 amount) public {
        require(amount <= withdrawalAllowance[msg.sender], "Insufficient allowance");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        
        hasWithdrawn[msg.sender] = true;
        withdrawalAllowance[msg.sender] -= amount;
    }
    
    // 只有owner能重置提取状态
    function resetWithdrawalStatus(address user) public onlyOwner {      //问ai说可以用external
        hasWithdrawn[user] = false;
    }
    
    // 只有owner能转移所有权
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    // 只有owner能查看宝藏详情
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }
}
