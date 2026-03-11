//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;
    mapping(string => uint256) public conversionRates;
    string[] public supportedCurrencies;
    uint public totalTipsReceived;
    mapping(address => uint256) public tipperContributions;
    mapping(string => uint256) public tipsPerCurrency;
    mapping(string => bool) isSupported;

    modifier  onlyOwner {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Rate must be greater than 0."); 
        // check if currency already exists
        /* for循环浪费大量gas
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth;
        */
        // require(isSupported[_currencyCode] == false, "Currency already exists."); //现在的逻辑： 只能新增，不能修改（如果要调整汇率，必须先删掉？但你还没写删除逻辑）。
        if (isSupported[_currencyCode] == false) {
            supportedCurrencies.push(_currencyCode);
            isSupported[_currencyCode] = true;
        }
        // 无论新旧，都更新他的汇率
        conversionRates[_currencyCode] = _rateToEth;
    }

    constructor() {
        owner = msg.sender;

        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("GBP", 7 * 10**14);
    }

    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported.");

        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0.");
        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    function withdrawTips() public onlyOwner {
        totalTipsReceived = 0;
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");
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
        return tipperContributions[_tipper];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }

}
