<template>
  <div class="app-container">
    <AppHeader
      :show-left-sidebar="showLeftSidebar"
      :show-right-sidebar="showRightSidebar"
      @toggle-left-sidebar="showLeftSidebar = !showLeftSidebar"
      @toggle-right-sidebar="showRightSidebar = !showRightSidebar"
    />
    <div v-if="shouldShowOverlay" class="sidebar-overlay active" @click.stop="closeSidebars"></div>
    <div class="main-layout">
      <DayNavigation
        :current-day="currentDay"
        @switch-day="switchDay"
        :class="{
          'hidden': !showLeftSidebar && !isMobile,
          'mobile-visible': isMobile && showLeftSidebar,
          'show': showLeftSidebar && isMobile
        }"
      />

      <DayContent :current-day="currentDay" @switch-day="switchDay" />

      <Sidebar
        :current-day="currentDay"
        :day-progress="progressStore.dayProgress"
        :realtime-data="realtimeData"
        :class="{
          'hidden': !showRightSidebar && !isMobile,
          'mobile-visible': isMobile && showRightSidebar,
          'show': showRightSidebar && isMobile
        }"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useProgressStore } from './stores/progressStore'
import { useCurrentDayRealtimeData } from './composables/useCurrentDayRealtimeData'
import AppHeader from './components/AppHeader.vue'
import DayNavigation from './components/DayNavigation.vue'
import DayContent from './components/DayContent.vue'
import Sidebar from './components/Sidebar.vue'

const progressStore = useProgressStore()

const showLeftSidebar = ref(true)
const showRightSidebar = ref(true)
const currentDay = ref(1)
const isMobile = ref(false)

// 获取当前 day 的 realtimeData
const { realtimeData } = useCurrentDayRealtimeData(currentDay)

const checkMobile = () => {
  const width = window.innerWidth
  const newIsMobile = width <= 1100
  
  // 只在从桌面端切换到移动端时关闭侧边栏
  if (!isMobile.value && newIsMobile) {
    showLeftSidebar.value = false
    showRightSidebar.value = false
  }
  // 只在从移动端切换到桌面端时打开侧边栏
  if (isMobile.value && !newIsMobile) {
    showLeftSidebar.value = true
    showRightSidebar.value = true
  }
  
  isMobile.value = newIsMobile
}

const shouldShowOverlay = computed(() => {
  return isMobile.value && (showLeftSidebar.value || showRightSidebar.value)
})

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})

const switchDay = (day) => {
  currentDay.value = day
}

const closeSidebars = () => {
  showLeftSidebar.value = false
  showRightSidebar.value = false
}
</script>

<style>
.app-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

.main-layout {
  display: flex;
  flex: 1;
  overflow: hidden;
  gap: 20px;
  padding: 20px;
}

.hidden {
  display: none;
}

.sidebar-overlay {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 100;
}

.sidebar-overlay.active {
  display: block;
}

@media (max-width: 1100px) {
  .main-layout {
    position: relative;
  }
}
</style>
