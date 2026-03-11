//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar{

    //变量
    address public owner;
    uint256 public totalTipsReceived;
    string[] public supportedCurrencies;

    //
    mapping(string => uint256) public conversionRates;
    mapping(address => uint256) public tipperContributions;
    mapping(string => uint256) public tipsPerCurrency;

    modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
    }


    //遍历数组，查看货币是不是已存在
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        bool currencyExists = false;//默认设置初始为False，根据遍历结果来修改状态
        for (uint i = 0; i < supportedCurrencies.length; i++) {
        if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {//比较两个哈希是否相等
            currencyExists = true;
            break;
            }//keccak256 输入映射为固定大小的256位（32字节）哈希值

        }

        // 增加货币
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }

        // 设置rate
        conversionRates[_currencyCode] = _rateToEth;

    }

    
    constructor() {//没有浮点数，没有分数 1 ETH = 1,000,000,000,000,000,000 wei = 10^18 wei
        owner = msg.sender;

        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("GBP", 7 * 10**14);
    }
    //将constructor放在add之前，会报错是为什么呢？

    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");

        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }


    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");

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
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");

        totalTipsReceived = 0;
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
    

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }


    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }


}