//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker{
    struct UserProfile{
        string name;
        uint256 weight;
        bool isRegistered;
    }

    struct WorkoutActivity{
        string ActivityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;
    }

    mapping (address => UserProfile) public userProfiles;
    mapping (address=>WorkoutActivity[]) private workoutActivities;
    mapping (address=>uint256) public totalWorkOuts;
    mapping (address=>uint256) public totalDistance;

    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, string name, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);

    modifier onlyRegistered(){
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }

    function registerUser(string memory _name, uint256 _weight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        userProfiles[msg.sender] = UserProfile({
            name:_name,
            weight: _weight,
            isRegistered: true
            });
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    function updateWeight(uint256 _newWeight) public onlyRegistered{
        UserProfile storage profile = userProfiles[msg.sender];
        if(_newWeight < profile.weight && (profile.weight - _newWeight)*100/profile.weight >= 5){
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }
        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, userProfiles[msg.sender].name, _newWeight, block.timestamp);
    }

    function logWorkout(string memory _activityType, uint256 _duration, uint256 _distance) public onlyRegistered{
        WorkoutActivity memory newWorkout = WorkoutActivity({
            ActivityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });
        workoutActivities[msg.sender].push(newWorkout);
        totalWorkOuts[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        emit WorkoutLogged(msg.sender, _activityType, _duration, _distance, block.timestamp);

        if(totalWorkOuts[msg.sender] % 10 == 0){
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        }
        else if(totalWorkOuts[msg.sender] == 50 ){
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        if(totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000){
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }

    function getUserWorkoutCount() public view onlyRegistered returns (uint256){
        return workoutActivities[msg.sender].length;
    }
}