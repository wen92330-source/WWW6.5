//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract SimpleFitnessTracker {
	address public owner;
	struct UserProfile {
		string name;
		uint256 weight;
		bool isRegistered;
	}
	struct UserActivity {
		string activityType;
		uint256 duration;
		uint256 distance;
		uint256 timestamp;
	}
	mapping (address => UserProfile) public userProfiles;
	mapping (address => UserActivity []) private workoutHistory;
	mapping (address => uint256) public totalWorkouts;
	mapping (address => uint256) public totalDistance;
	// declare events
	event UserRegister(address indexed userAddress, string name, uint256 timestamp);
	event ProfileUpdate(address indexed userAddress, uint256 newWeight, uint256 timestamp);
	event ActivityLog(address indexed userAddress, string activityType, uint256 duration, uint256 distance, uint256 timestamp);
	event MilestoneAchieve(address indexed userAddress, string milestone, uint256 timestamp);
	constructor() {
		owner = msg.sender;
	}
	modifier registeredOnly() {
		require(userProfiles[msg.sender].isRegistered, "User not registered");
		_;
	}
	function registerUser(string memory _name, uint256 _weight) public {
		require(!userProfiles[msg.sender].isRegistered, "User already registered");
		// Construct new struct
		userProfiles[msg.sender] = UserProfile({name : _name, weight : _weight, isRegistered : true});
		// fire events
		emit UserRegister(msg.sender, _name, block.timestamp);
	}
	function updateWeight(uint256 _newWeight) public registeredOnly {
		// storage means create reference instead of copy
		UserProfile storage profile = userProfiles[msg.sender];
		if (_newWeight < profile.weight && (profile.weight - _newWeight) *100 / profile.weight >= 5)
			emit MilestoneAchieve(msg.sender, "Weight goal achieved", block.timestamp);
		profile.weight = _newWeight;
		emit ProfileUpdate(msg.sender, _newWeight, block.timestamp);
	}
	function logActivity(string memory _type, uint256 _duration, uint256 _distance) public registeredOnly {
		UserActivity memory activity = UserActivity({activityType: _type, duration: _duration, distance: _distance, timestamp: block.timestamp});
		workoutHistory[msg.sender].push(activity);
		totalWorkouts[msg.sender]++;
		totalDistance[msg.sender] += _distance;
		emit ActivityLog(msg.sender, _type, _duration, _distance, block.timestamp);
		if (totalWorkouts[msg.sender] == 10)
			emit MilestoneAchieve(msg.sender, "10 workouts completed", block.timestamp);
		else if (totalWorkouts[msg.sender] == 50)
			emit MilestoneAchieve(msg.sender, "50 workouts completed", block.timestamp);
		if (totalDistance[msg.sender] >= 100000 && totalDistance[msg.sender] - _distance < 100000)
			emit MilestoneAchieve(msg.sender, "100k distance completed", block.timestamp);

	}
	function getTotalActivity() public view registeredOnly returns (uint256){
		return (totalWorkouts[msg.sender]);
	}
}