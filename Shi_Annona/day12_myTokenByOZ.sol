//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;//attention: openzeppelin require version over 0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20Token is ERC20{
    constructor(uint256 initialSupply) ERC20("My Token","MTK"){
        _mint(msg.sender, initialSupply*(10**decimals()));
    }

}