// 在 useDay6.js 中添加实时数据接口（示例）

import { computed } from 'vue'
import { useOperationLogStore } from '@/stores/operationLogStore'

// 在 useDay6 函数的返回值中添加：

/**
 * 获取实时数据接口（供 Sidebar 使用）
 */
const realtimeData = computed(() => {
  const logStore = useOperationLogStore()

  return {
    // 核心指标
    metrics: [
      {
        label: '会员数量',
        value: members.value.length,
        unit: '人',
        icon: '👥'
      },
      {
        label: '您的余额',
        value: formatWeiToEth(userBalance.value),
        unit: 'ETH',
        icon: '💰'
      },
      {
        label: '银行总余额',
        value: formatWeiToEth(
          members.value.reduce((sum, member) => sum + (balance[member] || 0), 0)
        ),
        unit: 'ETH',
        icon: '🏦'
      }
    ],
    // Gas 消耗
    gasUsage: logStore.getDayGasUsage(6),
    ethCost: logStore.getDayEthCost(6),
    operationCount: logStore.getDayOperationCount(6)
  }
})

// 在操作函数中记录日志：

const addMembers = (address) => {
  // ... 原有逻辑 ...

  // 记录操作日志
  const logStore = useOperationLogStore()
  logStore.addLog(6, '添加会员', `添加会员: ${address}`, 'addMembers')

  return success
}

const depositEther = (amount) => {
  // ... 原有逻辑 ...

  // 记录操作日志
  const logStore = useOperationLogStore()
  logStore.addLog(6, '存入ETH', `存入 ${amount} ETH`, 'depositAmountEther')

  return success
}

const withdrawEth = (amount) => {
  // ... 原有逻辑 ...

  // 记录操作日志
  const logStore = useOperationLogStore()
  logStore.addLog(6, '提取ETH', `提取 ${amount} ETH`, 'withdrawAmount')

  return success
}

// 导出时添加 realtimeData
return {
  // ... 原有返回值 ...
  realtimeData  // 新增
}
