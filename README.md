# skills

通用 skills 集合，统一管理并可同步到 Cursor / Codex / Qoder / Kiro。

## 目录结构

```
.
├── sync-skills.sh          # 同步脚本（支持交互式选择同步目标）
├── README.md
└── src/
    └── <skill-name>/        # 每个 skill 一个目录
        └── SKILL.md        # skill 定义文件
```

## 使用方法

### 交互式选择同步目标

```bash
./sync-skills.sh
```

运行后会弹出菜单，按数字切换同步目标，回车确认。默认同步到以下四个目录：

- `~/.cursor/skills/`
- `~/.codex/skills`
- `~/.qoder/skills`
- `~/.kiro/skills/`

如果目标中已有同名 skill，项目中的版本会覆盖目标目录中的版本。

### 常用配置

```bash
# 仅同步到 Cursor
SYNC_TO_CODEX=0 SYNC_TO_QODER=0 SYNC_TO_KIRO=0 ./sync-skills.sh

# 仅同步到 Codex
SYNC_TO_CURSOR=0 SYNC_TO_QODER=0 SYNC_TO_KIRO=0 ./sync-skills.sh

# 仅同步到 Qoder
SYNC_TO_CURSOR=0 SYNC_TO_CODEX=0 SYNC_TO_KIRO=0 ./sync-skills.sh

# 仅同步到 Kiro
SYNC_TO_CURSOR=0 SYNC_TO_CODEX=0 SYNC_TO_QODER=0 ./sync-skills.sh

# 自定义 Kiro 目标目录
KIRO_TARGET_DIR="$HOME/.kiro/custom" ./sync-skills.sh

# 禁用彩色输出（重定向或管道输出时也会自动禁用）
NO_COLOR=1 ./sync-skills.sh
```

### 添加新的 skill

1. 在 `src/` 下创建对应目录，例如 `src/my-new-skill/`
2. 在该目录下创建 `SKILL.md` 文件
3. 运行 `./sync-skills.sh` 同步到选定的目标

## 已集成的 Skills

| Skill | 说明 |
|-------|------|
| `atomic-commit` | 将未提交变更按功能拆分为原子 commit，支持 Conventional Commits 规范 |
| `clean-code-javascript` | JavaScript clean code 规则，用于代码重构与质量提升 |
| `code-review` | 代码审查技能，覆盖反馈接收、审查请求和验证门控 |
| `prd` | 生成产品需求文档（PRD），用于功能规划和项目启动 |
| `ralph` | 将 PRD 转换为 Ralph 自主代理系统的 prd.json 格式 |
| `sequential-thinking` | 系统性逐步推理，适用于复杂问题分析与方案设计 |
| `ui-ux-pro-max` | Web/移动端设计指南，含 67 种风格、96 套配色、57 种字体搭配 |
| `universal-api-doc-generator` | 从源代码提取 API 接口信息，生成标准化 Markdown 文档或 OpenAPI 规范 |
| `user-profile` | 了解用户个人习惯、术语和工作风格 |

## 参考链接

- [超越上下文，让 Agent Skills 完成你的真正需求（3）](https://zhuanlan.zhihu.com/p/2012102105616377451)
