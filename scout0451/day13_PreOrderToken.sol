//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PreOrderToken is ERC20 {

    uint256 public tokenPrice;//代币值
    uint256 public saleStartTime;
    uint256 public saleEndTime;//开始结束时间
    uint256 public minPurchase;
    uint256 public maxPurchase;//单笔交易最大最小限额
    uint256 public totalRaised;//目前接收ETH总额
    address public projectOwner;//钱包地址
    bool public finalized = false;// 发售是否结束
    bool private initialTransferDone = false;// 合约锁定转账前收到所有代币

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor( 
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )ERC20("MyToken","MTK"){
        _mint(msg.sender,_initialSupply);
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;//储存项目所有者地址
    

    _transfer(msg.sender, address(this), totalSupply());//自动将代币从部署者转移到合约中
    initialTransferDone = true;
}
    function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable{
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        uint256 tokenAmount = (msg.value * 10**uint256(decimals()))/ tokenPrice;//计算要发多少代币
        require(balanceOf(address(this)) >= tokenAmount, "Not enough tokens left for sale");
        totalRaised+= msg.value;
        _transfer(address(this),msg.sender,tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
        
    }

    function transfer(address _to, uint256 _value)public override returns(bool){
        //三个条件都满足，函数回滚交易撤销：发售未完成、不是由合约本身发起、代币已转合约中
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }

        return super.transfer(_to, _value);//否则调用母合约原始函数
    }

    function transferFrom(address _from, address _to, uint256 _value)public override returns(bool){
        if(!finalized && _from != address(this)){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    //结束发售
    function finalizeSale() public payable{
        require(msg.sender == projectOwner, "Only owner can call this function");
        require(!finalized,"Sale is already finalized");
        require (block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;
        uint256 tokensSold = totalSupply() - balanceOf(address(this));
        (bool sucess,) = projectOwner.call{value:  address(this).balance}("");//把筹集到的ETH全部转项目负责人
        require(sucess, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    //倒计时发售时间
    function timeRemaining() public view  returns(uint256){
        if(block.timestamp >= saleEndTime){
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }

    //倒计时代币可购买量
    function tokensAvailable()public view returns(uint256){
        return balanceOf(address(this));
    }

    //回退函数，有人转入ETH后台自动调用buyTokens()
    receive() external payable{
        buyTokens();
    }
}





