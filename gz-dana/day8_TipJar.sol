// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TipJar {
    address public owner;
    uint256 public totalTipsInEth;
    
    struct Currency {
        string name;
        uint256 rate;
        bool isActive;
    }
    
    mapping(bytes32 => Currency) public currencies;
    bytes32[] public currencyList;
    
    struct Tip {
        address tipper;
        bytes32 currencyId;
        uint256 amount;
        uint256 ethValue;
        uint256 timestamp;
        string message;
    }
    
    Tip[] public tips;
    mapping(address => uint256) public tipperTotalEth;
    
    event CurrencyAdded(bytes32 indexed id, string name, uint256 rate);
    event TipReceived(address indexed tipper, bytes32 indexed currencyId, uint256 amount, uint256 ethValue);
    event Withdrawn(address indexed owner, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function addCurrency(bytes32 _id, string calldata _name, uint256 _rate) external onlyOwner {
        require(_rate > 0, "rate > 0");
        require(!currencies[_id].isActive, "exists");
        currencies[_id] = Currency(_name, _rate, true);
        currencyList.push(_id);
        emit CurrencyAdded(_id, _name, _rate);
    }
    
    function updateRate(bytes32 _id, uint256 _rate) external onlyOwner {
        require(currencies[_id].isActive, "not found");
        require(_rate > 0, "rate > 0");
        currencies[_id].rate = _rate;
    }
    
    function tipInEth(string calldata _msg) external payable {
        require(msg.value > 0, "send ETH");
        _record(msg.sender, bytes32(0), msg.value, msg.value, _msg);
    }
    
    function tipInCurrency(bytes32 _id, uint256 _amount, string calldata _msg) external payable {
        require(_amount > 0, "amount > 0");
        require(currencies[_id].isActive, "currency not found");
        
        uint256 ethNeeded = _amount * currencies[_id].rate;
        require(msg.value >= ethNeeded, "insufficient ETH");
        
        _record(msg.sender, _id, _amount, ethNeeded, _msg);
        
        if (msg.value > ethNeeded) {
            payable(msg.sender).transfer(msg.value - ethNeeded);
        }
    }
    
    function _record(address _tipper, bytes32 _cid, uint256 _amt, uint256 _eth, string memory _msg) internal {
        tips.push(Tip(_tipper, _cid, _amt, _eth, block.timestamp, _msg));
        totalTipsInEth += _eth;
        tipperTotalEth[_tipper] += _eth;
        emit TipReceived(_tipper, _cid, _amt, _eth);
    }
    
    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "no tips");
        payable(owner).transfer(bal);
        emit Withdrawn(owner, bal);
    }
    
    function convertToEth(bytes32 _id, uint256 _amount) external view returns (uint256) {
        require(currencies[_id].isActive, "not found");
        return _amount * currencies[_id].rate;
    }
    
    function getTipCount() external view returns (uint256) {
        return tips.length;
    }
    
    function getCurrencyCount() external view returns (uint256) {
        return currencyList.length;
    }
    
    receive() external payable {
        require(msg.value > 0, "send ETH");
        string memory emptyMsg = "";
        _record(msg.sender, bytes32(0), msg.value, msg.value, emptyMsg);
    }
}