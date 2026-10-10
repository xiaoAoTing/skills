# Agent 指南

## 仓库用途

这是一个 **skills 集合仓库**，用于统一管理和维护 AI agent skills。所有 skills 通过 `sync-skills.sh` 脚本同步到多个目标工具：

- Cursor (`~/.cursor/skills/`)
- Codex (`~/.codex/skills`)
- Qoder (`~/.qoder/skills`)
- Qoder-CN (`~/.qoder-cn/skills`)
- Kiro (`~/.kiro/skills/`)
- DeepSeek Harness (`$DSH_HOME/skills`)

## 修改范围

### ✅ 应该修改的

**`src/` 目录下的 skills**

这是唯一需要修改的地方。每个 skill 是一个独立目录：

```
src/
└── <skill-name>/
    ├── SKILL.md          # skill 定义文件（必须）
    └── references/       # 参考文档（可选）
```

### ❌ 不应该修改的

- **同步目标目录**（如 `~/.cursor/skills/`、`~/.qoder/skills` 等）——这些是自动生成的，修改会被覆盖
- **其他项目目录**——除非明确要求，不要修改此仓库之外的文件

## 常见操作

### 添加新 skill

1. 在 `src/` 下创建目录：`src/my-new-skill/`
2. 创建 `SKILL.md` 文件，包含 YAML frontmatter（必须包含 `name` 和 `description`）
3. 运行 `./sync-skills.sh` 同步到目标工具

### 修改现有 skill

直接编辑 `src/<skill-name>/SKILL.md` 或相关文件，然后运行同步脚本。

### 同步 skills

```bash
./sync-skills.sh  # 交互式选择同步目标
```

## SKILL.md 格式要求

```yaml
---
name: skill-name-kebab-case
description: 简短描述这个 skill 的用途
---

# Skill 内容

详细的 skill 指令和说明...
```

- `name` 必须是 kebab-case（`^[a-z0-9]+(-[a-z0-9]+)*$`）
- `name` 和 `description` 都是必填字段
- 缺少 frontmatter 的 skill 会被某些工具（如 DeepSeek Harness）忽略

## 注意事项

1. **只修改 `src/` 目录**——这是所有变更的源头
2. **同步是单向的**——从这个仓库同步到目标，反向修改会丢失
3. **测试后再同步**——确保 SKILL.md 格式正确，避免同步后不生效
