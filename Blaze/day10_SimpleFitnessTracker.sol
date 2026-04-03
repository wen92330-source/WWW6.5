// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//链上健身记录器
contract SimpleFitnessTracker {
    //个人信息
    struct UserProfile {
        string name;
        uint256 weight; // in kg
        bool isRegistered;
    }
    //锻炼信息
    struct WorkoutActivity {
        string activityType;
        uint256 duration; // in seconds
        uint256 distance; // in meters
        uint256 timestamp;
    }

    mapping(address => UserProfile) public userProfiles;//为每个用户（通过他们的地址）存储一份个人资料
    mapping(address => WorkoutActivity[]) private workoutHistory;//为每个用户保存一个锻炼日志数组
    mapping(address => uint256) public totalWorkouts;//跟踪每个用户记录了多少次锻炼
    mapping(address => uint256) public totalDistance;//跟踪用户覆盖的总距离

    

    //事件声明
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);//用户注册事件
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);//用户信息更新事件
    //event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);//触发徽章、音效或解锁奖励

    
    event WorkoutLogged(
        address indexed userAddress, //谁进行了锻炼
        string activityType,//他们做了什么类型的活动——跑步、骑行等。
        uint256 duration,//锻炼持续了多长时间，单位=秒
        uint256 distance,//他们运动了多远，单位=米
        uint256 timestamp//事件发生的时间，使用 block.timestamp 捕获。
    );

    //确保调用者已经注册
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }

    //先注册用户
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");

        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        //调用UserRegistered事件：记录有人刚刚注册了——这是他是谁，以及注册的时间
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    //更新体重
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        //直接指向合约存储中已经存在的数据
        UserProfile storage profile = userProfiles[msg.sender];

        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }

        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }


    //处理用户记录新锻炼时发生的一切
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
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

    //告诉用户他们到目前为止记录了多少次锻炼
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }







}