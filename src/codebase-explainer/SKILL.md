---
name: codebase-explainer
description: 分析项目代码和业务逻辑，生成易于理解的 HTML 解释文档，包含 Mermaid 图表和可视化流程。当用户想要理解项目中某部分代码的业务逻辑、梳理复杂流程、解释某个模块如何工作、或需要可视化代码逻辑时使用。触发词：理解代码、解释逻辑、梳理流程、这个怎么工作的、business logic、explain this code、how does this work。
---

# Codebase Explainer

将项目中的业务逻辑转化为清晰易懂的 HTML 解释文档，配合 Mermaid 图表帮助理解。

## 工作流程

### 1. 定位与阅读代码

根据用户指定的模块、文件或功能，深入阅读所有相关代码：

- 从入口点开始，追踪完整调用链
- 读取所有相关文件：路由、控制器、服务、模型、中间件、工具函数
- 识别外部依赖：API 调用、数据库操作、消息队列、缓存
- 注意边界条件和异常处理逻辑

### 2. 分析业务逻辑

梳理出完整的业务逻辑链条：

- 核心流程的主线步骤
- 每个分支决策的条件和原因
- 数据在各环节的变换过程
- 错误处理和回退机制

### 3. 生成 HTML 文件

在项目根目录生成 `explain-{模块名}.html`，要求：

- **自包含**：所有 CSS 内联，Mermaid 通过 CDN 引入
- **中文**：所有说明文字使用中文
- **基于事实**：只解释代码中实际存在的逻辑，不猜测

#### HTML 结构

