// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker {
    // ================= 结构体定义 =================
    struct UserProfile {
        string name;
        uint256 weight;
        bool isRegistered;
    }
    
    struct WorkoutActivity {
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;
    }
    
    // ================= 状态变量 =================
    // 确保上面结构体的大括号 } 已经闭合
    
    mapping(address => UserProfile) public userProfiles;
    mapping(address => WorkoutActivity[]) private workoutHistory;
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;
    
    // ================= 事件 =================
    // 【重点检查】确保每个事件末尾都有分号 ;
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    // ^ 这里必须有分号
    
    // ================= 修饰符 =================
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    
    // ================= 功能函数 =================
    
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "Already registered");
        
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];
        
        if (_newWeight < profile.weight) {
            uint256 weightLost = profile.weight - _newWeight;
            if ((weightLost * 100) / profile.weight >= 5) {
                emit MilestoneAchieved(msg.sender, "Weight Goal Reached (5% lost!)", block.timestamp);
            }
        }
        
        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    function logWorkout(
        string memory _activityType, 
        uint256 _duration, 
        uint256 _distance
    ) public onlyRegistered {
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        workoutHistory[msg.sender].push(newWorkout);
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);
        
        checkMilestones(_distance);
    }
    
    function checkMilestones(uint256 _lastDistance) private {
        uint256 count = totalWorkouts[msg.sender];
        uint256 distance = totalDistance[msg.sender];
        
        if (count == 10) {
            emit MilestoneAchieved(msg.sender, "10 workouts completed!", block.timestamp);
        } else if (count == 50) {
            emit MilestoneAchieved(msg.sender, "50 workouts completed!", block.timestamp);
        }
        
        if (distance >= 100000 && (distance - _lastDistance) < 100000) {
            emit MilestoneAchieved(msg.sender, "100km distance achieved!", block.timestamp);
        }
    }
    
    // ================= 查询函数 =================
    
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return totalWorkouts[msg.sender];
    }
    
    function getWorkoutHistory() public view onlyRegistered returns (WorkoutActivity[] memory) {
        return workoutHistory[msg.sender];
    }
    
    function getLatestWorkout() public view onlyRegistered returns (WorkoutActivity memory) {
        require(workoutHistory[msg.sender].length > 0, "No workouts yet");
        uint256 lastIndex = workoutHistory[msg.sender].length - 1;
        return workoutHistory[msg.sender][lastIndex];
    }
}