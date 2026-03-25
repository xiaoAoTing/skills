---
name: user-profile
description: 了解用户个人习惯、术语和工作风格。当用户提到个人偏好、特殊术语、或希望 AI 理解其个人习惯时使用此技能。
---

# 用户Profile

记录用户的个人习惯、术语和工作风格，供 AI 更好地理解用户。

## 术语表

### 页面级组件

**背景**: 用户在开发 Vue 组件时，会将组件拆分为不同层级。

**定义**: 相对于全局组件，页面级组件是指只在当前页面使用的组件。

**存放位置**: `src/views/{页面名称}/components/` 目录下

**示例结构**:
```
src/
├── components/          # 全局组件
│   └── Button.vue
└── views/
    └── user/
        ├── UserList.vue
        └── components/  # 页面级组件（仅 UserList 使用）
            └── UserCard.vue
```

---

## 开发习惯

（待补充）

## 代码风格偏好

（待补充）

## 其他

（待补充 - 可以记录更多个人信息）
