---
name: atomic-commit
description: Automatically split uncommitted workspace changes into multiple atomic commits by functionality, present a commit plan for user confirmation, then execute commits with Conventional Commit messages and push to remote. Use when the user wants to batch commit, split changes into logical commits, clean up a messy working tree, or asks for atomic/structured commits. Triggers on: atomic commit, split commits, batch commit, commit by feature, clean commits, /atomic-commit.
---

# Atomic Commit

将工作区大量未提交的变更按功能拆分为多个原子 commit，梳理计划供用户确认后自动执行 commit + push。

## 工作流程

### Phase 1: 收集变更信息

1. 运行 `git status` 获取所有变更文件（tracked/untracked）
2. 运行 `git diff` 获取已暂存和未暂存的差异
3. 运行 `git diff --cached` 获取已暂存差异
4. 运行 `git log --oneline -10` 了解近期提交风格
5. 对每个变更文件，用 Read 工具阅读 diff 内容，理解其功能归属

### Phase 2: 分析与分组

根据 diff 内容，将变更按功能/模块分组为原子 commit。分组原则：

- **同一功能**的所有文件归为一个 commit（如一个 API 的路由+控制器+测试）
- **独立的重构**单独一个 commit
- **配置变更**（如 package.json、tsconfig）单独或按用途合并
- **删除/重命名**操作与相关功能合并
- 每个 commit 应保持**可独立回滚**的粒度

### Phase 3: 安全检查（每个 commit 组）

对每个分组执行以下检查，任一失败则**阻止该组提交并告知用户**：

#### 防泄密检查

用 Grep 工具扫描分组文件，检测以下模式：

```
# 密钥/凭证模式
(AWS_SECRET|AWS_ACCESS_KEY|PRIVATE_KEY|SECRET_KEY|API_KEY|TOKEN|PASSWORD|CREDENTIALS)
# 环境变量文件
\.env(\.local|\.production|\.staging)?$
# 凭证文件
(id_rsa|\.pem|\.key|credentials\.json|service-account\.json)$
```

匹配到的文件**严禁加入任何 commit**，立即告知用户并从分组中移除。

#### 加密文件识别

脚本能区分**加密后的 .env** 和**明文 .env**，避免误拦安全文件：

**识别为加密（放行）的条件（满足任一即可）：**

- 文件扩展名为 `.enc`、`.age`、`.gpg`、`.sops.json/yaml/env`、`.vault` 等
- 文件内容包含加密标记：`ENC[...]`（sops/dotenv-vault）、`age-encryption.org`、`BEGIN PGP MESSAGE`、`BEGIN AGE ENCRYPTED FILE` 等
- 文件内容包含 dotenvx 标记：`DOTENV_PUBLIC_KEY`、`encrypted:` 前缀的值
- `.env` 文件中无明显 `KEY=value` 明文模式（<30% 行为键值对）

**识别为明文密钥（拦截）的条件：**

- 文件名为 `.env*` 且内容包含大量 `KEY=value` 格式
- 内容匹配密钥模式（`SECRET_KEY=`、`API_KEY=`、`PRIVATE KEY` 等）
- **`.env.keys` 文件**（dotenvx 私钥文件，包含 `DOTENV_PRIVATE_KEY`）— 无论内容格式，始终拦截

使用 `scripts/scan_secrets.sh` 执行检测，输出 `ENCRYPTED_SKIP` 表示加密文件已放行，`SENSITIVE_FILE` 或 `SECRET_CONTENT` 表示已拦截。

#### 破坏性命令禁令

以下参数在任何 git 命令中**绝对禁止使用**：

- `--force` / `-f`（force push）
- `--force-with-lease`（仍属强制推送）
- `reset --hard`
- `--no-verify`（跳过 hooks）
- `--no-gpg-sign`（跳过签名）
- 向 `main`/`master` 分支的 `push --force`

#### Hook 失败处理

若 `git commit` 因 pre-commit hook 失败：

