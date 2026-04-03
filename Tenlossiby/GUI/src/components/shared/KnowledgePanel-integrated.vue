<!-- KnowledgePanel.vue - 集成实时数据的版本 -->
<template>
  <div class="knowledge-panel">
    <div class="panel-content">
      <!-- 概念解释区域 -->
      <div class="concepts-section">
        <h3>💡 知识点解锁</h3>
        <div class="concepts-grid">
          <div
            v-for="concept in currentDayConcepts"
            :key="concept.key"
            :class="['concept-card', { unlocked: concept.isUnlocked }]"
            @click="handleConceptClick(concept)"
          >
            <div class="concept-icon">{{ concept.icon }}</div>
            <div class="concept-name">{{ concept.name }}</div>
          </div>
        </div>
      </div>

      <!-- 代码预览区域 -->
      <div class="code-section">
        <h3>📝 合约代码预览</h3>
        <div class="code-preview">
          <pre><code>{{ codePreview }}</code></pre>
        </div>
        <button @click="$emit('show-full-code')" class="view-full-code-btn">
          📄 查看完整代码
        </button>
      </div>
    </div>

    <!-- Sidebar（传入 realtimeData）-->
    <Sidebar
      :realtime-data="realtimeData"
      :day-progress="dayProgress"
      :current-day="currentDay"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { dayConfigs } from '@/data/days'
import { conceptDefinitions } from '@/data/concepts'
import { useProgressStore } from '@/stores/progressStore'
import Sidebar from '@/components/Sidebar.vue'

const props = defineProps({
  currentDay: {
    type: Number,
    required: true
  },
  unlockedConcepts: {
    type: Array,
    default: () => []
  },
  progressPercentage: {
    type: Number,
    default: 0
  },
  fullCode: {
    type: String,
    default: ''
  },
  // ← 新增：实时数据接口
  realtimeData: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['show-full-code'])

const progressStore = useProgressStore()

const dayProgress = computed(() => progressStore.dayProgress)

const currentDayConcepts = computed(() => {
  const dayConfig = dayConfigs[props.currentDay]
  if (!dayConfig || !dayConfig.concepts) return []

  return dayConfig.concepts.map(conceptKey => {
    const concept = conceptDefinitions[conceptKey]
    return {
      key: conceptKey,
      name: concept?.name || conceptKey,
      icon: props.unlockedConcepts.includes(conceptKey) ? concept?.icon : '🔒',
      isUnlocked: props.unlockedConcepts.includes(conceptKey),
      message: concept?.message || '',
      code: concept?.code || ''
    }
  })
})

const codePreview = computed(() => {
  // 显示第一个已解锁概念的代码示例
  const unlockedConcept = currentDayConcepts.value.find(c => c.isUnlocked)
  if (unlockedConcept && unlockedConcept.code) {
    return unlockedConcept.code
  }
  // 如果没有解锁任何概念，显示合约基本结构
  return `// 点击查看完整代码\ncontract ClickCounter {\n    uint256 public counter;\n    \n    function click() public {\n        counter++;\n    }\n}`
})

const handleConceptClick = (concept) => {
  if (concept.isUnlocked) {
    // 可以在这里显示概念详情的弹窗
    alert(`${concept.message}\n\n代码示例：\n${concept.code}`)
  }
}
</script>

<style scoped>
.knowledge-panel {
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 100%;
  max-width: 380px;
}

.panel-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.concepts-section,
.code-section {
  background: var(--bg-surface-1);
  padding: 20px;
  border-radius: 8px;
  border: 2px solid var(--border-main);
}

.concepts-section h3,
.code-section h3 {
  margin-top: 0;
  color: var(--accent-yellow);
}

.concepts-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
  margin-top: 15px;
}

.concept-card {
  padding: 12px;
  background: var(--bg-base);
  border-radius: 6px;
  border: 2px solid var(--border-main);
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.concept-card.locked {
  opacity: 0.5;
  cursor: not-allowed;
}

.concept-card.unlocked:hover {
  border-color: var(--accent-yellow);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(250, 204, 21, 0.2);
}

.concept-icon {
  font-size: 2em;
  margin-bottom: 8px;
}

.concept-name {
  font-size: 0.9em;
  font-weight: 600;
  color: var(--text-main);
}

.code-preview {
  background: var(--bg-surface-2);
  padding: 15px;
  border-radius: 6px;
  overflow-x: auto;
  margin: 15px 0;
}

.code-preview pre {
  margin: 0;
  font-family: 'Fira Code', monospace;
  font-size: 0.85em;
  line-height: 1.5;
}

.code-preview code {
  color: var(--accent-cyan);
}

.view-full-code-btn {
  width: 100%;
  padding: 12px;
  background: var(--accent-yellow);
  color: #000;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.view-full-code-btn:hover {
  background: #eab308;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(234, 179, 8, 0.3);
}

@media (max-width: 768px) {
  .knowledge-panel {
    max-width: 100%;
  }

  .concepts-grid {
    grid-template-columns: 1fr;
  }
}
</style>
