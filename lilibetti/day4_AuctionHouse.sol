// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {

    //记录地址
    address public owner;
    // 记录拍卖物品的名称
    string public item;
    // 记录拍卖截止时间
    uint public auctionEndTime;
    // 记录当前出价最高的人的地址（保密）
    address private highestBidder;
    // 记录当前最高出价金额
    uint private highestBid;
    // 记录拍卖是否已结束的开关，false=进行中，true=已结束
    bool public ended;

    // 一个记账本：记录每个地址（每个人）总共出了多少钱
    mapping(address => uint) public bids;

    //一个签名表：用数组记录所有参与出价的人的地址列表
    address[] public bidders;

    //合约被创建时自动运行一次
    constructor(string memory _item, uint _biddingTime) {
        // 把部署合约的人（msg.sender）设为owner
        owner = msg.sender;
        //记录产品名称
        item = _item;
        
        // 拍卖截止时间 = 当前区块链时间 + 拍卖持续秒数
        auctionEndTime = block.timestamp + _biddingTime;
    }
    // 定义出价，只能从合约外部调用（别人来调用）
    function bid(uint amount) external {
        // 检查：当前时间必须小于截止时间，否则报错 "Auction ended"（拍卖已结束）
        require(block.timestamp < auctionEndTime, "Auction ended");

        // 检查：出价必须大于当前最高价，否则报错 
        require(amount > highestBid, "Bid too low");
    
        // 如果这个人之前没有出过价（记账本里金额是0）
        if (bids[msg.sender] == 0) {
            // 把这个人的地址加入签到表（说明是第一次来参与）
            bidders.push(msg.sender);
            
        }
        // 在记账本里，把这个人的总出价金额加上本次出价
        bids[msg.sender] += amount;
        
        // 如果这个人的总出价超过了当前最高价
        if (bids[msg.sender] > highestBid) {
            // 更新最高出价为这个人的总出价
            highestBid = bids[msg.sender];
            // 更新最高出价者为这个人
            highestBidder = msg.sender;
           
        }
    }
    // 定义结束拍卖
    function endAuction() external {
        // 检查：拍卖还没有结束过，防止owner重复点击结束
        require(!ended, "Auction already ended");

        // 检查：当前时间必须已经过了截止时间
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        
        // 检查：调用这个函数的人必须是owner
        require(msg.sender == owner, "Only owner can end");
        
        // 把开关设为 true，标记拍卖已经结束
        ended = true;
        
    }
    // 定义查看赢家
    function getWinner() external view returns (address, uint) {
        
        // 检查：拍卖必须已经结束了才能查看赢家
        require(ended, "Auction not ended");
       
        // 返回最高出价者的地址和最高出价金额
        return (highestBidder, highestBid);

    }
    // 定义查看所有出价者
    function getAllBidders() external view returns (address[] memory) {

        // 返回所有参与出价的人的地址列表
        return bidders;
    }
}
