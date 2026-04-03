import { computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 9 - 跨合约调用
 * 学习概念：pure_function, view_function, cross_contract_call, interface_call,
 *           low_level_call, modifier_onlyOwner, newton_iteration, contract_composition
 */
export function useDay9() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref
  const day9Contract = contractStore.contracts.day9
  const day9Progress = progressStore.dayProgress[9]

  // 获取Day 9的合约状态
  const contract = computed(() => contractStore.getContract(9))
  const owner = computed(() => day9Contract.owner)
  const userAddress = computed(() => day9Contract.userAddress)
  const isOwner = computed(() => day9Contract.isUserAdmin)
  const scientificCalculatorAddress = computed(() => day9Contract.scientificCalculatorAddress)
  const isAddressSet = computed(() => day9Contract.isAddressSet)
  const operationCount = computed(() => day9Contract.operationCount)
  const operationHistory = computed(() => day9Contract.operationHistory)
  const interactionCount = computed(() => day9Contract.interactionCount)

  // 挑战任务状态
  const challengeTasks = computed(() => day9Contract.challengeTasks || {
    setAddress: false,
    powerCalc: false,
    sqrtCalc: false,
    permissionCheck: false
  })

  // 切换身份
  const toggleIdentity = () => {
    contractStore.initializeContract(9)
    day9Contract.isUserAdmin = !day9Contract.isUserAdmin

    // 记录操作日志
    logStore.addLog(9, '切换身份', day9Contract.isUserAdmin ? '切换为管理员' : '切换为用户')
  }

  // 基础运算
  const calculate = (operator, a, b) => {
    contractStore.initializeContract(9)

    if (isNaN(a) || isNaN(b)) {
      throw new Error('请输入有效的数字')
    }

    let result
    switch (operator) {
      case 'add':
        result = a + b
        break
      case 'subtract':
        result = a - b
        break
      case 'multiply':
        result = a * b
        break
      case 'divide':
        if (b === 0) throw new Error('不能除以零')
        result = a / b
        break
      default:
        throw new Error('未知运算符')
    }

    // 更新状态
    day9Contract.operationCount++
    day9Contract.operationHistory.push({ operator, a, b, result, timestamp: Date.now() })
    day9Contract.interactionCount++
    day9Progress.interactionCount++

    // 记录操作日志
    const operatorNames = { add: '加法', subtract: '减法', multiply: '乘法', divide: '除法' }
    logStore.addLog(9, '基础运算', `${operatorNames[operator]}: ${a} ${operator === 'add' ? '+' : operator === 'subtract' ? '-' : operator === 'multiply' ? '×' : '÷'} ${b} = ${result}`)

    // 解锁 pure_function（完成3次运算）
    if (day9Contract.operationCount >= 3) {
      progressStore.unlockConcept(9, 'pure_function')
    }

    return result
  }

  // 设置科学计算器地址
  const setScientificCalculator = (address) => {
    contractStore.initializeContract(9)

    if (!day9Contract.isUserAdmin) {
      throw new Error('Only owner can do this action')
    }

    if (!address || address.length < 3) {
      throw new Error('请输入合约地址')
    }

    if (!address.startsWith('0x')) {
      throw new Error('合约地址必须以 0x 开头')
    }

    day9Contract.scientificCalculatorAddress = address
    day9Contract.isAddressSet = true
    day9Contract.interactionCount++
    day9Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(9, '设置合约地址', `科学计算器地址: ${address}`)

    // 初始化挑战任务
    if (!day9Contract.challengeTasks) {
      day9Contract.challengeTasks = {
        setAddress: false,
        powerCalc: false,
        sqrtCalc: false,
        permissionCheck: false
      }
    }
    day9Contract.challengeTasks.setAddress = true

    // 解锁 modifier_onlyOwner
    progressStore.unlockConcept(9, 'modifier_onlyOwner')

    return true
  }

  // 指数运算（跨合约调用）
  const calculatePower = (base, exponent) => {
    contractStore.initializeContract(9)

    if (!day9Contract.isAddressSet) {
      throw new Error('请先设置ScientificCalculator合约地址')
    }

    if (isNaN(base) || isNaN(exponent)) {
      throw new Error('请输入有效的数字')
    }

    // 模拟跨合约调用计算
    let result = 1
    for (let i = 0; i < exponent; i++) {
      result *= base
    }

    day9Contract.interactionCount++
    day9Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(9, '指数运算', `${base}^${exponent} = ${result}`)

    // 更新挑战任务
    if (!day9Contract.challengeTasks) {
      day9Contract.challengeTasks = {
        setAddress: false,
        powerCalc: false,
        sqrtCalc: false,
        permissionCheck: false
      }
    }
    day9Contract.challengeTasks.powerCalc = true

    // 解锁 view_function, cross_contract_call, interface_call
    progressStore.unlockConcept(9, 'view_function')
    progressStore.unlockConcept(9, 'cross_contract_call')
    progressStore.unlockConcept(9, 'interface_call')

    return result
  }

  // 平方根计算（底层call）
  const calculateSquareRoot = (number) => {
    contractStore.initializeContract(9)

    if (!day9Contract.isAddressSet) {
      throw new Error('请先设置ScientificCalculator合约地址')
    }

    if (isNaN(number) || number < 0) {
      throw new Error('请输入有效的非负数字')
    }

    // 模拟底层call调用计算平方根
    let result = number / 2
    const steps = []
    for (let i = 0; i < 10; i++) {
      const prevResult = result
      result = (result + number / result) / 2
      steps.push({
        round: i + 1,
        value: result,
        prevValue: prevResult,
        formula: `(${prevResult.toFixed(4)} + ${number}/${prevResult.toFixed(4)}) / 2 = ${result.toFixed(4)}`
      })
    }

    day9Contract.interactionCount++
    day9Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(9, '平方根计算', `√${number} ≈ ${Math.floor(result)}`)

    // 更新挑战任务
    if (!day9Contract.challengeTasks) {
      day9Contract.challengeTasks = {
        setAddress: false,
        powerCalc: false,
        sqrtCalc: false,
        permissionCheck: false
      }
    }
    day9Contract.challengeTasks.sqrtCalc = true

    // 解锁 low_level_call
    progressStore.unlockConcept(9, 'low_level_call')

    return { result: Math.floor(result), steps }
  }

  // 牛顿迭代可视化
  const runNewtonIteration = async (number, autoPlay = false) => {
    contractStore.initializeContract(9)

    if (isNaN(number) || number < 0) {
      throw new Error('请输入有效的非负数字')
    }

    const steps = []
    let result = number / 2

    for (let i = 0; i < 10; i++) {
      const prevResult = result
      result = (result + number / result) / 2
      steps.push({
        round: i + 1,
        value: result,
        prevValue: prevResult,
        formula: `(${prevResult.toFixed(4)} + ${number}/${prevResult.toFixed(4)}) / 2 = ${result.toFixed(4)}`
      })

      if (autoPlay) {
        await new Promise(resolve => setTimeout(resolve, 500))
      }
    }

    day9Contract.interactionCount++
    day9Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(9, '牛顿迭代', `计算 √${number} 的迭代过程`)

    // 解锁 newton_iteration
    progressStore.unlockConcept(9, 'newton_iteration')

    return steps
  }

  // 权限验证
  const checkPermission = (asOwner) => {
    contractStore.initializeContract(9)

    // 记录操作日志
    logStore.addLog(9, '权限验证', asOwner ? '以管理员身份验证' : '以用户身份验证')

    if (asOwner) {
      if (!day9Contract.challengeTasks) {
        day9Contract.challengeTasks = {
          setAddress: false,
          powerCalc: false,
          sqrtCalc: false,
          permissionCheck: false
        }
      }
      day9Contract.challengeTasks.permissionCheck = true
      return { success: true, message: '验证通过：Owner权限确认' }
    } else {
      return { success: false, message: '验证失败：Only owner can do this action' }
    }
  }

  // 完成挑战
  const completeChallenge = () => {
    contractStore.initializeContract(9)

    const tasks = day9Contract.challengeTasks || {
      setAddress: false,
      powerCalc: false,
      sqrtCalc: false,
      permissionCheck: false
    }

    const completedCount = Object.values(tasks).filter(v => v).length

    if (completedCount === 4) {
      // 解锁 contract_composition
      progressStore.unlockConcept(9, 'contract_composition')
      return { success: true, message: '🎉 恭喜！你已完成所有挑战任务！' }
    } else {
      const remaining = 4 - completedCount
      return { success: false, message: `还有 ${remaining} 个任务未完成` }
    }
  }

  // 获取进度信息
  const progress = computed(() => day9Progress)
  const progressPercentage = computed(() => {
    return progressStore.getProgressPercentage(9)
  })
  const unlockedConcepts = computed(() => {
    return progressStore.getUnlockedConcepts(9)
  })

  // 挑战完成数量
  const completedChallengeCount = computed(() => {
    const tasks = day9Contract.challengeTasks || {
      setAddress: false,
      powerCalc: false,
      sqrtCalc: false,
      permissionCheck: false
    }
    return Object.values(tasks).filter(v => v).length
  })

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    gasUsage: logStore.getDayGasUsage(9),
    ethCost: logStore.getDayEthCost(9),
    operationCount: logStore.getDayOperationCount(9)
  }))

  return {
    // 状态
    owner,
    userAddress,
    isOwner,
    scientificCalculatorAddress,
    isAddressSet,
    operationCount,
    operationHistory,
    interactionCount,
    challengeTasks,
    progress,
    progressPercentage,
    unlockedConcepts,
    completedChallengeCount,

    // 实时数据接口
    realtimeData,

    // 方法
    toggleIdentity,
    calculate,
    setScientificCalculator,
    calculatePower,
    calculateSquareRoot,
    runNewtonIteration,
    checkPermission,
    completeChallenge
  }
}
