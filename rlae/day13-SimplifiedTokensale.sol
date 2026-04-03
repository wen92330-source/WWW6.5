// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./day13-ERC20.sol";
//get inheritated from SimpleERC20
contract SimplifiedTokenSale is SimpleERC20 {
    uint256 public tokenPrice; //每个代币值多少 ETH（单位是 wei，1 ETH = 10¹⁸ wei）
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner; //收钱人的钱包地址
    bool public finalized = false; //发售是否已经正式关闭
    bool private initialTransferDone = false; // 变量用于确定锁定转账前已收到所有代币
    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);// why alaways need 2 variables to reprenst amount?
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold); //ETH (totalRaised), token (totalTokensSold) 展示发售的实时动态
    constructor( 
    // constructor use "," instead of ";"
    uint256 _intitialSupply,// 造钱的初始值
    uint256 _tokenPrice,   
    uint256 _saleDurationInSeconds,
    uint256 _minPurchase,
    uint256 _maxPurchase,
    address _projectOwner
    ) SimpleERC20(_intitialSupply){  // 造钱的初始值
    tokenPrice = _tokenPrice;
    saleStartTime = block.timestamp;
    saleEndTime = block.timestamp + _saleDurationInSeconds;
    minPurchase = _minPurchase; //unit wei
    maxPurchase = _maxPurchase; //unit wei
    projectOwner = _projectOwner;
    // 将所有代币转移至此合约用于发售
    _transfer(msg.sender, address(this), totalSupply); //address(this) 此合约的地址 // from owner to this contractor
    initialTransferDone= true; // 标记从部署者那里转移了代币success

}
function isSaleActive() public view returns (bool) {
    return(!finalized&& block.timestamp >= saleStartTime && block.timestamp <= saleEndTime); //发售还没结束&&时间必须在发售时间窗口内
}
// add payable use RTH for trade
function buyTokens() public payable {
    require(isSaleActive(), "Sale is not active");
    require(msg.value >= minPurchase, "Amount is below minimum purchase");
    require(msg.value <= maxPurchase, "Amount exceeds maximum purchase");
    uint256 tokenAmount = (msg.value * 10**uint256(decimals)) / tokenPrice;//计算买家发送的 ETH 应该获得多少代币 
    require(balanceOf[address(this)] >= tokenAmount, "Not enough tokens left for sale"); //check合约里是否持有足够的代币来满足请求
    totalRaised += msg.value; //ETH total added
    _transfer(address(this), msg.sender, tokenAmount); // from this to buyer
    emit TokensPurchased(msg.sender, msg.value, tokenAmount);
}
//re-write trasnfer()锁定直接转
function transfer(address _to, uint256 _value) public override returns (bool) { //override The override keyword is used to indicate that this function is overriding a function from the parent contract (SimpleERC20 in this case).
    if (!finalized && msg.sender != address(this) && initialTransferDone) { // 发售尚未完成 && 交易不是由合约本身发起的 && 初始代币供应已经转移到合约中
        require(false, "Tokens are locked until sale is finalized"); // the above if condition need to be false, or revert
    }
    return super.transfer(_to, _value); //正常转账,调用母合约的原始 transfer() 函数

}
function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
    if (!finalized && _from != address(this)) { //  发售尚未完成 && from the address 不等于本合约，使是已获批准的消费者，也不能在发售期间以他人的名义转移代币。
        require(false, "Tokens are locked until sale is finalized");
    }
    return super.transferFrom(_from, _to, _value);
}
function finalizeSale() public payable {
    require(msg.sender == projectOwner, "Only Owner can call the function");
    require(!finalized, "Sale already finalized");
    require(block.timestamp > saleEndTime, "Sale not finished yet");
    finalized= true;
    uint256 tokensSold = totalSupply - balanceOf[address(this)];
    (bool success, ) = projectOwner.call{value: address(this).balance}("");//把发售期间筹集到的全部 ETH 转给  projectOwner
    require(success, "Transfer to project owner failed");
    emit SaleFinalized(totalRaised, tokensSold);
}
function timeRemaining() public view returns (uint256) {
    if (block.timestamp >= saleEndTime) {
        return 0;
    }
    return saleEndTime - block.timestamp; //显示倒计时
}
function tokensAvailable() public view returns (uint256) {
    return balanceOf[address(this)]; //返回当前可购买的代币数量
}
receive() external payable { //特殊的回退函数，在满足以下条件时被触发(有人直接向合约地址发送 ETH &&未指定要调用的任何函数)
    buyTokens();
}

} 
