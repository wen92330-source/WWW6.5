// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Day12SimpleToken
 * @dev 一个标准的 ERC-20 代币实现，用于第12天练习
 */
contract Day12SimpleToken {
    // ================= 代币元数据 =================
    string public name = "SimpleToken";
    string public symbol = "SIM";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    // ================= 核心映射 =================
    // 记录每个地址的余额
    mapping(address => uint256) public balanceOf;
    // 记录授权额度：owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;
    
    // ================= 事件 =================
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // ================= 构造函数 =================
    /**
     * @param _initialSupply 初始供应量（单位：个，不是 wei）
     * 例如：传入 1000000，实际铸造 1000000 * 10^18
     */
    constructor(uint256 _initialSupply) {
        // 计算实际总供应量（考虑小数位）
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        
        // 将所有代币分配给部署者
        balanceOf[msg.sender] = totalSupply;
        
        // 触发转移事件（从 0 地址铸造）
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    // ================= 外部函数 =================
    
    /**
     * @dev 直接转账
     * @param _to 接收者地址
     * @param _value 转账金额（最小单位）
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid address: zero address");
        require(_value > 0, "Invalid value: must be greater than 0");
        
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @dev 授权 spender 使用 _value 额度的代币
     * @param _spender 被授权的地址
     * @param _value 授权额度
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Invalid address: zero address");
        
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev 代转代币（需要预先授权）
     * @param _from 代币持有者
     * @param _to 接收者
     * @param _value 转账金额
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Invalid address: zero address");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        
        // 扣减授权额度
        allowance[_from][msg.sender] -= _value;
        
        // 执行内部转账
        _transfer(_from, _to, _value);
        return true;
    }
    
    // ================= 内部函数 =================
    
    /**
     * @dev 内部转账逻辑，供 transfer 和 transferFrom 调用
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Solidity 0.8+ 会自动检查下溢，但为了逻辑清晰保留检查
        require(balanceOf[_from] >= _value, "Insufficient balance");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(_from, _to, _value);
    }
    
    // ================= 辅助查看函数 (可选) =================
    
    /**
     * @dev 查看某个地址对另一个地址的授权额度
     */
    function checkAllowance(address _owner, address _spender) public view returns (uint256) {
        return allowance[_owner][_spender];
    }
}