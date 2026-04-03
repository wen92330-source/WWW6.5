//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {

    address public owner; 
    string[] public supportedCurrencies; //支持的汇率类型
    uint256 public totalTipsReceived; //合约收到的小费合计 

    mapping(string => uint256) public conversionRates; //对应汇率
    mapping(string => bool) public isSupported; //是否支持
    mapping(address => uint256) public tipperContributions; //个人贡献总金额
    mapping(string => uint256) public tipsPerCurrency; //合约收到的某种货币对应金额


    // 初始化管理员及默认汇率
    constructor() {
        owner = msg.sender;
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH ETH
    }

    // 权限修饰符：限制仅管理员可操作
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 添加或更新支持的币种及汇率
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Rate must be more than 0");
        // 检测是否已经添加过，添加过就更新汇率，没添加过就放入数组中
        if(!isSupported[_currencyCode]) {
            supportedCurrencies.push(_currencyCode);
            isSupported[_currencyCode] = true;
        }
        conversionRates[_currencyCode] = _rateToEth;
    }

    // 将法币金额按汇率换算为 ETH 数量并返回可见数据
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns(uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
       
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    // 用户直接发送 ETH 进行打赏
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");

        tipperContributions[msg.sender] += msg.value; //用户总贡献
        totalTipsReceived += msg.value; //合约收到的小费合计
        tipsPerCurrency["ETH"] += msg.value; //合约收到的ETH合计
    }

    // 用户按指定法币数额对应的 ETH 打赏
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        
        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    // 管理员提取合约全部余额
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");
        totalTipsReceived = 0;
    }

    // 转移合约管理员权限
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    // 获取所有支持的币种列表
    function getSupportedCurrencies() public view returns(string[] memory) {
        return supportedCurrencies;
    }

    // 查询合约当前的 ETH 余额
    function getContractBalance() public view returns(uint256) {
        return address(this).balance; //这里不用totalTipsReceived，因为它是账面数据，但address(this).balance是实际余额(wei为单位)
    }

    // 查询指定地址的累计打赏额
    function getTipperContribution(address _tipper) public view returns(uint256) {
        require(_tipper != address(0), "Invalid address");
        return tipperContributions[_tipper];
    }

    // 查询特定币种累计收到的金额
    function getTipsInCurrency(string memory _currencyCode) public view returns(uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    // 查询指定币种的当前汇率
    function getConversionRate(string memory _currencyCode) public view returns(uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }

}