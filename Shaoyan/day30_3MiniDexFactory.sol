// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniDexPair {
    address public token0;
    address public token1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }
}

contract MiniDexFactory {
    // 跟踪所有配对：tokenA => tokenB => pairAddress
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 pairIndex);

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Identical tokens");
        
        // 排序地址以确保映射的一致性
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Zero address");
        require(getPair[token0][token1] == address(0), "Pair already exists");

        // 部署新的配对合约
        pair = address(new MiniDexPair(token0, token1));

        // 存储配对信息
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // 反向映射，方便双向查询
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    // 获取已创建交易对的总数
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    // 通过索引获取交易对地址
    function getPairAtIndex(uint256 index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}