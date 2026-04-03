// SPDX-License-Identifier:MIT
pragma solidity^0.8.0;

contract SaveMyName{
    // 状态变量-将姓名、简介、年龄永久存储在区块链上
    string name;
    string bio;
    uint age;
    // 1.添加、更新数据
    function add(string memory _name, string memory _bio, uint256 _age) public 
    {
        name=_name;
        bio=_bio;
        age=_age;
    }
    // 2.只读函数-检索数据
    function retrieve() public view returns (string memory, string memory, uint256)
    {
        return (name, bio, age);
    }
    // 3.只读函数-返回姓名
    function getName() public view returns (string memory)
    {
        return name;
    }
    // 4.只读函数-返回简介
    function getBio() public view returns (string memory)
    {
        return bio;
    }
    // 5.更新姓名
    function updateName(string memory _newName) public 
    {
        name=_newName;
    }
    // 6.组合函数-更新和检索年龄
    function updateAge(uint256 _newAge) public
    {
        age=_newAge;
    }
    function getAge() public view returns (uint256)
    {
        return age;
    }
    // 7.组合函数-保存并立即返回
    function saveAndRetrieve(string memory _name, string memory _bio, uint256 _age) 
    public returns (string memory, string memory, uint256)
    {
        name=_name;
        bio=_bio;
        age=_age;
        return(name, bio, age);
    }
}
