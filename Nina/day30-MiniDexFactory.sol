/** ### 池子创建者

一旦我们理解了单个配对合约的工作原理，我们就会将其提升到下一个级别。
我们不会为每个代币组合手动部署新的配对合约，而是构建一个工厂：
- 可以**动态创建**新的MiniDexPair合约
- 跟踪**所有现有配对**
- 确保没有重复的池子
- 让我们探索像Uniswap这样的协议如何扩展到数千个配对

这个合约——`MiniDexFactory`——是我们DEX系统的支柱。它是让我们**动态创建新流动性池**的部分，无论何时需要任何代币配对。
这是高级逻辑：
- 只有合约所有者可以创建新配对（目前）
- 当调用`createPair()`时，它使用给定代币启动新的`MiniDexPair`
- 它将该配对的地址存储在映射中，以便我们稍后可以获取它
- 它确保**不创建重复配对**（例如，`DAI/WETH`和`WETH/DAI`应该被视为相同）
- 它用`PairCreated`事件记录一切
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./day30-MiniDexPair.sol"; // 假设MiniDexPair.sol在同一目录中

contract MiniDexFactory is Ownable {
    event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint);

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    constructor(address _owner) Ownable(_owner) {}

    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        require(_tokenA != _tokenB, "Identical tokens");
        require(getPair[_tokenA][_tokenB] == address(0), "Pair already exists");

        // 代币排序 -> 一致性
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA); // 无论用户输入顺序，都是唯一配对

        // 部署配对合约 - new 关键字用来在区块链上“实例化”并部署一个合约
        pair = address(new MiniDexPair(token0, token1));

        // 存储配对
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        
        emit PairCreated(token0, token1, pair, allPairs.length - 1);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPairAtIndex(uint index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}

