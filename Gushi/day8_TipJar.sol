//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {  //可以用来收取别人的打赏
    address public owner;
    
    uint256 public totalTipsReceived;
    
    // 1ETH=10^18wei,使用wei作为最小单位，基本上所有的交易都可以用整数了，就可以避免浮点数精度缺陷，导致数据转换出现问题
    mapping(string => uint256) public conversionRates; //存储其他货币与ETH间的汇率

    mapping(address => uint256) public tipPerPerson;  //每个人给了多少打赏
    string[] public supportedCurrencies;  // 这个合约当前支持的货币清单，之后可以调用
    mapping(string => uint256) public tipsPerCurrency;  //每种货币有多少打赏
    
    constructor() { //一个初始化的架构函数，添加了一些货币种类和汇率
        owner = msg.sender;
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH ETH
    }
    
    modifier onlyOwner() { 
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 增加或者更新一种货币
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner { //说到string必须memory或者其他，简单类型（uint、int、bool、address）不用写，合约知道她们放在哪
        require(_rateToEth > 0, "Conversion rate must be greater than 0"); //汇率得是正数
        bool currencyExists = false; //首先把所有货币是否在此合约的初始状态统一设为false
        for (uint i = 0; i < supportedCurrencies.length; i++) { //for循环，从i=0开始第一次比对下面的if函数，直到清单全部的货币都被if了一遍
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) { //string类型不能比较，所以我们把它们转化为字节bytes（），再得出哈希值keccak256，比较它们的哈希值
                currencyExists = true; //已经存在的货币，状态会被设置为true
                break;
            }
        }
        if (!currencyExists) { //只有状态为false的货币会被添加到清单中，即之前没有过的货币种类
            supportedCurrencies.push(_currencyCode);
        }
        conversionRates[_currencyCode] = _rateToEth; //无论货币种类之前是否已经存在，它的汇率都会被更新
    }
    
    //将某金额的货币转换成一定汇率计算后的以太币金额，单位wei
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
        //得到的是wei为单位的值，要想得到ETH，除以10^18:
    }
    
    // 直接用以太币打赏
    function tipInEth() public payable { //payable登场，锵锵
        require(msg.value > 0, "Tip amount must be greater than 0");
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }
    
    //用其他货币打赏
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");//汇率检查
        require(_amount > 0, "Amount must be greater than 0"); //金额检查
        uint256 ethAmount = convertToEth(_currencyCode, _amount); //调用converttoeth函数得到换算后以太币的值
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount"); //实际交易金额检查
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    //提取打赏。余额（真实的代币哦）本来存在合约账户上，现在要提取到本人的账户里
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance; //ddress(this).balance指的是这个合约地址的余额，合约也有账户。
        require(contractBalance > 0, "No tips to withdraw");
        (bool success, ) = payable(owner).call{value: contractBalance}(""); //一调用这个函数就是取走全部余额
        require(success, "Transfer failed");
        totalTipsReceived = 0; //余额归零
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
