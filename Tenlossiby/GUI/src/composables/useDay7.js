import { computed, ref } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 7 - IOU 借条系统
 * 学习概念：nested_mapping, address_payable, debt_tracking, internal_transfer, transfer_method, call_method, withdraw_pattern
 */
export function useDay7() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day7Contract = contractStore.contracts.day7
  const day7Progress = progressStore.dayProgress[7]

  // 临时状态
  const checkedBalance = ref(null)

  // 获取Day 7的合约状态
  const contract = computed(() => contractStore.getContract(7))
  const owner = computed(() => day7Contract.owner)
  const userAddress = computed(() => day7Contract.userAddress)
  const friendsList = computed(() => day7Contract.friendList)
  const userBalance = computed(() => day7Contract.balances[day7Contract.userAddress] || 0)
  const debts = computed(() => day7Contract.debts)
  const interactionCount = computed(() => day7Contract.interactionCount)

  // 添加好友
  const iouAddFriend = (friendAddress) => {
    contractStore.initializeContract(7)

    if (day7Contract.registeredFriends[friendAddress]) return false

    // 直接修改响应式状态
    day7Contract.registeredFriends[friendAddress] = true
    day7Contract.friendList.push(friendAddress)
    day7Contract.balances[friendAddress] = 0

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '添加好友', `好友: ${friendAddress}`, 'addFriend')

    // 解锁概念
    progressStore.unlockConcept(7, 'nested_mapping')

    return true
  }

  // 存款
  const iouDeposit = (amountEth) => {
    contractStore.initializeContract(7)
    const user = day7Contract.userAddress

    if (!day7Contract.registeredFriends[user]) return false

    const amountWei = amountEth * 1e18
    day7Contract.balances[user] = (day7Contract.balances[user] || 0) + amountWei

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '存款', `存入 ${amountEth} ETH`, 'depositIntoWallet')

    // 解锁概念
    progressStore.unlockConcept(7, 'address_payable')

    return true
  }

  // 记录债务
  const iouRecordDebt = (debtor, amountEth) => {
    contractStore.initializeContract(7)
    const user = day7Contract.userAddress

    const amountWei = amountEth * 1e18
    if (!day7Contract.debts[debtor]) {
      day7Contract.debts[debtor] = {}
    }
    day7Contract.debts[debtor][user] = (day7Contract.debts[debtor][user] || 0) + amountWei

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '记录债务', `债务人: ${debtor}, 金额: ${amountEth} ETH`, 'recordDebt')

    // 解锁概念
    progressStore.unlockConcept(7, 'debt_tracking')

    return true
  }

  // 还款
  const iouPayDebt = (creditor, amountEth) => {
    contractStore.initializeContract(7)
    const user = day7Contract.userAddress

    const amountWei = amountEth * 1e18
    if ((day7Contract.balances[user] || 0) < amountWei) {
      return "余额不足：你的钱包可用余额小于还款金额！"
    }

    day7Contract.balances[user] -= amountWei
    day7Contract.balances[creditor] = (day7Contract.balances[creditor] || 0) + amountWei

    if (day7Contract.debts[user] && day7Contract.debts[user][creditor]) {
      day7Contract.debts[user][creditor] -= amountWei
      if (day7Contract.debts[user][creditor] < 0) {
        day7Contract.debts[user][creditor] = 0
      }
    }

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '还款', `债权人: ${creditor}, 金额: ${amountEth} ETH`, 'payFromWallet')

    // 解锁概念
    progressStore.unlockConcept(7, 'internal_transfer')

    return true
  }

  // 转账（transfer）
  const iouTransferMethod = (toAddress, amountEth) => {
    contractStore.initializeContract(7)
    const user = day7Contract.userAddress

    const amountWei = amountEth * 1e18
    if ((day7Contract.balances[user] || 0) < amountWei) {
      return "余额不足：试图转账的金额超过了你拥有的钱包余额！"
    }

    day7Contract.balances[user] -= amountWei
    day7Contract.balances[toAddress] = (day7Contract.balances[toAddress] || 0) + amountWei

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '转账(transfer)', `收款方: ${toAddress}, 金额: ${amountEth} ETH`, 'transferEther')

    // 解锁概念
    progressStore.unlockConcept(7, 'transfer_method')

    return true
  }

  // 转账
  const iouCallMethod = (toAddress, amountEth) => {
    contractStore.initializeContract(7)
    const user = day7Contract.userAddress

    const amountWei = amountEth * 1e18
    if ((day7Contract.balances[user] || 0) < amountWei) {
      return "余额不足：低级调用失败，因为你的钱包没有足够的以太币！"
    }

    day7Contract.balances[user] -= amountWei
    day7Contract.balances[toAddress] = (day7Contract.balances[toAddress] || 0) + amountWei

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '转账call', `收款方: ${toAddress}, 金额: ${amountEth} ETH`, 'transferEtherViaCall')

    // 解锁概念
    progressStore.unlockConcept(7, 'call_method')

    return true
  }

  // 提款
  const iouWithdraw = (amountEth) => {
    contractStore.initializeContract(7)
    const user = day7Contract.userAddress
    const amountWei = amountEth * 1e18

    if ((day7Contract.balances[user] || 0) < amountWei) {
      return "余额不足：你无法提取超过拥有额度的资金！"
    }

    day7Contract.balances[user] -= amountWei

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '提款', `提取 ${amountEth} ETH`, 'withdraw')

    // 解锁概念
    progressStore.unlockConcept(7, 'withdraw_pattern')

    return true
  }

  // 查询余额
  const iouCheckBalance = () => {
    contractStore.initializeContract(7)
    const user = day7Contract.userAddress

    checkedBalance.value = day7Contract.balances[user] || 0

    day7Contract.interactionCount++
    day7Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(7, '查询余额', `余额: ${(checkedBalance.value / 1e18).toFixed(4)} ETH`)

    // 解锁概念
    progressStore.unlockConcept(7, 'withdraw_pattern')

    return checkedBalance.value
  }

  // 格式化余额显示
  const formatBalance = (balanceWei) => {
    return (balanceWei / 1e18).toFixed(4) + ' ETH'
  }

  // 获取进度信息
  const progress = computed(() => day7Progress)
  const progressPercentage = computed(() => {
    if (!day7Progress || day7Progress.totalConcepts === 0) return 0
    return Math.floor((day7Progress.unlockedConcepts.length / day7Progress.totalConcepts) * 100)
  })
  const unlockedConcepts = computed(() => day7Progress.unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(7),
    ethCost: logStore.getDayEthCost(7),
    operationCount: logStore.getDayOperationCount(7)
  }))

  return {
    // 状态
    owner,
    userAddress,
    friendsList,
    userBalance,
    debts,
    interactionCount,
    checkedBalance,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    iouAddFriend,
    iouDeposit,
    iouRecordDebt,
    iouPayDebt,
    iouTransferMethod,
    iouCallMethod,
    iouWithdraw,
    iouCheckBalance,
    formatBalance
  }
}
