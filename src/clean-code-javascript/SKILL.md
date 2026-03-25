---
name: clean-code-javascript
description: 优化 JavaScript 代码，依据 clean-code-javascript 所定义的规则。用于代码重构、提升可读性、减少复杂度、遵循最佳实践。当用户要求优化 JS 代码、重构、提升代码质量或提及 clean code 时自动应用。
---

# Clean Code JavaScript 优化指南

依据 [clean-code-javascript](https://github.com/ryanmcdermott/clean-code-javascript) 原则优化 JavaScript 代码。

## 核心原则（模块化参考）

| 编号 | 原则 | 参考文件 |
|------|------|----------|
| 1 | 变量命名 | `references/01-naming.md` |
| 2 | 函数原则 | `references/02-functions.md` |
| 3 | 条件语句 | `references/03-conditions.md` |
| 4 | 对象和数据结构 | `references/04-objects.md` |
| 5 | 类和构造函数 | `references/05-classes.md` |
| 6 | 异步 | `references/06-async.md` |
| 7 | 错误处理 | `references/07-error-handling.md` |
| 8 | 注释 | `references/08-comments.md` |
| 9 | 避免过早抽象 | `references/09-premature-abstraction.md` |
| 10 | 避免深层嵌套 | `references/10-nesting.md` |
| 11 | DRY 原则 | `references/11-dry.md` |

## 快速检查清单

优化代码时，快速检查以下各项：

- [ ] 变量名是否清晰、有意义
- [ ] 函数是否只做一件事
- [ ] 函数参数是否过多（>3）
- [ ] 是否有深层嵌套（>2 层）
- [ ] 是否有重复代码
- [ ] 是否使用了魔法数字/字符串
- [ ] 是否有副作用
- [ ] 错误处理是否完善
- [ ] 是否使用了现代语法（ES6+）
- [ ] 注释是否必要且清晰

详细检查清单：`references/checklist.md`

## 优化流程

1. **分析代码**：理解代码的功能和意图
2. **识别问题**：对照检查清单找出问题
3. **重构代码**：应用 clean code 原则
4. **验证功能**：确保重构后功能不变
5. **审查改进**：检查是否还有优化空间

详细流程：`references/flow.md`

## 参考资源

- [clean-code-javascript](https://github.com/ryanmcdermott/clean-code-javascript) - 完整的 clean code JavaScript 指南
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript) - Airbnb 的 JavaScript 风格指南

完整资源列表：`references/resources.md`