```html
<!DOCTYPE html>
<html lang="zh-CN" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{模块名} - 业务逻辑解析</title>
  <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js" crossorigin="anonymous"></script>
  <style>
    /* ===== Notion 风格 CSS 变量 ===== */
    /* 亮色主题（默认） */
    :root, [data-theme="light"] {
      --bg-primary: #ffffff;
      --bg-secondary: #f7f6f3;
      --bg-tertiary: #f1f1ef;
      --bg-hover: #efefee;
      --bg-code: #f7f6f3;
      --text-primary: #37352f;
      --text-secondary: #6b6b6b;
      --text-tertiary: #9b9a97;
      --border-color: #e8e7e4;
      --border-light: #f0efec;
      --accent-blue: #2383e2;
      --accent-red: #eb5757;
      --accent-green: #0f7b6c;
      --accent-yellow: #d9730d;
      --accent-purple: #6940a5;
      --shadow-sm: 0 1px 2px rgba(0,0,0,0.04);
      --shadow-md: 0 4px 12px rgba(0,0,0,0.08);
      --callout-bg: #f7f6f3;
      --callout-info: #e8f0fe;
      --callout-warn: #fef7e0;
      --callout-error: #fde7e7;
      --modal-bg: rgba(15,15,15,0.6);
      --modal-content-bg: #ffffff;
    }
    /* 暗色主题 */
    [data-theme="dark"] {
      --bg-primary: #191919;
      --bg-secondary: #202020;
      --bg-tertiary: #2f2f2f;
      --bg-hover: #383838;
      --bg-code: #2f2f2f;
      --text-primary: #e8e8e3;
      --text-secondary: #9b9b9b;
      --text-tertiary: #6b6b6b;
      --border-color: #383838;
      --border-light: #2f2f2f;
      --accent-blue: #529cca;
      --accent-red: #ff7369;
      --accent-green: #4dab9a;
      --accent-yellow: #ffa344;
      --accent-purple: #9a6dd7;
      --shadow-sm: 0 1px 2px rgba(0,0,0,0.2);
      --shadow-md: 0 4px 12px rgba(0,0,0,0.4);
      --callout-bg: #2f2f2f;
      --callout-info: #1a2a3a;
      --callout-warn: #2a2510;
      --callout-error: #2a1515;
      --modal-bg: rgba(0,0,0,0.75);
      --modal-content-bg: #202020;
    }

    /* ===== 全局 Notion 风格基础样式 ===== */
    /* 字体：-apple-system, "Segoe UI", sans-serif；行高 1.6；字重 400/600 */
    /* body: var(--bg-primary) 背景，var(--text-primary) 文字，过渡 transition: background 0.2s, color 0.2s */
    /* 最大内容宽度 900px 居中（Notion 风格窄列），图表区域可更宽 */

    /* ===== 主题切换按钮 ===== */
    /* 固定在右上角，圆形按钮，亮色时显示🌙，暗色时显示☀️ */
    /* 使用 localStorage 记住用户选择 */

    /* ===== Notion 风格组件 ===== */
    /* 标题：h1 30px bold，h2 24px semibold，h3 20px semibold，无装饰，干净 */
    /* 段落：间距宽松，段前 0.5em 段后 0.5em */
    /* Callout 块：左侧彩色竖线 + 浅背景色，类似 Notion 的 callout block */
    /* 代码块：var(--bg-code) 背景，圆角 4px，Notion 风格等宽字体 */
    /* 行内代码：浅灰背景，圆角 3px，padding 2px 5px */
    /* 表格：简洁边框，表头浅灰背景，无多余装饰 */
    /* 列表：标准缩进，marker 颜色用 var(--text-tertiary) */

    /* ===== 大纲导航（Notion 风格侧边栏） ===== */
    /* 左侧 sticky，窄列 220px，字体 14px，行间距紧凑 */
    /* 当前章节高亮用 var(--accent-blue) 左侧竖线 */
    /* 悬停时 var(--bg-hover) 背景 */

    /* ===== 图表容器 ===== */
    /* .mermaid 容器 width: 100%，不设 max-width */
    /* .mermaid svg min-width: 100%，height: auto */
    /* cursor: pointer，hover 时轻微 box-shadow 提示可点击 */

    /* ===== 全屏遮罩层 ===== */
    /* .diagram-modal: fixed 全屏，var(--modal-bg) 背景 */
    /* .modal-content: var(--modal-content-bg)，圆角 8px，max-width: 95vw，max-height: 90vh，overflow: auto */
    /* 支持滚轮缩放和拖拽平移 */
  </style>
</head>
<body>
  <!-- 主题切换按钮（固定右上角） -->
  <button class="theme-toggle" id="themeToggle" aria-label="切换主题">
    <span class="theme-icon-light">🌙</span>
    <span class="theme-icon-dark">☀️</span>
  </button>

  <!-- 大纲导航：Notion 风格左侧 sticky sidebar -->
  <!-- 概述：一句话说清楚这个模块做什么 -->
  <!-- 核心流程：分步骤拆解，每步配代码位置 -->
  <!-- 流程图：Mermaid flowchart/sequence/state 等 -->
  <!-- 数据流向：输入什么、怎么变、输出什么 -->
  <!-- 关键决策点：为什么这样设计、有哪些分支 -->

  <!-- 图表全屏遮罩（一个即可，所有图表共用） -->
  <div class="diagram-modal" id="diagramModal">
    <div class="modal-close">&times;</div>
    <div class="modal-content" id="modalContent"></div>
  </div>

  <script>
    // ===== 主题切换逻辑 =====
    // 1. 初始化时从 localStorage 读取主题，无记录则默认 'light'
    // 2. 设置 document.documentElement.dataset.theme
    // 3. 点击按钮切换主题，更新 localStorage 和 Mermaid 主题
    // 4. 切换后需重新渲染 Mermaid 图表（light 用 'default' 主题，dark 用 'dark' 主题）

    // ===== 图表交互逻辑 =====
    // 1. 点击任意 .mermaid 图表 → 克隆其 SVG 到 modal 中展示
    // 2. modal 中支持：鼠标滚轮缩放（transform: scale）、拖拽平移
    // 3. 关闭方式：点击 × 按钮、点击遮罩空白区域、按 Esc 键
    // 4. 缩放范围：0.5x ~ 5x，初始适配容器大小
  </script>
</body>
</html>
```

#### 大纲导航

每个章节标题使用带 `id` 的标题标签（`<h2 id="...">`），大纲区域生成对应的锚点链接列表：

- 大纲固定在页面左侧（sticky sidebar）或顶部，滚动时始终可见
- 点击大纲项平滑滚动到对应章节
- 当前浏览章节在大纲中高亮显示（可用 IntersectionObserver 实现）
- 章节层级与大纲层级一致（H2 为一级，H3 为缩进子项）
- 移动端大纲可折叠或放到顶部下拉菜单

#### 样式要求

整体视觉风格模仿 Notion 的页面设计，遵循以下原则：

- **Notion 风格排版**：使用 `-apple-system, "Segoe UI", Helvetica, "PingFang SC", sans-serif` 字体栈；行高 1.6；内容区域最大宽度 900px 居中，营造阅读舒适感
- **Notion 风格配色**：严格使用上方 CSS 变量体系，亮色主题以 `#ffffff` / `#f7f6f3` / `#37352f` 为主色调，暗色主题以 `#191919` / `#202020` / `#e8e8e3` 为主色调
- **Notion 风格组件**：
  - Callout 块：左侧 3px 彩色竖线 + 浅色背景，用于提示信息（info 蓝色、warn 黄色、error 红色）
  - 代码块：`var(--bg-code)` 背景，`border-radius: 4px`，等宽字体 `"SFMono-Regular", Menlo, Consolas, monospace`
  - 行内代码：浅灰背景，`border-radius: 3px`，`padding: 2px 5px`，`font-size: 0.9em`
  - 表格：`var(--border-color)` 细边框，表头 `var(--bg-secondary)` 背景，无多余装饰