1. **不 amend**，不跳过 hook
2. 分析 hook 报错信息
3. 修复代码问题
4. 创建**新的 commit**（非 amend）

### Phase 4: 生成 Commit 计划

将分组结果以表格形式呈现给用户确认：

```markdown
## Commit 计划

| # | 类型 | 范围(scope) | 描述 | 文件数 | 文件列表 |
|---|------|------------|------|--------|---------|
| 1 | feat | auth       | add JWT login support | 3 | src/auth/jwt.ts, src/auth/login.ts, tests/auth.test.ts |
| 2 | fix  | api        | handle null response in user endpoint | 1 | src/api/user.ts |
| 3 | refactor | utils  | extract date formatting to helper | 2 | src/utils/date.ts, src/components/Header.tsx |
| 4 | docs | -          | update README with setup instructions | 1 | README.md |

### Breaking Changes
- Commit #1: 认证接口从 session 迁移到 JWT，需要更新客户端请求头

### 安全警告
- 已跳过 .env.local（包含敏感凭证）
```

**等待用户确认后才执行。** 用户可以：
- 确认全部
- 要求调整分组
- 跳过某些 commit
- 修改 commit message

### Phase 5: 执行提交

用户确认后，按以下顺序执行每个 commit：

```bash
# 1. 暂存该组文件（逐个指定，不用 git add -A / git add .）
git add <file1> <file2> <file3>

# 2. 提交（使用 HEREDOC 保证格式）
git commit -m "<type>(<scope>): <description>"

# 3. 若失败（hook 报错），修复后创建新 commit，不 amend
```

### Phase 6: 推送远程

所有 commit 完成后：

```bash
# 普通推送，禁止 force
git push
```

若当前分支无上游分支，使用 `git push -u <remote> <branch>`。

推送前**确认目标分支不是 main/master 的 force push**。

## Conventional Commits 规范

### 类型表

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(auth): add OAuth2 login` |
| `fix` | 修复缺陷 | `fix(api): handle null response` |
| `refactor` | 重构（不改变行为） | `refactor(utils): extract date helper` |
| `docs` | 文档变更 | `docs: update README setup guide` |
| `test` | 测试相关 | `test(auth): add JWT unit tests` |
| `chore` | 构建/工具/依赖 | `chore: upgrade typescript to 5.4` |
| `perf` | 性能优化 | `perf(query): add index for user lookup` |
| `ci` | CI/CD 配置 | `ci: add Node 20 to test matrix` |
| `build` | 构建系统 | `build: switch to pnpm workspace` |
| `revert` | 回退提交 | `revert: feat(auth): add OAuth2 login` |
| `style` | 格式调整（不影响逻辑） | `style: fix eslint warnings` |

### Breaking Changes 标注

两种方式：

1. **类型后加 `!`**：`feat!: migrate auth from session to JWT`
2. **Footer 说明**（推荐用于详细描述）：

```
feat(auth): migrate to JWT authentication

Migrate session-based auth to JWT tokens for stateless API.

BREAKING CHANGE: Client must send Authorization header with Bearer token.
Session cookie is no longer supported.
```

### Scope 推断规则

- 从文件路径推断：`src/auth/...` → scope 为 `auth`
- 跨模块变更：省略 scope 或使用最上层的模块名
- 全局配置变更：省略 scope（如 `chore: upgrade dependencies`）

## Commit Message 语言

- **优先匹配用户当前对话语言**：根据用户本次会话中使用的语言来决定 commit message 语言
- 若用户用中文交流，commit message 使用中文
- 若用户用英文交流，commit message 使用英文
- 若无法判断用户语言，默认使用中文
- 可参考近期 `git log` 中的 commit 语言作为辅助，但对话语言优先级更高

## 注意事项

- 绝不使用 `git add -A` 或 `git add .`，始终逐个指定文件
- 绝不修改 git config
- 每个 commit 必须是可独立理解和回滚的
- 推送前再次确认没有包含敏感文件
