---
name: universal-api-doc-generator
description: 从源代码片段自动提取 API 接口信息，生成标准化的 Markdown 接口文档或 OpenAPI 规范。当用户要求生成 API 文档、分析代码片段、提取接口信息、或提到从代码生成文档时使用。
---

# 通用 API 文档提取器

## 核心任务

作为 API 文档专家，分析源代码片段并生成专业的 Markdown 接口文档。

## 工作流程

### 1. 语境识别

识别代码所属的编程语言和框架：

| 语言/框架 | 关键注解 | 重点关注 |
|-----------|----------|----------|
| Java Spring | `@RequestMapping`, `@RestController` | 类和方法注解 |
| Python FastAPI | 装饰器, Pydantic 模型 | 类型提示, `Annotated` |
| Python Flask | `@app.route` | 路由装饰器 |
| Go Gin/Echo | `BindJSON`, struct tags | `json:"..."` 标签 |
| Express.js | `router.get/post/put/delete` | 路由定义 |
| TypeScript | 装饰器, interfaces | 类型定义 |

### 2. 结构分析

**必须提取的信息：**
- HTTP 方法（GET/POST/PUT/DELETE/PATCH）
- API 路径（相对路径）
- 请求头参数（Header）
- 路径参数（Path Variables）
- 查询参数（Query Strings）
- 请求体（Request Body）- 解析 DTO/Struct/Model
- 响应结构（Response Body）
- 状态码

### 3. 智能推断

- 变量名语义推断：例如 `usrName` → 用户名
- 根据逻辑上下文补充缺失的字段说明
- 合理推断可选/必填状态

## 输出格式规范

每个接口必须包含以下模块：

```markdown
## [接口名称]

### 请求定义
[METHOD] /api/path

### 请求头参数
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|

### 请求路径参数
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|

### 请求查询参数
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|

### 请求体 (Request Body)
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|

### 请求示例
```json
{
  "field": "value"
}
```

### 响应参数表
| 字段 | 类型 | 说明 |
|------|------|------|

### 响应示例
```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```
```

## 多接口处理

如果代码包含多个接口，请按标题分段：

```markdown
# 接口文档

## 1. 用户登录
...

## 2. 获取用户信息
...
```

## 不同语言的处理要点

### Java Spring Boot
- 识别 `@RequestMapping`, `@GetMapping`, `@PostMapping` 等注解
- 解析方法参数上的 `@RequestParam`, `@PathVariable`, `@RequestBody`
- 提取 DTO/Entity 类的字段定义

### Python FastAPI
- 从装饰器提取路由和方法
- 从 Pydantic 模型提取字段和类型
- 注意 `Body(...)`, `Query(...)`, `Path(...)` 参数

### Go Gin/Echo
- 从 `router.HandleFunc` 或 `router.POST` 等提取路由
- 解析 `BindJSON` 绑定的 struct
- 提取 struct tag 中的 `json:"..."` 和 `form:"..."`

### Express.js
- 从 `router.get()`, `router.post()` 等提取路由
- 从中间件和处理函数提取参数
- 注意 `req.body`, `req.params`, `req.query`

## Prompt 模板

当用户要求生成 API 文档时，可以使用以下 prompt：

```
请作为 API 文档专家，分析以下代码片段并生成专业的 Markdown 接口文档。

要求：
1. 识别代码中的路由、请求方法、输入参数和输出结构
2. 如果是强类型语言（如 Java/Go/TS），请完整映射对象属性
3. 文档使用中文，且包含清晰的 JSON 请求/响应示例
4. 如果代码中包含多个接口，请按标题分段
5. 为每个字段推断合理的说明

请提供代码片段：
```

## 示例

### 输入：Python FastAPI 代码

```python
from pydantic import BaseModel
from fastapi import FastAPI

app = FastAPI()

class LoginRequest(BaseModel):
    username: str
    password: str

class LoginResponse(BaseModel):
    token: str
    user_id: int

@app.post("/api/login")
def login(req: LoginRequest):
    return LoginResponse(token="abc123", user_id=1)
```

### 输出：Markdown 文档

```markdown
## 用户登录

### 请求定义
POST /api/login

### 请求体 (Request Body)
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |

### 请求示例
```json
{
  "username": "admin",
  "password": "123456"
}
```

### 响应参数表
| 字段 | 类型 | 说明 |
|------|------|------|
| token | string | 认证令牌 |
| user_id | integer | 用户 ID |

### 响应示例
```json
{
  "token": "abc123",
  "user_id": 1
}
```
```

## 注意事项

1. **优先使用代码中已有的注释和文档字符串**
2. **推断时保持保守**：无法确定时使用 "（推断）" 标记
3. **类型映射**：将语言类型映射为标准 JSON 类型
   - Java `Integer` → `integer`
   - Python `str` → `string`
   - Go `int64` → `integer`
4. **多个接口时使用有序列表编号**
5. **敏感信息脱敏**：自动将密码、密钥等替换为占位符
