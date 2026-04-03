// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==========================================================
// 1. 父合约：Ownable (直接写在这个文件里，不需要单独建文件)
// ==========================================================
contract Ownable {
    address private owner;
    
    // 事件: 记录所有权转移
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    function ownerAddress() public view returns (address) {
        return owner;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address previousOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
}

// ==========================================================
// 2. 子合约：Day11Masterkey (已修改名字以匹配你的文件名)
//    它继承自上面的 Ownable
// ==========================================================
contract Day11Masterkey is Ownable {
    // 新的事件
    event DepositSuccessful(address indexed account, uint256 value);
    event WithdrawSuccessful(address indexed recipient, uint256 value);
    
    // 查看合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // 存款函数
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH");
        emit DepositSuccessful(msg.sender, msg.value);
    }
    
    // 取款函数：使用了继承来的 onlyOwner 修饰符
    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_to != address(0), "Invalid recipient address");
        require(_amount <= address(this).balance, "Insufficient balance");
        
        // 使用 call 进行转账（更安全）
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer failed");
        
        emit WithdrawSuccessful(_to, _amount);
    }
    
    // 额外功能：提取所有资金
    function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool success, ) = payable(ownerAddress()).call{value: balance}("");
        require(success, "Transfer failed");
        
        emit WithdrawSuccessful(ownerAddress(), balance);
    }
}