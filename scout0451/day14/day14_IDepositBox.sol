//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

//存款箱接口
interface IDepositBox {

    //外部调用
    function getOwner() external view returns(address);//当前所有者
    function transferOwnership(address newOwner)external;//转移所有权
    function storeSecret(string calldata secret)external;//保存字符串秘密在金库中
    function getSecret() external view returns (string memory);//检索存储秘密
    function getBoxType() external pure returns(string memory);//存款箱类型
    function getDepositTime() external view returns(uint256);//创建时间
}