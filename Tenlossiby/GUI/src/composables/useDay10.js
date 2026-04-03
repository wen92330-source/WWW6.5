import { computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 10 - 健身追踪器
 * 学习概念：struct_definition, array_in_mapping, multiple_mappings, storage_keyword,
 *          event_logging, milestone_detection, timestamp_usage, onlyRegistered_modifier
 */
export function useDay10() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day10Contract = contractStore.contracts.day10
  const day10Progress = progressStore.dayProgress[10]

  // 获取Day 10的合约状态
  const contract = computed(() => contractStore.getContract(10))
  const owner = computed(() => day10Contract.owner)
  const userAddress = computed(() => day10Contract.userAddress)
  const userProfile = computed(() => day10Contract.userProfile)
  const workoutHistory = computed(() => day10Contract.workoutHistory)
  const totalWorkouts = computed(() => day10Contract.totalWorkouts)
  const totalDistance = computed(() => day10Contract.totalDistance)
  const milestones = computed(() => day10Contract.milestones)
  const isRegistered = computed(() => day10Contract.userProfile.isRegistered)

  // 初始化合约
  const initializeContract = () => {
    contractStore.initializeContract(10)
  }

  // 获取解锁提示（下一步该做什么）
  const getUnlockHint = (conceptKey) => {
    const hints = {
      // 注册时解锁的概念（3个）
      struct_definition: '📦 太棒了！你学会了使用结构体打包数据！👉 记录一次运动来看看时间戳如何工作！',
      event_logging: '📋 不错！你触发了事件日志！👉 记录运动来查看运动历史如何存储！',
      onlyRegistered_modifier: '🛡️ 太棒了！你了解了修饰符如何保护函数！👉 记录运动来解锁更多概念！',

      // 记录运动时解锁的概念（2个）
      timestamp_usage: '⏰ 很好！你学会了记录时间戳！👉 查看运动历史来解锁 array_in_mapping！',
      array_in_mapping: '🗂️ 很好！你看到了映射到数组的用法！👉 查看统计数据来解锁 multiple_mappings！',

      // 查看统计时解锁的概念（1个）
      multiple_mappings: '🗺️ 优秀！你了解了多个映射如何协同工作！👉 更新体重来解锁 storage_keyword！',

      // 更新体重时解锁的概念（1个）
      storage_keyword: '💾 太棒了！你了解了 storage 的威力！👉 继续记录运动，达成里程碑来解锁 milestone_detection！',

      // 达成里程碑时解锁的概念（1个）
      milestone_detection: '🏆 恭喜！你达成了里程碑！👉 查看完整代码来复习所有知识！'
    }
    return hints[conceptKey] || ''
  }

  // 注册用户
  const registerUser = (name, weight) => {
    initializeContract()

    if (day10Contract.userProfile.isRegistered) {
      return { success: false, error: 'User already registered' }
    }

    // 更新用户资料
    day10Contract.userProfile = {
      name: name,
      weight: weight,
      isRegistered: true
    }

    day10Contract.interactionCount++
    day10Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(10, '注册用户', `用户: ${name}, 体重: ${weight}kg`)

    // 解锁概念：struct_definition, event_logging, onlyRegistered_modifier
    const unlockedConcepts = []
    progressStore.unlockConcept(10, 'struct_definition')
    unlockedConcepts.push(getUnlockHint('struct_definition'))
    progressStore.unlockConcept(10, 'event_logging')
    unlockedConcepts.push(getUnlockHint('event_logging'))
    progressStore.unlockConcept(10, 'onlyRegistered_modifier')
    unlockedConcepts.push(getUnlockHint('onlyRegistered_modifier'))

    return { success: true, unlockedHints: unlockedConcepts }
  }

  // 记录运动
  const logWorkout = (activityType, duration, distance) => {
    initializeContract()

    if (!day10Contract.userProfile.isRegistered) {
      return { success: false, error: 'User not registered' }
    }

    // 创建运动记录
    const newWorkout = {
      activityType: activityType,
      duration: duration,
      distance: distance,
      timestamp: Date.now()
    }

    // 添加到历史记录
    day10Contract.workoutHistory.unshift(newWorkout)

    // 更新统计数据
    const previousTotalDistance = day10Contract.totalDistance
    day10Contract.totalWorkouts++
    day10Contract.totalDistance += distance

    day10Contract.interactionCount++
    day10Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(10, '记录运动', `${activityType} ${distance}米 ${formatDuration(duration)}`)

    // 解锁概念：timestamp_usage, array_in_mapping
    const wasTimestampUnlocked = !progressStore.isConceptUnlocked(10, 'timestamp_usage')
    const wasArrayUnlocked = !progressStore.isConceptUnlocked(10, 'array_in_mapping')
    progressStore.unlockConcept(10, 'timestamp_usage')
    progressStore.unlockConcept(10, 'array_in_mapping')

    // 检查里程碑
    const milestoneUnlocked = checkMilestones(previousTotalDistance, distance)

    // 构建提示信息
    const hints = []
    if (wasTimestampUnlocked) {
      hints.push(getUnlockHint('timestamp_usage'))
    }
    if (wasArrayUnlocked) {
      hints.push(getUnlockHint('array_in_mapping'))
    }
    if (milestoneUnlocked) {
      hints.push(getUnlockHint('milestone_detection'))
    }

    return { success: true, unlockedHints: hints }
  }

  // 更新体重
  const updateWeight = (newWeight) => {
    initializeContract()

    if (!day10Contract.userProfile.isRegistered) {
      return { success: false, error: 'User not registered' }
    }

    const oldWeight = day10Contract.userProfile.weight

    // 检查减重里程碑（减少≥5%）
    let milestoneUnlocked = false
    if (newWeight < oldWeight && oldWeight > 0) {
      const weightLossPercent = ((oldWeight - newWeight) * 100) / oldWeight
      if (weightLossPercent >= 5) {
        unlockMilestone('weightGoal')
        milestoneUnlocked = true
      }
    }

    // 更新体重
    day10Contract.userProfile.weight = newWeight

    day10Contract.interactionCount++
    day10Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(10, '更新体重', `${oldWeight}kg → ${newWeight}kg`)

    // 解锁概念：storage_keyword, multiple_mappings
    const wasStorageUnlocked = !progressStore.isConceptUnlocked(10, 'storage_keyword')
    const wasMultipleUnlocked = !progressStore.isConceptUnlocked(10, 'multiple_mappings')
    progressStore.unlockConcept(10, 'storage_keyword')
    progressStore.unlockConcept(10, 'multiple_mappings')

    // 构建提示信息
    const hints = []
    if (wasStorageUnlocked) {
      hints.push(getUnlockHint('storage_keyword'))
    }
    if (wasMultipleUnlocked) {
      hints.push(getUnlockHint('multiple_mappings'))
    }
    if (milestoneUnlocked) {
      hints.push(getUnlockHint('milestone_detection'))
    }

    return { success: true, unlockedHints: hints }
  }

  // 检查里程碑
  const checkMilestones = (previousTotalDistance, currentDistance) => {
    const currentWorkouts = day10Contract.totalWorkouts
    const currentTotalDistance = day10Contract.totalDistance
    let milestoneUnlocked = false

    // 运动次数里程碑
    if (currentWorkouts === 10) {
      unlockMilestone('workouts10')
      milestoneUnlocked = true
    } else if (currentWorkouts === 50) {
      unlockMilestone('workouts50')
      milestoneUnlocked = true
    }

    // 距离里程碑（跨越100公里 = 100000米）
    if (currentTotalDistance >= 100000 && previousTotalDistance < 100000) {
      unlockMilestone('distance100K')
      milestoneUnlocked = true
    }

    return milestoneUnlocked
  }

  // 解锁里程碑
  const unlockMilestone = (milestoneKey) => {
    const milestone = day10Contract.milestones[milestoneKey]
    if (milestone && !milestone.achieved) {
      milestone.achieved = true
      milestone.timestamp = Date.now()

      // 解锁概念：milestone_detection
      progressStore.unlockConcept(10, 'milestone_detection')
    }
  }

  // 单位转换：时长（分钟/小时 → 秒）
  const convertToSeconds = (value, unit) => {
    if (unit === 'minutes') {
      return value * 60
    } else if (unit === 'hours') {
      return value * 3600
    }
    return value
  }

  // 单位转换：距离（米/公里 → 米）
  const convertToMeters = (value, unit) => {
    if (unit === 'kilometers') {
      return value * 1000
    }
    return value
  }

  // 格式化时长显示
  const formatDuration = (seconds) => {
    if (seconds < 60) {
      return `${seconds}秒`
    } else if (seconds < 3600) {
      return `${Math.floor(seconds / 60)}分钟`
    } else {
      const hours = Math.floor(seconds / 3600)
      const minutes = Math.floor((seconds % 3600) / 60)
      return minutes > 0 ? `${hours}小时${minutes}分钟` : `${hours}小时`
    }
  }

  // 格式化距离显示
  const formatDistance = (meters) => {
    if (meters < 1000) {
      return `${meters}米`
    } else {
      return `${(meters / 1000).toFixed(2)}公里`
    }
  }

  // 格式化时间戳
  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp)
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  // 获取运动类型图标
  const getActivityIcon = (activityType) => {
    const iconMap = {
      '跑步': '🏃',
      'Running': '🏃',
      '骑行': '🚴',
      'Cycling': '🚴',
      '游泳': '🏊',
      'Swimming': '🏊',
      '步行': '🚶',
      'Walking': '🚶',
      '瑜伽': '🧘',
      'Yoga': '🧘',
      '篮球': '⛹️',
      'Basketball': '⛹️'
    }
    return iconMap[activityType] || '💪'
  }

  // 查看运动历史时解锁 array_in_mapping
  const viewWorkoutHistory = () => {
    const wasUnlocked = !progressStore.isConceptUnlocked(10, 'array_in_mapping')
    progressStore.unlockConcept(10, 'array_in_mapping')

    // 记录操作日志
    logStore.addLog(10, '查看运动历史', `共 ${day10Contract.workoutHistory.length} 条记录`)

    if (wasUnlocked) {
      return getUnlockHint('array_in_mapping')
    }
    return null
  }

  // 查看统计数据时解锁 multiple_mappings
  const viewStatistics = () => {
    const wasUnlocked = !progressStore.isConceptUnlocked(10, 'multiple_mappings')
    progressStore.unlockConcept(10, 'multiple_mappings')

    // 记录操作日志
    logStore.addLog(10, '查看统计', `总运动: ${day10Contract.totalWorkouts}次, 总距离: ${formatDistance(day10Contract.totalDistance)}`)

    if (wasUnlocked) {
      return getUnlockHint('multiple_mappings')
    }
    return null
  }

  // 获取进度信息
  const progress = computed(() => day10Progress)
  const progressPercentage = computed(() => {
    if (!day10Progress || day10Progress.totalConcepts === 0) return 0
    return Math.floor((day10Progress.unlockedConcepts.length / day10Progress.totalConcepts) * 100)
  })
  const unlockedConcepts = computed(() => day10Progress.unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    gasUsage: logStore.getDayGasUsage(10),
    ethCost: logStore.getDayEthCost(10),
    operationCount: logStore.getDayOperationCount(10)
  }))

  return {
    // 状态
    owner,
    userAddress,
    userProfile,
    workoutHistory,
    totalWorkouts,
    totalDistance,
    milestones,
    isRegistered,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    registerUser,
    logWorkout,
    updateWeight,
    convertToSeconds,
    convertToMeters,
    formatDuration,
    formatDistance,
    formatTimestamp,
    getActivityIcon,
    viewWorkoutHistory,
    viewStatistics,
    initializeContract
  }
}
