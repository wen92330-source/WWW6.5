// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ✅ 关键：导入路径必须与新文件名完全一致
import "./Day13_SimpleErc20.sol";

/**
 * @title Day13_PreorderToken
 * @dev 预售合约，继承自 Day13_SimpleErc20
 *      功能：在特定时间内出售代币，结束后解锁转账
 */
contract Day13_PreorderToken is Day13_SimpleErc20 {
    uint256 public tokenPrice;      // 代币价格 (wei)
    uint256 public saleStartTime;   // 销售开始时间
    uint256 public saleEndTime;     // 销售结束时间
    uint256 public minPurchase;     // 最小购买金额
    uint256 public maxPurchase;     // 最大购买金额
    uint256 public totalRaised;     // 已筹集资金
    address public projectOwner;    // 项目方地址
    bool public finalized = false;  // 是否已结算
    bool private initialTransferDone = false; // 初始代币是否已转入合约
    
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);
    
    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleStartTime,
        uint256 _saleDuration,
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) Day13_SimpleErc20(_initialSupply) {
        tokenPrice = _tokenPrice;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleStartTime + _saleDuration;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = msg.sender;
        
        // 构造函数执行时，代币在父合约构造函数中已发给 msg.sender (即项目方)
        // 这里需要将代币从项目方转移到本合约，以便出售
        // 注意：此时 msg.sender 是部署者 (projectOwner)
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }
    
    // 检查销售是否活跃
    function isSaleActive() public view returns (bool) {
        return block.timestamp >= saleStartTime && 
               block.timestamp <= saleEndTime && 
               !finalized;
    }
    
    // 购买代币函数
    function buyTokens() public payable {
        require(isSaleActive(), "Sale not active");
        require(msg.value >= minPurchase && msg.value <= maxPurchase, "Invalid purchase amount");
        
        // 计算应得代币数量
        uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Insufficient tokens in contract");
        
        // 执行转账
        _transfer(address(this), msg.sender, tokenAmount);
        totalRaised += msg.value;
        
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
    
    /**
     * @dev 重写 transfer 函数
     * 在销售结束并结算前，禁止普通用户转账 (防止预售期间抛售)
     */
    function transfer(address _to, uint256 _value) public override returns (bool) {
        // 如果未结算，且不是合约自己在转账，且初始转移已完成，则锁定
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            revert("Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value);
    }
    
    /**
     * @dev 重写 transferFrom 函数
     * 同样应用锁仓逻辑
     */
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this) && initialTransferDone) {
            revert("Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }
    
    // 结算函数：项目方提取资金，解锁代币
    function finalizeSale() public {
        require(msg.sender == projectOwner, "Only owner can finalize");
        require(block.timestamp > saleEndTime, "Sale has not ended yet");
        require(!finalized, "Already finalized");
        
        finalized = true;
        
        // 将筹集的资金发送给项目方
        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Failed to send funds to owner");
        
        uint256 soldTokens = totalSupply - balanceOf[address(this)];
        emit SaleFinalized(totalRaised, soldTokens);
    }
    
    // 辅助函数：查看剩余时间
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) return 0;
        return saleEndTime - block.timestamp;
    }
    
    // 辅助函数：查看合约内剩余可售代币
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }
    
    // 接收 ETH 自动调用购买函数
    receive() external payable {
        buyTokens();
    }
}