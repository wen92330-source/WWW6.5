// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./day30_MiniDexPair.sol"; 

/**
 * @title MiniDexFactory
 * @dev 这是一个工厂合约，用于部署和管理 MiniDexPair 交易对。
 * 它确保了每种代币组合只对应一个唯一的交易对合约，并提供查询功能。
 */
contract MiniDexFactory is Ownable {
    // --- 事件 ---

    /// @notice 当一个新的交易对被创建时触发
    /// @param tokenA 代币 A 的地址
    /// @param tokenB 代币 B 的地址
    /// @param pairAddress 部署的交易对合约地址
    /// @param allPairsLength 当前工厂管理的交易对总数
    event PairCreated(address indexed tokenA, address indexed tokenB, address pairAddress, uint allPairsLength);

    // --- 状态变量 ---

    /// @notice 存储代币地址对到交易对合约地址的映射
    /// @dev 使用双向映射：getPair[tokenA][tokenB] 和 getPair[tokenB][tokenA] 都指向同一个地址
    mapping(address => mapping(address => address)) public getPair;
    
    /// @notice 存储所有已创建交易对地址的数组
    address[] public allPairs;

    /**
     * @dev 构造函数，初始化工厂所有者
     * @param _owner 指定拥有创建权限的管理员地址
     */
    constructor(address _owner) Ownable(_owner) {}

    /**
     * @notice 创建一个新的交易对合约
     * @param _tokenA 第一个代币地址
     * @param _tokenB 第二个代币地址
     * @return pair 返回新创建的交易对合约地址
     * @dev 逻辑：
     * 1. 检查地址合法性，防止重复创建。
     * 2. 对代币地址进行排序（token0 < token1），确保映射的一致性。
     * 3. 使用 `new` 关键字部署新的 MiniDexPair 合约。
     */
    function createPair(address _tokenA, address _tokenB) external onlyOwner returns (address pair) {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token address");
        require(_tokenA != _tokenB, "Identical tokens");
        require(getPair[_tokenA][_tokenB] == address(0), "Pair already exists");

        // 为了一致性对代币地址进行排序 (Solidity 中地址可以像数字一样比较大小)
        // 这样无论用户传入 (A, B) 还是 (B, A)，在系统里都是同一组 ID
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);

        // 部署新的交易对合约
        pair = address(new MiniDexPair(token0, token1));

        // 记录映射关系（存两次，方便双向查询）
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;

        // 将新地址存入全局数组
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length - 1);
    }

    /**
     * @notice 获取当前已创建的交易对总数
     */
    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    /**
     * @notice 根据索引从数组中查询交易对地址
     * @param index 索引值
     */
    function getPairAtIndex(uint index) external view returns (address) {
        require(index < allPairs.length, "Index out of bounds");
        return allPairs[index];
    }
}