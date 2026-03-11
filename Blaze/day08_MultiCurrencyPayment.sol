// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract MultiCurrencyPayment {
    address public owner;
    //货币对汇率
    mapping(string => uint256) public conversionRates;
    //货币代码数组
    string[] public supportedCurrencies;
    //合约收集的ETH数量
    uint256 public totalTipsReceived;
    //每个地址在小费中发送了多少eth
    mapping(address => uint256) public tipperContributions;
    //每种货币的小费金额
    mapping(string => uint256) public tipsPerCurrency;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }


    //仅所有者添加或更新币种与其兑 ETH 汇率
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");

        // Check if currency already exists
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }

        // Add to the list if it's new
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }

        // Set the conversion rate
        conversionRates[_currencyCode] = _rateToEth;
    }

    //预加载值
    constructor() {
        owner = msg.sender;

        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("GBP", 7 * 10**14);
    }

    //转换为 ETH（以 wei 为单位）
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");

        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    //发送小费
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");

        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }


     //用指定货币发送小费
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    //提取小费  从eth里撤回小费
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");

        totalTipsReceived = 0;
    }

    //转让所有权
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    //从合约中获取支持的货币
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }


    //合约当前持有多少 ETH
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //知道某人给了多少小费
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipperContributions[_tipper];
    }

    //获取汇率
    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }




}