<template>
  <div class="coming-soon-content">
    <div class="coming-soon-card">
      <div class="icon">🚧</div>
      <h2>内容建设中</h2>
      <p class="subtitle">Coming Soon</p>
      <p class="description">
        Day {{ day }} 的内容正在开发中，敬请期待！
      </p>
      <div class="suggestion">
        <p>💡 提示：目前可用的学习内容：</p>
        <div class="available-days">
          <span 
            v-for="d in availableDays" 
            :key="d"
            class="day-tag"
            @click="goToDay(d)"
          >
            Day {{ d }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { dayConfigs } from '@/data/days'

const props = defineProps({
  day: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['switchDay'])

// 可用的天数列表（dayConfigs 是常量，无需使用 computed）
const availableDays = Object.keys(dayConfigs).map(Number).sort((a, b) => a - b)

// 跳转到指定天数
const goToDay = (day) => {
  emit('switchDay', day)
}
</script>

<style scoped>
.coming-soon-content {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
  padding: 20px;
}

.coming-soon-card {
  background: var(--bg-surface-1);
  border: 2px solid var(--border-main);
  border-radius: 12px;
  padding: 40px;
  text-align: center;
  max-width: 500px;
  width: 100%;
}

.icon {
  font-size: 4em;
  margin-bottom: 20px;
}

h2 {
  color: var(--accent-cyan);
  margin: 0 0 10px 0;
  font-size: 1.8em;
}

.subtitle {
  color: var(--text-muted);
  font-size: 1.2em;
  margin: 0 0 20px 0;
  font-style: italic;
}

.description {
  color: var(--text-main);
  font-size: 1.1em;
  margin: 0 0 30px 0;
  line-height: 1.6;
}

.suggestion {
  background: var(--bg-base);
  border-radius: 8px;
  padding: 20px;
  border: 1px solid var(--border-main);
}

.suggestion p {
  color: var(--accent-yellow);
  margin: 0 0 15px 0;
  font-weight: bold;
}

.available-days {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: center;
}

.day-tag {
  background: var(--accent-cyan);
  color: var(--bg-base);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.9em;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.day-tag:hover {
  background: var(--accent-cyan-hover);
  transform: translateY(-2px);
  box-shadow: 0 4px 8px var(--shadow-cyan-4);
}

@media (max-width: 768px) {
  .coming-soon-card {
    padding: 30px 20px;
  }
  
  h2 {
    font-size: 1.5em;
  }
  
  .icon {
    font-size: 3em;
  }
}
</style>
