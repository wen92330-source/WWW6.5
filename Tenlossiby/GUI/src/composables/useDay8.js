import { computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 8 - 小费罐
 * 学习概念：modifier_onlyOwner, payable_tip, msg_value_tip, mapping_rates, address_balance, call_withdraw
 */
export function useDay8() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day8Contract = contractStore.contracts.day8
  const day8Progress = progressStore.dayProgress[8]

  // 获取Day 8的合约状态
  const contract = computed(() => contractStore.getContract(8))
  const owner = computed(() => day8Contract.owner)
  const userAddress = computed(() => day8Contract.userAddress)
  const isAdmin = computed(() => day8Contract.isUserAdmin)
  const totalTips = computed(() => day8Contract.totalTipsReceived)
  const supportedCurrencies = computed(() => day8Contract.supportedCurrencies)
  const conversionRates = computed(() => day8Contract.conversionRates)
  const interactionCount = computed(() => day8Contract.interactionCount)

  // 切换管理员模式
  const tipJarToggleAdmin = () => {
    contractStore.initializeContract(8)

    day8Contract.isUserAdmin = !day8Contract.isUserAdmin

    day8Contract.interactionCount++
    day8Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(8, '切换管理员模式', day8Contract.isUserAdmin ? '开启管理员模式' : '关闭管理员模式')

    // 解锁概念
    progressStore.unlockConcept(8, 'modifier_onlyOwner')
  }

  // 用 ETH 打赏
  const tipJarTipInEth = (amountEth) => {
    contractStore.initializeContract(8)

    const amountWei = amountEth * 1e18
    day8Contract.totalTipsReceived += amountWei

    const user = day8Contract.userAddress
    day8Contract.tipPerPerson[user] = (day8Contract.tipPerPerson[user] || 0) + amountWei

    day8Contract.interactionCount++
    day8Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(8, '打赏ETH', `打赏 ${amountEth} ETH`, 'tipInEth')

    // 解锁概念
    progressStore.unlockConcept(8, 'payable_tip')
  }

  // 用其他货币打赏
  const tipJarTipInCurrency = (currency, amount) => {
    contractStore.initializeContract(8)

    const rate = day8Contract.conversionRates[currency]
    if (!rate) return false

    const amountWei = amount * rate
    day8Contract.totalTipsReceived += amountWei

    const user = day8Contract.userAddress
    day8Contract.tipPerPerson[user] = (day8Contract.tipPerPerson[user] || 0) + amountWei

    if (!day8Contract.tipsPerCurrency[currency]) {
      day8Contract.tipsPerCurrency[currency] = 0
    }
    day8Contract.tipsPerCurrency[currency] += amount

    day8Contract.interactionCount++
    day8Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(8, '打赏货币', `打赏 ${amount} ${currency}`, 'tipInCurrency')

    // 解锁概念
    progressStore.unlockConcept(8, 'msg_value_tip')
    progressStore.unlockConcept(8, 'mapping_rates')

    return true
  }

  // 提取小费
  const tipJarWithdraw = () => {
    contractStore.initializeContract(8)

    if (!day8Contract.isUserAdmin) {
      return "revert: Only owner can perform this action"
    }

    if (day8Contract.totalTipsReceived === 0) {
      return "revert: No tips to withdraw"
    }

    day8Contract.totalTipsReceived = 0
    day8Contract.interactionCount++
    day8Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(8, '提取小费', '提取所有小费', 'withdrawTips')

    // 解锁概念
    progressStore.unlockConcept(8, 'address_balance')
    progressStore.unlockConcept(8, 'call_withdraw')

    return true
  }

  // 获取用户打赏总额
  const getUserTips = () => {
    const user = day8Contract.userAddress
    const tips = day8Contract.tipPerPerson[user] || 0

    // 记录操作日志（view 函数，无 Gas）
    logStore.addLog(8, '查询打赏', `累计打赏: ${(tips / 1e18).toFixed(4)} ETH`)

    return tips
  }

  // 格式化余额显示
  const formatBalance = (balanceWei) => {
    return (balanceWei / 1e18).toFixed(4) + ' ETH'
  }

  // 获取进度信息
  const progress = computed(() => day8Progress)
  const progressPercentage = computed(() => {
    if (!day8Progress || day8Progress.totalConcepts === 0) return 0
    return Math.floor((day8Progress.unlockedConcepts.length / day8Progress.totalConcepts) * 100)
  })
  const unlockedConcepts = computed(() => day8Progress.unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    gasUsage: logStore.getDayGasUsage(8),
    ethCost: logStore.getDayEthCost(8),
    operationCount: logStore.getDayOperationCount(8)
  }))

  return {
    // 状态
    owner,
    userAddress,
    isAdmin,
    totalTips,
    supportedCurrencies,
    conversionRates,
    interactionCount,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    tipJarToggleAdmin,
    tipJarTipInEth,
    tipJarTipInCurrency,
    tipJarWithdraw,
    getUserTips,
    formatBalance
  }
}
