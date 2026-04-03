//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol"; //路径和文件名要能够让合约找得到，我的母合约和女合约在一个文件夹里

contract Calculator{

    address public owner;
    address public scientificCalculatorAddress;//后面的高级和低级调用都会用到这个科学计算器地址

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
         _; 
    }
    
    //import相当于知道了一个房间的工具清单，她的address相当于知道了这个房间的门牌号，这样想用什么工具的时候就知道去哪个房间找
    function setScientificCalculator(address _address)public onlyOwner{ //等ScientificCalculator合约部署好，就可以把她的地址放在这里，之后就可以调用了
        scientificCalculatorAddress = _address;
        }

    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;
    }

    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;
    }

    function divide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!= 0, "Cannot divide by zero"); //分母不能为0
        uint256 result = a/b;
        return result;
    }

    //高级调用，要有import，导入了外部合约的代码；知道其他合约的结构而且能访问的时候，推荐这个
    function calculatePower(uint256 base, uint256 exponent)public view returns(uint256){ //前面都是pure。现在用的是view，因为要读取从另一个合约函数计算的结果

    //强制地址转换。我们知道有一个地址，实际上它是一个合约，所以我们先import合约让solidity也知道这是一个合约，帮我们把地址转换成合约
    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);

    //然后就可调用子合约里的函数，用点表示法，只读调用，让她在自己的合约里运算，然后返回结果 
    uint256 result = scientificCalc.power(base, exponent);

    return result;
    }

    //低级调用，更加灵活，也不用先import，知道另一个合约函数的地址和名称就行。但是风险性更高，而且不会报错，错了也会执行，浪费gas，因此需要增加success和require等增加安全性和及时停止执行
    function calculateSquareRoot(uint256 number)public returns (uint256){ //这里的public returns中间其实是nonpayable，代表可读可写但不可接发ETH
    //可见性（谁可以调用）public（内外）/extenal（外部）/private（内部）；状态（谁可以修改）：payable/nonpayable（不写即默认）/view/pure
        require(number >= 0 , "Cannot calculate square root of negative nmber");//确保参数大于等于0

        //将 函数（参数类型），参数 通过abi.借口转成二进制的字节数组，方便EVM处理，高级调用中solidity自动进行了这个处理
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);
        //date是我们刚转换的 函数（参数类型），参数，我们告诉solidity，把这些信息发送给这个地址，然后调用，返回的是成功与否，还有结果（字节数组的形式）
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed"); //返回是否成功，否的话就停止执行，节省gas
        uint256 result = abi.decode(returnData, (uint256)); //返回的字节数组形式的结果经过abi.的解码，被转换为uint256的类型数值存在result里
        return result;
    }

    
}
