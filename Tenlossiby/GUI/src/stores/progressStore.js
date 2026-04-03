import { defineStore } from 'pinia'
import { ref } from 'vue'
import { dayConfigs } from '@/data/days'

// 从 dayConfigs 自动生成初始进度数据
// 自动计算 totalConcepts，避免硬编码和不同步问题
const generateInitialDayProgress = () => {
  return Object.keys(dayConfigs).reduce((acc, day) => {
    acc[day] = {
      unlockedConcepts: [],
      totalConcepts: dayConfigs[day].concepts.length, // 自动计算概念总数
      interactionCount: 0
    }
    return acc
  }, {})
}

export const useProgressStore = defineStore('progress', () => {
  // 学习进度 - 从 dayConfigs 自动生成
  const dayProgress = ref(generateInitialDayProgress())

  // 统一处理day参数（支持数字或字符串）
  const normalizeDay = (day) => String(day)

  // 解锁概念
  const unlockConcept = (day, conceptKey) => {
    const dayKey = normalizeDay(day)
    const progress = dayProgress.value[dayKey]
    if (progress && !progress.unlockedConcepts.includes(conceptKey)) {
      progress.unlockedConcepts.push(conceptKey)
    }
  }

  // 增加交互次数
  const incrementInteraction = (day) => {
    const dayKey = normalizeDay(day)
    const progress = dayProgress.value[dayKey]
    if (progress) {
      progress.interactionCount++
    }
  }

  // 获取指定Day的进度
  const getDayProgress = (day) => {
    const dayKey = normalizeDay(day)
    return dayProgress.value[dayKey]
  }

  // 获取解锁的概念列表
  const getUnlockedConcepts = (day) => {
    const dayKey = normalizeDay(day)
    return dayProgress.value[dayKey]?.unlockedConcepts || []
  }

  // 检查概念是否已解锁
  const isConceptUnlocked = (day, conceptKey) => {
    const unlocked = getUnlockedConcepts(day)
    return unlocked.includes(conceptKey)
  }

  // 获取进度百分比
  const getProgressPercentage = (day) => {
    const dayKey = normalizeDay(day)
    const progress = dayProgress.value[dayKey]
    if (!progress || progress.totalConcepts === 0) return 0
    return Math.floor((progress.unlockedConcepts.length / progress.totalConcepts) * 100)
  }

  return {
    dayProgress,
    unlockConcept,
    incrementInteraction,
    getDayProgress,
    getUnlockedConcepts,
    isConceptUnlocked,
    getProgressPercentage
  }
})
