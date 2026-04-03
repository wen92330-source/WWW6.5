// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./day30_MiniDexPair.sol";

contract MiniDexFactory is Ownable {
    //通过createPair()创建新配对时触发
    event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint);
    //存储每个创建的配对的部署地址
    mapping(address => mapping(address => address)) public getPair;
    //存储创建的所有配对合约
    address[] public allPairs;

    constructor(address _owner) Ownable(_owner) {}

    //部署新的流动性池
    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        require(_tokenA != _tokenB, "Identical tokens");
        require(getPair[_tokenA][_tokenB] == address(0), "Pair already exists");

        // 为一致性排序代币：将DAI/WETH和WETH/DAI视为同一个配对
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);

        pair = address(new MiniDexPair(token0, token1));
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;

        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length - 1);
    }

    //获取创建的配对总数
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    //通过在列表中的位置检索特定的配对合约
    function getPairAtIndex(uint index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}

