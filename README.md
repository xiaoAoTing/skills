# skills

通用 skills 集合，统一管理并可同步到 Cursor IDE。

## 目录结构

```
.
├── sync-skills.sh          # 同步脚本
├── README.md
└── src/
    └── <skill-name>/        # 每个 skill 一个目录
        └── SKILL.md        # skill 定义文件
```

## 使用方法

### 同步 skills 到 Cursor

```bash
./sync-skills.sh
```

该脚本会将 `src/` 目录下的所有 skills 同步到 `~/.cursor/skills-cursor/` 目录。如果 Cursor 中已有同名的 skill，项目中的版本会**覆盖** Cursor 中的版本。

### 添加新的 skill

1. 在 `src/` 下创建对应目录，例如 `src/my-new-skill/`
2. 在该目录下创建 `SKILL.md` 文件
3. 运行 `./sync-skills.sh` 同步到 Cursor

## 已集成的 Skills

| Skill | 说明 |
|-------|------|
| `clean-code-javascript` | JavaScript  clean code 规则，用于代码重构与质量提升 |
| `code-review` | 代码审查技能，提交前检查潜在 bug |


## 参考链接

- 超越上下文，让 Agent Skills 完成你的真正需求（3）Anthropic 官方教你更好的构建Skill https://zhuanlan.zhihu.com/p/2012102105616377451