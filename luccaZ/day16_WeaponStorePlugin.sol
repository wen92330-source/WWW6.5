//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WeaponStorePlugin {
  mapping (address => string) public equippedWeapon;
  //set weapon for a user (called by PluginStore)
  function setWeapon(address user, string memory weapon) public {
    equippedWeapon[user] = weapon;
  }
  //get weapon for a user (called by PluginStore)
  function getWeapon(address user) public view returns (string memory) {
    return equippedWeapon[user];
  }
}