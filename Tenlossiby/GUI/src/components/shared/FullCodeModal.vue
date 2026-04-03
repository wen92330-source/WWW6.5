<template>
  <Teleport to="body">
    <div v-if="show" class="full-code-modal" @click.self="close">
      <div class="full-code-modal-content">
        <h3>📝 {{ title }}</h3>
        <div class="full-code-container">
          <pre>{{ code }}</pre>
        </div>
        <button class="close-btn" @click="close">
          🔙 返回知识解释
        </button>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: '完整代码'
  },
  code: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['close'])

const close = () => {
  emit('close')
}
</script>

<style scoped>
.full-code-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  overflow-y: auto;
}

.full-code-modal-content {
  background: var(--bg-surface-1);
  border-radius: 8px;
  padding: 20px;
  max-width: 900px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  border: 1px solid var(--border-main);
  animation: slideIn 0.3s ease;
}

.full-code-modal-content h3 {
  color: var(--accent-yellow);
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.full-code-container {
  background: var(--code-bg);
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  overflow-x: auto;
  border: 1px solid var(--code-border);
}

.full-code-container pre {
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
  line-height: 1.6;
  color: var(--text-muted);
  white-space: pre-wrap;
  word-break: break-word;
  margin: 0;
  animation: codeReveal 0.3s ease;
}

.close-btn {
  width: 100%;
  padding: 12px 20px;
  background: var(--accent-cyan);
  color: var(--bg-base);
  border: none;
  border-radius: 6px;
  font-size: 1em;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: var(--accent-cyan-hover);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px var(--shadow-cyan-4);
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes codeReveal {
  from {
    opacity: 0.5;
  }
  to {
    opacity: 1;
  }
}
</style>
