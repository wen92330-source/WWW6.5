// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./Day13_MyToken.sol";

contract PreOrderToken is MyToken {
	uint256 public tokenPrice;// ETH
	uint256 public saleStartTime;
	uint256 public saleEndTime;
	uint256 public minPurchase;
	uint256 public maxPurchase;
	uint256 public totalRaised;// ETH
	address public projectOwner;
	bool public finalized = false;
	bool private initTransferDone = false;
	event TokenPurchase(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
	event SaleFinalize(uint256 totalRaised, uint256 totalTokenSold);
	// Convey param to base contract constructor
	constructor(
		uint256 _initSupply,
		uint256 _tokenPrice,
		uint256 _saleDuration,
		uint256 _minPurchase,
		uint256 _maxPurchase,
		address _projectOwner
	) MyToken(_initSupply) {
		tokenPrice = _tokenPrice;
		saleStartTime = block.timestamp;
		saleEndTime = block.timestamp + _saleDuration;
		minPurchase = _minPurchase;
		maxPurchase = _maxPurchase;
		projectOwner = _projectOwner;
		// Transfer all tokens to contract address
		_transfer(msg.sender, address(this), totalSupply);
		initTransferDone = true;
	}
	function isSaleActive() public view returns (bool) {
		return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
	}
	function buyTokens() public payable {
		require(isSaleActive(), "Sale is not active");
		require(msg.value >= minPurchase, "Amount is below min");
		require(msg.value <= maxPurchase, "Amount is above max");
		uint256 tokenAmount = (msg.value * 10 ** uint256(decimals)) / tokenPrice;
		require(tokenAmount <= balanceOf[address(this)], "Not enough tokens");
		totalRaised += msg.value;
		_transfer(address(this), msg.sender, tokenAmount);
		emit TokenPurchase(msg.sender, msg.value, tokenAmount);
	}
	// Lock transferal until finalized
	function transfer(address _to, uint256 _amount) public override returns (bool) {
		if (!finalized && msg.sender != address(this) && initTransferDone) {
			require(false, "Tokens are locked until sale is finalized");
		}
		return super.transfer(_to, _amount);
	}
	function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool) {
		if (!finalized && _from != address(this) && initTransferDone) {
			require(false, "Tokens are locked until sale is finalized");
		}
		return super.transferFrom(_from, _to, _amount);
	}
	// Withdraw money from contract to owner
	function finalizeSale() public payable {
		require(msg.sender == projectOwner, "Only owner can finalize");
		require(!finalized, "Already finalized");
		require(block.timestamp > saleEndTime, "Sale not finished yet");
		finalized = true;
		uint256 tokenSold = totalSupply - balanceOf[address(this)];
		(bool success, ) = projectOwner.call{value:address(this).balance}("");
		require(success, "Transfer failed");
		emit SaleFinalize(totalRaised, tokenSold);
	}
	function timeRemaining() public view returns (uint256) {
		if (block.timestamp >= saleEndTime)
			return (0);
		return (saleEndTime - block.timestamp);
	}
	function tokensAvailable() public view returns (uint256) {
		return (balanceOf[address(this)]);
	}
	// Allow user transfer ETH without calling buyToken()
	receive() external payable {
		buyTokens();
	}
}
