import { computed, ref } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 6 - 银行系统
 * 学习概念：address_mapping_balance, payable, msg_value, wei_unit, ether_deposit_withdraw
 */
export function useDay6() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day6Contract = contractStore.contracts.day6
  const day6Progress = progressStore.dayProgress[6]

  // 临时状态
  const queryBalance = ref(null)
  const membersList = ref([])

  // 获取Day 6的合约状态
  const contract = computed(() => contractStore.getContract(6))
  const bankManager = computed(() => day6Contract.bankManager)
  const members = computed(() => day6Contract.members)
  const userAddress = computed(() => day6Contract.userAddress)
  const userBalance = computed(() => day6Contract.balance[day6Contract.userAddress] || 0)
  const interactionCount = computed(() => day6Contract.interactionCount)

  // 添加成员
  const addMembers = (memberAddress) => {
    contractStore.initializeContract(6)

    if (memberAddress === '0x0000000000000000000000000000000000000000') return false
    if (memberAddress === day6Contract.bankManager) return false
    if (day6Contract.registeredMembers[memberAddress]) return false

    // 直接修改响应式状态
    day6Contract.registeredMembers[memberAddress] = true
    day6Contract.members.push(memberAddress)
    day6Contract.balance[memberAddress] = 0
    day6Contract.interactionCount++
    day6Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(6, '添加会员', `会员: ${memberAddress}`, 'addMembers')

    // 解锁概念
    progressStore.unlockConcept(6, 'address_mapping_balance')

    return true
  }

  // 存款
  const depositEther = (amountEth) => {
    contractStore.initializeContract(6)
    const userAddr = day6Contract.userAddress

    if (!day6Contract.registeredMembers[userAddr]) return false

    const amountWei = amountEth * 1e18
    day6Contract.balance[userAddr] += amountWei
    day6Contract.interactionCount++
    day6Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(6, '存入ETH', `存入 ${amountEth} ETH`, 'depositAmountEther')

    // 解锁概念
    progressStore.unlockConcept(6, 'payable')
    progressStore.unlockConcept(6, 'msg_value')

    return true
  }

  // 提款
  const withdrawEth = (amountEth) => {
    contractStore.initializeContract(6)
    const userAddr = day6Contract.userAddress

    if (!day6Contract.registeredMembers[userAddr]) return false

    const amountWei = amountEth * 1e18
    if (day6Contract.balance[userAddr] < amountWei) return false

    day6Contract.balance[userAddr] -= amountWei
    day6Contract.interactionCount++
    day6Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(6, '提取ETH', `提取 ${amountEth} ETH`, 'withdrawAmount')

    // 解锁概念
    progressStore.unlockConcept(6, 'wei_unit')
    progressStore.unlockConcept(6, 'ether_deposit_withdraw')

    return true
  }

  // 查询余额
  const getBalance = (queryAddress) => {
    contractStore.initializeContract(6)

    day6Contract.interactionCount++
    day6Progress.interactionCount++

    queryBalance.value = day6Contract.balance[queryAddress] || 0

    // 记录操作日志
    logStore.addLog(6, '查询余额', `查询: ${queryAddress}`)

    return queryBalance.value
  }

  // 获取成员列表
  const getMembers = () => {
    contractStore.initializeContract(6)

    day6Contract.interactionCount++
    day6Progress.interactionCount++

    membersList.value = [...day6Contract.members]

    return membersList.value
  }

  // 格式化余额显示
  const formatBalance = (balanceWei) => {
    return (balanceWei / 1e18).toFixed(4) + ' ETH'
  }

  // 获取进度信息
  const progress = computed(() => day6Progress)
  const progressPercentage = computed(() => {
    if (!day6Progress || day6Progress.totalConcepts === 0) return 0
    return Math.floor((day6Progress.unlockedConcepts.length / day6Progress.totalConcepts) * 100)
  })
  const unlockedConcepts = computed(() => day6Progress.unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(6),
    ethCost: logStore.getDayEthCost(6),
    operationCount: logStore.getDayOperationCount(6)
  }))

  return {
    // 状态
    bankManager,
    members,
    userAddress,
    userBalance,
    interactionCount,
    queryBalance,
    membersList,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    addMembers,
    depositEther,
    withdrawEth,
    getBalance,
    getMembers,
    formatBalance
  }
}
