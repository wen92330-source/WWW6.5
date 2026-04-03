//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {

    address public owner; 
    string[] public supportedCurrencies;
    mapping( string => uint256) public conversionRates;//映射货币名=>ETH的汇率
    uint256 public totalTipsReceived;//总共给了多少小费
    mapping(address => uint256)public tipPerPerson;//某个人给了多少小费
    mapping(string => uint256)public tipsPerCurrency;//那种货币给的小费最多，相当于哪个地区


    //1 ETH = 1,000,000,000,000,000,000 wei  1ETH=10^18wei
    constructor() {
        owner = msg.sender;
        addCurrency("USD", 5*10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6*10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4*10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7*10**12);  // 1 INR = 0.000007ETH

    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        bool currencyExists = false;//先假设货币不存在
        //for循环
        for (uint i = 0; i < supportedCurrencies.length; i++){//i是数组的位置编号，i=0意味着从数组的第一个货币开始检查，当目前的4个货币都检查完了，开始检查第五个时，i=4.但因为长度也为4，i<lengh不成立，所以停止
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))){//检查新加的_currencyCode是不是已经在supportedCurrencies这个数组里
                currencyExists = true;
                break;//如果true，就会触发结束循环。如果一直没有找到，
            }
        }

        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);//如果货币不存在，则将这个“货币代码”添加到supportedCurrencies这个数组中
        }
        conversionRates[_currencyCode] = _rateToEth;
    }

    //将某种货币兑换成ETH
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    //用户用ETH打赏
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        tipPerPerson[msg.sender] += msg.value;//把这个用户发送的ETH加到他的打赏记录里
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }
    
    //用户用某种货币打赏但实际支付 ETH
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");
        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;//address（this）是当前合约的地址
        require(contractBalance > 0, "No tips to withdraw");
        (bool success, ) = payable(owner).call{value: contractBalance}("");
        //(bool success, ) 记录转账是否成功
        //要给某个地址转钱就要携程payable(address)
        require(success, "Transfer failed");
        totalTipsReceived = 0;//更新合约里tips金额
    }

    //转让管理权
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
    
   //获取某人打赏多少钱
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }
    

    //获取某个地区打赏多少钱
    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }

}