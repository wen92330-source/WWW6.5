# 🌟 Solidity 每日学习记录与 GUI 可视化界面

欢迎来到我的 Solidity 学习仓库！这里不仅存放着我每日的 Solidity 智能合约实战作业，更包含了一个为了更直观体验智能合约运行效果而制作的**可视化界面 (GUI)**。

无论你是有经验的开发者，还是对 Web3 完全零基础的小白，都可以通过这个界面轻松点点按按，感受智能合约的神奇魅力！✨

***

## 💡 产品理念：为 Web3 小白打造零门槛学习体验

### 🎯 用户痛点

在 Web3 学习社群中，我们发现大量**零基础小白**面临以下困境：

- **代码门槛高**：Solidity 智能合约代码对非技术背景用户来说晦涩难懂
- **环境配置复杂**：想要体验合约交互，需要安装 MetaMask、配置测试网、获取测试币，步骤繁琐
- **缺乏即时反馈**：学习过程中无法直观看到操作结果，难以建立信心
- **学习资源分散**：概念解释、代码示例、实际运行效果分布在不同地方

### ✨ 产品解决方案

基于以上用户需求，我们开发了这个**一站式 Solidity 学习 GUI**：

| 用户需求  | 产品功能                                            |
| ----- | ----------------------------------------------- |
| 看不懂代码 | 🎮 **可视化交互界面** - 将合约功能封装成按钮和输入框，像玩网页游戏一样操作      |
| 环境配置难 | 🚀 **零安装即开即用** - 无需钱包、无需测试币，浏览器打开就能体验           |
| 缺乏反馈  | 📊 **实时状态展示** - 每次点击立即看到合约状态变化，直观理解运行逻辑         |
| 概念难懂  | 🧩 **渐进式知识解锁** - 交互过程中逐步解锁 Solidity 概念，配合代码片段讲解 |
| 学习枯燥  | 🏆 **游戏化进度追踪** - 完成度百分比、解锁徽章、每日挑战，增加学习动力        |

### 🌈 核心产品特性

- **🎓 30天渐进式学习路径**：从最简单的点击计数器到复杂的借贷系统，难度循序渐进
- **🔄 双向学习模式**：既可以通过 GUI 操作理解合约逻辑，也可以查看完整源码学习语法
- **🌙 贴心护眼设计**：支持日间/夜间模式切换，长时间学习不疲劳
- **📱 响应式布局**：支持桌面和移动设备，随时随地都能学习

***

## 🎮 面向小白的 GUI 操作指南（最简单，免安装！）

为了让大家能最快、最无痛地体验这些智能合约，我已经把 GUI 网站部署到了网上。

**你不需要了解任何代码，也不需要安装任何复杂的环境！**

### 🎈 只需要两步体验：

1. **🚀 点击直接访问：**
   打开浏览器，点击以下链接即可直接进入我的可视化操作界面：
   👉 **<https://tenlossiby.github.io/WWW6.5/>**
2. **🖱️ 尽情点按探索：**
   - 在网页左侧，你可以看到我每天学习所对应的各种功能模块（例如：点击计数器、拍卖行、储蓄罐等）。
   - 点击任意一个模块，右侧区域就会展示对应的操作面板。
   - 你可以像玩普通网页小游戏一样，输入数字、点击按钮，观察界面的变化。这就是智能合约在"后台"运行的结果展现！

***

## 🏗️ 产品技术架构（20260312重构）

### 前端技术栈

```
┌─────────────────────────────────────────────────────────────┐
│                    前端技术架构                              │
├─────────────────────────────────────────────────────────────┤
│  UI 框架      │  Vue 3 (Composition API)                    │
│  状态管理     │  Pinia (现代化状态管理)                      │
│  构建工具     │  Vite 5 (极速开发体验)                       │
│  样式方案     │  CSS Variables (主题系统)                    │
│  部署方式     │  GitHub Pages (静态托管)                     │
└─────────────────────────────────────────────────────────────┘
```

### 核心模块设计（20260312重构）

| 模块                     | 职责     | 技术亮点                   |
| ---------------------- | ------ | ---------------------- |
| **App.vue**            | 应用布局容器 | 响应式布局、侧边栏控制            |
| **AppHeader.vue**      | 顶部导航   | 主题切换、响应式布局             |
| **DayNavigation.vue**  | 课程导航   | 30天学习路径、正序/倒序切换        |
| **DayContent.vue**     | 交互主面板  | **动态导入**、ComingSoon 提示 |
| **Sidebar.vue**        | 进度侧边栏  | 实时数据展示、操作日志            |
| **KnowledgePanel.vue** | 知识面板   | 共享组件、概念解锁展示            |
| **contractStore.js**   | 合约状态管理 | Pinia Store、响应式状态      |
| **progressStore.js**   | 学习进度管理 | **自动计算 totalConcepts** |
| **concepts.js**        | 知识库    | 30+ Solidity 概念定义      |
| **days.js**            | 课程配置   | 每日合约配置、核心配置源           |