- **亮/暗主题切换**：页面右上角固定主题切换按钮（亮色显示 🌙，暗色显示 ☀️），使用 `localStorage` 记忆用户选择，默认亮色主题。切换时同步更新 Mermaid 图表主题（亮色 `'default'`，暗色 `'dark'`）
- **响应式布局**：移动端大纲折叠到顶部，内容区域全宽
- 图表区域有足够留白，不拥挤
- 关键概念用 `var(--accent-*)` 颜色突出
- **图表默认大尺寸展示**：Mermaid 容器宽度 100%，不设 max-width 上限
- **点击放大交互**：点击任意图表弹出全屏遮罩层展示放大视图，支持鼠标滚轮缩放（0.5x~5x）和拖拽平移，按 Esc / 点击遮罩 / 点击 × 关闭

### 4. 选择合适的图表类型

根据逻辑特征选择最合适的 Mermaid 图表：

| 逻辑类型 | 图表类型 | Mermaid 语法 |
|---------|---------|-------------|
| 决策分支流程 | 流程图 | `flowchart TD` |
| 多服务/组件交互 | 时序图 | `sequenceDiagram` |
| 状态变化生命周期 | 状态图 | `stateDiagram-v2` |
| 数据模型关系 | ER 图 | `erDiagram` |
| 对象继承关系 | 类图 | `classDiagram` |
| 多步骤线性流程 | 甘特图 | `gantt` |

一个模块可以包含多个不同类型的图表，选择最能清晰表达逻辑的类型。

### 5. 图表规范

- 节点文字简洁，不超过 15 个字
- 复杂流程拆分为多个小图表，每个聚焦一个子流程
- 用 subgraph 对相关步骤分组
- 关键路径用颜色标注（红色=关键/异常，绿色=正常/成功）
- 在图表下方添加文字说明，解释图表展示的内容

#### Mermaid 初始化配置

在 `<script>` 中初始化 Mermaid 时，根据当前主题动态设置 Mermaid 主题，并提供重新渲染函数以支持主题切换：

```javascript
// 根据当前页面主题返回对应的 Mermaid 主题名
function getMermaidTheme() {
  return document.documentElement.dataset.theme === 'dark' ? 'dark' : 'default';
}

// 初始化 Mermaid
function initMermaid() {
  mermaid.initialize({
    startOnLoad: false,
    theme: getMermaidTheme(),
    securityLevel: 'loose',
    flowchart: { useMaxWidth: false, htmlLabels: true, padding: 20 },
    sequence: { useMaxWidth: false, diagramMarginX: 50, diagramMarginY: 10 },
    timeline: { useMaxWidth: false },
    gantt: { useMaxWidth: false }
  });
}

// 主题切换时重新渲染所有图表
async function rerenderMermaid() {
  initMermaid();
  const diagrams = document.querySelectorAll('.mermaid');
  for (const el of diagrams) {
    const graphDef = el.getAttribute('data-graph') || el.textContent;
    el.removeAttribute('data-processed');
    el.innerHTML = '';
    const { svg } = await mermaid.render(`mermaid-${Date.now()}-${Math.random()}`, graphDef);
    el.innerHTML = svg;
  }
}
```

关键配置说明：
- `startOnLoad: false`：手动控制渲染时机，确保主题切换后能重新渲染
- `theme`：根据当前页面主题动态选择 `'default'`（亮色）或 `'dark'`（暗色）
- `useMaxWidth: false`：禁用最大宽度限制，让图表按内容自然撑满容器
- `securityLevel: 'loose'`：允许 SVG 中的点击事件等交互行为
- `padding: 20`：给流程图节点增加内边距，视觉上更舒适

#### 图表交互要求

每个 `.mermaid` 图表容器必须具备以下交互能力：

1. **默认大尺寸**：容器 `width: 100%`，无 `max-width` 限制，SVG 自然撑满
2. **点击放大**：点击图表弹出全屏 modal，克隆 SVG 到 modal 中展示
3. **滚轮缩放**：modal 中支持鼠标滚轮缩放，范围 0.5x ~ 5x
4. **拖拽平移**：缩放后支持鼠标拖拽移动图表位置
5. **关闭方式**：× 按钮、点击遮罩空白区域、按 Esc 键均可关闭
6. **移动端**：双指缩放替代滚轮缩放，单指滑动替代拖拽

## 质量标准

- 不懂代码的人能看懂整体流程
- 懂代码的人能对照图表快速定位代码
- 所有图表正确渲染，无语法错误
- 文件自包含，打开即用，无外部依赖（Mermaid CDN 除外）
