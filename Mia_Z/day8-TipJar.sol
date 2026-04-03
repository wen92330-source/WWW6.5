//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract TipJar{

    address public owner;
    uint256 public totalTipsReceived;

    mapping(string => uint256) public conversionRates;

    mapping(address => uint256) public tipPerPerson;
    string[] public supportedCurrencies ;
    mapping(address => uint256) public tipperContributions;

    mapping(string => uint256) public tipsPerCurrency;


    modifier onlyOwner(){
        require(msg.sender == owner,"Only owener can perform this action");
        _;
    }

    /**
     * 货币转换 真钱和ETH
     */
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner{

        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        
        bool currencyExists = false;
        for(uint i = 0; i < supportedCurrencies.length; i++ ){
            /**
             *这里的kecak是啥？？有什么用？
             **JavaScript 或 Python 中那样直接使用 `==`** 比较两个字符串。这是因为 Solidity 中的字符串是存储在内存中的复杂类型，而不是原始值。

            那么我们如何比较它们呢？

            我们使用 `bytes(...)`然后将这些字节传递给 `keccak256()` — 的内置加密哈希函数。
            这为我们提供了每个字符串的唯一指纹，我们会比较它们。
            如果哈希值匹配，则意味着字符串相等，并且我们知道货币已经存在。因此，我们设置了 currencyExists = true 并脱离循环。
             */
            if(keccak256(bytes(supportedCurrencies[i]))==keccak256(bytes(_currencyCode))){
                currencyExists = true;
                break;
            }

        }
            //add to the list if it's new
            if(!currencyExists){
                supportedCurrencies.push(_currencyCode);
            }

            //set the conversion rate
            conversionRates[_currencyCode] = _rateToEth;
    }

    constructor(){
        owner = msg.sender;

        /**
         *  wei 的世界——ETH 的最小单位
         *  
            1 ETH = 1,000,000,000,000,000,000 wei = 10^18 wei
         */
        addCurrency("USD", 5 * 10 **14) ;
        addCurrency("EUR", 6 * 10 **14) ;
        addCurrency("JPY", 4 * 10 **12) ;
        addCurrency("GBP", 7 * 10 **14) ;
    }

    //转化ETH
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256){
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];

        return ethAmount;
    }

    //实例 
    //addCurrency("USD", 5 * 10 **14) ;//1 USD = 5 * 10 **14 wei = 0.0005 ETH
    function tipInEth() public payable{
        require(msg.value > 0,"Tip amount must be greater than 0");

        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable{
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        
        //值可以直接比，但字符串不能 ==
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    //体现小费
    //它确保只有所有者才能提取小费，防止空提款，并安全地处理 ETH 转账，而无需假设接收者的任何信息。
    function withdrawTips() public onlyOwner{
        //哪来的this？
        /**
         * 
         *  his = 当前合约本身。
         * address(this) = 当前合约的地址。
         */
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        /**这是什么语法？？ 
         * 这是 Solidity 里一个「底层调用」语法：

        (bool success, bytes memory data) = someAddress.call{
            value: 发送的wei数量,
            gas: 可选gas限制
        }(调用数据)
        在这里只是简单地「给 owner 地址转钱」，不调用对方函数，所以数据是空字符串 ""。

        返回：

        success：转账是否成功（true / false）
        后面那个逗号留给 bytes 返回值，但这里不需要，所以用 _ 或空占位。

        C 伪代码类比：
        bool success = transfer_eth(owner, contractBalance);
        if (!success) {
            error("Transfer failed");
        }
        */
        (bool success, ) = payable(owner).call{value:contractBalance}("");
        require(success,"Transfer failed");

        totalTipsReceived = 0;
    }

    function transferOwnership(address _newOwner) public onlyOwner{
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;

    }

    //从合约中获取信息
    function getSupportedCurrencies() public view returns (string[] memory ) {
        return supportedCurrencies;
    }

    function getTipperContributions(address _tipper) public view returns (uint256) {
        return tipperContributions[_tipper];
    }

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256){
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256){
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }


}