### 状态管理架构（20260312重构）

使用 **Pinia** 替代原来的集中式状态管理：

```javascript
// contractStore.js - 合约状态管理
contracts: {
  day1: { count, interactionCount },
  day2: { name, bio, hasStored, hasRetrieved },
  day3: { candidates, voteCount },
  ...
}

// progressStore.js - 学习进度（自动从 dayConfigs 生成）
dayProgress: {
  1: { unlockedConcepts: [], totalConcepts: 4, interactionCount: 0 },
  2: { unlockedConcepts: [], totalConcepts: 6, interactionCount: 0 },
  // ... 自动计算，无需硬编码
}
```

### 组件架构（20260312重构）

**动态导入**: 使用 `defineAsyncComponent` 实现按需加载

```javascript
// DayContent.vue
const dayComponents = {
  1: defineAsyncComponent(() => import('./days/Day1/ClickCounter.vue')),
  2: defineAsyncComponent(() => import('./days/Day2/SaveMyName.vue')),
  // ... 按需加载，减少首屏体积
}
```

**共享组件**: 提取公共逻辑到 shared 目录

- `KnowledgePanel.vue` - 知识面板（右栏）
- `FullCodeModal.vue` - 完整代码弹窗
- `ComingSoon.vue` - 未开发天数提示

### 主题系统设计

```css
/* CSS Variables 主题方案 */
:root {
  --bg-base: #fdf6e3;           /* 背景色 */
  --bg-surface-1: #eee8d5;      /* 卡片背景 */
  --text-main: #657b83;         /* 主文字 */
  --accent-yellow: #b58900;     /* 强调色 */
  --accent-cyan: #2aa198;       /* 交互色 */
  /* ... 更多变量 */
}

[data-theme="dark"] {
  --bg-base: #002b36;
  --bg-surface-1: #073642;
  /* ... 暗色主题覆盖 */
}
```

### 全局样式系统

**按钮样式**（统一在 main.css 中定义）：

```html
<button class="day-action-btn cyan">按钮</button>
<button class="day-action-btn green">按钮</button>
<button class="day-action-btn red small">小按钮</button>
```

可用颜色：blue, yellow, orange, green, magenta, cyan, red

***

## � 项目结构

```
Tenlossiby/
├── GUI/                          # 可视化界面代码
│   ├── src/
│   │   ├── components/
│   │   │   ├── days/             # 各Day组件
│   │   │   │   ├── Day1/ClickCounter.vue
│   │   │   │   ├── Day2/SaveMyName.vue
│   │   │   │   └── ...
│   │   │   ├── shared/           # 共享组件
│   │   │   │   ├── ComingSoon.vue
│   │   │   │   ├── FullCodeModal.vue
│   │   │   │   └── KnowledgePanel.vue
│   │   │   ├── AppHeader.vue
│   │   │   ├── DayContent.vue
│   │   │   ├── DayNavigation.vue
│   │   │   └── Sidebar.vue
│   │   ├── composables/          # 组合式函数
│   │   │   ├── useDay1.js
│   │   │   └── ...
│   │   ├── stores/               # Pinia 状态管理
│   │   │   ├── contractStore.js
│   │   │   └── progressStore.js
│   │   ├── data/
│   │   │   ├── concepts.js       # 概念定义
│   │   │   └── days.js           # 日程配置
│   │   ├── styles/
│   │   │   └── main.css          # 全局样式
│   │   └── App.vue
│   ├── AI_PROMPT_GUIDE.md        # AI开发指南
│   └── skill.md                  # 开发Skill文档
│
├── day1-ClickCounter.sol         # Solidity 合约源码
├── day2-SaveMyName.sol
├── day3-PollStation.sol
└── ...                           # 更多合约文件
```

***

## 🚀 本地开发

如果你想在本地运行或修改这个项目：

```bash
# 进入 GUI 目录
cd GUI

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build
```

***

## �� 关于这个仓库的内容

除了上面好玩的 GUI 界面，这个仓库的核心其实是我的 Solidity 智能合约代码作业：

- **GUI 文件夹**：包含了上述可视化界面的全部前端代码（基于 Vue 3 + Pinia + Vite）。
- **dayX-xxx.sol 结尾的文件**：这些是我每天完成的 Solidity 智能合约作业源码。它们也是 GUI 界面背后真正运行逻辑的"大脑"。

***

## 📝 重构记录

本项目经历了完整的重构优化：

1. **状态管理重构**：从 App.vue 集中式状态迁移到 Pinia Store
2. **组件架构重构**：提取共享组件，使用动态导入
3. **样式重构**：统一按钮样式，保留各 Day 独特配色
4. **维护性优化**：自动计算 totalConcepts，减少硬编码

详细重构内容请参考 `GUI/skill.md`。

***

欢迎大家多点点我的 GUI 界面，如果你觉得这个项目对你有帮助或者觉得挺好玩，欢迎给我点一个 ⭐️ **Star** 鼓励一下哦！
