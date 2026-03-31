// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Day30-Ownable.sol";
import "./Day30-MiniDexPair.sol";

contract MiniDexFactory is Ownable {

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address tokenA, address tokenB, address pair);

    function createPair(address tokenA, address tokenB)
        external
        onlyOwner
        returns (address pair)
    {
        require(tokenA != tokenB, "Same token");

        pair = address(new MiniDexPair(tokenA, tokenB));

        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;

        allPairs.push(pair);

        emit PairCreated(tokenA, tokenB, pair);
    }
}
