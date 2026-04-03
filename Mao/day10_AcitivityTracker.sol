//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//健身追踪器，学习事件。达到某个条件，自动触发事件，返回给前端显示出不同效果

contract SimpleFitnessTracker {
    
    //定义两个数据结构
    //1、用户的数据结构
    struct UserProfile{
        string name;
        uint256 weight;
        bool isRegistered;
        uint256 totalWorkouts;
        uint256 totalDistance;
    }

    //2、每次锻炼的细节
    struct WorkoutActivity{
        string activityType;
        uint256 duration; //秒
        uint256 distance; //米
        uint256 timestamp; //发生时间
    }
    //映射关系，每个用户地址对应一个用户，一个用户地址对应一个锻炼数组
    mapping ( address => UserProfile ) public userProfile;
    mapping ( address => WorkoutActivity[] ) private WorkoutActivities;

   //indexed:  一个参数标记为 indexed 时，你使它变得可搜索。这意味着你可以在前端根据该特定值筛选日志。  
   //在一个事件中，你最多只能索引**三个**参数。所以要明智地使用它们。
   event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
   event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
   event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
   event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

   //修改器
   modifier onlyRegistered(){
     require(userProfile[msg.sender].isRegistered, "You must register before using this app.");
      _;
   }
  
  //用户注册
  function registeredUser(string memory _name,uint256 _weigth) public {
    require(!userProfile[msg.sender].isRegistered,"User already registered");
    
    userProfile[msg.sender]=UserProfile({
        name:_name,
        weight:_weigth,
        isRegistered:true,
        totalWorkouts:0,
        totalDistance:0
    });

    //发出事件是智能合约暴露数据最节省 Gas 的方式之一。
    //这就是为什么我们经常将它们用于前端更新、分析以及任何不需要永久存储在状态中的事情。
    emit UserRegistered(msg.sender, _name, block.timestamp);
  }


   //更新体重，里程碑检查，更新体重
   function updateWeight(uint256 _newWeight) public onlyRegistered{
       UserProfile storage profile = userProfile[msg.sender];

       //检查里程碑
       if(_newWeight < profile.weight && (profile.weight - _newWeight)*100/profile.weight >=5){
           emit MilestoneAchieved(msg.sender,"5% weight loss",block.timestamp);
       }
       //更新体重
       profile.weight = _newWeight;
       emit ProfileUpdated(msg.sender,_newWeight,block.timestamp);
   }

   //追踪每一次训练
   function logWorkout(string memory _activityType,uint256 _duration,uint256 _distance) public onlyRegistered {
       //1、更新训练活动
       WorkoutActivity memory newWorkout = WorkoutActivity({
           activityType:_activityType,
           duration:_duration,
           distance:_distance,
           timestamp:block.timestamp
       });
   
    WorkoutActivities[msg.sender].push(newWorkout);
    
    //更新每个用户的运动时间和距离
    // 获取该用户的存储指针 (指向 userProfiles 映射里的那条记录)
    UserProfile storage profile = userProfile[msg.sender];

    //  直接更新结构体内部的字段
    profile.totalWorkouts += 1;          // 对应流程图：更新 totalWorkouts
    profile.totalDistance += _distance;  // 对应流程图：更新 totalDistance
   
    //触发运动记录
     emit WorkoutLogged(
        msg.sender,
        _activityType,
        _duration,
        _distance,
        block.timestamp
    );

    //检查运动次数是否到达里程碑10/50
    if(profile.totalWorkouts == 10){
        emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
    } else if(profile.totalWorkouts == 50){
         emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
    }

    //检查距离里程碑：这确保了我们只在用户跨过阈值的那一刻触发一次
    if(profile.totalDistance >= 10000 && profile.totalDistance - _distance < 10000){
      emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
   }
}
      //目前为止进行了多少次训练
   function getUserWorkoutCount() public view onlyRegistered returns (uint256){
    return WorkoutActivities[msg.sender].length;
   }

}