//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {
  mapping (address => string) public latestAchievement;

  //set achievement for a user (called by PluginStore)
  function setAchievement(address user, string memory achievement) public {
    latestAchievement[user] = achievement;
  }
  //get achievement for a user (called by PluginStore)
  function getAchievement(address user) public view returns (string memory) {
    return latestAchievement[user];
  }
}