//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    address public owner;
    
    // 创建一个用户资料的结构体，结构体可以看成是类似address的类型，只是存的信息多一些，存单个变量和打包存放多个变量的区别，所以后面结构体用法跟类型一样
    struct UserProfile {
        string name;
        uint256 weight; 
        bool isRegistered;
    }
    
    
    struct WorkoutActivity {
        string activityType; 
        uint256 duration;    // 单位秒
        uint256 distance;    // 单位米
        uint256 timestamp;   //时间戳
    }
    
   
    mapping(address => UserProfile) public userProfiles; //把用户与用户资料结构体关联，然后存放到用户资料文件柜中（userProfiles）
    
    mapping(address => WorkoutActivity[]) private workoutHistory;
    
   
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;
    
    //事件，被记录在链上的日志中，跟状态变量之类的分开存储，消耗gas少，一旦emit就会触发并广播出去，前端实时监听捕捉，页面出现有好玩的提示
    event UserRegistered(address indexed userAddress, string name, uint256 timestamp); //加indexed的，是索引参数，一个event最多3个索引参数，所以要给最常搜索的参数
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(
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
    
    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered"); //从用户的userProfiles文件柜里用点函数调用isRegistered的数据
        _;
    }
    
    // 新用户创建账户
    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        
        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        
        // 触发一个事件并广播出去
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }
    
    // 用户更新体重，用的是storege这个永久存储，因为体重数据要永久留在链上
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];
        
        // 检查体重是否减轻了之前的5%，但是用的是整数表达百分数的方法，uint是整数，如果不*100，计算得到的就是0，无法做判断。同时因为浮点数精度问题，以太币以wei做最小单位
        if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        
        profile.weight = _newWeight;
        
        // 触发体重更新事件
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    // 记录一次运动
    function logWorkout(
        string memory _activityType, 
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        // Create new workout activity
        WorkoutActivity memory newWorkout = WorkoutActivity({ //这里用了memory，为了临时把信息放在newWorkout里，然后push到workoutHistory里永久存储
            activityType: _activityType, //冒号清晰地显示了属性名和属性值，也能一眼看出结构体的初始化代码
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        }); //（{}）是结构体实例并初始化的固定语法
        
        // 把新运动push到运动记录里
        workoutHistory[msg.sender].push(newWorkout);
        
        // 更新记录
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        // 触发运动记录事件，你更新了一项运动，balabala
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );
        
        // 触发关于特定运动次数的事件
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) { //多次if
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // Check for distance milestones
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) { //后面的是为了保证1万米这个事件只触发一次
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }
    
    // 获取运动次数数据
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}
