// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
contract MyToken {
	string public name = "Raven";
	string public symbol = "RAV";
	// Same as ETH
	uint8 public decimals = 18;
	uint256 public totalSupply;

	mapping(address => uint256) public balanceOf;
	// allowance[owner][spender]
	mapping(address => mapping(address => uint256)) public allowance;
	event Transfer(address indexed from, address indexed to, uint256 amount);
	event Approval(address indexed owner, address indexed spender, uint256 amount);
	constructor(uint256 _initialSupply) {
		totalSupply = _initialSupply * (10 ** uint256(decimals));
		balanceOf[msg.sender] = totalSupply;
		emit Transfer(address(0), msg.sender, totalSupply);
	}
	// Report bool as part of ERC20 for safety
	function transfer(address _to, uint256 _amount) public virtual returns (bool) {
		require(_amount <= balanceOf[msg.sender], "Not enough balance");
		_transfer(msg.sender, _to, _amount);
		return (true);
	}
	// Mark as Internal to avoid escaping require check
	function _transfer(address _from, address _to, uint256 _amount) internal virtual {
		require(_to != address(0), "Invalid address");
		balanceOf[_from] -= _amount;
		balanceOf[_to] += _amount;
		emit Transfer(_from, _to, _amount);
	}
	// Race condition of front-running
	function approve(address _spender, uint256 _amount) public returns (bool) {
		allowance[msg.sender][_spender] = _amount;
		emit Approval(msg.sender, _spender, _amount);
		return (true);
	}
	// Using smart contract to transfer tokens to othe party
	// Need approve allowance beforehand
	function transferFrom(address _from, address _to, uint256 _amount) public virtual returns (bool) {
		require(_amount <= balanceOf[_from], "Not enough balance");
		require(_amount <= allowance[_from][msg.sender], "Not enough allowance");
		allowance[_from][msg.sender] -= _amount;
		_transfer(_from, _to, _amount);
		return (true);
	}
}