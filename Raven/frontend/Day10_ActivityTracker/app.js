// Contract ABI - Add your deployed contract ABI here
const CONTRACT_ABI = [
    "function registerUser(string memory _name, uint256 _weight) public",
    "function updateWeight(uint256 _newWeight) public",
    "function logActivity(string memory _type, uint256 _duration, uint256 _distance) public",
    "function getTotalActivity() public view returns (uint256)",
    "function userProfiles(address) public view returns (string name, uint256 weight, bool isRegistered)",
    "function totalWorkouts(address) public view returns (uint256)",
    "function totalDistance(address) public view returns (uint256)",
    "event UserRegister(address indexed userAddress, string name, uint256 timestamp)",
    "event ProfileUpdate(address indexed userAddress, uint256 newWeight, uint256 timestamp)",
    "event ActivityLog(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp)",
    "event MilestoneAchieve(address indexed userAddress, string milestone, uint256 timestamp)"
];

// Replace with your deployed contract address
const CONTRACT_ADDRESS = "0xYourContractAddressHere";

let provider;
let signer;
let contract;
let userAddress;

// Connect to MetaMask
async function connectWallet() {
    try {
        if (typeof window.ethereum === 'undefined') {
            alert('Please install MetaMask to use this application!');
            return;
        }

        // Request account access
        await window.ethereum.request({ method: 'eth_requestAccounts' });

        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        userAddress = await signer.getAddress();

        // 检查网络
        const network = await provider.getNetwork();
        console.log('Connected to network:', network.name, 'Chain ID:', network.chainId);

        // Sepolia Chain ID is 11155111
        if (network.chainId !== 11155111) {
            alert('请切换到 Sepolia 测试网络！\nPlease switch to Sepolia test network!\n\n当前网络 Current: ' + network.name);
            return;
        }

        // 检查余额
        const balance = await provider.getBalance(userAddress);
        const ethBalance = ethers.utils.formatEther(balance);
        console.log('Wallet balance:', ethBalance, 'ETH');

        if (parseFloat(ethBalance) < 0.001) {
            alert('余额不足！请从水龙头获取测试 ETH\nInsufficient balance! Please get test ETH from faucet\n\n当前余额 Balance: ' + ethBalance + ' ETH');
        }

        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

        // Update UI
        document.getElementById('connectionStatus').textContent = `Connected: ${userAddress.slice(0, 6)}...${userAddress.slice(-4)} | ${parseFloat(ethBalance).toFixed(4)} ETH`;
        document.getElementById('connectionStatus').classList.add('connected');
        document.getElementById('connectBtn').textContent = 'Connected';
        document.getElementById('connectBtn').disabled = true;

        // Check if user is registered
        await checkUserRegistration();

        // Setup event listeners
        setupEventListeners();

        console.log('Wallet connected successfully!');
    } catch (error) {
        console.error('Error connecting wallet:', error);
        alert('Failed to connect wallet: ' + error.message);
    }
}

// Check if user is registered
async function checkUserRegistration() {
    try {
        const profile = await contract.userProfiles(userAddress);

        if (profile.isRegistered) {
            // User is registered, show profile and activity sections
            document.getElementById('registerSection').style.display = 'none';
            document.getElementById('profileSection').style.display = 'block';
            document.getElementById('activitySection').style.display = 'block';

            // Load user data
            await loadUserProfile();
        } else {
            // User not registered, show registration form
            document.getElementById('registerSection').style.display = 'block';
            document.getElementById('profileSection').style.display = 'none';
            document.getElementById('activitySection').style.display = 'none';
        }
    } catch (error) {
        console.error('Error checking registration:', error);
    }
}

// Load user profile
async function loadUserProfile() {
    try {
        const profile = await contract.userProfiles(userAddress);
        const totalWorkoutsCount = await contract.totalWorkouts(userAddress);
        const totalDistanceCount = await contract.totalDistance(userAddress);

        document.getElementById('profileName').textContent = profile.name;
        document.getElementById('profileWeight').textContent = ethers.BigNumber.from(profile.weight).toString();
        document.getElementById('totalWorkouts').textContent = totalWorkoutsCount.toString();
        document.getElementById('totalDistance').textContent = totalDistanceCount.toString();
    } catch (error) {
        console.error('Error loading profile:', error);
    }
}

