// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==================== 内联接口定义 ====================

// IERC20 接口
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// IERC20Metadata 接口
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// Chainlink 价格预言机接口
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// ==================== OpenZeppelin 核心合约内联实现 ====================

// 基础 Context
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Ownable 合约
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }
    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// AccessControl 合约
abstract contract AccessControl is Context {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }
    mapping(bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].members[account];
    }
    
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }
    
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(string(abi.encodePacked("AccessControl: account ", _toHexString(account), " is missing role ", _toHexString(uint256(role), 32))));
        }
    }
    
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }
    
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }
    
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin");
        _grantRole(role, account);
    }
    
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }
    
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }
    
    function _toHexString(address addr) internal pure returns (string memory) {
        return _toHexString(uint256(uint160(addr)), 20);
    }
    
    function _toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = bytes1(uint8(48 + uint256(value & 0xf)));
            if (uint8(buffer[i]) > 57) buffer[i] = bytes1(uint8(buffer[i]) + 7);
            value >>= 4;
        }
        return string(buffer);
    }
}

// ReentrancyGuard 合约
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    
    constructor() {
        _status = _NOT_ENTERED;
    }
    
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

// ERC20 合约
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}

// SafeERC20 库
library SafeERC20 {
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(_callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value))), "SafeERC20: transfer failed");
    }
    
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(_callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value))), "SafeERC20: transferFrom failed");
    }
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: operation did not succeed");
        }
        return true;
    }
}

// ==================== 你的稳定币合约 ====================

contract SimpleStablecoin is ERC20, Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;
    
    bytes32 public constant PRICE_FEED_MANAGER_ROLE = keccak256("PRICE_FEED_MANAGER_ROLE");
    
    IERC20 public collateralToken;
    uint8 public collateralDecimals;
    AggregatorV3Interface public priceFeed;
    uint256 public collateralizationRatio;
    
    event Minted(address indexed user, uint256 stablecoinAmount, uint256 collateralAmount);
    event Redeemed(address indexed user, uint256 stablecoinAmount, uint256 collateralAmount);
    event PriceFeedUpdated(address indexed newPriceFeed);
    event CollateralizationRatioUpdated(uint256 newRatio);
    
    error InvalidCollateralTokenAddress();
    error InvalidPriceFeedAddress();
    error MintAmountIsZero();
    error InsufficientStablecoinBalance();
    error CollateralizationRatioTooLow();
    
    constructor(
        address _collateralToken,
        address _priceFeed,
        uint256 _collateralizationRatio
    ) ERC20("Simple USD", "sUSD") Ownable(msg.sender) {
        if (_collateralToken == address(0)) revert InvalidCollateralTokenAddress();
        if (_priceFeed == address(0)) revert InvalidPriceFeedAddress();
        if (_collateralizationRatio < 10000) revert CollateralizationRatioTooLow();
        
        collateralToken = IERC20(_collateralToken);
        collateralDecimals = IERC20Metadata(_collateralToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);
        collateralizationRatio = _collateralizationRatio;
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PRICE_FEED_MANAGER_ROLE, msg.sender);
    }
    
    function getCurrentPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        
        uint8 priceFeedDecimals = priceFeed.decimals();
        
        if (priceFeedDecimals < 18) {
            return uint256(price) * (10 ** (18 - priceFeedDecimals));
        } else if (priceFeedDecimals > 18) {
            return uint256(price) / (10 ** (priceFeedDecimals - 18));
        }
        return uint256(price);
    }
    
    function mint(uint256 stablecoinAmount) external nonReentrant {
        if (stablecoinAmount == 0) revert MintAmountIsZero();
        
        uint256 requiredCollateral = getRequiredCollateralForMint(stablecoinAmount);
        
        collateralToken.safeTransferFrom(msg.sender, address(this), requiredCollateral);
        
        _mint(msg.sender, stablecoinAmount);
        
        emit Minted(msg.sender, stablecoinAmount, requiredCollateral);
    }
    
    function redeem(uint256 stablecoinAmount) external nonReentrant {
        if (balanceOf(msg.sender) < stablecoinAmount) {
            revert InsufficientStablecoinBalance();
        }
        
        uint256 collateralToReturn = getCollateralForRedeem(stablecoinAmount);
        
        _burn(msg.sender, stablecoinAmount);
        
        collateralToken.safeTransfer(msg.sender, collateralToReturn);
        
        emit Redeemed(msg.sender, stablecoinAmount, collateralToReturn);
    }
    
    function getRequiredCollateralForMint(uint256 stablecoinAmount)
        public
        view
        returns (uint256)
    {
        uint256 collateralPrice = getCurrentPrice();
        uint256 baseCollateral = (stablecoinAmount * 10 ** collateralDecimals) / collateralPrice;
        uint256 requiredCollateral = (baseCollateral * collateralizationRatio) / 10000;
        
        return requiredCollateral;
    }
    
    function getCollateralForRedeem(uint256 stablecoinAmount)
        public
        view
        returns (uint256)
    {
        uint256 collateralPrice = getCurrentPrice();
        uint256 collateralAmount = (stablecoinAmount * 10 ** collateralDecimals) / collateralPrice;
        
        return collateralAmount;
    }
    
    function setCollateralizationRatio(uint256 _newRatio) external onlyOwner {
        if (_newRatio < 10000) revert CollateralizationRatioTooLow();
        collateralizationRatio = _newRatio;
        emit CollateralizationRatioUpdated(_newRatio);
    }
    
    function setPriceFeedContract(address _newPriceFeed)
        external
        onlyRole(PRICE_FEED_MANAGER_ROLE)
    {
        if (_newPriceFeed == address(0)) revert InvalidPriceFeedAddress();
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }
    
    function getSystemInfo() external view returns (
        address _collateralToken,
        uint256 _collateralizationRatio,
        uint256 _currentPrice,
        uint256 _totalSupply,
        uint256 _collateralBalance
    ) {
        return (
            address(collateralToken),
            collateralizationRatio,
            getCurrentPrice(),
            totalSupply(),
            collateralToken.balanceOf(address(this))
        );
    }
}