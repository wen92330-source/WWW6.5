// Contract ABI
const OWNABLE_ABI = [
    "function owner() public view returns (address)",
    "function getOwnerAddress() public view returns (address)",
    "function transferOwnership(address _newOwner) public",
    "event TransferOwner(address indexed oldOwner, address indexed newOwner)"
];

const VAULT_ABI = [
    "function getBalance() public view returns (uint256)",
    "function deposit() public payable",
    "function withdraw(address _to, uint256 _amount) public",
    "event DepositSuccess(address indexed account, uint256 amount)",
    "event WithdrawSuccess(address indexed recipient, uint256 amount)"
];

// Replace with your deployed contract address
const CONTRACT_ADDRESS = "ContractAddress";

// State variables
let provider;
let signer;
let contract;
let userAddress;

// Initialize on page load
window.addEventListener('load', async () => {
    setupEventListeners();

    // Check if MetaMask is installed
    if (typeof window.ethereum !== 'undefined') {
        console.log('MetaMask detected');
        updateStatus('Click "Connect Wallet" to get started', false);
    } else {
        updateStatus('Please install MetaMask to use this DApp', false);
        document.getElementById('connectBtn').disabled = true;
    }
});

// Setup event listeners
function setupEventListeners() {
    document.getElementById('connectBtn').addEventListener('click', connectWallet);
    document.getElementById('depositBtn').addEventListener('click', depositETH);
    document.getElementById('withdrawBtn').addEventListener('click', withdrawETH);
    document.getElementById('transferBtn').addEventListener('click', transferOwnership);
}

// Connect wallet
async function connectWallet() {
    try {
        // Check if contract address is set
        if (CONTRACT_ADDRESS === "YOUR_DEPLOYED_CONTRACT_ADDRESS_HERE" || !CONTRACT_ADDRESS) {
            alert('⚠️ Contract address not configured!\n\nPlease:\n1. Deploy Day11_VaultMaster.sol to Sepolia testnet\n2. Copy the contract address\n3. Update CONTRACT_ADDRESS in app.js (line 17)');
            return;
        }

        updateStatus('Connecting...', false);

        // Request account access
        await window.ethereum.request({ method: 'eth_requestAccounts' });

        // Initialize provider and signer
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        userAddress = await signer.getAddress();

        // Check network first
        const network = await provider.getNetwork();
        if (network.chainId !== 11155111) {
            alert('Please switch to Sepolia testnet in MetaMask');
            return;
        }

        // Initialize contract with proper address validation
        if (!ethers.utils.isAddress(CONTRACT_ADDRESS)) {
            alert('Invalid contract address format! Please check app.js');
            return;
        }

        contract = new ethers.Contract(CONTRACT_ADDRESS, [...OWNABLE_ABI, ...VAULT_ABI], signer);

        // Update UI
        updateStatus('Connected', true);
        document.getElementById('userAddress').textContent = formatAddress(userAddress);
        document.getElementById('contractAddress').textContent = CONTRACT_ADDRESS;

        // Load contract data
        await loadContractData();

        // Setup event listeners
        setupContractListeners();

        // Listen for account changes
        window.ethereum.on('accountsChanged', handleAccountsChanged);

    } catch (error) {
        console.error('Connection error:', error);
        updateStatus('Connection failed', false);
        alert('Failed to connect: ' + error.message);
    }
}

// Load contract data
async function loadContractData() {
    try {
        // Get owner address
        const owner = await contract.getOwnerAddress();
        document.getElementById('ownerAddress').textContent = formatAddress(owner);
        console.log('Contract Owner:', owner);
        console.log('User Address:', userAddress);

        // Get vault balance
        const balance = await contract.getBalance();
        document.getElementById('vaultBalance').textContent = ethers.utils.formatEther(balance) + ' ETH';

        // Check if user is owner
        const isOwner = owner.toLowerCase() === userAddress.toLowerCase();
        console.log('Is Owner?', isOwner);

        document.getElementById('userStatus').textContent = isOwner ? 'Owner' : 'User';
        document.getElementById('userStatus').className = 'value badge ' + (isOwner ? 'badge-owner' : 'badge-user');

        // Show/hide owner-only sections
        const ownerSections = document.querySelectorAll('.owner-only');
        console.log('Found owner sections:', ownerSections.length);
        ownerSections.forEach(section => {
            section.style.display = isOwner ? 'block' : 'none';
            console.log('Section display set to:', isOwner ? 'block' : 'none');
        });

    } catch (error) {
        console.error('Error loading contract data:', error);
    }
}

