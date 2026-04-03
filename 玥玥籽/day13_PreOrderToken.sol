// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day13_MyToken.sol";

contract PreOrderToken {

    MyToken public token;
    address public owner;

    uint256 public tokenPrice;

    bool public saleActive;

    mapping(address => uint256) public purchasedTokens;

    event TokensPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);

    event EthWithdrawn(address indexed owner, uint256 amount);

    constructor(address _tokenAddress, uint256 _tokenPrice) {
        token = MyToken(_tokenAddress);
        owner = msg.sender;
        tokenPrice = _tokenPrice;
        saleActive = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function buyTokens() public payable {
        require(saleActive, "Sale is not active");
        require(msg.value > 0, "Must send ETH to buy tokens");

        uint256 tokenAmount = msg.value * tokenPrice;

        require(token.balanceOf(address(this)) >= tokenAmount, "Not enough tokens in contract");

        token.transfer(msg.sender, tokenAmount);

        purchasedTokens[msg.sender] += tokenAmount;

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    function setTokenPrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }

    function setSaleActive(bool _active) public onlyOwner {
        saleActive = _active;
    }

    function withdrawEth() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");

        emit EthWithdrawn(owner, balance);
    }

    function withdrawTokens() public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        token.transfer(owner, balance);
    }

    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
