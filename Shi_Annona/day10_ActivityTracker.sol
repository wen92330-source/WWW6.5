//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract activityTracker{
    //we need: owner
    address public owner;

    //user profile, new thing: struct
    struct userProfile{
        string userName;
        uint256 weight;
        bool registered;
    }

    //work activity,stull a struct, used for my friends to record their workout.
    struct workActivity{
        string activityName;
        uint256 duration; //sec
        uint256 distance; //meter
        uint256 timestamp;
    }

    //we need know the mapping of user address and their user profile
    //the mapping of user address and their activity
    mapping(address => userProfile) public userProfiles; //attention:this mapping name must be difference from the struct name, too close
    mapping(address => workActivity[]) private workoutHerstory; //[] means there will be many workActivity for one user

    //mapping some important records
    mapping(address => uint256) public totalDistance;
    mapping(address => uint256) public totalTime;

    //tons of events
    event userRegistered(address indexed useraddress, string name, uint timestamp);
    event profileUpdate(address indexed useraddress, uint256 newWeight, uint256 timestamp);
    event workoutLogged(
        address indexed useraddress,
        string activity,
        uint256 duration,
        uint256 distance,
        uint256 timestamp
        );
    
    event MilestoneAchieved(address indexed useraddress, string milestone, uint256 timestamp);

    constructor(){
        owner = msg.sender;
    }

    modifier onlyRegiteredFriends(){
        require(userProfiles[msg.sender].registered,"not registered");
        _;
    }

    //regiter a new user
    function register(string memory _user, uint _weight) public {
        require(!userProfiles[msg.sender].registered, "already registered");
        userProfiles[msg.sender] = userProfile({
            userName:_user,
            weight:_weight,
            registered: true
        });

        //emit this register event
        emit userRegistered(msg.sender, _user, block.timestamp);
    }

    //update weight
    function updateWeight(uint256 _newWeight) public onlyRegiteredFriends{
        userProfile storage profile  = userProfiles[msg.sender]; 
        if(_newWeight < profile.weight && ((profile.weight - _newWeight)/profile.weight)*100 > 5){
            emit MilestoneAchieved(msg.sender, "Weight goal achieved",block.timestamp);
        }

        profile.weight = _newWeight;

        emit profileUpdate(msg.sender, _newWeight, block.timestamp);
    }

    //record workout(log a workout)
    function logWorkout(string memory _activityName,uint256 _duration,uint256 _distance) public onlyRegiteredFriends{
        //create a new activity
        workActivity memory newWorkout = workActivity({
        activityName: _activityName,
        duration: _duration,
        distance: _distance,
        timestamp: block.timestamp
        });

        workoutHerstory[msg.sender].push(newWorkout);

        //update total
        totalDistance[msg.sender] += _distance;
        totalTime[msg.sender] ++;

        //emit workout looged
        emit  workoutLogged(
            msg.sender,
            _activityName,
            _duration,
            _distance,
            block.timestamp
        );

        //check the milestone
        if(totalTime[msg.sender] == 10){
            emit MilestoneAchieved(msg.sender, "10 Workouts Completed", block.timestamp);
        }
        else if(totalTime[msg.sender] == 50){
            emit MilestoneAchieved(msg.sender, "50 Workouts Completed", block.timestamp);
        }

        if(totalDistance[msg.sender]>=10000 && (totalDistance[msg.sender]-_distance)<10000){
            emit MilestoneAchieved(msg.sender, "100K Total Distance", block.timestamp);
        }

    }

    //get the count of workout 
    function countWorkout() public view onlyRegiteredFriends returns(uint256){
        uint256 count = workoutHerstory[msg.sender].length;
        return count;
    }
}
//1a:0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2