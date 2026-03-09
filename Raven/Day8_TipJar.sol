//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract TipJar {
	address public owner;
	uint256 public totalTips; // ETH
	string [] public currencies;
	mapping (string => bool) public isSupportedCurrency;
	mapping (string => uint256) public exchangeRate; // ETH
	mapping (address => uint256) public tipPerPerson; // ETH
	mapping (string => uint256) public tipPerCurrency; // Currency

	constructor() {
		owner = msg.sender;
		// The order of function does not matter in solidity
		// 1 ETH = 1 * 10 ^ 18 WEI, to avoid float
		addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH ETH
	}
	modifier onlyOwner() {
		require(msg.sender == owner, "Only owner has access to operate");
		_;
	}
	// Owner adds a currency when it is not included in the array
	// Update excahnge rate every time
	// Use mapping instead of loop to save gas
	function addCurrency(string memory _currency, uint256 _rate) public onlyOwner {
		require(_rate > 0, "Exchange rate should be positive");
		if (!isSupportedCurrency[_currency])
		{
			currencies.push(_currency);
			isSupportedCurrency[_currency] = true;
		}
		exchangeRate[_currency] = _rate;
	}
	// Keyword Payable only applied to functions receive ETH
	function tipInEth() public payable {
		require(msg.value > 0, "Invalid payment");
		totalTips += msg.value;
		tipPerPerson[msg.sender] += msg.value;
		tipPerCurrency["ETH"] += msg.value;
	}
	function convertToEth(string memory _currency, uint256 _amount) public view returns (uint256) {
		require(exchangeRate[_currency] > 0, "Invalid exchange rate");
		return (_amount * exchangeRate[_currency]);
	}
	function tipInCurrency(string memory _currency, uint256 _amount) public payable {
		require(_amount > 0, "Payment should be positive");
		require(isSupportedCurrency[_currency], "Currency not supported");
		uint256 ethAmount = convertToEth(_currency, _amount);
		// calculated ETH amount should be equal to payment in reality
		require(ethAmount == msg.value, "Invalid payment");
		totalTips += msg.value;
		tipPerPerson[msg.sender] += msg.value;
		tipPerCurrency[_currency] += _amount;
	}
	// Withdraw all money from this address
	function withdrawTips() public onlyOwner {
		uint256 contractBalance = address(this).balance; // Total real ETH value of this account
		require(contractBalance > 0, "Not enough tips");
		totalTips = 0; // Avoid Reentrancy
		(bool success, ) = payable(msg.sender).call{value:contractBalance}("");
		require(success, "Fail to wuthdraw");
	}
	function transferOwnership(address _newOwner) public onlyOwner {
		require(_newOwner != address(0), "Invalid address");
		owner = _newOwner;
	}
	function getCurrencies() public view returns (string [] memory) {
		return (currencies);
	}
	function getExchangRate(string memory _currency) public view returns (uint256) {
		require(exchangeRate[_currency] > 0, "Invalid currency type");
		return (exchangeRate[_currency]);
	}
	function getContractBalance() public view returns (uint256) {
		return (address(this).balance);
	}
	function getTipperContribution(address _tipper) public view returns (uint256) {
		return (tipPerPerson[_tipper]);
	}
	function getTipInCurrency(string memory _currency) public view returns (uint256) {
		return (tipPerCurrency[_currency]);
	}
}
