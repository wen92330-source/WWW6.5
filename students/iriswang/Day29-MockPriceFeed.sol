// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MockPriceFeed {
    
    int256 private price;
    uint8 public decimals = 8;
    
    constructor(int256 _price) {
        price = _price;
    }
    
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        return (0, price, 0, 0, 0);
    }
    
    function setPrice(int256 _price) external {
        price = _price;
    }
}
