//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker{
    address public owner;

    //用户资料结构体
    struct UserProfile{
        string name;
        uint256 weight;
        bool isRegistered;

    }

    struct WorkoutActivity{
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;
    }

    mapping(address=>UserProfile)public userProfiles;

    mapping (address=>WorkoutActivity[])private workoutHistory;

    mapping(address=>uint256)public totalWorkouts;
    mapping(address=>uint256)public totalDistance;

    event UserRegistered(address indexed userAddress,string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress,uint256 newWeight, uint256 timestamp);
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
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }

    //注册一个新用户
    function registerUser(string memory _name, uint256 _weight)public{
        require(!userProfiles[msg.sender].isRegistered,"User already registered");

        userProfiles[msg.sender]=UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        //触发注册事件

        emit UserRegistered(msg.sender,_name,block.timestamp);
    }


    //更新用户体重
    function updateWeight(uint256 _newWeight) public onlyRegistered{
        //把当前用户（msg.sender） 在区块链存储里的个人资料（UserProfile）取出来
        //赋值给变量 profile后面直接改 profile，就等于直接修改链上的用户数据。
        UserProfile storage profile = userProfiles[msg.sender];

        //检查用户是否瘦了
        if(_newWeight<profile.weight&&(profile.weight - _newWeight) * 100 / profile.weight >= 5){
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }

        profile.weight = _newWeight;
        
        // Emit profile update event
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);

    }

    //记录一次健身
    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    )public onlyRegistered{
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });

        //加入用户的健身历史
        workoutHistory[msg.sender].push(newWorkout);

        //更新总的数据
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;

        //触发健身记录事件
        emit WorkoutLogged(
        msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );

        //判断健身次数里程碑
        if (totalWorkouts[msg.sender]==10){
            emit MilestoneAchieved(msg.sender,"10 Workouts Completed"  , block.timestamp);

        }else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }

        // 判断距离里程碑
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
        
    }

    //查询某用户的健身次数
    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }
}