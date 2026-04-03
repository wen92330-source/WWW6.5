// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 Ownable：提供 owner 和 onlyOwner 权限控制
import "@openzeppelin/contracts/access/Ownable.sol";

// 引入池子合约：工厂负责部署 MiniDexPair
import "./Day30-MiniDexPair.sol";

/// @title MiniDexFactory - DEX 池子工厂
/// @notice 用于创建和管理 MiniDexPair 池子
contract MiniDexFactory is Ownable {

    // =========================================================
    // 状态变量
    // =========================================================

    // 保存所有已创建的池子
    // 类型是 MiniDexPair[]，说明数组里存的是 MiniDexPair 合约实例
    MiniDexPair[] public allPairs;

    // 记录两个 token 对应的池子地址
    // 例如：getPair[tokenA][tokenB] => pair 地址
    // 用双重 mapping 方便快速查找
    mapping(address => mapping(address => address)) public getPair;

    // =========================================================
    // 事件
    // =========================================================

    /// @notice 当新池子创建时触发
    /// @param tokenA 交易对中的第一个代币
    /// @param tokenB 交易对中的第二个代币
    /// @param pair 新创建的池子地址
    /// @param allPairsLength 当前池子总数
    event PairCreated(
        address indexed tokenA,
        address indexed tokenB,
        address pair,
        uint256 allPairsLength
    );

    // =========================================================
    // 构造函数
    // =========================================================

    /// @notice 部署工厂时设置 owner
    /// @param _owner 工厂所有者地址
    constructor(address _owner) Ownable(_owner) {}

    // =========================================================
    // 核心函数：创建池子
    // =========================================================

    /// @notice 创建新的交易对池子
    /// @dev 只有 owner 能创建，避免任意地址乱建池子
    /// @param _tokenA 第一个代币地址
    /// @param _tokenB 第二个代币地址
    /// @return pair 新创建出来的 MiniDexPair 地址
    function createPair(address _tokenA, address _tokenB)
        external
        onlyOwner
        returns (address pair)
    {
        // 不允许两个 token 一样
        // 否则就变成自己和自己组池，没有意义
        require(_tokenA != _tokenB, "Identical tokens");

        // 不允许传入零地址
        // 零地址通常表示无效地址
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address");

        // 检查这个交易对是否已经存在
        // 如果 getPair[_tokenA][_tokenB] 不是 0，说明之前已经创建过了
        require(getPair[_tokenA][_tokenB] == address(0), "Pair exists");

        // 部署一个新的 MiniDexPair 合约
        // 这里的 new 会在链上创建一个新的合约实例
        MiniDexPair newPair = new MiniDexPair(_tokenA, _tokenB);

        // 把池子地址记录到映射中
        // 正向记录：A => B => pair
        getPair[_tokenA][_tokenB] = address(newPair);

        // 反向也记录一次：B => A => pair
        // 这样无论用户查 A/B 还是 B/A，都能拿到同一个池子
        getPair[_tokenB][_tokenA] = address(newPair);

        // 把新池子加入数组，方便后续遍历和统计
        allPairs.push(newPair);

        // 触发事件，告诉外部“新池子已经创建”
        emit PairCreated(_tokenA, _tokenB, address(newPair), allPairs.length);

        // 返回新池子的地址
        return address(newPair);
    }

    // =========================================================
    // 查询函数
    // =========================================================

    /// @notice 返回当前总共有多少个池子
    /// @return 池子数量
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    /// @notice 根据索引返回池子地址
    /// @param index 池子在 allPairs 数组里的位置
    /// @return 对应池子的地址
    function getPairAtIndex(uint256 index) external view returns (address) {
        // 防止数组越界
        require(index < allPairs.length, "Index out of bounds");

        // 返回对应索引的池子地址
        return address(allPairs[index]);
    }
}