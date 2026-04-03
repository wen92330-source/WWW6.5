# Vault Master - Frontend

A decentralized vault application built with Solidity and Web3. This DApp allows users to deposit ETH into a secure vault, with owner-only withdrawal capabilities and ownership transfer functionality.

---

## ⚠️ IMPORTANT: Deploy Contract First!

Before using the Web3 version, you **MUST** deploy the smart contract and update the contract address:

### Quick Deployment Steps:

1. **Go to Remix IDE**: https://remix.ethereum.org
2. **Create two files**:
   - `Ownable.sol` - Copy from `../../Day11_Ownable.sol`
   - `VaultMaster.sol` - Copy from `../../Day11_VaultMaster.sol`
3. **Compile both contracts** (Solidity 0.8.0+)
4. **Deploy**:
   - Select "VaultMaster" contract
   - Make sure MetaMask is on **Sepolia testnet**
   - Click "Deploy" and confirm transaction
5. **Copy the deployed contract address** (starts with 0x...)
6. **Update `app.js` line 17**:
   ```javascript
   const CONTRACT_ADDRESS = "0xYourActualContractAddressHere";
   ```

---

## 🎯 Features

### For All Users:
- 💰 **Deposit ETH**: Anyone can deposit ETH into the vault
- 📊 **View Vault Balance**: Check the total ETH stored in the vault
- 📜 **Activity Log**: See recent deposits, withdrawals, and ownership transfers

### For Owner Only:
- 🏧 **Withdraw ETH**: Extract funds to any address
- 🔐 **Transfer Ownership**: Assign a new owner to the contract
- 👑 **Owner Badge**: Visual indicator of owner status

---

## 🚀 Quick Start

### Option 1: Web3 Version (Full Functionality)

1. **Install MetaMask**
   - Download from [metamask.io](https://metamask.io)
   - Create or import a wallet
   - Switch to Sepolia testnet

2. **Get Test ETH**
   - Visit [Sepolia Faucet](https://sepoliafaucet.com)
   - Request test ETH for transactions

3. **Deploy Smart Contracts**
   - Go to [Remix IDE](https://remix.ethereum.org)
   - Copy [`Day11_Ownable.sol`](../../Day11_Ownable.sol) and [`Day11_VaultMaster.sol`](../../Day11_VaultMaster.sol)
   - Compile both contracts
   - Deploy `VaultMaster` (it will automatically use Ownable)
   - Copy the deployed contract address

4. **Configure Frontend**
   ```javascript
   // In app.js, line 17:
   const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS_HERE";
   ```

5. **Run Local Server**
   ```bash
   cd Raven/frontend/Day11_VaultMaster
   python3 -m http.server 8000
   ```

6. **Open in Browser**
   ```
   http://localhost:8000/index.html
   ```

### Option 2: Demo Version (No Wallet Required)

Simply open `demo.html` in your browser to explore the UI:

```bash
cd Raven/frontend/Day11_VaultMaster
python3 -m http.server 8000
# Open: http://localhost:8000/demo.html
```

---

## 🔧 Smart Contract Functions

### Ownable.sol Functions:
```solidity
function ownerAddress() public view returns (address)
function transferOwnership(address _newOwner) public onlyOwner
```

### VaultMaster.sol Functions:
```solidity
function getBalance() public view returns (uint256)
function deposit() public payable
function withdraw(address _to, uint256 _amount) public onlyOwner
```

---

## 📊 Events Monitored (Web3 Version Only)

- **DepositSuccessful**: When ETH is deposited
- **WithdrawSuccessful**: When ETH is withdrawn
- **OwnershipTransferred**: When ownership changes

---

## 🎨 UI Components

1. **Contract Information Panel**
   - Owner address
   - User address
   - Vault balance
   - User status (Owner/User)

2. **Deposit Section** (All Users)
   - ETH amount input
   - Deposit button

3. **Withdraw Section** (Owner Only)
   - Recipient address input
   - Amount input
   - Withdraw button

4. **Transfer Ownership** (Owner Only)
   - New owner address input
   - Transfer button

5. **Activity Log**
   - Real-time transaction history
   - Shows deposits, withdrawals, and transfers

---

## 📂 File Structure

```
Raven/
├── Day11_Ownable.sol           # Ownership management contract
├── Day11_VaultMaster.sol       # Main vault contract
├── frontend/
│   └── Day11_VaultMaster/
│       ├── index.html          # Full Web3 version
│       ├── demo.html           # UI Demo version
│       ├── app.js              # Web3 interactions
│       ├── style.css           # Styling
│       └── README.md           # This file
└── ... (other contracts)
```

---

## 🔐 Security Features

1. **Ownable Pattern**: Inherited from Ownable.sol for secure ownership management
2. **Access Control**: Owner-only functions protected by `onlyOwner` modifier
3. **Input Validation**: Checks for valid addresses and amounts
4. **Zero Address Protection**: Prevents transfers to zero address
5. **Event Logging**: All actions emit events for transparency

---

## ⚠️ Important Notes

### For Web3 Version:
- Requires MetaMask browser extension
- Must be on Sepolia testnet
- Need test ETH for transactions
- Gas fees apply to all transactions

### Transaction Costs (Estimated):
- Deposit: ~50,000 gas
- Withdraw: ~55,000 gas
- Transfer Ownership: ~30,000 gas

---

## 🎓 Learning Resources

- [Ethers.js Documentation](https://docs.ethers.org/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [MetaMask Guide](https://metamask.io/faqs/)
- [Remix IDE](https://remix.ethereum.org/)

---

## 📄 License

MIT

---

## 👨‍💻 Developer Notes

This frontend demonstrates:
- Web3 wallet integration
- Contract inheritance (Ownable pattern)
- Event listening and logging
- Access control UI elements
- Responsive design principles
- Error handling and user feedback

---

## 🎉 Getting Help

If you encounter issues:
1. Check the browser console for errors
2. Verify MetaMask is connected
3. Confirm you're on Sepolia testnet
4. Ensure contract address is correct
5. Check you have sufficient test ETH

---

**Built with ❤️ for Web3 learning**