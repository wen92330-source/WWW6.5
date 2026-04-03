//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
        address public owner;

    // user profiles struct //注释，提示下方是用户资料的结构定义
    struct UserProfile { //定义一个名为 UserProfile 的结构体，用于组合存储用户信息。
        string name; //存储用户的名字
        uint256 weight; //存储用户的体重（正整数）
        bool isRegistered; //布尔值，标记该用户是否已经在系统中注册
    }

    struct WorkoutActivity {  //定义另一个结构体，用于记录单次运动的数据
        string activityType; // 运动类型（如“跑步”或“游泳”）
        uint256 duration;//运动时长
        uint256 distance;//运动距离
        uint256 timestamp;//记录运动发生的时间戳
    }
    mapping(address => UserProfile) public userProfiles;//定义了一个公开映射,将以太坊地址映射到userProfile结构体
    mapping(address => WorkoutActivity[]) private workoutHistory;//定义了一个私有映射workoutHistory，把以太坊地址映射到WorkoutActivity数组，用于记录用户的锻炼历史。

    mapping(address => uint256) public totalWorkouts;//将以太坊地址映射到uint256，用于记录每个地址对应的总锻炼次数
    mapping(address => uint256) public totalDistance;//把以太坊地址映射到uint256，用来记录每个地址对应的总运动距离。

    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);//定义了一个名为UserRegistered的事件，当用户注册时触发，记录注册用户的地址、姓名以及注册时间戳
    event ProfileUpdated(address indexed usersAddress, uint256 newWeight, uint256 timestamp);//当用户资料更新时触发，记录更新用户的地址、新体重及时间戳
    event WorkoutLogged(
        address indexed userAddress,
        string activityType,
        uint256 duration,
        uint256 distance,
        uint256 timestamp
    );
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    //当用户达成某个里程碑时触发，记录用户地址、里程碑内容及时间戳

    constructor() { //构造函数，将合约部署者地址赋值给owner变量
        owner =msg.sender;
    }

    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
        //检查调用者是否为已注册用户，不是则抛出错误
    }

        // ========== 新增核心函数：用户注册 ==========
    function registerUser(string memory _name, uint256 _initialWeight) public {
        // 检查用户是否已注册，避免重复注册
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        // 检查用户名非空、体重大于0（基础校验）
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_initialWeight > 0, "Weight must be greater than 0");

        // 存储用户资料
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _initialWeight,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    function getLatestWorkout() public view onlyRegistered returns (
        string memory activityType,
        uint256 duration,
        uint256 distance,
        uint256 timestamp
    ) {

        // 获取用户的运动历史数组
        WorkoutActivity[] memory history = workoutHistory[msg.sender];
        // 检查是否有运动记录
        require(history.length > 0, "No workout history found");
        // 取数组最后一个元素（最新的记录）
        WorkoutActivity memory latestWorkout = history[history.length - 1];
        // 返回最新记录的字段
        return (
            latestWorkout.activityType,
            latestWorkout.duration,
            latestWorkout.distance,
            latestWorkout.timestamp
        );
    }


        function getWorkoutHistory() public view onlyRegistered returns (WorkoutActivity[] memory) {
        // 返回当前调用者的运动历史数组
        return workoutHistory[msg.sender];
    }

    function getUserRegistrationInfo(address _user) public view returns (string memory name, bool isRegistered, uint256 weight) {
        UserProfile memory profile = userProfiles[_user];
        return (profile.name, profile.isRegistered, profile.weight);
    }

    function verifyUserRegistration(address _userAddress) public view returns (string memory name, uint256 weight, bool isRegistered) {
        // 直接读取userProfiles映射中的数据（核心验证逻辑）
        UserProfile memory user = userProfiles[_userAddress];
        return (user.name, user.weight, user.isRegistered);
    }


    //function to log workout activities
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {

    // Emint workout logged event //锻炼记录事件
    emit WorkoutLogged(//表示触发WorkoutLogged事件，该事件用于记录锻炼相关信息
        msg.sender,
        _activityType,
        _duration,
        _distance,
        block.timestamp
    );

    // Check for workout count milestones注释，提示接下来代码是检查锻炼次数里程碑
    if (totalWorkouts[msg.sender] == 10) { //通过if语句判断当前调用者地址对应的总锻炼次数totalWorkouts是否等于 10
        emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);//如果到达10此就会记录
    } else if (totalWorkouts[msg.sender] == 50) {//看看有没有到达50次
        emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);//等于50，就会触发地址时间戳
    }
    
    // Check for distance milestones 检查运动距离里程碑
    if (totalDistance[msg.sender] >= 10000 && (totalDistance[msg.sender]) - _distance < 10000) { //判断总运动距离是否达到10000，且本次运动距离加上之前总距离小于10000
        emit MilestoneAchieved(msg.sender, "100k Total Distance", block.timestamp);//若条件满足就触发事件，记录用户达成。
    }
}
    // Get the numeber of workouts for a user //定义了一个名为getUserWorkoutCount的公共视图函数，用于获取用户锻炼次数，需已注册用户才能调用
    function getUserWorkoutCount() public view returns (uint256) {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        return workoutHistory[msg.sender].length;
    }
    }
