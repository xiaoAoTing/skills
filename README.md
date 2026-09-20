# skills

通用 skills 集合，统一管理并可同步到 Cursor / Codex / Qoder / Qoder-CN / Kiro / DeepSeek Harness。

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

运行后会弹出菜单，按数字切换同步目标，回车确认。默认同步到以下目录：

- `~/.cursor/skills/`
- `~/.codex/skills`
- `~/.qoder/skills`
- `~/.qoder-cn/skills`
- `~/.kiro/skills/`
- `$DSH_HOME/skills`（DeepSeek Harness，`DSH_HOME` 缺省为 `~/.dsh`，即 `~/.dsh/skills`）

如果目标中已有同名 skill，项目中的版本会覆盖目标目录中的版本。

### 关于 DeepSeek Harness

DSH 的本地 skill 提供方（`@deepseek-ai/dsh-skill-filesystem`）会扫描 `<dshHome>/skills`，即默认的 `~/.dsh/skills`。因此：

- 同步到该目录后，重启会话（或新建会话）即可在 skill 目录中看到这些 skills；DSH 会监听目录变化，通常无需重启进程。
- 每个 skill 必须是 `<name>/SKILL.md` 目录包，且 `SKILL.md` 的 YAML frontmatter 必须包含 **`name` 和 `description`** 两个字段，`name` 必须为 kebab-case（`^[a-z0-9]+(-[a-z0-9]+)*$`）。缺少 frontmatter 或字段的 skill 会被 DSH 静默忽略（仅记录 warning），不会出现在目录里。
- 如果设置了 `DSH_HOME` 环境变量，脚本会自动把目标定位到 `$DSH_HOME/skills`；也可以显式覆盖：

```bash
DSH_TARGET_DIR="$HOME/custom/dsh-skills" ./sync-skills.sh
```

### 常用配置

```bash
# 非交互式同步到全部目标
SYNC_TO_CURSOR=1 SYNC_TO_CODEX=1 SYNC_TO_QODER=1 SYNC_TO_QODER_CN=1 SYNC_TO_KIRO=1 SYNC_TO_DSH=1 ./sync-skills.sh

# 仅同步到 DeepSeek Harness
SYNC_TO_CURSOR=0 SYNC_TO_CODEX=0 SYNC_TO_QODER=0 SYNC_TO_QODER_CN=0 SYNC_TO_KIRO=0 SYNC_TO_DSH=1 ./sync-skills.sh

# 自定义 DSH 目标目录
DSH_TARGET_DIR="$HOME/.dsh/custom-skills" ./sync-skills.sh

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