// Register user
async function registerUser() {
    const name = document.getElementById('userName').value;
    const weight = document.getElementById('userWeight').value;

    if (!name || !weight) {
        alert('请填写所有字段！Please fill in all fields!');
        return;
    }

    try {
        // 添加 gas limit 以避免估算失败
        const tx = await contract.registerUser(name, weight, {
            gasLimit: 300000
        });
        addEventToLog('⏳ 交易处理中 Transaction Pending', '正在注册用户... Registering user...', 'pending');

        await tx.wait();
        addEventToLog('✅ 注册成功 Registration Successful', `欢迎 Welcome ${name}!`, 'register');

        // Refresh UI
        await checkUserRegistration();
    } catch (error) {
        console.error('Error registering user:', error);
        let errorMsg = error.message;
        if (error.code === 'INSUFFICIENT_FUNDS') {
            errorMsg = '余额不足！请确保有足够的 ETH 支付 Gas 费用\nInsufficient funds! Please ensure you have enough ETH for gas fees';
        }
        alert('注册失败 Failed to register: ' + errorMsg);
    }
}// Update weight
async function updateWeight() {
    const newWeight = document.getElementById('newWeight').value;

    if (!newWeight) {
        alert('Please enter a weight!');
        return;
    }

    try {
        const tx = await contract.updateWeight(newWeight);
        addEventToLog('⏳ Transaction Pending', 'Updating weight...', 'pending');

        await tx.wait();
        addEventToLog('✅ Weight Updated', `New weight: ${newWeight} kg`, 'update');

        // Refresh profile
        await loadUserProfile();
        document.getElementById('newWeight').value = '';
    } catch (error) {
        console.error('Error updating weight:', error);
        alert('Failed to update weight: ' + error.message);
    }
}

// Log activity
async function logActivity() {
    const activityType = document.getElementById('activityType').value;
    const duration = document.getElementById('duration').value;
    const distance = document.getElementById('distance').value;

    if (!activityType || !duration || !distance) {
        alert('Please fill in all fields!');
        return;
    }

    try {
        const tx = await contract.logActivity(activityType, duration, distance);
        addEventToLog('⏳ Transaction Pending', 'Logging activity...', 'pending');

        await tx.wait();
        addEventToLog('✅ Activity Logged', `${activityType}: ${duration}min, ${distance}m`, 'activity');

        // Refresh profile
        await loadUserProfile();

        // Clear form
        document.getElementById('activityType').value = '';
        document.getElementById('duration').value = '';
        document.getElementById('distance').value = '';
    } catch (error) {
        console.error('Error logging activity:', error);
        alert('Failed to log activity: ' + error.message);
    }
}

// Setup event listeners for contract events
function setupEventListeners() {
    // UserRegister event
    contract.on("UserRegister", (userAddr, name, timestamp) => {
        if (userAddr.toLowerCase() === userAddress.toLowerCase()) {
            const date = new Date(timestamp.toNumber() * 1000);
            addEventToLog('🎉 User Registered', `Welcome ${name}!`, 'register', date.toLocaleString());
        }
    });

    // ProfileUpdate event
    contract.on("ProfileUpdate", (userAddr, newWeight, timestamp) => {
        if (userAddr.toLowerCase() === userAddress.toLowerCase()) {
            const date = new Date(timestamp.toNumber() * 1000);
            addEventToLog('📊 Profile Updated', `New weight: ${newWeight} kg`, 'update', date.toLocaleString());
        }
    });

    // ActivityLog event
    contract.on("ActivityLog", (userAddr, activityType, duration, distance, timestamp) => {
        if (userAddr.toLowerCase() === userAddress.toLowerCase()) {
            const date = new Date(timestamp.toNumber() * 1000);
            addEventToLog('🏃 Activity Logged',
                `${activityType} - Duration: ${duration}min, Distance: ${distance}m`,
                'activity',
                date.toLocaleString());
        }
    });

    // MilestoneAchieve event
    contract.on("MilestoneAchieve", (userAddr, milestone, timestamp) => {
        if (userAddr.toLowerCase() === userAddress.toLowerCase()) {
            const date = new Date(timestamp.toNumber() * 1000);
            addEventToLog('🏆 Milestone Achieved!', milestone, 'milestone', date.toLocaleString());
        }
    });
}

// Add event to the events log
function addEventToLog(title, details, type, timestamp = new Date().toLocaleString()) {
    const eventsLog = document.getElementById('eventsLog');

    // Remove "no events" message if it exists
    const noEventsMsg = eventsLog.querySelector('.no-events');
    if (noEventsMsg) {
        noEventsMsg.remove();
    }

    const eventItem = document.createElement('div');
    eventItem.className = `event-item ${type}`;
    eventItem.innerHTML = `
        <div class="event-title">${title}</div>
        <div class="event-details">${details}</div>
        <div class="event-timestamp">${timestamp}</div>
    `;

    // Add to top of log
    eventsLog.insertBefore(eventItem, eventsLog.firstChild);
}

// Connect button click handler
document.getElementById('connectBtn').addEventListener('click', connectWallet);

// Auto-connect if already connected
window.addEventListener('load', async () => {
    if (typeof window.ethereum !== 'undefined') {
        const accounts = await window.ethereum.request({ method: 'eth_accounts' });
        if (accounts.length > 0) {
            connectWallet();
        }
    }
});

// Handle account changes
if (typeof window.ethereum !== 'undefined') {
    window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length > 0) {
            window.location.reload();
        }
    });
}
