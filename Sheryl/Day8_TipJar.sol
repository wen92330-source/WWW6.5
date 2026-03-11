// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;
    uint public totalTipsRecived;
    mapping (string => uint) public conversionRates;
    mapping (address => uint) public tipPerPerson;
    mapping (string => uint) tipsPerCurrency;
    string[] public supportedCurrencies;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function addCurrency(string memory _currencyCode, uint _ratetoEth) public onlyOwner {
        require(_ratetoEth > 0, "Conversion rate must be greater than 0");
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if(keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
            conversionRates[_currencyCode] = _ratetoEth;
        }
    }

    constructor() {
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH ETH
    }

    function converToEth(string memory _currencyCode, uint _amount) public view returns(uint) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        tipPerPerson[msg.sender] += msg.value;
        totalTipsRecived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    function tipInCurrency(string memory _currencyCode, uint _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");
        uint ethAmount = converToEth(_currencyCode, _amount);
        require(ethAmount == msg.value, "Sent ETH doesn't match the converted amount");
        tipPerPerson[msg.sender] += msg.value;
        totalTipsRecived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    function withdrawTips() public onlyOwner {
        uint contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer Failed"); 
        totalTipsRecived = 0;
    }

        function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }
}