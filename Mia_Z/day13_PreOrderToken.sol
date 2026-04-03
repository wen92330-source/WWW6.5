//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
// 本合约继承 MyToken（OpenZeppelin ERC20），使用 totalSupply()、decimals()、balanceOf(addr) 等函数接口
import "./day12_SimpleERC20_OpenZeppelin.sol";

contract PreOrderToken is MyToken {

    //这些定义很像C
    uint256 public tokenPrice;
    uint256 public saleStartTime;
    uint256 public saleEndTime;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public totalRaised;
    address public projectOwner;
    bool public finalized = false;
    bool private initialTransferDone = false;

    //定义事件 卖家索引 eth? token?
    event TokensPurchased(
        address indexed buyer,
        uint256 etherAmount,
        uint256 tokenAmount
    );
    // 结束事件 全部售出 总收益
    event SaleFinalized(uint256 totalRaised, uint256 totalTokensSold);

    constructor(
        //初始化 总供应量 价格 销售时间 最小购买量 最大购买量 项目所有者
        uint256 _intitialSupply,
        uint256 _tokenPrice,
        uint256 _saleDurationInSeconds,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        address _projectOwner
    ) MyToken(_intitialSupply) {
        
        tokenPrice = _tokenPrice;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _saleDurationInSeconds;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        projectOwner = _projectOwner;

        //初始化 将所有代币转移到合约地址
        _transfer(msg.sender, address(this), totalSupply());
        initialTransferDone = true;
    }
    //判断是否在销售时间
    function isSaleActive() public view returns (bool) {
        return (!finalized &&
            block.timestamp >= saleStartTime &&
            block.timestamp <= saleEndTime);
    }

    //购买代币
    function buyTokens() public payable {
        //判断是否在销售时间
        require(isSaleActive(), "Sale is not active");
        //判断是否达到最小购买量
        require(msg.value >= minPurchase, "Amount is below min purchase");
        //判断是否达到最大购买量
        require(msg.value <= maxPurchase, "Amount is above max purchase");
        //计算代币数量
        uint256 tokenAmount = (msg.value * 10 ** uint256(decimals())) /
            tokenPrice;
        require(
            balanceOf(address(this)) >= tokenAmount,
            "Not enough tokens left for sale"
        );
        totalRaised += msg.value;
        _transfer(address(this), msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
    //转移代币 override 重写 需要进一步解释 
    //子类重写父类函数，先做自己的检查再调用父类
    function transfer(
        address _to,
        uint256 _value
    ) public override returns (bool) {
         // 预售未结束 且 不是合约自己 且 初始化已完成 → 禁止普通用户互相转
        if (!finalized && msg.sender != address(this) && initialTransferDone) {
            require(false, "Tokens are locked until sale is finalized");
        }
        //super 调用父类函数
        // 再调用父类（OpenZeppelin）的 transfer
        return super.transfer(_to, _value);
    }

    //转移代币 from 从哪里来 to 到哪里去 value 多少 代转账
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        if (!finalized && _from != address(this)) {
            require(false, "Tokens are locked until sale is finalized");
        }
        return super.transferFrom(_from, _to, _value);
    }

    //结束销售
    // 1. 检查：调用者是 projectOwner
    // 2. 检查：尚未 finalize，且当前时间已超过 saleEndTime
    // 3. finalized = true;
    // 4. 把合约里所有 ETH 转给 projectOwner（call{value: ...} 相当于低级别转账）
    // 5. 发出 SaleFinalized 事件
    function finalizeSale() public payable {
        //判断是否是项目所有者
        require(
            msg.sender == projectOwner,
            "Only owner can call this function"
        );
        require(!finalized, "Sale is already finalized");
        require(block.timestamp > saleEndTime, "Sale not finished yet");
        finalized = true;
        uint256 tokensSold = totalSupply() - balanceOf(address(this));
        (bool sucess, ) = projectOwner.call{value: address(this).balance}("");
        require(sucess, "Transfer failed");
        emit SaleFinalized(totalRaised, tokensSold);
    }
    //剩余时间
    function timeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTime) {
            return 0;
        }
        return (saleEndTime - block.timestamp);
    }
    //剩余代币
    function tokensAvailable() public view returns (uint256) {
        return balanceOf(address(this));
    }
    //接收eth
    receive() external payable {
        buyTokens();
    }
}
