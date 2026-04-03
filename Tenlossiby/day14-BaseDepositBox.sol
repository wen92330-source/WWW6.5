//SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本为0.8.0或更高
import "./day14-IDepositBox.sol";
// 导入IDepositBox接口合约，本合约将实现该接口定义的功能

abstract contract BaseDepositBox is IDepositBox {
// 定义一个抽象合约BaseDepositBox，继承自IDepositBox接口
// abstract表示这是一个抽象合约，不能被直接部署，只能被其他合约继承

    address private owner;
    // 私有变量：存储合约所有者的地址，private表示只能在合约内部访问
    string private secret;
    // 私有变量：存储用户存入的私密信息（如密码、密钥等）
    uint256 private depositTime;
    // 私有变量：记录合约创建/存款的时间戳

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    // 所有权转移事件，当合约所有者变更时触发
    event SecretStored(address indexed owner);
    // 秘密存储事件，当用户存入秘密时触发

    constructor(){
    // 构造函数，合约部署时执行一次
        owner = msg.sender;
        // 将合约部署者设为初始所有者
        depositTime = block.timestamp;
        // 记录当前区块的时间戳作为存款时间
    }

    modifier onlyOwner(){
    // 定义一个函数修饰器，用于限制只有所有者才能调用某些函数
        require(owner == msg.sender, "Not the owner");
        // 检查调用者是否为所有者，如果不是则报错
        _;
        // 下划线表示被修饰函数的代码将在这里执行
    }

    function getOwner() public view override returns (address){
    // 获取当前所有者的地址
    // view表示不修改状态，override表示重写父接口中的函数
        return owner;
        // 返回所有者地址
    }

    function transferOwnership(address newOwner) external virtual override onlyOwner{
    // 转移所有权函数，只有当前所有者可以调用
    // external表示只能从外部调用，virtual表示可被重写
        require(newOwner != address(0), "Invalid Address");
        // 检查新所有者地址不能是零地址（防止所有权丢失）
        emit OwnershipTransferred(owner, newOwner); 
        // 触发所有权转移事件，记录变更
        owner = newOwner;
        // 更新所有者为新地址
    }

    function storeSecret(string calldata _secret)external virtual override onlyOwner{
    // 存储秘密函数，只有所有者可以存入秘密
    // calldata表示数据存储在调用数据中，节省gas
        secret = _secret;
        // 将传入的秘密字符串存储到状态变量
        emit SecretStored(msg.sender);
        // 触发秘密存储事件
    }

    function getSecret() public view virtual override onlyOwner returns (string memory){
    // 获取秘密函数，只有所有者可以查看秘密
        return secret;
        // 返回存储的秘密
    }

    function getDepositTime() external view virtual override onlyOwner returns (uint256) {
    // 获取存款时间函数，只有所有者可以查看
        return depositTime;
        // 返回合约创建时记录的时间戳
    }

   
   
    
    

}
