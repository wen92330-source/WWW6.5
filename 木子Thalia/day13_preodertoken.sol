//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./day13_mytoken.sol";

contract PreOrderToken is MyToken {

    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner;
    bool public finalized = false;
    bool private initialTransferDone = false;

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor( 
        uint256 _intitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    )MyToken(_intitialSupply){
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;
    }

    function isSaleActive()public view returns(bool){
        return(!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
    }

    function buyTokens() public payable {
        require(isSaleActive(), "Sale is not active");
        require(msg.value >= minPurchase, "Minimum purchase amount not met");
        require(msg.value <= maxPurchase, "Maximum purchase amount exceeded");

        uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Insufficient tokens in contract");

        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    function finalizeSale() public {
        require(msg.sender == projectOwner, "Only the owner can finalize the sale");
        require(!finalized, "Sale already finalized");
        finalized = true;
        uint256 tokensSold = totalSupply - balanceOf[address(this)];

        (bool success, ) = projectOwner.call{value:address(this).balance}("");
        require(success, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }

    receive() external payable {
        buyTokens();
    }

    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) {
            return 0;
        }
        return saleEndTime - block.timestamp;
    }

    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }
}





