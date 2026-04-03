// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 事件（events）:当发生时会发出日志（emit logs），用于监听或记录某个重要的时刻，触发相应的特殊情景
contract SimpleFitnessTracker {
    //结构体构建
    struct UserProfile {
        string name;
        uint256 weight; //单位：kg
        bool isRegistered;
    }
    struct WorkoutActivity {
        string activityType;
        uint256 duration; //单位：seconds
        uint256 distance; //单位：meters
        uint256 timestamp; //记录运动发生的时间
    }
    mapping (address => UserProfile) public userProfiles; //存储每个用户的个人资料
    mapping (address => WorkoutActivity[]) private workoutHistory; //存储每个用户的锻炼日志数组
    mapping (address => uint256) public totalWorkouts; //跟踪每个用户记录了多少次锻炼
    mapping (address => uint256) public totalDistance; //跟踪用户覆盖的总距离

    //声明事件（从而让前端能对其作出反应）——event，定义一个自定义的日志格式，里面的参数在事件发生时会被记录下来
    event UserRegistered (address indexed userAddress, string name, uint256 timestamp); //标记为indexed，参数可以被搜索，可以利用该值进行日志筛选。一个事件中，最多只能索引3个参数
    event ProfileUpdated (address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged (address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved (address indexed userAddress, string milestone, uint256 timestamp);

    //设置权限
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered.");
        _;
    }

    //加入健身小队
    function registerUser (string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered.");

        userProfiles[msg.sender] = UserProfile ({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _name, block.timestamp); //发出evets比在链上存储数据消耗更少的gas
    }

    //更新体重数据
    function updateWeight (uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender]; //访问用户的个人资料并引用——storage：并非创建一个原数据的副本，而是直接引用，以便后续更新后直接修改原数据

        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) { //新体重是否比当前体重减少了至少5%（一个显著的进步）
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached.", block.timestamp);
        }

        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    //追踪每一次的运动训练
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        //创建一个新的运动记录
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration:  _duration,
            distance: _distance,
            timestamp: block.timestamp
        });

        //添加到该用户的运动记录跟踪里
        workoutHistory[msg.sender].push (newWorkout);

        //更新该用户的总运动数据
        totalWorkouts[msg.sender] ++; //总运动次数+1
        totalDistance[msg.sender] += _distance; //总运动距离增加

        //发出事件
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );

        //检测并庆祝里程碑
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed.", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed.", block.timestamp);
        }
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance.", block.timestamp);
        } //只有当新的距离总数超过了100K，且之前的旧距离总数（新距离总数-此次运动的距离）没有超过100K的时候，才触发——仅在跨过100K阈值的那一刻
    }

    //告诉用户至今的运动次数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}