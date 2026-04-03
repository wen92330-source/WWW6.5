import { computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 1 - 点击计数器（扩展版）
 * 学习概念：function, increment, uint256, contract
 *
 * 返回实时数据接口供 Sidebar 使用
 */
export function useDay1() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day1Contract = contractStore.contracts.day1

  // 获取Day 1的合约状态
  const contract = computed(() => contractStore.getContract(1))
  const counter = computed(() => day1Contract.count)
  const interactionCount = computed(() => day1Contract.interactionCount)

  // 点击计数器
  const clickCounter = () => {
    // 直接修改响应式状态
    day1Contract.count++
    day1Contract.interactionCount++

    // 记录操作日志
    logStore.addLog(1, '点击计数器', 'Counter +1', 'increment')

    progressStore.incrementInteraction(1)

    // 根据点击次数解锁概念
    const newCount = day1Contract.count

    // 使用 progressStore.unlockConcept 统一解锁
    if (newCount === 1) {
      progressStore.unlockConcept(1, 'function')
    } else if (newCount === 2) {
      progressStore.unlockConcept(1, 'increment')
    } else if (newCount === 3) {
      progressStore.unlockConcept(1, 'uint256')
    } else if (newCount === 4) {
      progressStore.unlockConcept(1, 'contract')
    }
  }

  // 重置计数器
  const resetCounter = () => {
    day1Contract.count = 0
    // 记录重置操作
    logStore.addLog(1, '重置计数器', 'Counter reset to 0', 'reset')
  }

  // 获取进度信息
  const progress = computed(() => progressStore.dayProgress[1])
  const progressPercentage = computed(() => progressStore.getProgressPercentage(1))
  const unlockedConcepts = computed(() => progressStore.dayProgress[1].unlockedConcepts)

  // ========== 实时数据接口（供 Sidebar 使用）==========
  const realtimeData = computed(() => ({
    // 核心指标
    metrics: [
      {
        label: '当前计数值',
        value: counter.value,
        unit: '',
        icon: '🔢'
      },
      {
        label: '点击次数',
        value: interactionCount.value,
        unit: '次',
        icon: '🖱️'
      }
    ],
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(1),
    ethCost: logStore.getDayEthCost(1),
    operationCount: logStore.getDayOperationCount(1)
  }))

  return {
    // 状态
    counter,
    interactionCount,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    clickCounter,
    resetCounter
  }
}
