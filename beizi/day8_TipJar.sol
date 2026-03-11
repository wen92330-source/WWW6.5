//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public  owner;
    //一个总金额计数器，告诉你存钱罐里现在一共值多少钱（以 Wei 为单位）
    uint256 public totalTipsReceived;
    //汇率表
    mapping(string => uint256) public conversionRates;
    mapping(address => uint256) public tipPerPerson;//给了谁多少钱
    string[] public supportedCurrencies;//支持的全部货币种类
    mapping(string => uint256) public tipsPerCurrency;//账本

    
    modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
}
    // 货币对ETH的汇率
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
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
    }
    constructor() {
        owner = msg.sender;
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH ETH
    }    
     function  convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");

    uint256 ethAmount = _amount * conversionRates[_currencyCode];
    return ethAmount;
}
//内部ETH转账
function tipInEth() public payable {
    require(msg.value > 0, "Tip amount must be greater than 0");
    tipPerPerson[msg.sender]+= msg.value;
    totalTipsReceived += msg.value;
    tipsPerCurrency["ETH"] += msg.value;
}
//外部转账
function tipInCurrency (string memory _currencyCode, uint256 _amount) public payable {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");
    require(_amount > 0, "Amount must be greater than 0");
    uint256 ethAmount = convertToEth(_currencyCode, _amount);
    require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
    tipPerPerson[msg.sender]+= msg.value;
    totalTipsReceived += msg.value;
    tipsPerCurrency["ETH"] += msg.value;
}
function withdrawTips() public onlyOwner {
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "No tips to withdraw");
    (bool success, ) = payable(owner).call{value: contractBalance}("");
    require(success, "Transfer failed");
    totalTipsReceived=0;
}

function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Invalid address");
    owner = _newOwner;
}
//取存储在合约中的数据(检查) 货币代码
function getSupportedCurrencies() public view returns (string[] memory) {
    return supportedCurrencies;
}
//合约当前持有多少 ETH
function getContractBalance() public view returns (uint256) {
    return address(this).balance;
}
//某个人给了多少小费
function getTipperContribution(address _tipper) public view returns (uint256) {
    return tipPerPerson[_tipper];
}
//以特定货币支付小费的总金额
function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
    return tipsPerCurrency[_currencyCode];
}
//汇率是否正确
function getConversionRate(string memory _currencyCode) public view returns (uint256) {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");
    return conversionRates[_currencyCode];
}

}