// Setup contract event listeners
function setupContractListeners() {
    // Listen for deposits
    contract.on("DepositSuccess", (account, value) => {
        console.log('Deposit event:', account, value.toString());
        addActivity('deposit', `${ethers.utils.formatEther(value)} ETH from ${formatAddress(account)}`, 'Just now');
        loadContractData();
    });

    // Listen for withdrawals
    contract.on("WithdrawSuccess", (recipient, value) => {
        console.log('Withdraw event:', recipient, value.toString());
        addActivity('withdraw', `${ethers.utils.formatEther(value)} ETH to ${formatAddress(recipient)}`, 'Just now');
        loadContractData();
    });

    // Listen for ownership transfers
    contract.on("TransferOwner", (previousOwner, newOwner) => {
        console.log('Ownership transfer:', previousOwner, newOwner);
        addActivity('ownership', `From ${formatAddress(previousOwner)} to ${formatAddress(newOwner)}`, 'Just now');
        loadContractData();
    });
}

// Deposit ETH
async function depositETH() {
    try {
        const amount = document.getElementById('depositAmount').value;

        if (!amount || parseFloat(amount) <= 0) {
            alert('Please enter a valid amount');
            return;
        }

        const amountWei = ethers.utils.parseEther(amount);

        const tx = await contract.deposit({ value: amountWei });
        addActivity('pending', `Depositing ${amount} ETH...`, 'Pending');

        await tx.wait();

        document.getElementById('depositAmount').value = '';
        alert(`Successfully deposited ${amount} ETH!`);

    } catch (error) {
        console.error('Deposit error:', error);
        alert('Deposit failed: ' + (error.reason || error.message));
    }
}

// Withdraw ETH (owner only)
async function withdrawETH() {
    try {
        const to = document.getElementById('withdrawTo').value;
        const amount = document.getElementById('withdrawAmount').value;

        if (!to || !ethers.utils.isAddress(to)) {
            alert('Please enter a valid recipient address');
            return;
        }

        if (!amount || parseFloat(amount) <= 0) {
            alert('Please enter a valid amount');
            return;
        }

        const amountWei = ethers.utils.parseEther(amount);

        const tx = await contract.withdraw(to, amountWei);
        addActivity('pending', `Withdrawing ${amount} ETH...`, 'Pending');

        await tx.wait();

        document.getElementById('withdrawTo').value = '';
        document.getElementById('withdrawAmount').value = '';
        alert(`Successfully withdrew ${amount} ETH to ${formatAddress(to)}!`);

    } catch (error) {
        console.error('Withdraw error:', error);
        alert('Withdrawal failed: ' + (error.reason || error.message));
    }
}

// Transfer ownership (owner only)
async function transferOwnership() {
    try {
        const newOwner = document.getElementById('newOwner').value;

        if (!newOwner || !ethers.utils.isAddress(newOwner)) {
            alert('Please enter a valid address');
            return;
        }

        if (newOwner === ethers.constants.AddressZero) {
            alert('Cannot transfer to zero address');
            return;
        }

        const confirmed = confirm(`Are you sure you want to transfer ownership to ${formatAddress(newOwner)}?`);
        if (!confirmed) return;

        const tx = await contract.transferOwnership(newOwner);
        addActivity('pending', `Transferring ownership...`, 'Pending');

        await tx.wait();

        document.getElementById('newOwner').value = '';
        alert(`Ownership successfully transferred to ${formatAddress(newOwner)}!`);

    } catch (error) {
        console.error('Transfer error:', error);
        alert('Transfer failed: ' + (error.reason || error.message));
    }
}

// Add activity to log
function addActivity(type, details, time) {
    const log = document.getElementById('activityLog');

    // Remove empty state
    const emptyState = log.querySelector('.empty-state');
    if (emptyState) {
        emptyState.remove();
    }

    const item = document.createElement('div');
    item.className = 'activity-item';

    const icons = {
        'deposit': '📥 Deposit',
        'withdraw': '📤 Withdraw',
        'ownership': '🔐 Ownership Transfer',
        'pending': '⏳ Pending'
    };

    item.innerHTML = `
        <span class="activity-type ${type}">${icons[type]}</span>
        <span class="activity-details">${details}</span>
        <span class="activity-time">${time}</span>
    `;

    log.insertBefore(item, log.firstChild);

    // Keep only last 10 activities
    while (log.children.length > 10) {
        log.removeChild(log.lastChild);
    }
}

// Handle account changes
async function handleAccountsChanged(accounts) {
    if (accounts.length === 0) {
        updateStatus('Please connect to MetaMask', false);
    } else {
        window.location.reload();
    }
}

// Update connection status
function updateStatus(text, connected) {
    const statusText = document.getElementById('statusText');
    const connectBtn = document.getElementById('connectBtn');
    const walletStatus = document.getElementById('walletStatus');

    statusText.textContent = text;

    if (connected) {
        walletStatus.classList.add('connected');
        connectBtn.textContent = 'Connected';
        connectBtn.disabled = true;
    } else {
        walletStatus.classList.remove('connected');
        connectBtn.textContent = 'Connect Wallet';
        connectBtn.disabled = false;
    }
}

// Format address
function formatAddress(address) {
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
}