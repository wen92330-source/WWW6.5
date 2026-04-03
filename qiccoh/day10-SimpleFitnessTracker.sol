 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {


 //个人资料-结构体   
struct UserProfile {
    string name;
    uint256 weight; // in kg
    bool isRegistered;
}
    
struct WorkoutActivity {
    string activityType;//活动类型
    uint256 duration; // 持续时间
    uint256 distance; // 用户运动的距离
    uint256 timestamp;//发生时间
}
mapping(address => UserProfile) public userProfiles;//用户个人资料
mapping(address => WorkoutActivity[]) private workoutHistory;//锻炼日志数组
mapping(address => uint256) public totalWorkouts;//锻炼日志数组
mapping(address => uint256) public totalDistance;//总距离

//    indexed 时，你使它变得可搜索，一个事件索引最多三个
event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

//  修改器是一个简单的检查——它确保调用者已经注册
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
// 报告事件 消耗gas 最便宜的
    emit UserRegistered(msg.sender, _name, block.timestamp);
}
// 注册用户更新他们的体重
function updateWeight(uint256 _newWeight) public onlyRegistered {
    //创建引用 storage-》改变永久
    UserProfile storage profile = userProfiles[msg.sender];
// 设定门槛，生成里程碑报告----体重是否比当前体重至少减少了 5%。
    if (_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5) {
        emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
    }
// 保存新体重
    profile.weight = _newWeight;
// 报告
    emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
}
   
function logWorkout(
    // 该函数接受三个参数
    string memory _activityType,
    uint256 _duration,
    uint256 _distance
) public onlyRegistered {
    // 临时创建这个结构体，
    WorkoutActivity memory newWorkout = WorkoutActivity({
        activityType: _activityType,
        duration: _duration,
        distance: _distance,
        timestamp: block.timestamp
    });

    // 新的锻炼被添加到用户的锻炼历史-动态数组的形式
    workoutHistory[msg.sender].push(newWorkout);

    // 更新汇总统计数据
    totalWorkouts[msg.sender]++;
    totalDistance[msg.sender] += _distance;

    // Emit workout logged event
    emit WorkoutLogged(
        msg.sender,
        _activityType,//前端显示新活动
        _duration,//更新图表
        _distance,//动画化进度条
        block.timestamp//时间戳
    );

    // 检测并庆祝里程碑
    if (totalWorkouts[msg.sender] == 10) {
        emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
    } else if (totalWorkouts[msg.sender] == 50) {
        emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
    }

    // 检查用户的总距离
    if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
        emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
    }

}
  //  只读函数。它告诉用户他们到目前为止记录了多少次锻炼
function getUserWorkoutCount() public view onlyRegistered() returns (uint256) {
    return workoutHistory[msg.sender].length;
}
}