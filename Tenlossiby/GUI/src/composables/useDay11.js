import { ref, computed } from 'vue'
import { useContractStore } from '@/stores/contractStore'
import { useProgressStore } from '@/stores/progressStore'
import { useOperationLogStore } from '@/stores/operationLogStore'

export function useDay11() {
  const contractStore = useContractStore()
  const progressStore = useProgressStore()
  const logStore = useOperationLogStore()

  // 合约状态
  const contract = computed(() => {
    contractStore.initializeContract(11)
    return contractStore.getContract(11)
  })

  // 计算属性
  const owner = computed(() => contract.value?.owner || '')
  const contractBalance = computed(() => contract.value?.contractBalance || 0)
  const userAddress = computed(() => contract.value?.userAddress || '')
  const isOwner = computed(() => userAddress.value === owner.value)
  const eventLog = computed(() => contract.value?.eventLog || [])

  // 获取解锁提示
  const getUnlockHint = (conceptKey) => {
    const hints = {
      inheritance: '📦 太棒了！你看到 VaultMaster 继承了 Ownable 的功能！👉 存入 ETH 来学习 import 机制！',
      constructor: '🏗️ 太棒了！你了解了构造函数！👉 存入 ETH 来学习导入语句和私有变量！',
      import_statement: '📥 不错！你了解了导入语句！👉 继续存入 ETH 来学习事件日志！',
      event_logging: '📋 很好！你触发了事件日志！👉 尝试转移所有权来解锁更多概念！',
      private_visibility: '🔒 优秀！你学会了 private 变量的使用！合约余额等敏感数据都使用 private 保护！',
      transfer_ownership: '🔑 很好！你了解了所有权转移！👉 尝试以用户身份提取来学习修饰符！',
      indexed_parameter: '🏷️ 不错！你了解了索引参数！👉 切换到用户身份体验权限控制！',
      onlyOwner_modifier: '🛡️ 太棒了！你了解了 onlyOwner 修饰符！👉 查看完整代码来学习更多！'
    }
    return hints[conceptKey] || ''
  }

  // 解锁概念并返回提示
  const unlockConceptWithHint = (concept) => {
    const progress = progressStore.dayProgress[11]
    const alreadyUnlocked = progress?.unlockedConcepts?.includes(concept)
    
    if (!alreadyUnlocked) {
      progressStore.unlockConcept(11, concept)
      return getUnlockHint(concept)
    }
    return null
  }

  // 生成随机地址
  const generateRandomAddress = () => {
    return '0x' + Array(40).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('')
  }

  // 设置所有者模式
  const setOwnerMode = () => {
    if (contract.value) {
      contract.value.userAddress = contract.value.owner
      progressStore.incrementInteraction(11)

      // 记录操作日志
      logStore.addLog(11, '切换身份', '切换为所有者身份')

      return {
        hint: '✅ 已切换到所有者身份！👉 现在可以转移所有权和提取资金了！'
      }
    }
    return null
  }

  // 设置用户模式（生成新地址）
  const setUserMode = () => {
    if (contract.value) {
      const newAddress = generateRandomAddress()
      contract.value.userAddress = newAddress
      progressStore.incrementInteraction(11)

      // 记录操作日志
      logStore.addLog(11, '切换身份', `切换为用户身份: ${newAddress.slice(0, 10)}...`)

      return {
        hint: '👤 已切换到用户身份！👉 现在尝试提取资金来体验权限控制！'
      }
    }
    return null
  }

  // 获取当前所有者 - 首次调用解锁 inheritance 和 constructor
  const getOwner = () => {
    progressStore.incrementInteraction(11)

    // 记录操作日志
    logStore.addLog(11, '查询所有者', `所有者: ${owner.value.slice(0, 10)}...`)

    const hints = []

    // 首次查看所有者时解锁 inheritance 和 constructor
    const inheritHint = unlockConceptWithHint('inheritance')
    if (inheritHint) hints.push(inheritHint)

    const constructHint = unlockConceptWithHint('constructor')
    if (constructHint) hints.push(constructHint)

    return {
      address: owner.value,
      hint: hints.length > 0 ? hints.join('\n') : null
    }
  }

  // 获取合约余额
  const getBalance = () => {
    progressStore.incrementInteraction(11)

    // 记录操作日志
    logStore.addLog(11, '查询余额', `合约余额: ${(contractBalance.value / 1e18).toFixed(4)} ETH`)

    return contractBalance.value
  }

  // 存款 - 解锁 import_statement、event_logging 和 private_visibility
  const deposit = (amount) => {
    if (!amount || amount <= 0) return { success: false, error: '金额无效' }

    const weiAmount = Math.floor(amount * 1e18)
    contract.value.contractBalance += weiAmount

    // 添加事件日志
    contract.value.eventLog.push({
      name: 'DepositSuccessful',
      icon: '💰',
      details: `存入 ${amount} ETH (${weiAmount} wei)`,
      timestamp: Date.now()
    })

    contract.value.interactionCount++
    progressStore.incrementInteraction(11)

    // 记录操作日志
    logStore.addLog(11, '存款', `存入 ${amount} ETH`)

    // 解锁概念
    const hints = []
    const importHint = unlockConceptWithHint('import_statement')
    if (importHint) hints.push(importHint)

    const eventHint = unlockConceptWithHint('event_logging')
    if (eventHint) hints.push(eventHint)

    // 新增：在首次存入 ETH 时解锁 private_visibility
    const privateHint = unlockConceptWithHint('private_visibility')
    if (privateHint) hints.push(privateHint)

    return { success: true, hints }
  }

  // 提款（仅所有者）- 非所有者尝试时解锁 onlyOwner_modifier
  const withdraw = (recipient, amount) => {
    if (!recipient || !amount || amount <= 0) {
      return { success: false, error: '参数无效' }
    }

    if (!isOwner.value) {
      // 非所有者尝试提款，解锁知识点但拒绝操作
      unlockConceptWithHint('onlyOwner_modifier')
      progressStore.incrementInteraction(11)

      // 记录操作日志（失败尝试）
      logStore.addLog(11, '提取失败', '权限不足：非所有者尝试提取')

      return { success: false, error: '❌ 权限不足：只有所有者才能提取资金 🛡️ 解锁知识点：onlyOwner 修饰符！' }
    }

    const weiAmount = Math.floor(amount * 1e18)
    if (weiAmount > contractBalance.value) {
      return { success: false, error: '余额不足' }
    }

    contract.value.contractBalance -= weiAmount

    // 添加事件日志
    contract.value.eventLog.push({
      name: 'WithdrawSuccessful',
      icon: '💸',
      details: `提取 ${amount} ETH 到 ${recipient.slice(0, 6)}...${recipient.slice(-4)}`,
      timestamp: Date.now()
    })

    contract.value.interactionCount++
    progressStore.incrementInteraction(11)

    // 记录操作日志
    logStore.addLog(11, '提取资金', `提取 ${amount} ETH 到 ${recipient.slice(0, 10)}...`)

    return { success: true }
  }

  // 转移所有权 - 解锁 transfer_ownership 和 indexed_parameter
  const transferOwnership = (newOwner) => {
    if (!newOwner || newOwner === '0x0000000000000000000000000000000000000000') {
      return { success: false, error: '无效地址' }
    }
    if (!isOwner.value) {
      return { success: false, error: '权限不足' }
    }

    const oldOwner = contract.value.owner
    contract.value.owner = newOwner

    // 如果当前用户是所有者，更新后需要切换身份
    if (contract.value.userAddress === oldOwner) {
      contract.value.userAddress = newOwner
    }

    // 添加事件日志
    contract.value.eventLog.push({
      name: 'OwnershipTransferred',
      icon: '🔑',
      details: `所有权从 ${oldOwner.slice(0, 6)}... 转移到 ${newOwner.slice(0, 6)}...`,
      timestamp: Date.now()
    })

    contract.value.interactionCount++
    progressStore.incrementInteraction(11)

    // 记录操作日志
    logStore.addLog(11, '转移所有权', `${oldOwner.slice(0, 10)}... → ${newOwner.slice(0, 10)}...`)

    // 解锁概念
    const hints = []
    const transferHint = unlockConceptWithHint('transfer_ownership')
    if (transferHint) hints.push(transferHint)

    const indexedHint = unlockConceptWithHint('indexed_parameter')
    if (indexedHint) hints.push(indexedHint)

    // 新增：提示体验权限控制
    const progress = progressStore.dayProgress[11]
    if (!progress?.unlockedConcepts?.includes('onlyOwner_modifier')) {
      hints.push('🛡️ 想体验权限控制吗？👉 切换到"用户"身份，尝试提取资金！')
    }

    return { success: true, hints }
  }

  // 查看完整代码 - 不再解锁概念，只是提供反馈
  const viewFullCode = () => {
    progressStore.incrementInteraction(11)

    // 记录操作日志
    logStore.addLog(11, '查看代码', '查看完整合约代码')

    // 不再解锁概念，只是提供反馈
    return {
      hints: ['📖 你已了解所有核心概念！查看完整代码来巩固知识吧！']
    }
  }

  // 实时数据接口（供 Sidebar 使用）
  const realtimeData = computed(() => ({
    gasUsage: logStore.getDayGasUsage(11),
    ethCost: logStore.getDayEthCost(11),
    operationCount: logStore.getDayOperationCount(11)
  }))

  return {
    // 状态
    owner,
    contractBalance,
    userAddress,
    isOwner,
    eventLog,

    // 实时数据接口
    realtimeData,

    // 操作方法
    getOwner,
    getBalance,
    deposit,
    withdraw,
    transferOwnership,
    setOwnerMode,
    setUserMode,
    viewFullCode,
    unlockConceptWithHint,
    getUnlockHint
  }
}
