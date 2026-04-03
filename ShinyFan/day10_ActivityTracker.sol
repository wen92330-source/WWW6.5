// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker {
    struct UserProfile {//struct是结构体，将以下的信息整合在一起，使用时只需要写struct就行
        string name;
        uint256 weight;
        bool isRegistered; //是否注册 没赋值时“bool 变量名”默认为false
    }

    struct WorkoutActivity {
        string activityType;
        uint256 duration; // 持续时间/秒
        uint256 distance; // 路程/米
        uint256 timestamp;//时间戳 记录什么时候开始的
    }

    mapping(address => UserProfile) public userProfiles;//每个用户拥有个人资料
    mapping(address => WorkoutActivity[]) private workoutHistory;//private隐私、非公开的 每个用户拥有运动日志
    mapping(address => uint256) public totalWorkouts;//跟踪每个用户记录了多少次锻炼
    mapping(address => uint256) public totalDistance;//跟踪每个用户总共运动里程

    event UserRegistered(address indexed userAdress, string name,uint256 timetamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);//个人信息更新
    event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);//运动日志
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);//里程碑播报
    //indexed是索引，前端可以搜索到indexed的参数。例如，如果你只想在 Alice 的个人资料页面上显示她的事件，你的前端可以查询日志，并只拉取那些 userAddress == Alice 的事件
    //indexed只能用在event里，一个event里最多有三个indexed。

    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");//映射表[钥匙].某一个需求值
        _;
    }

    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");

        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        //冒号是给结构体赋值的固定用法，结构体字段：值

        emit UserRegistered(msg.sender, _name, block.timestamp);//触发事件，传入设定事件需要的参数就可以触发
    }

    function updateWeight (uint256 _newWeight)public onlyRegistered{
        UserProfile storage profile = userProfiles[msg.sender];//storage是将profile 代替 userProfiles[msg.sender]，永久储存在链上

        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {// && 是并且的意思 必须两边的条件都满足
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);//触发里程碑事件
        }
        
        profile.weight = _newWeight;//更新体重
        
        // 触发更新资料事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }


    // 记录一次锻炼活动
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        // 创建一个新的锻炼活动，把这次锻炼的所有信息，打包成一条完整的结构体记录，以便存进用户的锻炼历史数组
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });

        // 添加用户新的锻炼历史记录
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新总锻炼次数和运动里程
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // 触发锻炼日志
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        // 检查锻炼次数的里程碑情况
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {//如果不满足上面的条件1，满足条件2则触发下面这条
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // 检查里程数
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {//第二个条件是总里程-这次里程小于十万米，保证是这一次达到的成就
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    // 获取用户一共锻炼几次
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }

}