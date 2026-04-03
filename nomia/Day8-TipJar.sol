// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TipJar{
    address public owner;
    string[] public supportedCurrencies;
    mapping(string => uint256) public conversionRates;
    uint public totalTipsReceived; //一共收到了多少
    mapping(address => uint256) public tipsPerPerson; //每个地址给了多少
    mapping(string => uint256) public tipsPerCurrency; //每个币种一共收了多少

    modifier onlyOwner(){
        require(msg.sender == owner, "only owner can perform the action"); // 检查msg.sender是不是owner 只有owner才能执行
        _; //把原本函数的代码放在这里执行
    }

    constructor(){
        owner = msg.sender; //合约部署的时候把部署者设置成 owner
        addCurrency("USD", 5 * 10 ** 14);
        addCurrency("EUR", 6 * 10 ** 14);
        addCurrency("JPY", 4 * 10 ** 12); 
        addCurrency("GBP", 7 * 10**14);

    }


    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner{ // 添加币种 币种代码 和 这个币种对应的兑换率
        require(_rateToEth > 0, "conversion rate must be greater than 0"); //兑换率必须大于0
        bool currencyExists = false; //先假设这个币种不存在
        for (uint256 i = 0; i < supportedCurrencies.length; i++){  //从头到尾遍历 supportedCurrencies 数组 
            //检查数组里的某个字符串和新传进来的币种代码是不是一样 keccak256(bytes(字符串1)) == keccak256(bytes(字符串2))
             //先把字符串转成 bytes，再 hash 一下，再比较 hash 值  如果相等的话这个币种在数组里就已经存在了 
            if(keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))){ 
                currencyExists = true;  //如果存在
                break; //停止循环
        }

    }    

        if(!currencyExists){
            supportedCurrencies.push(_currencyCode);  
        }


    //更新或设置转化率
    conversionRates[_currencyCode] = _rateToEth;

    }

    function convertToEth(string memory _currencyCode, uint256 _amount)public view returns(uint256){
        require(conversionRates[_currencyCode] > 0, "currency is not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;

    }

    function tipInEth() public payable { //直接用eth打赏
        require(msg.value > 0,"value have to be greater than 0");
        tipsPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"]+=msg.value;



    }



    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable { //按外币金额打赏 系统换算成eth 实际支付eth
        require(conversionRates[_currencyCode] > 0, "currency is not supported");
        require(msg.value > 0, "value have to be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "sent ETH does not match the conversion amount");

        tipsPerPerson[msg.sender] += msg.value; //把打赏人的打的钱加上去 以eth为单位
        totalTipsReceived += msg.value; //加进收到的打赏总额
        tipsPerCurrency[_currencyCode] += _amount; //按这个币种计算时 增加数额
    }

    function withdrawTips() public onlyOwner{ //owner把打赏提走
        uint256 contractBalance = address(this).balance; //当前合约地址有多少eth
        require(contractBalance > 0, "no tips to withdraw");//有钱才能提走
        (bool success, ) = payable(owner).call{value: contractBalance}("");//把contract里的所有eth都给owner
        require(success, "transfer failed");//不成功就报错
        totalTipsReceived = 0;//转走以后reset

    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");//new owner不能是空地址
        owner = _newOwner;
    }


    function getSupportedCurrencies() public view returns (string[] memory) { //查询支持币种
        return supportedCurrencies;
    }


    function getContractBalance() public view returns (uint256){ //查询合约余额 withdraw以后就无了
        return address(this).balance;


    }


    function getTipperContribution(address _tipper) public view returns (uint256){
        return tipsPerPerson[_tipper]; //输入某个地址查看此人打赏了多少



    }


    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];

    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "currency not supported");
        return conversionRates[_currencyCode];

    }







    



}


