# Solidity Projects

This directory contains various Solidity smart contracts and their frontend implementations.

## 📁 Project Structure

### Smart Contracts (Root Directory)
- `Day1_ClickCounter.sol`
- `Day2_SaveMyName.sol`
- `Day3_PollStation.sol`
- `Day4_AuctionHouse.sol`
- `Day5_AdminOnly.sol`
- `Day6_EtherPiggyBank.sol`
- `Day7_SimpleIOUApp.sol`
- `Day8_TipJar.sol`
- `Day9_Calculator.sol`
- `Day9_ScientificCalculator.sol`
- `Day10_ActivityTracker.sol` ⭐
- `Day11_Ownable.sol` ⭐
- `Day11_VaultMaster.sol` ⭐

### Frontend Applications
Frontend implementations are organized in the `frontend/` subdirectory.

#### Available Frontends:
- **Day10 Activity Tracker** - Full web3 fitness tracking DApp
  - 📂 Location: `frontend/Day10_ActivityTracker/`
  - 📖 [View README](frontend/Day10_ActivityTracker/README.md)
  - 🚀 Quick start:
    ```bash
    cd frontend/Day10_ActivityTracker
    python3 -m http.server 8000
    # Then open: http://localhost:8000/demo.html (no wallet)
    # Or: http://localhost:8000/index.html (with MetaMask)
    ```

- **Day11 Vault Master** - Secure ETH vault with ownership controls
  - 📂 Location: `frontend/Day11_VaultMaster/`
  - 📖 [View README](frontend/Day11_VaultMaster/README.md)
  - 🚀 Quick start:
    ```bash
    cd frontend/Day11_VaultMaster
    python3 -m http.server 8000
    # Then open: http://localhost:8000/demo.html (no wallet)
    # Or: http://localhost:8000/index.html (with MetaMask)
    ```

## 🔧 Technologies Used

- **Smart Contracts**: Solidity ^0.8.0
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Web3 Library**: Ethers.js v5
- **Wallet**: MetaMask
- **Network**: Sepolia Testnet (Chain ID: 11155111)

## 📝 Notes

- Frontend files are organized by project in `frontend/` directory
- Each frontend has its own README with specific instructions
- Smart contract files remain in the root for easy access
- All paths in frontend files use relative references

---

**Happy coding! 🚀**