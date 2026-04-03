// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {

    // State Variables
    address public owner;
    string[] public supportedCurrencies;
    mapping(string => uint256) public conversionRates;
    mapping(string => uint256) public totalTipsPerCurrency;
    mapping(address => uint256) public userContributions;
    uint256 public totalEthReceived;

    // Events
    event CurrencyAdded(string currencyCode, uint256 rate);
    event TipReceived(address indexed sender, string currency, uint256 amount, uint256 ethValue);
    event OwnerWithdrawal(address indexed owner, uint256 amount);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
        // Call internal function to initialize ETH
        _addCurrency("ETH", 1 ether);
    }

    // Internal Helper Function (Fixes the visibility error)
    function _addCurrency(string memory _code, uint256 _rate) internal {
        require(_rate > 0, "Rate must be positive");
        
        bool exists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_code))) {
                exists = true;
                break;
            }
        }

        if (!exists) {
            supportedCurrencies.push(_code);
        }

        conversionRates[_code] = _rate;
        emit CurrencyAdded(_code, _rate);
    }

    // Admin Functions
    function addCurrency(string memory _code, uint256 _rate) external onlyOwner {
        _addCurrency(_code, _rate);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    // Tip Functions
    receive() external payable {
        _processTip("ETH", msg.value, msg.value);
    }

    function tipInEth() external payable {
        require(msg.value > 0, "Must send ETH");
        _processTip("ETH", msg.value, msg.value);
    }

    function tipInCurrency(string memory _code, uint256 _amount) external payable {
        uint256 rate = conversionRates[_code];
        require(rate > 0, "Currency not supported");
        
        uint256 expectedEth = (_amount * 1 ether) / rate;
        require(msg.value == expectedEth, "Sent ETH does not match converted amount");
        
        _processTip(_code, _amount, expectedEth);
    }

    // Internal Logic for processing tips
    function _processTip(string memory _code, uint256 _amount, uint256 _ethValue) internal {
        require(_amount > 0, "Amount must be positive");

        totalEthReceived += _ethValue;
        totalTipsPerCurrency[_code] += _amount;
        userContributions[msg.sender] += _ethValue;

        emit TipReceived(msg.sender, _code, _amount, _ethValue);
    }

    // Withdraw Function
    function withdrawTips() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");

        emit OwnerWithdrawal(owner, balance);
    }

    // View Functions
    function getSupportedCurrencies() external view returns (string[] memory) {
        return supportedCurrencies;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getRate(string memory _code) external view returns (uint256) {
        return conversionRates[_code];
    }
    
    function getUserContribution(address _user) external view returns (uint256) {
        return userContributions[_user];
    }
}