import { computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 2 - 保存名字
 * 学习概念：string, private, memory, view, parameters, returns
 */
export function useDay2() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day2Contract = contractStore.contracts.day2
  const day2Progress = progressStore.dayProgress[2]

  // 获取Day 2的合约状态
  const contract = computed(() => contractStore.getContract(2))
  const name = computed(() => day2Contract.name)
  const bio = computed(() => day2Contract.bio)
  const hasStored = computed(() => day2Contract.hasStored)
  const hasRetrieved = computed(() => day2Contract.hasRetrieved)
  const interactionCount = computed(() => day2Contract.interactionCount)

  // 存储数据
  const storeData = (nameValue, bioValue) => {
    // 直接修改响应式状态
    day2Contract.name = nameValue
    day2Contract.bio = bioValue
    day2Contract.hasStored = true
    day2Contract.interactionCount++
    day2Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(2, '存储数据', `存储: ${nameValue}`, 'addData')

    // 解锁概念 - 一次性解锁所有存储相关概念
    const conceptsToUnlock = ['string', 'private', 'memory']
    conceptsToUnlock.forEach(concept => {
      progressStore.unlockConcept(2, concept)
    })
  }

  // 检索数据
  const retrieveData = () => {
    // 直接修改响应式状态
    day2Contract.hasRetrieved = true
    day2Contract.interactionCount++
    day2Progress.interactionCount++

    // 记录操作日志（view 函数不消耗 Gas）
    logStore.addLog(2, '检索数据', `查询: ${name.value}`)

    // 解锁概念 - 一次性解锁所有检索相关概念
    const conceptsToUnlock = ['view', 'parameters', 'returns']
    conceptsToUnlock.forEach(concept => {
      progressStore.unlockConcept(2, concept)
    })

    return {
      name: name.value,
      bio: bio.value
    }
  }

  // 获取进度信息
  const progress = computed(() => day2Progress)
  const progressPercentage = computed(() => {
    if (!day2Progress || day2Progress.totalConcepts === 0) return 0
    return Math.floor((day2Progress.unlockedConcepts.length / day2Progress.totalConcepts) * 100)
  })
  const unlockedConcepts = computed(() => day2Progress.unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(2),
    ethCost: logStore.getDayEthCost(2),
    operationCount: logStore.getDayOperationCount(2)
  }))

  return {
    // 状态
    name,
    bio,
    hasStored,
    hasRetrieved,
    interactionCount,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    storeData,
    retrieveData
  }
}
