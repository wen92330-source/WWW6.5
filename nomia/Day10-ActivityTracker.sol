//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    address public owner; //合约部署人
    
    
    struct UserProfile { //be like 信息包 把多个相关数据打包在一起
        string name;
        uint256 weight; 
        bool isRegistered;

    }
    
    
    struct WorkoutActivity {
        string activityType; 
        uint256 duration;    // seconds
        uint256 distance;    // meters
        uint256 timestamp;   

    }
    
   //每个地址对应一个用户资料
    mapping(address => UserProfile) public userProfiles;
    
    //每个地址对应workout activity的数组 外部不可直接读取
    mapping(address => WorkoutActivity[]) private workoutHistory;
    
    mapping(address => uint256) public totalWorkouts;

    mapping(address => uint256) public totalDistance;
    
    //event 区块链上的通知消息日志记录
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp); //事件触发 用户注册
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);//事件触发 体重更新
    event WorkoutLogged( //事件触发 workout数据记录
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );

    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyRegistered() { //需要是已注册用户
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;

    }
    
    //新用户注册
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // 触发用户注册成功事件 把这条消息广播出去
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    // 更新用户体重
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender]; //storage是永久的
        
    
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);//如果达成上述条件触发里程碑事件
        }
        
        profile.weight = _newWeight;//更新体重
        
        // 触发profile update事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    //记录运动数据
    function logWorkout(
        string memory _activityType, //临时存储
        uint256 _duration,
        uint256 _distance

    ) public onlyRegistered {
        //创建新的运动记录
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        
        // 加入历史记录
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新运动总数
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // 触发成功记录运动事件
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        //里程碑是否达成
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);

        }
        
        // 总里程
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }

    }
    
    // 获取当前用户的运动记录量 
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;

    }


}