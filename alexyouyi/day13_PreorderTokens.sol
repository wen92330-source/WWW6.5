//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day12_MyToken.sol";

contract PreorderToken is MyToken{
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner;
    bool public finalized = false;
    bool public initialTransferDone = false;

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 totalAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor(
        uint256 _initialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    ) MyToken(_initialSupply) {
        require(_minPurchase < _maxPurchase, "Min purchase must be less than max purchase");
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }

    function isSaleActive() public view returns (bool) {
        return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable {
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Amount is below minimum purchase");
        require(msg.value <= maxPurchase, "Purchase amount out of bounds");

        uint256 tokensToBuy = (msg.value * (10 ** uint256(decimals))) / tokenPrice;
        require(balanceOf[address(this)] >= tokensToBuy, "Not enough tokens left for sale");

        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokensToBuy);
        emit TokensPurchased(msg.sender, msg.value, tokensToBuy);
        
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        if(!finalized && msg.sender != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if(!finalized && _from != address(this) && initialTransferDone){
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    function finializeSale() public {
        require(msg.sender == projectOwner, "Only project owner can finalize the sale");
        require(!finalized, "Sale already finalized");
        require(block.timestamp > saleEndTime || balanceOf[address(this)] == 0, "Sale not ended or tokens still available");

        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];
        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Transfer to project owner failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    function timeRemaining() public view returns (uint256) {
        if(block.timestamp >= saleEndTime){
            return 0;
        } else {
            return saleEndTime - block.timestamp;
        }
    }

    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    receive() external payable {
        buyTokens();
    }
}