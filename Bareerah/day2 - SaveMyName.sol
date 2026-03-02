// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SaveMyName{
    string name;
    string bio;

    function add(string memory _name, string memory _bio) public {
        name = _name;
        bio = _bio;
    }
    function retrieve() public view returns (string memory, string memory) {
        return (name, bio);
    }

    // function contains add() and retrieve()
    function saveMyName(string memory _name, string memory _bio) public returns(string memory, string memory) {
        name = _name;
        bio = _bio;
        return (name, bio);
    }

    // Exercises
    function getName() view public returns(string memory) {
        return name;
    }

    function getBio() view public returns(string memory) {
        return bio;
    }

    function updateName(string memory _newName) public {
        name = _newName;
    }

}