//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    address public owner;
    
    // User profile struct
    // 每个注册的地址都会在链上存储一个这样的个人资料。
    struct UserProfile {
        string name;
        uint256 weight; 
        bool isRegistered;
    }
    // 每当用户记录一次锻炼，我们就会创建一个这样的结构体并将其添加到他们的锻炼历史中。
    struct WorkoutActivity {
        string activityType; 
        uint256 duration;    // in seconds
        uint256 distance;    // in meters
        uint256 timestamp;   
    }
    /* struct（结构体）将不同类型的数据（如string字符串/uint数字/bool值）打包在一起，形成一个有意义的整体。使用 struct 后，你可以直接定义一个 User 类型，包含了多项信息，而不是定义多个散乱的变量。*/
    
   // 用映射将数据结构连接起来
    mapping(address => UserProfile) public userProfiles; // 为每个用户（通过他们的地址）存储一份个人资料
    mapping(address => WorkoutActivity[]) private workoutHistory; // 为每个用户保存一个锻炼日志数组
    mapping(address => uint256) public totalWorkouts; // 跟踪每个用户记录了多少次锻炼
    mapping(address => uint256) public totalDistance; // 跟踪用户覆盖的总距离
    
    // 声明一些事件，这样前端就能对它们作出反应（event中的变量是想要广播的信息）
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(
        address indexed userAddress,  // 当你将一个参数标记为 indexed 时，你使它变得可搜索。这意味着你可以在前端根据该特定值筛选日志。// 注意：在一个事件中，你最多只能索引三个参数。
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    /* 在 Solidity 中，一个 `event` 就像定义一个自定义的日志格式。当你的合约中发生重要事件时，你可以 `emit`（发出）一个这样的事件，它将被记录在交易日志中。
    事件不会影响你的合约状态——它们只是合约用来表达“嘿，刚刚发生了点事”并发送相关细节的一种方式。
    然后，这些日志可以被你的前端捕获，以显示消息、更新用户界面或实时触发操作。
    如果不使用event，合约内部合约执行完，外部前端并不知晓，只能不停轮询（polling）读取变量来判断数据是否变化，这既低效又费钱。
    虽然发出事件确实会消耗一点 Gas（因为日志被写入区块链），但它们比在链上存储数据便宜得多。事实上，发出事件是智能合约暴露数据最节省 Gas 的方式之一。这就是为什么我们经常将它们用于前端更新、分析以及任何不需要永久存储在状态中的事情。所以，大胆地发出事件吧。它便宜、快速，并使你的 dApp 充满活力。*/

    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    // Register a new user
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // Emit registration event
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    // Update user weight
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender]; // 【声明profile局部变量，以UserProfile类型，显式声明更改存储在storage，并反映在全局的userProfiles映射中。】【关于赋值号（=）：数据类型相同 -> userProfiles是一个address类型到UserProfile类型的映射。存储位置相同 -> userProfiles是状态变量，天然存在于storage。】// UserProfile：是结构体，也是类型。// storage：创建一个指向区块链上永久存储位置的引用，引用合约存储中已经存在的数据，并且更改也存储其中（不同于memory在临时副本上工作，任何更改都将在函数结束时被丢弃）。// profile：定义在函数内部的局部变量。像一个存储指针，在函数中修改profile就直接修改了区块链上的userProfiles 映射。
        
        // Check if significant weight loss (5% or more)
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) { // 如果没有第一个判断条件，第二个判断条件为负，uint无法识别，函数会报错回滚。
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        profile.weight = _newWeight;
        
        // Emit profile update event
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    // Log a workout activity
    function logWorkout(string memory _activityType, uint256 _duration, uint256 _distance) public onlyRegistered {
        // Create new workout activity
        WorkoutActivity memory newWorkout = WorkoutActivity({ // 为什么是memory：临时创建 newWorkout 结构体，只是为了把数据推入 workoutHistory 数组，newWorkout不需要被永久存储
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        // Add to user's workout history
        workoutHistory[msg.sender].push(newWorkout);
        
        // Update total stats
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // Emit workout logged event
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        // Check for workout count milestones
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // Check for distance milestones
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) { // 这确保了我们只在用户跨过阈值的那一刻触发一次里程碑
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    // Get the number of workouts for a user
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length; // 原则上和返回totalWorkouts变量值结果相同
    }
}