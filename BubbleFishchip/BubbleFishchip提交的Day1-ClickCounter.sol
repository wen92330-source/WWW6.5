// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract ClickCounter{

    uint256 public counter ;

    // 1.增加计数
    function click() public 
    {
        counter++;
    }

    // 2.重置为0
    function reset() public 
    {
        counter = 0;
    }

    // 3.计数-1
    function decrease() public 
    {
        require(counter > 0, "Counter is already zero!");
        counter--;
    }

    // 4. 返回当前计数
    function getCounter() public view returns (uint256)
    { 
        return counter;
    } 

    // 5. 一次增加多次
    function clickMultiple(uint256 times) public 
    {
        counter+=times;
    }
}
