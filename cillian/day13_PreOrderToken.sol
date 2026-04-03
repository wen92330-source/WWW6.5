// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day12_ERC20.sol";

// 继承母合约SimpleERC20
contract PreOrderToken is SimpleERC20 {

    uint256 public tokenPrice; // 代币单价 
    uint256 public saleStartTime; // 预售开始的时间戳
    uint256 public saleEndTime; // 预售结束的时间戳
    uint256 public minPurchase; // 单笔最小购买金额 
    uint256 public maxPurchase; // 单笔最大购买金额
    uint256 public totalRaised; // 已筹集到的以太币总量
    address public projectOwner; // 项目所有者地址，用于提取资金和结束预售
    bool public finalized = false; // 预售是否已正式结束/结算的标记
    bool private initialTransferDone; // 内部标记：构造函数中初始代币转移是否完成

    // 事件：记录购买行为
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    // 事件：记录预售结算
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);
    // 初始化代币供应量、价格、持续时间、最小最大购买量、项目管理者，并将代币转移至合约地址
    constructor(
        uint256 _intitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    ) SimpleERC20(_intitialSupply) {
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;
        
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }

    // 检查当前是否处于预售活跃状态（未结算且在时间范围内）
    function isSaleActive() public view returns(bool) {
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    // 用户购买代币的核心逻辑，根据转入的 ETH 计算并分发代币
    function buyTokens() public payable {
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");

        uint256 tokenAmount = (msg.value * 10**uint256(decimals))/ tokenPrice; // (ETH金额 * 10^精度) / 单价。乘以 10^decimals 是为了处理代币的小数位精度
        require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
        totalRaised+= msg.value;

        _transfer(address(this),msg.sender,tokenAmount); // 执行转账：调用母类的内部函数 _transfer，将代币从合约地址（address(this)）发送给购买者（msg.sender）
        emit TokensPurchased(msg.sender, msg.value, tokenAmount); // 触发事件：在区块链上记录本次购买的信息，包括买家地址、支付的 ETH 金额和获得的代币数量
    }

    // 重写母类的转账函数：在预售完成前，限制普通用户的转账行为
    function transfer(address _to, uint256 _value) public override returns(bool) {
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }

        return super.transfer(_to, _value); // super 跳过当前合约的定义，去调用母类里的 transfer 函数
    }

    // 重写母类的授权转账函数：在预售完成前，限制代币的第三方转移 （“代币锁定期”或“转账限制”）
    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){ //预售没结束 且 发币方不是合约自己
            require(false, "Tokens are locked until sale is finalized"); //强制回滚，程序执行到这一句时会立即停止，并撤销本次交易的所有改动，同时把错误信息返回给用户
        }
        return super.transferFrom(_from, _to, _value);
    }

    // 结算预售：将筹集的资金转给项目方，并解除代币的转账锁定
    function finalizeSale() public payable {
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;

        uint256 tokensSold = totalSupply - balanceOf[address(this)]; // 统计销量：总供应量减去合约当前剩余的代币数量，得出本次预售实际卖出的代币总额
        (bool sucess,) = projectOwner.call{value:  address(this).balance}(""); // 提取资金：使用底层 call 方法，将合约内收到的所有 ETH（address(this).balance）发送给项目所有者
        require(sucess, "Transfer failed"); // 安全检查：确保上述 ETH 转账操作成功执行，如果转账失败则回滚整个交易
        emit SaleFinalized(totalRaised, tokensSold); // 触发事件：在链上记录结算信息，包括总筹款额（totalRaised）和最终卖出的代币数量
    }

    // 计算距离预售结束还剩多少秒
    function timeRemaining() public view returns(uint256) {
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    // 查询合约当前剩余可供购买的代币数量
    function tokensAvailable() public view returns(uint256) {
        return balanceOf[address(this)];
    }

    // 备用收款函数：当用户直接向合约转账 ETH 时，自动触发购买逻辑
    receive() external payable { // 使用户不调用buyTokens时也可以转账（receive），并且只能在外部触发（external），设置“投币口”（payable）
        buyTokens();
    }

}