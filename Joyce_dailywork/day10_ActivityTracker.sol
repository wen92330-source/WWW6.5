// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ActivityTracker{

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

    mapping (address => UserProfile) public UserProfiles;
    mapping (address => WorkoutActivity[]) private workoutHistory;
    mapping (address => uint256) public totalWorkouts;
    mapping (address => uint256) public totalDistance;

    modifier onlyRegistered(){
        require(UserProfiles[msg.sender].isRegistered, "User not registered!");
        _;
    }

    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
    event MilestoneAchieve(address indexed userAddress, string milestone, uint256 timestamp);

    function registerUser(string memory _name, uint256 _weight) public {
        require(!UserProfiles[msg.sender].isRegistered, "User already registered");
        UserProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = UserProfiles[msg.sender];

        if(_newWeight < profile.weight && (profile.weight - _newWeight) * 100 / profile.weight >= 5){
            emit MilestoneAchieve(msg.sender, "Weight goal reached", block.timestamp);
        }

        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    function logWorkout(
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered{
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

        if(totalWorkouts[msg.sender] == 10){
            emit MilestoneAchieve(msg.sender, "10 Workouts completed!", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50){
            emit MilestoneAchieve(msg.sender, "50 Workouts completed!", block.timestamp);
        }

        if(totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000){
            emit MilestoneAchieve(msg.sender, "100k Workouts completed!", block.timestamp);
        }
    }

    function getUserWorkoutCount() public view onlyRegistered returns (uint256){
        return workoutHistory[msg.sender].length;
    }

    function getUserWorkoutHistory() public view onlyRegistered returns (WorkoutActivity[] memory){
        return workoutHistory[msg.sender];
    }

    function getLatestWorkout() public view onlyRegistered returns (WorkoutActivity memory){
        require(workoutHistory[msg.sender].length > 0, "No workouts yet");
        uint256 lastIndex  = workoutHistory[msg.sender].length - 1;
        return workoutHistory[msg.sender][lastIndex];
    }
}