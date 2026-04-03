import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { gasEstimates, ethPricePerGwei } from '@/data/concepts'

/**
 * 操作日志 Store
 * 记录所有 day 的操作历史和 Gas 消耗
 */
export const useOperationLogStore = defineStore('operationLog', () => {
  // 操作日志列表
  const logs = ref([])

  // 每个day的累计Gas消耗
  const dayGasUsage = ref({})

  // 每个day的操作计数
  const dayOperationCounts = ref({})

  /**
   * 添加操作日志
   * @param {number} day - Day编号
   * @param {string} operation - 操作名称
   * @param {string} details - 操作详情
   * @param {string} gasKey - concepts.js中的gas估算key
   */
  const addLog = (day, operation, details, gasKey = null) => {
    const timestamp = new Date().toLocaleTimeString('zh-CN', { hour12: false })

    let gasUsed = 0
    let ethCost = 0

    // 如果提供了gasKey，计算消耗
    if (gasKey && gasEstimates[gasKey]) {
      gasUsed = gasEstimates[gasKey]
      ethCost = gasUsed * ethPricePerGwei

      // 更新该day的累计消耗
      if (!dayGasUsage.value[day]) {
        dayGasUsage.value[day] = 0
      }
      dayGasUsage.value[day] += gasUsed
    }

    // 更新操作计数
    if (!dayOperationCounts.value[day]) {
      dayOperationCounts.value[day] = 0
    }
    dayOperationCounts.value[day]++

    // 添加日志
    const logEntry = {
      id: `${day}-${Date.now()}-${Math.random()}`,
      day,
      timestamp,
      operation,
      details,
      gasUsed,
      ethCost
    }

    logs.value.unshift(logEntry) // 最新的在前面

    return logEntry
  }

  /**
   * 清空某个day的日志
   */
  const clearDayLogs = (day) => {
    logs.value = logs.value.filter(log => log.day !== day)
  }

  /**
   * 清空所有日志
   */
  const clearAllLogs = () => {
    logs.value = []
    dayGasUsage.value = {}
    dayOperationCounts.value = {}
  }

  /**
   * 获取某个day的日志（最近10条）
   */
  const getDayLogs = (day) => {
    return logs.value.filter(log => log.day === day).slice(0, 10)
  }

  /**
   * 获取某个day的累计Gas消耗
   */
  const getDayGasUsage = (day) => {
    return dayGasUsage.value[day] || 0
  }

  /**
   * 获取某个day的累计ETH成本
   */
  const getDayEthCost = (day) => {
    return (dayGasUsage.value[day] || 0) * ethPricePerGwei
  }

  /**
   * 获取某个day的操作次数
   */
  const getDayOperationCount = (day) => {
    return dayOperationCounts.value[day] || 0
  }

  /**
   * 获取所有日志（最近20条）
   */
  const recentLogs = computed(() => {
    return logs.value.slice(0, 20)
  })

  return {
    // 状态
    logs,
    dayGasUsage,
    dayOperationCounts,
    recentLogs,

    // 方法
    addLog,
    clearDayLogs,
    clearAllLogs,
    getDayLogs,
    getDayGasUsage,
    getDayEthCost,
    getDayOperationCount
  }
})
