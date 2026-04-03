import { computed, ref } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

/**
 * Day 4 - 拍卖系统
 * 学习概念：constructor, block_timestamp, require, msg_sender, external, bool_type, address_type
 */
export function useDay4() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 直接引用 store 的 ref，避免响应式问题
  const day4Contract = contractStore.contracts.day4
  const day4Progress = progressStore.dayProgress[4]

  // 临时状态
  const winner = ref(null)

  // 获取Day 4的合约状态
  const contract = computed(() => contractStore.getContract(4))
  const owner = computed(() => day4Contract.owner)
  const item = computed(() => day4Contract.item)
  const auctionEndTime = computed(() => day4Contract.auctionEndTime)
  const highestBidder = computed(() => day4Contract.highestBidder)
  const highestBid = computed(() => day4Contract.highestBid)
  const ended = computed(() => day4Contract.ended)
  const bids = computed(() => day4Contract.bids)
  const bidders = computed(() => day4Contract.bidders)
  const interactionCount = computed(() => day4Contract.interactionCount)

  // 初始化拍卖
  const initializeAuction = (itemName, biddingTime) => {
    // 直接修改响应式状态
    day4Contract.owner = contractStore.generateAddress()
    day4Contract.item = itemName
    day4Contract.auctionEndTime = Math.floor(Date.now() / 1000) + biddingTime
    day4Contract.interactionCount++
    day4Progress.interactionCount++

    // 记录操作日志（无 Gas 估算）
    logStore.addLog(4, '初始化拍卖', `物品: ${itemName}, 时长: ${biddingTime}秒`)

    // 解锁概念
    progressStore.unlockConcept(4, 'constructor')
    progressStore.unlockConcept(4, 'block_timestamp')
  }

  // 出价
  const placeBid = (amount, bidderAddress) => {
    if (day4Contract.ended) return false

    const currentTime = Math.floor(Date.now() / 1000)
    if (currentTime >= day4Contract.auctionEndTime) return false
    if (amount <= 0) return false

    const currentBid = day4Contract.bids[bidderAddress] || 0
    if (amount <= currentBid) return false

    // 直接修改响应式状态
    day4Contract.bids[bidderAddress] = amount
    day4Contract.interactionCount++
    day4Progress.interactionCount++

    if (currentBid === 0) day4Contract.bidders.push(bidderAddress)
    if (amount > day4Contract.highestBid) {
      day4Contract.highestBid = amount
      day4Contract.highestBidder = bidderAddress
    }

    // 记录操作日志
    logStore.addLog(4, '出价', `出价 ${amount}`, 'placeBid')

    // 解锁概念
    progressStore.unlockConcept(4, 'require')
    if (day4Contract.bidders.length >= 1) {
      progressStore.unlockConcept(4, 'msg_sender')
    }
    if (day4Contract.bidders.length >= 2 || day4Contract.interactionCount >= 2) {
      progressStore.unlockConcept(4, 'external')
    }

    return true
  }

  // 结束拍卖
  const endAuction = () => {
    const currentTime = Math.floor(Date.now() / 1000)
    if (currentTime < day4Contract.auctionEndTime) return false
    if (day4Contract.ended) return false

    // 直接修改响应式状态
    day4Contract.ended = true
    day4Contract.interactionCount++
    day4Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(4, '结束拍卖', '拍卖已结束', 'endAuction')

    // 解锁概念
    progressStore.unlockConcept(4, 'bool_type')

    return true
  }

  // 获取获胜者
  const getWinner = () => {
    if (!day4Contract.ended) return null

    day4Contract.interactionCount++
    day4Progress.interactionCount++

    // 记录操作日志
    logStore.addLog(4, '查看获胜者', `获胜者: ${day4Contract.highestBidder}`)

    // 解锁概念
    progressStore.unlockConcept(4, 'address_type')

    winner.value = {
      winner: day4Contract.highestBidder,
      bid: day4Contract.highestBid
    }

    return winner.value
  }

  // 格式化时间
  const formatTime = (timestamp) => {
    if (!timestamp) return '未设置'
    const date = new Date(timestamp * 1000)
    return date.toLocaleString('zh-CN')
  }

  // 检查拍卖是否已结束
  const checkAuctionEnded = () => {
    const currentTime = Math.floor(Date.now() / 1000)
    return currentTime >= day4Contract.auctionEndTime
  }

  // 获取进度信息
  const progress = computed(() => day4Progress)
  const progressPercentage = computed(() => {
    if (!day4Progress || day4Progress.totalConcepts === 0) return 0
    return Math.floor((day4Progress.unlockedConcepts.length / day4Progress.totalConcepts) * 100)
  })
  const unlockedConcepts = computed(() => day4Progress.unlockedConcepts)

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(4),
    ethCost: logStore.getDayEthCost(4),
    operationCount: logStore.getDayOperationCount(4)
  }))

  return {
    // 状态
    owner,
    item,
    auctionEndTime,
    highestBidder,
    highestBid,
    ended,
    bids,
    bidders,
    interactionCount,
    winner,
    progress,
    progressPercentage,
    unlockedConcepts,

    // 实时数据接口
    realtimeData,

    // 方法
    initializeAuction,
    placeBid,
    endAuction,
    getWinner,
    formatTime,
    checkAuctionEnded
  }
}
