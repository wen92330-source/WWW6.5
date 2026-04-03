<template>
  <div class="right-sidebar">
    <div class="sidebar-card">
      <h3>🎓 学习进度</h3>
      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: progressPercentage + '%' }"></div>
      </div>
      <div class="progress-stats">
        <span>完成度 {{ progressPercentage }}%</span>
        <span>已解锁 {{ unlockedCount }}/{{ totalConcepts }}</span>
      </div>
    </div>

    <div class="sidebar-card">
      <h3>✅ 已解锁概念</h3>
      <ul class="unlocked-list">
        <li v-if="currentDayConcepts.length === 0" class="locked">
          <span class="icon">🚧</span> 内容开发中...
        </li>
        <li
          v-for="concept in currentDayConcepts"
          :key="concept.key"
          :class="{ locked: !concept.isUnlocked }"
        >
          <span class="icon">{{ concept.icon }}</span>
          {{ concept.name }}
        </li>
      </ul>
    </div>

    <!-- 实时数据（动态显示）-->
    <div class="sidebar-card" v-if="realtimeData">
      <h3>📊 实时数据</h3>
      <div class="realtime-data">
        <!-- 动态指标 -->
        <div
          v-for="(metric, index) in realtimeData.metrics"
          :key="'metric-' + index"
          class="data-row"
        >
          <span class="metric-icon">{{ metric.icon }}</span>
          <span class="label">{{ metric.label }}：</span>
          <span class="value">{{ metric.value }} {{ metric.unit }}</span>
        </div>

        <!-- Gas 消耗统计 -->
        <div class="gas-stats" v-if="realtimeData.operationCount > 0">
          <div class="data-row">
            <span class="label">操作次数：</span>
            <span class="value">{{ realtimeData.operationCount }}</span>
          </div>
          <div class="data-row">
            <span class="label">Gas 消耗：</span>
            <span class="value">{{ realtimeData.gasUsage.toLocaleString() }}</span>
          </div>
          <div class="data-row">
            <span class="label">ETH 费用：</span>
            <span class="value">{{ realtimeData.ethCost.toFixed(6) }}</span>
          </div>
        </div>

        <!-- 无操作提示 -->
        <div v-else class="no-operations">
          <p>暂无操作记录</p>
          <p class="hint">开始交互后查看实时数据</p>
        </div>
      </div>
    </div>

    <!-- 操作日志（全局）-->
    <div class="sidebar-card">
      <h3>📋 操作日志</h3>
      <div class="operation-log">
        <div v-if="recentLogs.length === 0" class="no-logs">
          暂无操作记录
        </div>
        <div v-else>
          <div
            v-for="log in currentDayLogs"
            :key="log.id"
            class="log-entry"
            :class="{ 'current-day': log.day === currentDay }"
          >
            <div class="log-header">
              <span class="day-badge">Day {{ log.day }}</span>
              <span class="timestamp">{{ log.timestamp }}</span>
            </div>
            <div class="log-content">
              <strong>{{ log.operation }}</strong>
              <span class="details">{{ log.details }}</span>
            </div>
            <div v-if="log.gasUsed > 0" class="log-footer">
              <span class="gas-info">⛽ Gas: {{ log.gasUsed.toLocaleString() }}</span>
              <span class="eth-info">💰 ETH: {{ log.ethCost.toFixed(6) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { dayConfigs } from '../data/days'
import { conceptDefinitions } from '../data/concepts'
import { useOperationLogStore } from '@/stores/operationLogStore'

const props = defineProps({
  // 新增：实时数据接口
  realtimeData: {
    type: Object,
    default: null
  },
  // 保留原有的进度数据
  dayProgress: {
    type: Object,
    required: true
  },
  currentDay: {
    type: Number,
    required: true
  }
})

const logStore = useOperationLogStore()

// 获取当前day的日志（最近10条）
const currentDayLogs = computed(() => {
  return logStore.getDayLogs(props.currentDay)
})

// 获取所有最近日志（跨day）
const recentLogs = computed(() => {
  return logStore.recentLogs
})

const progressPercentage = computed(() => {
  const currentProgress = props.dayProgress[props.currentDay]
  if (!currentProgress || currentProgress.totalConcepts === 0) return 0
  return Math.floor((currentProgress.unlockedConcepts.length / currentProgress.totalConcepts) * 100)
})

const unlockedCount = computed(() => {
  const currentProgress = props.dayProgress[props.currentDay]
  return currentProgress?.unlockedConcepts.length || 0
})

const totalConcepts = computed(() => {
  const currentProgress = props.dayProgress[props.currentDay]
  return currentProgress?.totalConcepts || 0
})

const currentDayConcepts = computed(() => {
  const dayConfig = dayConfigs[props.currentDay]
  if (!dayConfig || !dayConfig.concepts) return []

  const currentProgress = props.dayProgress[props.currentDay]
  const unlockedConcepts = currentProgress?.unlockedConcepts || []

  return dayConfig.concepts.map(conceptKey => {
    const concept = conceptDefinitions[conceptKey]
    return {
      key: conceptKey,
      name: concept?.name || conceptKey,
      icon: unlockedConcepts.includes(conceptKey) ? concept?.icon : '🔒',
      isUnlocked: unlockedConcepts.includes(conceptKey)
    }
  })
})
</script>

<style scoped>
/* 新增样式 */
.metric-icon {
  font-size: 1.1em;
  margin-right: 4px;
}

.gas-stats {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid var(--border-main);
}

.no-operations {
  text-align: center;
  color: var(--text-muted);
  padding: 20px;
}

.no-operations p {
  margin: 5px 0;
}

.no-operations .hint {
  font-size: 0.85em;
  color: var(--text-muted);
  opacity: 0.7;
}

/* 日志样式 */
.log-entry {
  padding: 12px;
  margin-bottom: 10px;
  background: var(--bg-surface-1);
  border-radius: 6px;
  border-left: 3px solid var(--border-main);
  transition: all 0.2s ease;
}

.log-entry.current-day {
  border-left-color: var(--accent-yellow);
  background: rgba(250, 204, 21, 0.05);
}

.log-entry:hover {
  transform: translateX(2px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.log-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
  font-size: 0.85em;
}

.day-badge {
  background: var(--accent-yellow);
  color: #000;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 600;
  font-size: 0.9em;
}

.timestamp {
  color: var(--text-muted);
  font-size: 0.9em;
}

.log-content {
  margin-bottom: 6px;
}

.log-content .details {
  color: var(--text-secondary);
  font-size: 0.95em;
  margin-left: 6px;
}

.log-footer {
  display: flex;
  gap: 15px;
  font-size: 0.85em;
  color: var(--text-muted);
}

.gas-info {
  color: var(--accent-magenta);
}

.eth-info {
  color: var(--accent-green);
}

.no-logs {
  text-align: center;
  color: var(--text-muted);
  padding: 20px;
}

/* 响应式布局 */
@media (max-width: 768px) {
  .log-entry {
    padding: 10px;
  }

  .log-footer {
    flex-direction: column;
    gap: 4px;
  }
}
</style>
