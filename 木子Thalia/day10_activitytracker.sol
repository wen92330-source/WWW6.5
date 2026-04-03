//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleFitnessTracker {
    // User profile struct
    struct UserProfile {
        string name;
        uint256 weight;
        bool isRegistered;
    }
    mapping(address => UserProfile) public userProfiles;

    event UserRegistered(address indexed userAddress, string indexed name, uint256 timestamp);

    function registerUser(string memory _name, uint256 _weight) public {
        require(userProfiles[msg.sender].isRegistered == false, "User already registered");
        // userProfiles[msg.sender].name = _name;
        // userProfiles[msg.sender].weight = _weight;
        // userProfiles[msg.sender].isRegistered = true;

        userProfiles[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    modifier onlyRegistered() {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        _;
    }
    event MilestoneAchieved(address indexed user, string milestone, uint256 timestamp);
    event ProfileUpdated(address indexed user, uint256 weight, uint256 timestamp);

    function updateWeight(uint256 _newWeight) public onlyRegistered {
        UserProfile storage profile = userProfiles[msg.sender];

        if (_newWeight < profile.weight && ((profile.weight - _newWeight) * 100 / profile.weight) >= 5) {
            emit MilestoneAchieved(msg.sender, "Weight Goal Reached", block.timestamp);
        }

        // 3. 更新体重并触发 ProfileUpdated 事件
        profile.weight = _newWeight;
        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    struct WorkoutActivity {
        string activityType;
        uint256 duration; // in seconds
        uint256 distance; // in meters
        uint256 timestamp;
    }

    mapping(address => WorkoutActivity[]) public workoutHistory;
    mapping(address => uint256) public totalWorkouts;
    mapping(address => uint256) public totalDistance;
    
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );

    function logWorkout(string memory _activityType, uint256 _duration, uint256 _distance) public onlyRegistered {
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

        // Check for workout count milestones
        if (totalWorkouts[msg.sender] == 10) {
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        } else if (totalWorkouts[msg.sender] == 50) {
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }
        
        // Check for distance milestones
        if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000) {
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }
    }

    function getUserWorkoutCount() public view onlyRegistered returns (uint256) {
        return workoutHistory[msg.sender].length;
    }

    
}
