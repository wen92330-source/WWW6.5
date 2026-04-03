// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day13_SimpleERC20.sol";

// 代币预售合约 - 继承 SimpleERC20，增加了预售、锁定、结算机制
contract SimplifiedTokenSale is SimpleERC20 {

    // 预售参数
    uint256 public tokenPrice;         // 代币单价（wei/个）
    uint256 public saleStartTime;      // 预售开始时间（时间戳，可以设置为未来某个时间）
    uint256 public saleEndTime;        // 预售结束时间（时间戳）
    uint256 public minPurchase;        // 单次最低购买金额（wei）
    uint256 public maxPurchase;        // 单次最高购买金额（wei）
    uint256 public totalRaised;        // 已募集 ETH 总额（wei）
    address public projectOwner;       // 项目方地址
    bool public finalized = false;     // 预售是否已结算
    bool private initialTransferDone = false;  // 初始代币转移是否完成（避免构造函数中锁定逻辑误触发）

    // 事件
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    // 构造函数
    // SimpleERC20(_initialSupply)：先调用父合约构造函数铸造代币
    constructor(
        uint256 _initialSupply,        // 代币总发行量（整数，如 1000000）
        uint256 _tokenPrice,           // 代币单价（wei）
        uint256 _saleStartTime,        // 预售开始时间（时间戳，可设为未来时间实现"定时开售"）
        uint256 _saleDuration,         // 预售持续时间（秒）
        uint256 _minPurchase,          // 单次最低购买额（wei）
        uint256 _maxPurchase           // 单次最高购买额（wei）
    ) SimpleERC20(_initialSupply) {
        tokenPrice = _tokenPrice;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleStartTime + _saleDuration;  // 开始时间 + 持续时间 = 结束时间
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = msg.sender;     // 部署者即为项目方

        // 将所有代币从部署者转到合约地址，合约充当"代币池"
        _transfer(msg.sender, address(this), totalSupply);
        initialTransferDone = true;    // 标记完成，之后代币锁定逻辑开始生效
    }

    // 判断预售是否正在进行
    function isSaleActive() public view returns (bool) {
        return block.timestamp >= saleStartTime &&   // 已到开始时间
               block.timestamp <= saleEndTime &&     // 未超过结束时间
               !finalized;                           // 尚未结算
    }

    // 购买代币 - 用户发送 ETH 换取代币
    function buyTokens() public payable {
        require(isSaleActive(), "Sale not active");
        // 合并了最低和最高购买限制的检查（更简洁的写法）
        require(msg.value >= minPurchase && msg.value <= maxPurchase, "Invalid purchase amount");

        // 计算能买到多少代币
        // 公式：(支付的 ETH * 10^18) / 单价 = 代币数量（带精度）
        uint256 tokenAmount = (msg.value * 10 ** uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= tokenAmount, "Insufficient tokens"); // 检查库存

        _transfer(address(this), msg.sender, tokenAmount); // 从合约转代币给买家
        totalRaised += msg.value;                           // 累加募集总额

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    // 重写 transfer - 预售期间锁定代币，禁止用户之间互相转账
    // override：覆盖父合约 SimpleERC20 中标记为 virtual 的同名函数
    function transfer(address _to, uint256 _value) public override returns (bool) {
        // 三个条件同时满足时锁定：未结算 && 调用者不是合约自身 && 初始转移已完成
        // 合约自身不受限制，因为预售过程中合约需要把代币转给买家
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        // super.transfer()：调用父合约 SimpleERC20 的原始 transfer 逻辑
        return super.transfer(_to, _value);
    }

    // 重写 transferFrom - 同样在预售期间锁定授权转账
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        if (!finalized && _from != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    // 结算预售 - 预售结束后由项目方调用
    function finalizeSale() public payable {
        require(msg.sender == projectOwner, "Only owner");        // 仅项目方
        require(block.timestamp > saleEndTime, "Sale not ended"); // 预售必须已结束
        require(!finalized, "Already finalized");                 // 不能重复结算

        finalized = true;  // 标记已结算，代币转账锁定解除

        // 将合约中所有 ETH 转给项目方
        (bool success, ) = projectOwner.call{value: address(this).balance}("");
        require(success, "Transfer failed");

        // totalSupply - 合约剩余代币 = 已售出的代币数量
        emit SaleFinalized(totalRaised, totalSupply - balanceOf[address(this)]);
    }

    // 查询预售剩余时间（秒）
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) return 0;
        return saleEndTime - block.timestamp;
    }

    // 查询合约中剩余可售代币数量
    function tokensAvailable() public view returns (uint256) {
        return balanceOf[address(this)];
    }

    // receive 函数 - 用户直接向合约转 ETH 时自动调用 buyTokens()
    // 这样用户不需要知道函数名，直接转账就能买到代币
    receive() external payable {
        buyTokens();
    }
}