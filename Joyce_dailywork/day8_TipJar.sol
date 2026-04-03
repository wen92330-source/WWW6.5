// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract TipJar{
    // 合约总体收集的ETH
    uint256 public totalTipReceived;

    // 合约部署人和操作人
    address public owner;

    // 每个地址发送的小费（ETH）
    mapping (address => uint256) public tipperContributions;

    // 每种货币的小费金额
    mapping (string => uint256) public tipsPerCurrency;

    // 映射汇率（e.g, USD => ETH）
    mapping (string => uint256) public conversionRates;

    // 跟踪添加的所有货币代码
    string[] public supportedCurrencies;

    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner!");
        _;
    }

    // 目前手动设置汇率，后续会使用预言机等方式获取实时数据
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0!");
        // 检查代币是否存在
        bool currencyExists = false;
        for(uint i = 0; i < supportedCurrencies.length; i++){
            if(keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))){
                currencyExists = true;
                break;
            }
        }
        if(!currencyExists){
            supportedCurrencies.push(_currencyCode);
        }

        conversionRates[_currencyCode] = _rateToEth;
    }

    constructor(){
        owner = msg.sender;
        minTipAmount = 1 * 10**15;
        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("GBP", 7 * 10**14);
    }

    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256){
        require(conversionRates[_currencyCode] > 0, "Currency not found.");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0!");
        tipperContributions[msg.sender] += msg.value;
        totalTipReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not found!");
        require(_amount > 0, "Tip amount must be greater than 0!");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH amount doesn't match the converted amount.");
        tipperContributions[msg.sender] += msg.value;
        totalTipReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");
        (bool success,) = payable (owner).call{value: contractBalance}("");
        require(success, "Transfer failed.");
        totalTipReceived = 0;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    function getSupportedCurrencies() public view returns (string[] memory){
        return supportedCurrencies;
    }

    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }

    function getTipperContribution(address _tipper) public view returns (uint256){
        return tipperContributions[_tipper];
    }

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256){
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256){
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }

    // exercises
    uint256 public minTipAmount;

    address[] public allTippers;

    struct Tipper{
        address addr;
        uint256 amount;
    }

    function refundToTipper(address tipper, uint256 amount) public onlyOwner{
        require(tipperContributions[tipper] >= amount, "Insufficient amount!");
        require(amount > 0 && amount <= address(this).balance, "Invalid amount!");
        (bool success, ) = payable (tipper).call{value: amount}("");
        require(success, "Refund failed.");
        tipperContributions[tipper] -= amount;
        totalTipReceived -= amount;
    }

    function removeCurrency(string memory _currencyCode) public onlyOwner{
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        conversionRates[_currencyCode] = 0;
        for(uint i = 0; i < supportedCurrencies.length;i++){
            if(keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))){
                supportedCurrencies[i] = supportedCurrencies[supportedCurrencies.length - 1];
                supportedCurrencies.pop();
            }
        }
    }

    function getTopTippers(uint256 topN) public view returns (Tipper[] memory){
        uint256 len = allTippers.length;
        if(len == 0){
            return new Tipper[](0);
        }
        Tipper[] memory tippers = new Tipper[](len);
        for(uint i = 0; i < len; i++){
            tippers[i] = Tipper(allTippers[i], tipperContributions[allTippers[i]]);
        }

        for(uint i = 0; i < len - 1; i++){
            for(uint j = 0; j < len - i - 1; j++){
                if(tippers[j].amount < tippers[j + 1].amount){
                    Tipper memory temp = tippers[j];
                    tippers[j] = tippers[j + 1];
                    tippers[j + 1] = temp;
                }
            }
        }
        if(topN > len) topN = len;
        Tipper[] memory top = new Tipper[](topN);
        for(uint i = 0; i < topN; i++){
            top[i] = tippers[i];
        }
        return top;
    }
}