// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day12-MyFirstToken.sol";

/**
 * @title PreOrderToken
 * @author mumu
 * @notice 基于ERC20实现代币预售功能
 * @dev 允许以固定的ETH价格发售我们自己的代币，也就是用ETH换代币
 */

contract PreOrderToken is MyFisrtToken{

    // 一个固定的价格
    uint256 public tokenPrice; // 单位是wei，1 ETH = 10^18wei
    uint256 public saleStartTime; // 预售开始时间
    uint256 public saleEndTime; // 预售结束时间戳
    uint256 public maxPurchase; 
    uint256 public minPurchase;
    address public projectOwner; // 发售结束后，接受ETH的钱包地址

    uint256 public totalRaised;

    bool public finalized = false; // 发售是否已经关闭
    bool private initialTransferDone = false; // 标注是否已经准备好

    // 事件
    // 1. 购买代币
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    // 2. 预售结束
    event SaleFinalized(uint256 totalRaised, uint256 totalTokenSold);
    // 3. 提取ETH
    event WithDrawEth(address indexed owner, uint256 etherAmount);

    constructor(
        uint256 _initialSupply, // 有多少可以发售
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    ) MyFisrtToken(_initialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp; // 当前时间作为开始时间
        saleEndTime = saleStartTime + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase; 

        require(_projectOwner != address(0), "_projectOwner is invalid");
        projectOwner = _projectOwner; // 注意这里的owner address不能是0，不过在转帐的时候会检查
        
        // 将所有的代币转移至此合约用于发售,这里的totalSupply是继承过来的
        _transfer(msg.sender, address(this), totalSupply);

        initialTransferDone = true;
    }

    function isSaleActive() public view returns(bool){
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyToken() public payable{
        require(isSaleActive(), "Sale is not active");
        // 检查购买范围
        require(msg.value >= minPurchase, "Amount is below minimum purchase");
        require(msg.value <= maxPurchase, "Amount exceeds maximum purchase");

        // 根据用户提供的msg.Value 计算可购买都少个token
        uint256 tokenAmount = (msg.value * 10 **uint256(decimals) / tokenPrice);

        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount); // 发放代币
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    // override 重写 锁定直接转帐，目前只允许从该合约转出
    function transfer(address _to,uint256 _value) public override returns(bool){
        // 进行检查
        if (!finalized && msg.sender != address(this) && initialTransferDone){
            // 通过require抛出错误
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value); // 调用母合约的原始transfer 函数
    }

    // 重写transferFrom， 锁定委托转帐
    function transferFrom(address _from,address _to,uint256 _value) public override returns(bool){
        // 进行检查
        if (!finalized && msg.sender != address(this) && initialTransferDone){
            // 通过require抛出错误
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    // 结束代币发售的方法
    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only Owner can call the funtion");
        require(!finalized, "Sale already finalized");
        require(block.timestamp > saleEndTime, "Sale not finished yet");

        finalized = true;

        uint256 tokensSold = totalSupply - balanceOf[address(this)];

        (bool success, ) = projectOwner.call{value:address(this).balance}("");

        require(success, "Transfer to project owner faild");

        emit SaleFinalized(totalRaised,tokensSold);
    }

    // 提供两个辅助函数
    function timeRemaining() public view returns(uint256){
        if (block.timestamp >= saleEndTime){
            return 0;
        }

        return saleEndTime - block.timestamp;
    }

    // 剩余可购买代币的数量
    function tokensAvailable() public view returns (uint256){
        return balanceOf[address(this)];
    }

    // ETH 回退处理器; 对于有人直接向合约地址发送ETH且未指定任何需要调用的函数
    receive() external payable{
        buyToken();
    }

}