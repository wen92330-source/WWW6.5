//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract clickCounter{
    uint256 public counter;
    function click() public{
        counter++;
    }
    function reset1() public{
        counter=0;
    }
}
