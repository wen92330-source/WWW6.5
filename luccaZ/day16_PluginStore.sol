//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PluginStore {
  struct PlayerProfile {
    string name;
    string avatar;
  }

  mapping (address => PlayerProfile) public profiles;
  //==Multi Plugin==
  mapping(string => address) public plugins;

  //== Core Profile ==
  function setProfile(string memory _name, string memory _avatar) external {
    profiles[msg.sender] = PlayerProfile(_name, _avatar); 
  }

  function getProfile(address user) external view returns (string memory, string memory) {
    PlayerProfile memory profile = profiles[user];
    return (profile.name, profile.avatar);
  }

  //== Plugin System ==
  function registerPlugin(string memory key, address pluginAddress) external {
    plugins[key] = pluginAddress;
  }

  function getPlugin(string memory key) external view returns (address) {
    return plugins[key];
  }

  //== Plugin Execution ==
  function runPlugin(
    string memory key, 
    string memory functionSignature,
    address user,
    string memory argument
  ) external {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not found");

    bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
    (bool success, ) = plugin.call(data); //send the user and argument to the plugin function
    require(success, "Plugin execution failed");
  }

  function runPluginView(
    string memory key, 
    string memory functionSignature,
    address user
  ) external view returns (string memory) {
    address plugin = plugins[key];
    require(plugin != address(0), "Plugin not found");

    bytes memory data = abi.encodeWithSignature(functionSignature, user);
    (bool success, bytes memory result) = plugin.staticcall(data); //only read data
    require(success, "Plugin execution failed");

    return abi.decode(result, (string)); //convert the result back to string
  }

}