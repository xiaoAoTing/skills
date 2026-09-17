# Mermaid 速查

只在要画图时读这个文件。

## 选图类型

| 你想讲的东西 | 用这个 | 开头 |
|---|---|---|
| 流程 / 决策分支 | 流程图 | `flowchart TD` |
| 多方来回调用 | 时序图 | `sequenceDiagram` |
| 状态机 / 生命周期 | 状态图 | `stateDiagram-v2` |
| 表关系 / 数据模型 | ER 图 | `erDiagram` |
| 类 / 模块继承依赖 | 类图 | `classDiagram` |

拿不准就用 `flowchart TD`，它几乎不会写错。

## 不会渲染失败的写法

- 节点 ID 只用字母数字下划线：`a1`、`step_2`、`auth_ok`
- 显示文字一律用 `["..."]` 包起来：`a1["用户提交表单"]`
- 文字里不要出现 `()`、`{}`、`:`、`"`、`#`、`%%` —— 会直接解析失败，要表达就换成中文标点或改写
- 连线文字用 `|...|`：`a1 -->|校验通过| a2`
- subgraph 必须配对 `end`
- 高亮关键节点：`style a1 fill:#0f7b6c,color:#fff`

```
flowchart TD
    a1["用户请求"] --> a2{"权限校验"}
    a2 -->|通过| a3["写入数据库"]
    a2 -->|拒绝| a4["返回 403"]
    a3 --> a5["发出事件"]
    style a3 fill:#0f7b6c,color:#fff
```

## 复杂度

一张图最多 15 个节点。超了就拆：

1. 画一张总览图，把子流程压成单个节点
2. 每个子流程单独一张图

宁可三张清楚的小图，不要一张糊的大图。

## 时序图特有注意

```
sequenceDiagram
    participant U as 用户
    participant A as API
    U->>A: POST /login
    A-->>U: 200 + token
```

`participant X as 显示名` 先声明再用；`->>` 实线、`-->>` 虚线。冒号后的文字同样别带括号。
