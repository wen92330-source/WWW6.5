import { ref, computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

export function useDay5() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 输入状态
  const inputTreasureAmount = ref('')
  const inputRecipient = ref('')
  const inputAllowance = ref('')
  const inputWithdrawAmount = ref('')
  const inputNewOwner = ref('')

  // 合约状态
  const contract = computed(() => {
    contractStore.initializeContract(5)
    return contractStore.getContract(5)
  })

  const owner = computed(() => contract.value?.owner || '')
  const treasureAmount = computed(() => contract.value?.treasureAmount || 0)
  const userAddress = computed(() => contract.value?.userAddress || '')
  const userAllowance = computed(() => contract.value?.userAllowance || 0)
  const hasWithdrawn = computed(() => {
    if (!contract.value?.hasWithdrawn) return false
    return !!contract.value.hasWithdrawn[userAddress.value]
  })

  // 添加宝藏
  const addTreasure = (amount) => {
    if (!amount || amount <= 0) return false

    contract.value.treasureAmount += amount
    contract.value.interactionCount++
    progressStore.incrementInteraction(5)

    // 记录操作日志
    logStore.addLog(5, '添加宝藏', `数量: ${amount}`, 'addTreasure')

    progressStore.unlockConcept(5, 'modifier')
    return true
  }

  // 批准提款
  const approveWithdrawal = (recipient, amount) => {
    if (!recipient || !amount || amount <= 0) return false

    if (amount <= contract.value.treasureAmount) {
      contract.value.withdrawalAllowance[recipient] = amount
      if (recipient === contract.value.userAddress) {
        contract.value.userAllowance = amount
      }
    }
    contract.value.interactionCount++
    progressStore.incrementInteraction(5)

    // 记录操作日志
    logStore.addLog(5, '批准提款', `批准 ${recipient}: ${amount}`, 'approveWithdrawal')

    progressStore.unlockConcept(5, 'return_statement')
    return true
  }

  // 提取宝藏
  const withdrawTreasure = (userAddress, amount) => {
    if (!userAddress || !amount || amount <= 0) return false

    const withdrawn = false
    if (userAddress === contract.value.owner) {
      if (amount <= contract.value.treasureAmount) {
        contract.value.treasureAmount -= amount
        withdrawn = true
      }
    } else {
      const allowance = contract.value.withdrawalAllowance[userAddress]
      if (allowance > 0 && !contract.value.hasWithdrawn[userAddress] &&
          allowance <= contract.value.treasureAmount && allowance >= amount) {
        contract.value.hasWithdrawn[userAddress] = true
        contract.value.treasureAmount -= allowance
        contract.value.withdrawalAllowance[userAddress] = 0
        if (userAddress === contract.value.userAddress) {
          contract.value.userAllowance = 0
        }
        withdrawn = true
      }
    }

    contract.value.interactionCount++
    progressStore.incrementInteraction(5)

    if (withdrawn) {
      // 记录操作日志
      logStore.addLog(5, '提取宝藏', `提取: ${amount}`, 'withdrawTreasure')
    }

    return true
  }

  // 重置提款状态
  const resetWithdrawalStatus = (userAddress) => {
    if (!userAddress) userAddress = contract.value.userAddress
    contract.value.hasWithdrawn[userAddress] = false
    contract.value.interactionCount++
    progressStore.incrementInteraction(5)

    // 记录操作日志
    logStore.addLog(5, '重置提款状态', `重置: ${userAddress}`)

    return true
  }

  // 转移所有权
  const transferOwnership = (newOwner) => {
    if (!newOwner || newOwner === '0x0000000000000000000000000000000000000000') return false

    contract.value.owner = newOwner
    contract.value.interactionCount++
    progressStore.incrementInteraction(5)

    // 记录操作日志
    logStore.addLog(5, '转移所有权', `新所有者: ${newOwner}`, 'transferOwnership')

    progressStore.unlockConcept(5, 'zero_address')
    return true
  }

  // 获取宝藏详情
  const getTreasureDetails = () => {
    contract.value.interactionCount++
    progressStore.incrementInteraction(5)

    // 记录操作日志
    logStore.addLog(5, '查询宝藏', `宝藏数量: ${contract.value.treasureAmount}`)

    progressStore.unlockConcept(5, 'return_statement')
    return contract.value.treasureAmount
  }

  // 获取进度信息
  const progress = computed(() => progressStore.dayProgress[5])
  const progressPercentage = computed(() => {
    const p = progressStore.dayProgress[5]
    if (!p || p.totalConcepts === 0) return 0
    return Math.floor((p.unlockedConcepts.length / p.totalConcepts) * 100)
  })
  const unlockedConcepts = computed(() => progressStore.dayProgress[5].unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(5),
    ethCost: logStore.getDayEthCost(5),
    operationCount: logStore.getDayOperationCount(5)
  }))

  return {
    // 输入状态
    inputTreasureAmount,
    inputRecipient,
    inputAllowance,
    inputWithdrawAmount,
    inputNewOwner,
    // 合约状态
    owner,
    treasureAmount,
    userAddress,
    userAllowance,
    hasWithdrawn,
    progress,
    progressPercentage,
    unlockedConcepts,
    // 实时数据接口
    realtimeData,
    // 操作方法
    addTreasure,
    approveWithdrawal,
    withdrawTreasure,
    resetWithdrawalStatus,
    transferOwnership,
    getTreasureDetails
  }
}
