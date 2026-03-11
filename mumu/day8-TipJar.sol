// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TipJar
 * @author mumu
 * @notice 支持多种货币的小费罐
 * @dev 这是一个支持多货币的小费罐。用户可以用ETH或其他货币(USD、EUR等)给小费,合约会自动转换为ETH。Owner可以提取所有小费。

*/

contract TipJar{
    address public owner;
    //转换汇率map
    mapping(string => uint256) public exchangeRates; // 货币代码 => 转换为ETH的汇率（一个ETH对应多少该货币，例如：1 ETH = 2000 USD）
    // 当前支持哪些货币
    string[] public supportedCurrencies;
    //每个人给小费的记录
    mapping(address => uint256) public tipsGiven; // 用户地址 => 以ETH为单位的小费总额
    // 每种货币的小费记录
    mapping(string => uint256) public tipsByCurrency; // 货币代码 => 以该货币单位的小费总额

    // 事件记录
    event TipGiven(address indexed tipper, string currency, uint256 amountInCurrency);
    event TipsWithdrawn(address indexed owner, uint256 amountInEth);
    event PartialTipsWithdrawn(address indexed owner, uint256 amountInEth);
    event TipRefunded(address indexed tipper, string currency, uint256 amountInCurrency, uint256 amountInEth);

    constructor() {
        owner = msg.sender;
        // 首先支持ETH作为默认货币，汇率为1:1
        exchangeRates["ETH"] = 1; // 1 ETH = 1
        supportedCurrencies.push("ETH");
        // // 初始化一些常见货币的汇率（假设1 USD = 0.0005 ETH, 1 EUR = 0.0006 ETH）
        // exchangeRates["USD"] = 2000; // 0.0005 ETH
        // exchangeRates["EUR"] = 1666; // 0.0006 ETH
        // supportedCurrencies.push("USD");
        // supportedCurrencies.push("EUR");
    }

    // modifier: onlyOwner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 添加或更新货币汇率
    function setExchangeRate(string memory _currency, uint256 _rateIn) public onlyOwner {
        exchangeRates[_currency] = _rateIn;
        // 如果是新货币，添加到支持列表
        bool exists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currency))) {
                exists = true;
                break;  
            }
        }

        if (!exists) {
            supportedCurrencies.push(_currency);
        }
    }

    // updateExchangeRate函数：更新现有货币的汇率
    function updateExchangeRate(string memory _currency, uint256 _newRateIn) public onlyOwner {
        require(exchangeRates[_currency] > 0, "Currency not supported");
        exchangeRates[_currency] = _newRateIn;
    }

    // 获取所有支持的货币列表
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }

    // convertToEth函数：将指定货币金额转换为ETH
    function convertToEth(string memory _currency, uint256 _amount) public view returns (uint256) {
        uint256 rate = exchangeRates[_currency];
        require(rate > 0, "Unsupported currency");
        return (_amount * 1 ether) / rate; // 计算转换后的ETH金额，注意乘以1 ether来保持单位一致
    }

    // 给小费函数，用户可以选择货币类型和金额
    function giveTip(string memory _currency, uint256 _amount) public payable {
        require(exchangeRates[_currency] > 0, "Unsupported currency");
        uint256 tipInETH = convertToEth(_currency, _amount);
        require(msg.value >= tipInETH, "Insufficient ETH sent for the tip");

        // 更新小费记录
        tipsGiven[msg.sender] += tipInETH; // 以ETH为单位记录用户的小费总额
        tipsByCurrency[_currency] += _amount;   
        // 如果用户发送的ETH超过了小费金额，退回多余的部分
        if (msg.value > tipInETH) {
            uint256 refundAmount = msg.value - tipInETH;
            (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
            require(success, "Refund failed");
        }
        
        emit TipGiven(msg.sender, _currency, _amount);
    }

    // 提取小费函数，只有owner可以提取
    function withdrawTips() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No tips to withdraw");
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed");

        emit TipsWithdrawn(owner, balance);
    }

    // 获取用户给的小费总额（验证
    function getUserTips(address _user) public view returns (uint256) {
        return tipsGiven[_user];
    }

    // 获取每种货币的小费总额
    function getTipsByCurrency(string memory _currency) public view returns (uint256) {
        return tipsByCurrency[_currency];
    }

    // 获取小费罐的总余额（验证
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 实现removeCurrency函数，允许owner移除不再支持的货币
    function removeCurrency(string memory _currency) public onlyOwner {
        require(exchangeRates[_currency] > 0, "Currency not supported");
        delete exchangeRates[_currency];
        // 从支持列表中移除
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currency))) {
                supportedCurrencies[i] = supportedCurrencies[supportedCurrencies.length - 1]; // 用最后一个元素覆盖要移除的元素
                supportedCurrencies.pop(); // 移除最后一个元素
                break;
            }
        }
    }

    // // 实现部分提取功能
    // function withdrawPartialTips(uint256 _amountInEth) public onlyOwner {
    //     uint256 balance = address(this).balance;
    //     require(_amountInEth <= balance, "Insufficient tips to withdraw");
    //     (bool success, ) = payable(owner).call{value: _amountInEth}("");
    //     require(success, "Withdrawal failed");
        
    //     // 触发事件
    //     emit PartialTipsWithdrawn(owner, _amountInEth);
    // }
    // 实现部分提取功能
    function withdrawPartialTips(uint256 _amountInEth) public onlyOwner {
        uint256 amount = _amountInEth * 1 ether;
        uint256 balance = address(this).balance;
        require(amount <= balance, "Insufficient tips to withdraw");
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Withdrawal failed");
        // 触发事件
        emit PartialTipsWithdrawn(owner, amount);
    }

    // 添加退款功能
    function refundTip(address _tipper, string memory _currency, uint256 _amount) public onlyOwner {
        require(exchangeRates[_currency] > 0, "Unsupported currency");
        uint256 tipInETH = convertToEth(_currency, _amount);
        require(tipsGiven[_tipper] >= tipInETH, "Tipper has not given enough tips to refund");

        // 更新小费记录
        tipsGiven[_tipper] -= tipInETH; // 以ETH为单位更新用户的小费总额
        tipsByCurrency[_currency] -= _amount; // 更新该货币的小费总额

        // 退款给用户
        (bool success, ) = payable(_tipper).call{value: tipInETH}("");
        require(success, "Refund failed");

        // 触发事件
        emit TipRefunded(_tipper, _currency, _amount, tipInETH);
    }
}


/**
知识点：
1. ETH的单位体系 Wei； solidity不支持小数
    1 ETH = 1e18 Wei  （常用单位
    1 gWei = 1e9 Wei （Gas价格单位

2. 货币转换计算
    首先需要确定转换汇率：这里假设 1ETH = USD
    10 USD ÷ (2000 USD/ETH) = 0.005 ETH
    = 0.005 × 10^18 wei
    = 5,000,000,000,000,000 wei

3. keccak256-字符串的比较
    keccak256:实际上是比较两个字符串的哈希值(类似摘要)
✅ Keccak256的其他用途:
    生成唯一ID
    Merkle树验证
    签名验证

拓展题：todo
1. 实现小费排行榜
2. 集成Chainlink获取实时汇率，自动更新exchangeRates
 */