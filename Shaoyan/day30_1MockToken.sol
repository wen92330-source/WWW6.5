// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 引入 OpenZeppelin 的标准 ERC20 实现
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockToken
 * @dev 用于测试环境的模拟代币，继承自 OpenZeppelin 的 ERC20 标淮
 */
contract MockToken is ERC20 {
    /**
     * @param name 代币名称 (例如: "Token A")
     * @param symbol 代币符号 (例如: "TKA")
     * @param initialSupply 初始发行量 (注意：输入时需考虑 decimals，通常为 18)
     */
    constructor(
        string memory name, 
        string memory symbol, 
        uint256 initialSupply
    ) ERC20(name, symbol) {
        // 将初始发行的代币全部铸造给部署者 (msg.sender)
        _mint(msg.sender, initialSupply);
    }

        /**
         * @dev 额外的铸造功能（可选），方便测试时获取更多代币
         */
        function mint(address to, uint256 amount) public {
            _mint(to, amount);
        }
    }