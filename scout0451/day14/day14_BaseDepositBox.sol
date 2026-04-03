//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 
import "./day14_IDepositBox.sol";

//抽象合约：这个合约不能直接部署，充当其他合约构建的模板或地基。
abstract contract BaseDepositBox is IDepositBox {

    address private owner;
    string private secret;
    uint256 private depositTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecretStored(address indexed owner);

    constructor(){
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "Not the owner");
        _;
    }

    function getOwner() public view override returns (address){
        //override用于函数重写，表示子函数覆盖同名母函数。
        return owner;
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner{
        //virtual函数可以被进一步重写
        require(newOwner != address(0), "Invalid Address");
        emit OwnershipTransferred(owner, newOwner); 
        owner = newOwner;
    }

    function storeSecret(string calldata _secret)external virtual override onlyOwner{
        //calldata函数外部调用时的只读数据位置，存于区块链交易数据中；适合存外部传入参数 
        secret = _secret;
        emit SecretStored(msg.sender);
    }

    function getSecret() public view virtual override onlyOwner returns (string memory){
        return secret;
    }

    function getDepositTime() external view virtual override onlyOwner returns (uint256) {
        return depositTime;
    }

    
   
    
    

}
