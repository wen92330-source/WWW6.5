# Simple Fitness Tracker - Frontend

A minimal web3 frontend for the SimpleFitnessTracker smart contract with two versions available.

## 📦 Available Versions

### 1. Full Web3 Version (`index.html`) 🔗
- **Full blockchain integration** with MetaMask
- **Real-time event monitoring** from smart contract
- **Persistent data storage** on blockchain
- Requires wallet connection and gas fees

### 2. UI Demo Version (`demo.html`) 🎨
- **No wallet required** - pure UI demonstration
- **Simulated functionality** - no blockchain connection
- **Pre-populated data** for immediate preview
- Perfect for showcasing UI/UX design

---

## 🚀 Quick Start

### Running the Demo Version (No Setup Required)

1. **Start a local server:**
   ```bash
   # Navigate to the frontend/Day10_ActivityTracker folder
   cd /path/to/Raven/frontend/Day10_ActivityTracker

   # Start Python HTTP server
   python3 -m http.server 8000
   ```

2. **Open in browser:**
   ```
   http://localhost:8000/demo.html
   ```

3. **That's it!** 🎉
   - No MetaMask needed
   - No wallet connection required
   - All features are interactive but simulated

---

### Running the Full Web3 Version

#### Prerequisites
- MetaMask browser extension installed
- Connected to Sepolia test network
- Test ETH in your wallet (get from faucet)
- Deployed smart contract address

#### Setup Instructions
#### Setup Instructions

1. **Deploy the Smart Contract**
   - Deploy `../../Day10_ActivityTracker.sol` to Sepolia test network
   - Use Remix IDE (https://remix.ethereum.org/)
   - Ensure MetaMask is connected to Sepolia network
   - Copy the deployed contract address

2. **Update Contract Address**
   - Open `app.js` in this directory
   - Replace line 16 with your deployed contract address:
     ```javascript
     const CONTRACT_ADDRESS = "0xYourContractAddressHere";
     ```

3. **Get Test ETH**
   - Visit a Sepolia faucet:
     - https://sepoliafaucet.com/
     - https://www.alchemy.com/faucets/ethereum-sepolia
   - Request test ETH (0.1 ETH recommended)

4. **Start Local Server**
   ```bash
   cd /path/to/Raven/frontend/Day10_ActivityTracker
   python3 -m http.server 8000
   ```

5. **Open in Browser**
   ```
   http://localhost:8000/index.html
   ```

6. **Connect Wallet**
   - Click "Connect Wallet" button
   - Approve MetaMask connection
   - Ensure you're on Sepolia network (Chain ID: 11155111)

7. **Use the Application**
   - Register if you're a new user
   - Log activities and update your weight
   - Watch the Events Log for real-time updates!

---

## ✨ Features

### Full Web3 Version Features
- ✅ Connect MetaMask wallet with network detection
- ✅ Register new users with name and weight
- ✅ Update weight and track progress
- ✅ Log workout activities (type, duration, distance)
- ✅ Real-time event monitoring for all contract events
- ✅ Track total workouts and distance
- ✅ Milestone notifications (weight loss, workout count, distance achievements)
- ✅ Display wallet balance in the UI

### Demo Version Features
- ✅ Fully interactive UI without blockchain
- ✅ Simulated user registration and login
- ✅ Mock activity logging with animations
- ✅ Pre-populated sample events
- ✅ Perfect for presentations and screenshots

---

## 📂 File Structure

```
Raven/
├── Day10_ActivityTracker.sol   # Smart contract (parent directory)
├── frontend/
│   └── Day10_ActivityTracker/
│       ├── index.html          # Full Web3 version (requires wallet)
│       ├── demo.html           # UI Demo version (no wallet needed)
│       ├── app.js              # JavaScript for Web3 interactions
│       ├── style.css           # Shared CSS styling
│       └── README.md           # This file
└── ... (other contracts)
```

---

## 📊 Events Monitored (Web3 Version Only)

- **UserRegister**: When a new user registers
- **ProfileUpdate**: When weight is updated
- **ActivityLog**: When a workout activity is logged
- **MilestoneAchieve**: When milestones are reached
  - 10 workouts completed
  - 50 workouts completed
  - 100km (100,000m) distance achieved
  - 5% weight loss achieved

---

## 🎓 Learning Resources

- [Ethers.js Documentation](https://docs.ethers.org/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [MetaMask Guide](https://metamask.io/faqs/)
- [Remix IDE](https://remix.ethereum.org/)

---

## 📄 License

MIT

---

## 🙋 Support

For issues or questions:
1. Check the browser console for error messages
2. Verify all prerequisites are met
3. Try the demo version first to test UI
4. Ensure MetaMask is properly configured

---

**Happy tracking your fitness on the blockchain! 🏃‍♂️💪**
