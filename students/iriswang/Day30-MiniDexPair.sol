// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Day30-IERC20.sol";
import "./Day30-ReentrancyGuard.sol";

contract MiniDexPair is ReentrancyGuard {

    address public tokenA;
    address public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public totalLPSupply;

    mapping(address => uint256) public lpBalances;

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        uint256 lp = amountA + amountB;

        lpBalances[msg.sender] += lp;
        totalLPSupply += lp;

        _update();
    }

    function swap(uint256 amountIn, address inputToken) external nonReentrant {
        require(inputToken == tokenA || inputToken == tokenB, "Invalid token");

        address outputToken = inputToken == tokenA ? tokenB : tokenA;

        IERC20(inputToken).transferFrom(msg.sender, address(this), amountIn);

        uint256 amountOut = amountIn;

        IERC20(outputToken).transfer(msg.sender, amountOut);

        _update();
    }

    function _update() private {
        reserveA = IERC20(tokenA).balanceOf(address(this));
        reserveB = IERC20(tokenB).balanceOf(address(this));
    }
}
