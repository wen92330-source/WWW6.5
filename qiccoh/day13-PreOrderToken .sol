//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./day12-SimpleERC20.sol";

contract PreOrderToken is SimpleERC20 {

uint256 public tokenPrice;
uint256 public saleStartTime;
uint256 public saleEndTime;
uint256 public minPurchase;
uint256 public maxPurchase;
uint256 public totalRaised;
address public projectOwner;
bool public finalized = false;
bool private initialTransferDone = false;

event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);
// 成功购买代币时触发。它会记录购买者、支付的 ETH 数量以及收到的代币数量
event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);
// 发售结束时触发。记录筹集的 ETH 总数和售出的代币数量

//父类中有需要参数的构造函数,这里必须提供参数
// 构造函数里，程序会自动地将所有代币从部署者（你）转移至合约里
constructor(
    // 为何要写两遍? 
    // 定义参数列表,告诉编译器构造函数需要参数
    uint256 _initialSupply,
    uint256 _tokenPrice,
    uint256 _saleDurationInSeconds,
    uint256 _minPurchase,
    uint256 _maxPurchase,
    address _projectOwner
) SimpleERC20(_initialSupply) {
    // 使用这些参数来初始化合约的状态变量
    tokenPrice = _tokenPrice;
    saleStartTime = block.timestamp;
    saleEndTime = block.timestamp + _saleDurationInSeconds;//设置销售时间
    // 限制最小\最大购入
    minPurchase = _minPurchase;
    maxPurchase = _maxPurchase;
    projectOwner = _projectOwner;

    // 将所有代币转移至此合约用于发售
    _transfer(msg.sender, address(this), totalSupply);

    // 标记我们已经从部署者那里转移了代币,“代币分发员”
    initialTransferDone = true;
}
// 是否在销售期
function isSaleActive() public view returns (bool) {
    return (!finalized && block.timestamp >= saleStartTime && block.timestamp <= saleEndTime);
}
// 核心-->销售函数
function buyTokens() public payable {
    // 是否在购买
    require(isSaleActive(), "Sale is not active");
    // 限制最低最高
    require(msg.value >= minPurchase, "Amount is below minimum purchase");
    require(msg.value <= maxPurchase, "Amount exceeds maximum purchase");
//  计算代币?
    uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;
    require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale");
//算出买家能收到的代币数量
    totalRaised += msg.value;
    // 代币转给买家
    _transfer(address(this), msg.sender, tokenAmount);
    // 触发购买事件
    emit TokensPurchased(msg.sender, msg.value, tokenAmount);
}
// 重写transfer,在发售进行期间暂时限制代币转账
function transfer(address _to, uint256 _value) public override returns (bool) {
    // 交易不是由合约本身发起的msg.sender != address(this)
    if (!finalized && msg.sender != address(this) && initialTransferDone) {
        // 如果这三个条件都满足，函数会回滚，交易会被撤销 
        require(false, "Tokens are locked until sale is finalized");
    }
    // 只需调用父合约的原始 transfer() 函数。这会执行实际的转账逻辑。
    return super.transfer(_to, _value);
}
// 重写 transferFrom() — 锁定委托转账
function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
    if (!finalized && _from != address(this)) {
        require(false, "Tokens are locked until sale is finalized");
    }
    // 即使是已获批准的消费者，也不能在发售期间以他人的名义转移代币
    return super.transferFrom(_from, _to, _value);
}
// 结束发币
function finalizeSale() public payable {
    // 人`时间`事件
    require(msg.sender == projectOwner, "Only Owner can call the function");
    require(!finalized, "Sale already finalized");
    require(block.timestamp > saleEndTime, "Sale not finished yet");
//标记发售结束
    finalized = true;
// 计算已售出的代币数量 总-合约当前持有的代币余额（即尚未售出部分）=用户拿走的代币
    uint256 tokensSold = totalSupply - balanceOf[address(this)];
// 向项目所有者发送 ETH
    (bool success, ) = projectOwner.call{value: address(this).balance}("");
    require(success, "Transfer to project owner failed");
// - 筹集的 ETH总额\售出的代币数量
    emit SaleFinalized(totalRaised, tokensSold);
}
// 查询多久结束发售
function timeRemaining() public view returns (uint256) {
    if (block.timestamp >= saleEndTime) {
        return 0;
    }
    return saleEndTime - block.timestamp;
}
//代币库存
function tokensAvailable() public view returns (uint256) {
    return balanceOf[address(this)];
}
// - 有人**直接**向合约地址发送 ETH
// - 且**未指定**要调用的任何函数
// 允许ETH流入，并将 ETH 直接路由到代币销售逻辑中
// receive() 就是一个见钱就干活的自动开关。它让合约变得更聪明，只要收到钱，就自动去执行你设定好的任务
receive() external payable {
    buyTokens();
}



}


