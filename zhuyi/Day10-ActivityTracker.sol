 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {

    //数据结构
    struct UserProfile {
        string name;
        uint256 weight; // in kg
        bool isRegistered;
    }

        
    struct WorkoutActivity {
        string activityType;
        uint256 duration; // in seconds
        uint256 distance; // in meters
        uint256 timestamp;
    }

    mapping(address => UserProfile) public userProfiles;
    mapping(address => WorkoutActivity[]) private workoutHistory;
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;

    //声明事件
    //event:定义的日志格式。当你的合约中发生重要事件时，你可以 emit（发出）一个这样的事件，它将被记录在交易日志中
    //indexed: 可搜索参数
    // 在一个事件中，最多只能索引三个参数
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

    //提示注册
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }

    
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");

        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        //发出事件确实会消耗一点 Gas（因为日志被写入区块链），但它们比在链上存储数据便宜得多
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    //storage：更新是永久
    //`storage` 是持久的——它存在于区块链上，读/写都需要消耗 Gas。
    //`memory` 是临时的——它只在函数调用期间存在，而且便宜得多。
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];

        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }

        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

       
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance) public onlyRegistered {
        // Create new workout activity
        WorkoutActivity memory newWorkout = WorkoutActivity({
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
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }

     //只读：记录次数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}