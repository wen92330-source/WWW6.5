//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar{
    address public owner;
    string[] public supportedCurrencies;
    // 此映射存储从货币代码（如“USD”）到 ETH 的汇率
    mapping(string => uint256) public conversionRates;
    // 这个动态数组帮助我们跟踪我们添加的所有货币代码
    uint256 public totalTipsReceived;
    // 这个变量告诉我们合约总体上收集了多少 ETH（以 wei 为单位）
    mapping(address => uint256) public tipperContributions;
//    这存储了每个地址在小费中发送了多少 ETH
    mapping(string => uint256) public tipsPerCurrency;
    // 这跟踪了每种货币的小费金额。因此，如果有人发送等值 2000 美元，我们会在“USD”条目下存储“2000”。

    modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
}


function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
    require(_rateToEth > 0, "Conversion rate must be greater than 0");

    // 检查代笔类是否存在
    bool currencyExists = false;
    for (uint i = 0; i < supportedCurrencies.length; i++) {
        if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
            currencyExists = true;
            break;
        }
    }

    // 不存在则加入货币类别里面
    if (!currencyExists) {
        supportedCurrencies.push(_currencyCode);
    }

    // 更新汇率
    conversionRates[_currencyCode] = _rateToEth;
}

//在构造函数中使用它来实际预加载一些值并存储合约所有者地址
constructor() {
    owner = msg.sender;

    addCurrency("USD", 5 * 10**14);
    addCurrency("EUR", 6 * 10**14);
    addCurrency("JPY", 4 * 10**12);
    addCurrency("GBP", 7 * 10**14);
}
// solidity内无小数，放大倍数存储1 ETH = 1,000,000,000,000,000,000 wei = 10^18 wei

// memory _currencyCode汇率名，换的钱uint256 _amount
function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");

    uint256 ethAmount = _amount * conversionRates[_currencyCode];
    return ethAmount;
}

//用 ETH 发送小费
function tipInEth() public payable {
    require(msg.value > 0, "Tip amount must be greater than 0");
// 1. 记录了该特定用户迄今为止在 `tipperContributions`中的贡献。
// 2. 它更新了 `totalTipsReceived`，这是合约曾经收到的所有 ETH 的运行总数。
// 3. 它将小费添加到 `tipsPerCurrency` 中的`"ETH"` 桶中，因此我们可以将 ETH 小费与美元或其他货币分开跟踪
    tipperContributions[msg.sender] += msg.value;
    totalTipsReceived += msg.value;
    tipsPerCurrency["ETH"] += msg.value;
}
// - `msg.value` 是与函数调用一起发送的 ETH 数量（以 wei 为单位）。
// - `payable` 关键字允许函数实际接收 ETH。如果没有它，该函数将拒绝发送的任何以太币。
// - 我们首先检查`msg.value > 0`。这可以防止用户发送 0 ETH 小费

// 外币小费


function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
   //1、货币种类存在 2、钱大于0
    require(conversionRates[_currencyCode] > 0, "Currency not supported");
    require(_amount > 0, "Amount must be greater than 0");
// 转换成ETH
    uint256 ethAmount = convertToEth(_currencyCode, _amount);
    // 函数检查msg.value 即随交易发送的实际 ETH）是否与预期金额匹配？验证
    require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

    tipperContributions[msg.sender] += msg.value;
    totalTipsReceived += msg.value;
    tipsPerCurrency[_currencyCode] += _amount;
}
// 提现小费

function withdrawTips() public onlyOwner {
    // 获取合约当前的 ETH 余额。如果没有什么可提取的，该功能会立即停止。
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "No tips to withdraw");
// 将全部余额发送给合约的 owner “所有者”？
    (bool success, ) = payable(owner).call{value: contractBalance}("");
    // .call{value: contractBalance}("")：使用 call 方法将 contractBalance 以太币发送到 owner 地址
    // (bool success, )：call 方法返回一个布尔值 success，表示交易是否成功。
    require(success, "Transfer failed");

    totalTipsReceived = 0;
}

// 转让所有权
function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Invalid address");
    owner = _newOwner;
}

// 从合约中获取信息
//返回合约中的货币代码
function getSupportedCurrencies() public view returns (string[] memory) {
    return supportedCurrencies;
}

// 合约当前持有多少 ETH
function getContractBalance() public view returns (uint256) {
    return address(this).balance;
}
// 传入地址，返回总贡献榜/wei
function getTipperContribution(address _tipper) public view returns (uint256) {
    return tipperContributions[_tipper];
}


//返回当前汇率
function getConversionRate(string memory _currencyCode) public view returns (uint256) {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");
    return conversionRates[_currencyCode];
}








}