//SPDX-License-Identifier: MIT
// SPDX许可证标识符，指定代码使用MIT开源许可证

pragma solidity ^0.8.0; 
// 指定Solidity编译器版本为0.8.0或更高

import "./day14-BaseDepositBox.sol";
// 导入BaseDepositBox抽象合约，本合约将继承其功能

contract BasicDepositBox is BaseDepositBox{
// 定义BasicDepositBox合约，继承自BaseDepositBox
// 这是一个具体的、可部署的合约（非抽象合约）

    function getBoxType() external pure override returns(string memory){
    // 获取存款盒类型函数
    // external表示只能从外部调用
    // pure表示不读取也不修改状态，仅根据输入计算输出
    // override表示重写父合约中的虚函数
        return "Basic";
        // 返回字符串"Basic"，表示这是基础版本的存款盒
    }
}
