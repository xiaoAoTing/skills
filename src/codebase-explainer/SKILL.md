---
name: codebase-explainer
description: 分析项目代码和业务逻辑，生成一个自包含的 HTML 解释文档，用一张图和精炼的文字讲清"这块逻辑到底怎么跑"。当用户想理解某段代码的业务逻辑、梳理复杂流程、解释某个模块如何工作、或需要可视化代码逻辑时使用。触发词：理解代码、解释逻辑、梳理流程、画个图讲一下、这个怎么工作的、business logic、explain this code、how does this work。
---

# Codebase Explainer

产出一个 HTML 文件，解释内容全部写在里面。

页面的样式、主题切换、目录导航、图表渲染已经写死在 `template.html` 里了。**你只填正文，不要重写模板。**

## 流程

### 1. 读代码

只看和用户问题相关的链路。记下：

- 入口在哪（`file:line`）
- 数据从输入到输出经过哪几步
- 哪些地方不看注释就想不明白

每个结论都要能对到具体行号。没读到的代码不要写。

### 2. 建文件

```bash
cp <本skill目录>/template.html explain-<主题>.html
```

`<本skill目录>` 就是你刚才读到这个 SKILL.md 的目录。找不到就用：

```bash
find . ~/.qoder-cn -maxdepth 6 -path '*codebase-explainer/template.html' 2>/dev/null | head -1
```

### 3. 填正文

两次 Edit 搞定：

- `@@TITLE@@` → 主题
- `@@CONTENT@@` → 正文 HTML（结构见下）

正文骨架：

```html
<h1>{主题}</h1>
<p class="answer">{一句话给答案}</p>

<div class="figure">
  <div class="mermaid">{核心图，写进标签内部}</div>
  <div class="caption">图注：{这张图在讲什么}</div>
</div>

<h2>{小节标题}</h2>
<p>{3-5 句讲清一件事}</p>
<p class="ref">src/foo.ts:42</p>

<div class="callout warn">
  <span class="label">容易踩的坑</span>
  {不看代码绝对猜不到的事}
</div>
```

可用的块：`class="answer"` 结论、`class="figure"` 图、`class="callout info|warn|error"` 提示、`class="ref"` 代码位置、`<pre><code>` 片段、普通 `<table>`。

## 内容规则

**Less is More。** 每句话都要能回答用户问的那个问题，回答不了就删掉。

- 开头一句话说清答案，别铺垫
- 默认一张图。真需要才加第二张
- 不写过渡句和总结句（"下面我们来看"、"综上所述" → 删）
- 不复述代码本身。`if (x > 0)` 不用翻译成"如果 x 大于零"
- 只写读到的事实。"可能"、"大概"、"应该是" → 要么查清楚，要么删掉
- 优先讲**反直觉**和**不看代码猜不到**的东西，那才是这份文档的价值

篇幅参照：简单问题 200 字以内 + 1 图；复杂问题不超过 600 字 + 3 图。写得比这多，通常是废话。

## 画图

需要画图时读 `references/mermaid.md`，里面有防渲染失败的写法约束和单图 15 节点上限。

## 收尾

```bash
open explain-<主题>.html
```

确认：图渲染出来了（不是报错文本）、侧边目录有条目、第一句话能独立回答用户的问题。
