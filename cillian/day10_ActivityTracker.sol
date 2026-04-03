//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {

    address public owner; // 管理员地址

    // 用户资料结构
    struct UserProfile { 
        string name;
        uint256 weight; 
        bool isRegistered;
    } 

    // 运动详情结构
    struct WorkoutActivity {
        string activityType; 
        uint256 duration;   
        uint256 distance;    
        uint256 timestamp; 
    }

    mapping(address => UserProfile) public userProfiles; // 用户资料映射

    mapping(address => WorkoutActivity[]) private workoutHistory; // 运动历史记录映射

    mapping(address => uint256) public totalWorkouts; // 累计运动次数

    mapping(address => uint256) public totalDistance; // 累计运动距离

    // 关键事件定义
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

    // 初始化部署者
    constructor() {
        owner = msg.sender;
    }

    // 权限验证：必须是注册用户
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }

    // 注册新用户
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // 发出注册事件
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    // 更新体重并检查里程碑 updateWeight(uint256 _newWeight)
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];
        
        // Check if significant weight loss (5% or more)
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        profile.weight = _newWeight;
        
        // 发出用户更新事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    // 记录运动数据并检查里程碑 
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
        
        // 添加用户运动历史
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新用户总运动数据
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // 发送运动事件
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        // 检查运动次数是否达到里程碑
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // 检查运动距离是否达到里程碑
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }

    // 查询用户运动总次数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }

}