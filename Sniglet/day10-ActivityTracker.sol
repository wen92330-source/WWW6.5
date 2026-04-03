// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker{
    struct UserProfile {
        string name ;
        uint256 weight ;
        bool isRegistered;
    }

struct WorkoutActivity{
    string activityType;
    uint256 duration;
    uint256 distance;
    uint256 timestamp;
    }

mapping(address=> UserProfile) public userProfiles;
mapping(address => WorkoutActivity[]) private workoutHistory;
mapping(address => uint256) public totalWorkouts;
mapping(address => uint256) public totalDistance;

event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
event UserRegistered(address indexed userAddress,string name ,uint256 timestamp);
event WorkoutLogged(
    address indexed userAddress, 
    string activityType, 
    uint256 duration, 
    uint256 distance, 
    uint256 timestamp
    );
event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

modifier onlyRegistered(){
    require(userProfiles [msg.sender].isRegistered, "User not registered");
    _;
}

function registerUser(string memory _name ,uint256 _weight)public{
    require(!userProfiles[msg.sender]. isRegistered,"alredy registered");
    userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _name,block.timestamp);
}

function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];
        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }
    
    // 记录锻炼
    function logWorkout(
        string memory _activityType, 
        uint256 _duration, 
        uint256 _distance
    ) public onlyRegistered {
        WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
workoutHistory[msg.sender].push(newWorkout);
        totalWorkouts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);
checkMilestones();
}

function checkMilestones() private{
    if (totalWorkouts[msg.sender]==10){
        emit MilestoneAchieved(msg.sender,"10workouts!!!!",block.timestamp);
    }
    if (totalDistance[msg.sender] >= 100000) {  
        emit MilestoneAchieved(msg.sender, "100km Milestone", block.timestamp);
    }
    if (totalWorkouts[msg.sender] == 50) {
        emit MilestoneAchieved(msg.sender, "50 workouts completed!", block.timestamp);
    }

}




 function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return totalWorkouts[msg.sender];
    }
    
    function getWorkoutHistory() public view onlyRegistered returns (WorkoutActivity[] memory) {
        return workoutHistory[msg.sender];
    }
    
    function getLatestWorkout() public view onlyRegistered returns (WorkoutActivity memory) {
        require(workoutHistory[msg.sender].length > 0, "No workouts yet");
        uint256 lastIndex = workoutHistory[msg.sender].length - 1;
        return workoutHistory[msg.sender][lastIndex];
}
}