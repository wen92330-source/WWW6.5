
// SPDX-License-Identifier: MIT


pragma solidity ^0.8.20;

//OpenZeppelin继承版
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

}

