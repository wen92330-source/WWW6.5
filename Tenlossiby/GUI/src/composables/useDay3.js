import { computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 3 - 投票系统
 * 学习概念：array, push, mapping, compound_assignment
 */
export function useDay3() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day3Contract = contractStore.contracts.day3

  // 获取Day 3的合约状态
  const contract = computed(() => contractStore.getContract(3))
  const candidates = computed(() => day3Contract.candidates)
  const voteCount = computed(() => day3Contract.voteCount)
  const interactionCount = computed(() => day3Contract.interactionCount)

  // 添加候选人
  const addCandidate = (candidateName) => {
    if (!candidateName || candidateName.trim() === '') return

    // 直接修改响应式状态
    day3Contract.candidates.push(candidateName)
    day3Contract.voteCount[candidateName] = 0
    day3Contract.interactionCount++
    progressStore.incrementInteraction(3)

    // 记录操作日志
    logStore.addLog(3, '添加候选人', `候选人: ${candidateName}`, 'addCandidate')

    // 根据候选人数量解锁概念
    const candidateCount = day3Contract.candidates.length
    if (candidateCount === 1) {
      progressStore.unlockConcept(3, 'array')
    } else if (candidateCount === 2) {
      progressStore.unlockConcept(3, 'push')
    } else if (candidateCount === 3) {
      progressStore.unlockConcept(3, 'mapping')
    }
  }

  // 为候选人投票
  const voteCandidate = (candidateName) => {
    if (day3Contract.voteCount[candidateName] === undefined) return

    // 直接修改响应式状态
    day3Contract.voteCount[candidateName]++
    day3Contract.interactionCount++
    progressStore.incrementInteraction(3)

    // 记录操作日志
    logStore.addLog(3, '投票', `投给 ${candidateName}`, 'vote')

    // 解锁复合赋值概念
    progressStore.unlockConcept(3, 'compound_assignment')
  }

  // 获取进度信息
  const progress = computed(() => progressStore.dayProgress[3])
  const progressPercentage = computed(() => progressStore.getProgressPercentage(3))
  const unlockedConcepts = computed(() => progressStore.dayProgress[3].unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(3),
    ethCost: logStore.getDayEthCost(3),
    operationCount: logStore.getDayOperationCount(3)
  }))

  return {
    // 状态
    candidates,
    voteCount,
    interactionCount,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    addCandidate,
    voteCandidate
  }
}
