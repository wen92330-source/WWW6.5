// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Calculator
 * @author mumu
 * @notice 活动跟踪器
 * @dev 目标：掌握结构体和复杂数据管理 提示：struct、数组映射、事件监听
 * 这是一个去中心化的健身追踪应用。用户可以注册个人资料、记录锻炼数据、查看历史记录。当达成里程碑时,会自动触发事件通知前端。
*/

contract SimpleFitnessTracker {
    
    // 用户结构体，存放基本信息
    struct UserProfile {
        string name;
        uint256 weight; // in kg
        bool isRegistered; // 是否注册过
    }

    // 锻炼记录结构体
    struct Workout {
        uint256 date; // 锻炼日期，秒级时间戳
        string workoutType; // 锻炼类型（跑步、举重等）
        uint256 duration; // 锻炼持续时间，单位为分钟
        uint256 distance; // 跑步距离，单位为米（如果适用）
    }

    // 用户地址 => 用户信息
    mapping(address => UserProfile) public users;

    // 用户地址 => 锻炼记录列表
    mapping(address => Workout[]) public workoutHistory;

    // 总锻炼次数
    mapping(address => uint256) public workoutCount;

    // 总距离映射
    mapping(address => uint256) public totalDistance;

    // 事件：当用户注册时触发
    event UserRegistered(address indexed user, string name , uint256 timestamp);
    event ProfileUpdated(address indexed userAddress, uint256 newWeight, uint256 timestamp);
    event WorkoutLogged(
        address indexed userAddress, 
        string activityType, 
        uint256 duration, 
        uint256 distance, 
        uint256 timestamp
    );
    // 里程碑事件：当用户达到特定锻炼次数或距离时触发
    event MilestoneAchieved(address indexed userAddress, string milestone, uint256 timestamp);
    
    modifier onlyRegistered() {
        require(users[msg.sender].isRegistered, "User not registered");
        _;
    }

    // 方法：注册用户
    function register(string memory _name, uint256 _weight) public {
        require(!users[msg.sender].isRegistered, "User already registered"); // 这样不会panic吗？golang中可能会panic
        // users[msg.sender] = UserProfile(_name, _weight, true); 
        // 推荐直接写出结构体
        users[msg.sender] = UserProfile({
            name: _name,
            weight: _weight,
            isRegistered: true
        });
        emit UserRegistered(msg.sender, _name, block.timestamp);
    }

    // 更新用户体重
    function updateWeight(uint256 _newWeight) public onlyRegistered {
        users[msg.sender].weight = _newWeight;
        // // 另一种写法，使用storage引用
        // UserProfile storage profile = users[msg.sender];
        // profile.weight = _newWeight;

        // 体重下降5%时触发里程碑事件
        if (_newWeight < users[msg.sender].weight * 95 / 100) {
            emit MilestoneAchieved(msg.sender, "Weight Loss Milestone Reached", block.timestamp);
        }

        emit ProfileUpdated(msg.sender, _newWeight, block.timestamp);
    }

    // 记录锻炼数据
    function logWorkout(string memory _workoutType, uint256 _duration, uint256 _distance) public onlyRegistered {
        Workout memory WorkoutLog = Workout({
            date: block.timestamp,
            workoutType: _workoutType,
            duration: _duration,
            distance: _distance
        });
        workoutHistory[msg.sender].push(WorkoutLog);

        workoutCount[msg.sender]++;
        totalDistance[msg.sender] += _distance;
        emit WorkoutLogged(msg.sender, _workoutType, _duration, _distance, block.timestamp);

        // 检查里程碑
        checkMilestones(msg.sender);
    }

    // 检查是否达到里程碑
    function checkMilestones(address user) internal {
        // 次数里程碑 (10次、50次、100次)
        if (workoutCount[user] == 10) {
            emit MilestoneAchieved(user, "10 Workouts Milestone Reached", block.timestamp);
        } else if (workoutCount[user] == 50) {
            emit MilestoneAchieved(user, "50 Workouts Milestone Reached", block.timestamp);
        } else if (workoutCount[user] == 100) {
            emit MilestoneAchieved(user, "100 Workouts Milestone Reached", block.timestamp);
        }

        // 距离里程碑 (10000米)
        if (totalDistance[user] >= 10000) {
            emit MilestoneAchieved(user, "10000 Meters Milestone Reached", block.timestamp);
        }
    }

    // 获取用户锻炼数量
    function getWorkoutCount(address user) public view returns (uint256) {
        return workoutCount[user];
    }

    // 查看最新的锻炼
    function getLatestWorkout(address user) public view returns (Workout memory) {
        require(workoutHistory[user].length > 0, "No workouts logged");
        return workoutHistory[user][workoutHistory[user].length - 1];
    }

    // 拓展
    // 1. 添加deleteWorkout(uint256 index)删除指定的锻炼记录
    function deleteWorkout(uint256 index) public onlyRegistered {
        require(index < workoutHistory[msg.sender].length, "Invalid workout index");
        // 删除指定索引的锻炼记录
        for (uint256 i = index; i < workoutHistory[msg.sender].length - 1; i++) {
            workoutHistory[msg.sender][i] = workoutHistory[msg.sender][i + 1];
        }
        workoutHistory[msg.sender].pop(); // 移除最后一个元素
    }

    // // 2. 实现每周/每月统计功能
    // function getWeeklyStats(address user) public view returns (uint256 totalWorkouts, uint256 totalDistance) {
    //     uint256 oneWeekAgo = block.timestamp - 7 days;
    //     totalWorkouts = 0;
    //     totalDistance = 0;

    //     for (uint256 i = 0; i < workoutHistory[user].length; i++) {
    //         if (workoutHistory[user][i].date >= oneWeekAgo) {
    //             totalWorkouts++;
    //             totalDistance += workoutHistory[user][i].distance;
    //         }
    //     }
    // }

    // function getMonthlyStats(address user) public view returns (uint256 totalWorkouts, uint256 totalDistance) {
    //     uint256 oneMonthAgo = block.timestamp - 30 days;
    //     totalWorkouts = 0;
    //     totalDistance = 0;

    //     for (uint256 i = 0; i < workoutHistory[user].length; i++) {
    //         if (workoutHistory[user][i].date >= oneMonthAgo) {
    //             totalWorkouts++;
    //             totalDistance += workoutHistory[user][i].distance;
    //         }
    //     }
    // }

    // 3. 添加卡路里计算(基于活动类型和时长)
    function calculateCalories(string memory _workoutType, uint256 _duration) public pure returns (uint256) {
        uint256 caloriesPerMinute;

        if (keccak256(bytes(_workoutType)) == keccak256(bytes("swiming"))) {
            caloriesPerMinute = 10; // 每分钟10卡路里
        } else if (keccak256(bytes(_workoutType)) == keccak256(bytes("weightlifting"))) {
            caloriesPerMinute = 8; // 每分钟8卡路里
        } else if (keccak256(bytes(_workoutType)) == keccak256(bytes("cycling"))) {
            caloriesPerMinute = 9; // 每分钟9卡路里
        } else {
            caloriesPerMinute = 5; // 默认每分钟5卡路里
        }

        return caloriesPerMinute * _duration;
    }

    // 4. 实现好友系统和排行榜
    // 5. 添加目标设定功能(每周跑步目标等)
    // 6. 实现成就徽章系统(NFT)
    // 7. 添加数据导出功能(返回JSON格式)
}

/**
知识点：
1. 结构体定义和使用
2. 复杂数据结构管理（映射中的数组）
3. 事件监听和触发
4. 数据存储优化（例如：将重量和身高存储为整数以节省存储空间）

5. indexed 关键字：
在事件中使用indexed可以让前端更高效地过滤和查询特定用户的事件。例如，在UserRegistered事件中，user地址被标记为indexed，这样前端就可以通过用户地址来快速查询该用户的注册事件，而不需要扫描所有事件。
当我门将一个参数标记为indexed时，相当于我们给数据库的指定字段加了索引。
以增加事件日志的查询效率

6.数组的gas成本
    存储数组到区块链成本很高!每次push()都要支付gas。对于大量数据:
    1）考虑使用链下存储(IPFS、Arweave)
    2）只在链上存储哈希和关键数据
    3）使用事件记录历史(gas更便宜)

拓展：
1. 添加deleteWorkout(uint256 index)删除指定的锻炼记录
2. 实现每周/每月统计功能
3. 添加卡路里计算(基于活动类型和时长)
4. 实现好友系统和排行榜
5. 添加目标设定功能(每周跑步目标等)
6. 实现成就徽章系统(NFT)
7. 添加数据导出功能(返回JSON格式)
 */