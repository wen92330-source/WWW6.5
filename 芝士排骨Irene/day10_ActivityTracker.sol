// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 运动追踪智能合约 - 用于记录用户的健身活动数据
contract ActivityTracker {

    //结构体定义

    // 用户档案结构体 - 存储用户的基本信息
    struct UserProfile {
        string name;           // 用户名称
        uint256 weight;        // 体重（单位可自定义，如千克）
        bool isRegistered;     // 是否已注册（用于权限控制）
    }

    // 锻炼活动结构体 - 记录每次锻炼的详细信息
    struct WorkoutActivity {
        string activityType;   // 活动类型："跑步"、"游泳"、"骑行"等
        uint256 duration;      // 持续时间（分钟）
        uint256 distance;      // 距离（米）
        uint256 timestamp;     // 时间戳（记录锻炼的时间）
    }

    //状态变量（永久存储在区块链上）

    // 地址 => 用户档案 的映射，存储每个用户的基本信息
    mapping(address => UserProfile) public userProfiles;

    // 地址 => 锻炼记录数组 的映射，存储每个用户的所有锻炼历史（私有，外部无法直接访问）
    mapping(address => WorkoutActivity[]) private workoutHistory;

    // 地址 => 总锻炼次数 的映射，方便快速查询
    mapping(address => uint256) public totalWorkouts;

    // 地址 => 总距离 的映射，累计用户的运动总距离
    mapping(address => uint256) public totalDistance;

    //事件定义（用于前端监听和日志记录）

    // 用户注册事件 - 当新用户注册时触发
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);

    // 档案更新事件 - 当用户更新体重时触发
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);

    // 锻炼记录事件 - 当用户记录一次新锻炼时触发
    event WorkoutLogged(
        address indexed userAddress,
        string activityType,
        uint256 duration,
        uint256 distance,
        uint256 timestamp
    );

    // 里程碑达成事件 - 当用户达成特定目标时触发
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

    //修饰符（函数的前置条件检查）
    // 仅已注册用户可调用 - 未注册用户调用会被拒绝并提示错误
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered"); // 检查调用者是否已注册
        _;  // 继续执行被修饰的函数
    }

    //写入函数（会修改区块链状态）

    // 注册用户 - 新用户填写姓名和体重进行注册
    function registerUser(string memory _name, uint256 _weight) public {
        // 检查用户是否已经注册，防止重复注册
        require(!userProfiles[msg.sender].isRegistered, "Already registered");

        // 创建用户档案并存储到 mapping 中
        // 这里直接赋值给 storage 类型的 mapping，数据会永久保存在链上
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        // 触发注册事件，通知前端或其他监听者
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    // 更新体重 - 已注册用户可以更新自己的体重
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        // storage 关键字：引用状态变量，修改会永久保存到区块链
        // 相当于直接操作链上数据，而非拷贝一份副本
        UserProfile storage profile = userProfiles[msg.sender];
        profile.weight = _newWeight;  // 永久修改链上的体重数据

        // 触发档案更新事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    // 记录锻炼 - 用户提交一次锻炼的详细信息
    function logWorkout(
        string memory _activityType,  // 活动类型（如"跑步"）
        uint256 _duration,            // 持续时间（分钟）
        uint256 _distance             // 距离（米）
    ) public onlyRegistered {
        // memory 关键字：临时变量，函数结束后销毁
        // 先在内存中创建锻炼记录对象，再推入存储数组
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp  // 使用区块时间戳作为记录时间
        });

        // 将新的锻炼记录添加到用户的历史记录数组中（永久存储）
        workoutHistory[msg.sender].push(newWorkout);

        // 更新统计数据
        totalWorkouts[msg.sender]++;           // 总锻炼次数 +1
        totalDistance[msg.sender] += _distance; // 累加总距离

        // 触发锻炼记录事件
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);

        // 检查是否达成里程碑
        checkMilestones();
    }

    // 内部函数（仅合约内部可调用）

    // 检查里程碑 - 根据用户的累计数据判断是否达成目标
    function checkMilestones() private {
        // 里程碑1：完成10次锻炼
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 workouts completed!", block.timestamp);
        }

        // 里程碑2：累计跑步100公里（100km = 100000米）
        if (totalDistance[msg.sender] >= 100000) {
            emit MilestoneAchieved(msg.sender, "100km distance achieved!", block.timestamp);
        }

        // 里程碑3：完成50次锻炼
        if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 workouts completed!", block.timestamp);
        }
    }

    //查询函数（只读，不消耗 gas）

    // 获取用户锻炼总次数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return totalWorkouts[msg.sender];
    }

    // 获取用户的完整锻炼历史记录
    // 返回 memory 类型的数组 - 返回的是链上数据的副本，不会影响原数据
    function getWorkoutHistory() public view onlyRegistered returns (WorkoutActivity[] memory) {
        return workoutHistory[msg.sender];
    }

    // 获取用户最近一次锻炼记录
    function getLatestWorkout() public view onlyRegistered returns (WorkoutActivity memory) {
        // 确保用户至少有一条锻炼记录
        require(workoutHistory[msg.sender].length > 0, "No workouts yet");

        // 获取数组最后一个元素的索引
        uint256 lastIndex = workoutHistory[msg.sender].length - 1;

        // 返回最新的锻炼记录
        return workoutHistory[msg.sender][lastIndex];
    }
}