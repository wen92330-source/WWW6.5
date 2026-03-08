// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {
    // State variables设置变量
    address public owner;
    // 所有者所有人都可以查到
    uint256 public treasureAmount;
    //整数
    mapping(address => uint256) public withdrawalAllowance;
    //映射，给每个地址设置一定的可以提取的额度
    mapping(address => bool) public hasWithdrawn;
    
    // Constructor sets the contract creator as the owner
    constructor() {
        owner = msg.sender;
    }
    //声明变量owner是msg.sender这个全局变量（也是当前调用该函数的地址）谁部署了这个合约，谁就是这个合约的拥有者，就会在接下来的合约中有特殊权限
    // Modifier for owner-only functions，通过修饰符实现可复用的访问控制
    modifier onlyOwner() {
        // modifier是修饰符，可以创建可以附加到函数中的可复用的小型权限检查逻辑。
        //会检查调用者是否是拥有者，如果不是，就不会执行函数
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");
        //以下这个符号是一个占位符，表示权限检查之后的函数主体将会被插入的位置
        //这样就不需要在每个函数当中都写require是owner才可以使用
        _;
    }
    //用unit256类型的变量储存了一个宝物？
    //只有拥有者可以调用 addTreasure() 函数。
    //当函数被调用时，宝箱中的数量会增加指定的数额。
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }
    
    // Only the owner can approve withdrawals
    //授权他人取宝物，每个地址能取的宝物是固定的数量，取多了就会显示不够
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Not enough treasure available");
        withdrawalAllowance[recipient] = amount;
    }
    // Anyone can attempt to withdraw, but only those with allowance will succeed
    function withdrawTreasure(uint256 amount) public {
//如果是拥有者取用
        if(msg.sender == owner){
            require(amount <= treasureAmount, "Not enough treasury available for this action.");
            treasureAmount-= amount;
//这里return是什么作用？
            return;
        }//以下是如果不是拥有者，ifA，否则：。
        uint256 allowance = withdrawalAllowance[msg.sender];
        
        // Check if user has an allowance and hasn't withdrawn yet
        require(allowance > 0, "You don't have any treasure allowance");//额度大于0才能取
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure");//从来没有取过才可以取
        require(allowance <= treasureAmount, "Not enough treasure in the chest");//额度小于宝箱所剩余的才可以取（其实只要amount小于不就可以了吗？
        require(allowance >= amount, "Cannot withdraw more than you are allowed"); // condition to check if user is withdrawing more than allowed
        
        // Mark as withdrawn and reduce treasure
        hasWithdrawn[msg.sender] = true;
        treasureAmount -= allowance;
        withdrawalAllowance[msg.sender] = 0;
        
    }
    
    // Only the owner can reset someone's withdrawal status
    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;
    }
    
    // Only the owner can transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
    
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;
    }
}
