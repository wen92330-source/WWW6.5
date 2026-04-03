//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScientificCalculator{

    function power(uint256 base, uint256 exponent)public pure returns(uint256){
        if(exponent == 0)return 1; // 其实，从 Solidity 0.8.0 版本开始，即使你不写 if (exponent == 0)，直接运行 base ** 0 也会得到 1（因为数学上任何数的 0 次幂都等于 1，包括 0^0 在 Solidity 中也定义为 1）。但在老版本的 Solidity（0.8.0 之前）中，某些溢出情况或特殊边界值的处理不如现在完善。于是很多开发者习惯显式地处理 0 次幂这一特殊情况，以确保逻辑的绝对严谨。
        else return (base ** exponent);
    }

    function squareRoot(uint256 number)public pure returns(uint256){ // uint确保开根号的对象为非负整数
        if(number == 0)return 0; // 如果number=0，直接返回0，结束本函数。因为按照下方公式，result=0会出现在分母，无法运算，0是牛顿迭代法的盲区，因此单独一行代码处理这种情况。 如果number不为0，跳过if，进入下方迭代法。

        uint256 result = number/2;
        for(uint256 i = 0; i<10; i++){
            result = (result + number / result)/2;
        } 
        return result;
        /* 牛顿迭代法。先猜result=number/2，如果result猜大了，那么number/result就小了，通过取均值缩小result与正确答案之间的差距。随着迭代次数增加，result就会逐渐收敛于正确答案。
        牛顿迭代法相当于“对折再对折”。十次迭代的精度足够了。
        注意Solidity中非整数会向下取整。*/

    }
}
