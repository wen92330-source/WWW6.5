//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract TipJar {//创建一个名为TipJar的智能合约    别人可以打赏我
address public owner;// 数据类型：存储钱包地址 （部署此合约的人的地址）
uint256 public totalTipsReceived; //只能存整数（总共收到多少打赏）
mapping(string => uint256) public conversionRates;//键值对存储结构 key-value 汇率
    mapping(address => uint256) public tipPerPerson; //用户地址-打赏金额 记录每个人打赏了多少eth
    string[] public supportedCurrencies;//数组 记录支持的货币列表  
    mapping(string => uint256) public tipsPerCurrency;//货币-打赏数量 记录原始货币数量而非eth
    constructor() {//合约部署时自动执行一次的函数
        owner = msg.sender;//把部署者设置为合约管理员
        addCurrency("USD", 5 * 10**14); //调用addCurrency()函数 设置usd汇率，1usd=0.0005*10**18=5*10**14eth        addCurrency("EUR", 6 * 10**14);  
        addCurrency("JPY", 4 * 10**12);//设置日元汇率 0.000004*10**18ETH 1ETH=10**18wei
        addCurrency("INR", 7 * 10**12); //设置卢比汇率 0.000007*10**18
    }   
    modifier onlyOwner() {//定义了一个名为onlyOwner的权限，在执行函数之前先检查函数权限，只有owner才能执行，否则执行失败
        require(msg.sender == owner, "Only owner can perform this action");//写条件：只有owner才可以执行
        //前面我们把owner=mag.sender所以 现在只有 验证其为合约管理员才可以执行
        _;//继续执行代码，没有它到这步函数就直接结束运行
    }
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        //添加新的货币将其转换成ETH  
        // 函数 函数名 储存货币的代码string memory 选择储存方式  _函数参数  （货币）  储存代码 _rateToEth 
        //区分 有  _ 为函数参数 无则为函数变量 
        require(_rateToEth > 0, "Conversion rate must be greater than 0");
        //条件 汇率大于0 
        bool currencyExists = false;//验证货币是否存在
        for (uint i = 0; i < supportedCurrencies.length; i++) {//利用for循环如果存在就停止
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                //为什么要这样写呢 因为在solidity里面 不能直接检查 需要先把byte转化为哈希函数在检查 
             //   keccak256()就是哈希函数   哈希(byte（字符串）)
                currencyExists = true;
                //其为真 停止执行  
                break;
            }
        } //不存在就添加代码
        if (!currencyExists) { //！xx 代表  xx不存在
            supportedCurrencies.push(_currencyCode);
            //添加货币到数组里面去 
        }
        conversionRates[_currencyCode] = _rateToEth;
        //添加的货币 的汇率添加到 货币汇率里
    }
    
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        //定义函数convertToEth 储存currencyCode 储存amount  公开 可读 返回Eth数量 
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        //条件 汇率大于0 不然货币就不存在
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        //定义eth数量 要其等于   数量*货币量
        return ethAmount;// 输出eth数量
    }
    function tipInEth() public payable {//定义函数 用eth打赏
        require(msg.value > 0, "Tip amount must be greater than 0");
       // 条件：用户发送的eth得大于0
        tipPerPerson[msg.sender] += msg.value;
        //记录每人打赏了多少，并且累加
        totalTipsReceived += msg.value; 
        //所有人一共打赏了多少eth
        tipsPerCurrency["ETH"] += msg.value;
        //每种货币一共收到多少eth

    }
    
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        //用某种货币打赏 定义这个函数 
        //储存 货币代码 储存货币数量 //payable 换算成eth
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        //条件：汇率大于0否则 货币不支持
        require(_amount > 0, "Amount must be greater than 0");
        //条件：打赏金额大于0 
        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        //计算应该发送多少eth 通过之前 定义的函数
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");
        //用户实际发送的eth
        tipPerPerson[msg.sender] += msg.value;
        //这个人打赏了多少eth
        totalTipsReceived += msg.value;
        //合约总打赏金额
        tipsPerCurrency[_currencyCode] += _amount;
        //每种货币打赏了多少
    }

    function withdrawTips() public onlyOwner {
        //提取打赏
        uint256 contractBalance = address(this).balance;
        //合约总打赏
        require(contractBalance > 0, "No tips to withdraw");
        //总打赏得大于0
        (bool success, ) = payable(owner).call{value: contractBalance}("");
       // 把owner变成可以接受eth得，并且通过call得方式交易
        require(success, "Transfer failed");
        //条件：成功，不然返回
        totalTipsReceived = 0;
        //将打赏清空
    }
  
    function transferOwnership(address _newOwner) public onlyOwner {
        //更换owner 
        require(_newOwner != address(0), "Invalid address");
        //owner地址不能为空
        owner = _newOwner;
        //将其换成新owner
    }

    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
        //获得支持得货币 短暂储存支持货币
    }
    

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
        //查看合约有多少eth获取合约余额
        
    }
    
   
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];//查看某个人打赏了多少eth
    }
    

    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
        //查看某种货币打赏看多少
    }

    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        //将某种货币 转化为eth汇率
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        //条件；汇率>0 确保货币存在
        return conversionRates[_currencyCode];
        
    }
}

//四大模块：管理员 打赏 提现 查询




