// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    address public owner;

    //User profile struct
    struct UserProfile{
        string name;
        uint256 weight;
        bool isRegistered;
    }

    struct WorkoutActivity {
        string activityType;
        uint256 duration;
        uint256 distance;
        uint256 timestamp;
    }

    mapping(address => UserProfile) public userProfiles;
    
    mapping(address => WorkoutActivity[]) private workoutHistory;
    
   
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;

    event UserRegistered(address indexed userAddress, string name, uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(
        address indexed userAddress,
        string activityType,
        uint256 duration,
        uint256 distance,
        uint256 timestamp
    );
    event MilesstoneAchieved(address indexed userAddress, string milesstone, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyRegistered() {
    require(userProfiles[msg.sender].isRegistered, "User not registered");
    _;
    }

    //Register a new user
    function registerUser(string memory newname, uint256 newweight) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");

        userProfiles[msg.sender] = UserProfile({
            name: newname,
            weight: newweight,
            isRegistered: true

    });

    //Emit registration event
    emit UserRegistered(msg.sender, newname, block.timestamp);
    
    }

    //Update user weight
    function updateWeight(uint256 _newweight) public onlyRegistered{
        UserProfile storage profile = userProfiles[msg.sender];

        //Check if significant weight loss(5% or more)
        if (_newweight < profile.weight && (profile.weight - _newweight) *100 / profile.weight >= 5) {
            emit MilesstoneAchieved(msg.sender, "Weight goal reached", block.timestamp);
        }

        profile.weight = _newweight;

        //Emit profile update event
        emit ProfileUpdated(msg.sender, _newweight, block.timestamp);
    }

    //Log a workout activity 
    function logWorkout (
        string memory _activityType,
        uint256 _duration,
        uint256 _distance
    ) public onlyRegistered {
        //Create a new workout activity
         WorkoutActivity memory newWorkout = WorkoutActivity({
            activityType: _activityType,
            duration: _duration,
            distance: _distance,
            timestamp: block.timestamp
        });

        //Add to user's workout history 
        workoutHistory[msg.sender].push(newWorkout);

        //Update total stats
        totalWorkouts[msg.sender]++ ;
        totalDistance[msg.sender] += _distance;

        //Emit workout logged event
        emit WorkoutLogged(
            msg.sender,
            _activityType,
            _duration,
            _distance,
            block.timestamp
        );

        //Check for workout count milestones
        if (totalWorkouts[msg.sender] == 10) {
            emit MilesstoneAchieved(msg.sender, "10 workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilesstoneAchieved(msg.sender, "50 workouts Completed", block.timestamp);
        }

        //Check for distance milestones
        if (totalDistance[msg.sender] >= 10000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilesstoneAchieved(msg.sender, "100k Total Distance", block.timestamp);
        }
    }

    //Get the number of workouts for a user
    function getUserWorkoutCount() public view onlyRegistered returns (uint256){
        return workoutHistory[msg.sender].length;
    }

}