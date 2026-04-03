//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
import "./day12_mySimpleToken.sol";

contract preOrderToken is mySimpleToken{
    //we need set something in constructor
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;

    address public projectOwner;

    bool public finalized = false;
    bool private initialTransferDone = false;

    //don't forget event
    event tokenPurchase(address indexed buyer, uint256 EthAmount, uint256 tokenAmount);
    event preSaleEnded(uint256 totalRaised, uint256 totalTokenSold);

    //attention: this is a child contract, you should give mother contract a parameter. Because mother contract's constructor need a parameter
    constructor(
        uint256 _InitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSec,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _ProjectOwner
    )mySimpleToken(_InitialSupply){

        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSec;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _ProjectOwner;
        //totalSupply is from mother contract
        _transfer(msg.sender, address(this), totalSupply);

        initialTransferDone = true;
    }

    function isSaleActived() public view returns(bool){
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable{
        require(isSaleActived(),"slae is not active");
        require(msg.value >= minPurchase, "Amount is below min purchase");
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        
        uint256 tokenPurchaseAmount = msg.value * (10 ** decimals) / tokenPrice;
        require(tokenPurchaseAmount <= balanceOf[address(this)], "insuffiient tokens for sale");
        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenPurchaseAmount);
        emit tokenPurchase(msg.sender, msg.value, tokenPurchaseAmount);

    }

    //override:transfer, transferFrom, because I don't want the buyer sales their purchased tokens before I allow them.
    function transfer(address _to, uint256 _amount) public override returns(bool){
        //means the tokens is still pre orderring, and the buyer try to transfer their tokens,that is not allowed
        if(!finalized && msg.sender!=address(this) && initialTransferDone){
            require(false, "Tokens are locked until pre sale is finalized");
        }

        //attention new tip: super, by using [super], you can directly use the funtion in mother contract. you don;t need to type them again
        return super.transfer(_to, _amount) ;

    }

    function transferFrom(address _from, address _to, uint256 _amount) public override returns(bool){
            if(!finalized && msg.sender!=address(this) && initialTransferDone){
            require(false, "Tokens are locked until pre sale is finalized");
        }

        return super.transferFrom(_from,_to,_amount);

    }

    //finalize the pre sale and withdraw the ETH
    function finalizeSale() public payable{
        require(msg.sender == projectOwner,"Only project owner can finalized this pre sale");
        require(!finalized,"presale is already ended");
        require(block.timestamp >= saleEndTime, "pre sale is not ended");
        finalized = true;
        uint256 totalSale = totalSupply- balanceOf[address(this)];
        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        emit preSaleEnded(totalRaised,totalSale);
    }

    function timeRemaining() public view returns(uint256){
        if(block.timestamp >saleEndTime){
            return 0;
        }

        return (saleEndTime - block.timestamp);
    }

    function getTokensAvaiable() public view returns(uint256){
        return(balanceOf[address(this)]);
    }
    //even though the buyers who forget to call any function of this child contract, it can help automatically call the buyTokens function
    //receive: a special function
    receive() external payable{
        buyTokens();
    }

}