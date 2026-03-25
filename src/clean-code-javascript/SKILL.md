---
name: clean-code-javascript
description: 优化 JavaScript 代码，依据 clean-code-javascript 所定义的规则。用于代码重构、提升可读性、减少复杂度、遵循最佳实践。当用户要求优化 JS 代码、重构、提升代码质量或提及 clean code 时自动应用。
---

# Clean Code JavaScript 优化指南

依据 [clean-code-javascript](https://github.com/ryanmcdermott/clean-code-javascript) 原则优化 JavaScript 代码。

## 核心原则

### 1. 变量命名
- 使用有意义且可发音的变量名
- 避免单字母变量（循环中 i/j/k 除外）
- 使用可搜索的名称
- 避免心理映射
- 避免不必要的上下文

### 2. 函数
- 函数应该只做一件事（单一职责）
- 函数名应该说明它做什么
- 函数参数最好不超过 3 个
- 避免使用标志参数（boolean 参数）
- 避免副作用
- 不要写全局函数

### 3. 条件语句
- 避免嵌套过深（提前返回）
- 避免否定条件
- 使用卫语句处理边界情况
- 优先使用 Array.includes 替代多个 ||

### 4. 对象和数据结构
- 使用 getter 和 setter
- 让对象拥有私有成员
- 优先使用类而非普通对象

### 5. 类和构造函数
- 使用 ES6 类语法
- 使用方法链
- 优先使用组合而非继承

### 6. 异步
- 使用 Promise 替代回调
- 使用 async/await 替代 Promise 链
- 处理错误

### 7. 错误处理
- 不要忽略捕获的错误
- 使用 try-catch 处理可能失败的代码

### 8. 注释
- 只在必要时添加注释
- 好的代码应该自解释
- 注释应该解释"为什么"而非"做什么"

### 9. 避免深层嵌套

- 嵌套层级过深会导致代码难以阅读和维护
- 使用卫语句（early return）提前处理边界情况
- 使用意图导向的私有函数替代复杂的三元表达式嵌套
- 优先使用 `if` 语句配合提前返回，而非多重嵌套三元运算符

**优化前（嵌套过深）：**
```javascript
// 逻辑嵌套 4 层，极难阅读
const title = item.ref?.type === 'REFUND'
  ? '訂單退款'
  : TITLE_MAP[item.ref?.order?.subject ?? ''] ?? item.ref?.channel?.title ?? (item.adjValue > 0 ? '餘額充值' : '餘額消費')
```

**优化后（意图导向函数）：**
```javascript
/**
 * 依据业务优先级获取记录标题
 * 优先级：退款 > 订单主题映射 > 渠道标题 > 余额变动类型
 */
function getRecordTitle(item) {
  // 1. 优先处理特殊业务类型：退款
  if (item.ref?.type === 'REFUND') {
    return '訂單退款'
  }

  // 2. 尝试获取订单映射标题
  const subject = item.ref?.order?.subject
  if (subject && TITLE_MAP[subject]) {
    return TITLE_MAP[subject]
  }

  // 3. 尝试获取渠道定义的标题
  if (item.ref?.channel?.title) {
    return item.ref.channel.title
  }

  // 4. 最终根据数值正负进行兜底分类
  return item.adjValue > 0 ? '餘額充值' : '餘額消費'
}

// 调用处：清晰易读
const title = getRecordTitle(item)
```

**为什么更好？**
- **可测试性**：可单独为 `getRecordTitle` 编写单元测试
- **可读性**：每行 `if` 都是明确的业务逻辑分界点
- **易于扩展**：增加新规则只需在中间加一个 `if` 分支

---

### 10. DRY 原则（Don't Repeat Yourself）
- 相同的代码逻辑只出现一次
- 避免"散弹式修改"：同一结构在多处重复定义
- 通过提取函数、变量或常量来消除重复
- 当需要修改同一结构时，只需修改一处

**优化前：**
```javascript
function mapRecord(item) {
  if (item.type === 'REFUND') {
    return {
      id: item.id,
      title: '訂單退款',
      amount: item.amount,
      time: formatTime(item.createdAt),
    }
  }
  return {
    id: item.id,
    title: item.orderTitle,
    amount: item.amount,
    time: formatTime(item.createdAt),
  }
}
```

**优化后：**
```javascript
function mapRecord(item) {
  const title = item.type === 'REFUND'
    ? '訂單退款'
    : item.orderTitle

  return {
    id: item.id,
    title,
    amount: item.amount,
    time: formatTime(item.createdAt),
  }
}
```

## 优化检查清单

优化代码时，检查以下各项：

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

## 常见优化示例

### 变量命名

**优化前：**
```javascript
const yyyymmdstr = moment().format('YYYY/MM/DD');
const ADDRESS = 'One Infinite Loop, Cupertino 95014';
const cityStateRegex = /^(\d+)[^,]*,\s*(\w+\s*\w+)$/;
```

**优化后：**
```javascript
const currentDate = moment().format('YYYY/MM/DD');
const COMPANY_HEADQUARTERS_ADDRESS = 'One Infinite Loop, Cupertino 95014';
const cityStateRegex = /^(?<zipCode>\d+)[^,]*,\s*(?<city>\w+\s*\w+)$/;
```

### 函数优化

**优化前：**
```javascript
function emailClients(clients) {
  clients.forEach(client => {
    const clientRecord = database.lookup(client);
    if (clientRecord.isActive()) {
      email(client);
    }
  });
}
```

**优化后：**
```javascript
function emailActiveClients(clients) {
  clients
    .filter(isActiveClient)
    .forEach(email);
}

function isActiveClient(client) {
  const clientRecord = database.lookup(client);
  return clientRecord.isActive();
}
```

### 条件语句优化

**优化前：**
```javascript
if (fsm.state === 'fetching' && isEmpty(listNode)) {
  // ...
}

function isDOMNodeNotPresent(node) {
  // ...
}

if (isDOMNodeNotPresent(node)) {
  // ...
}
```

**优化后：**
```javascript
function shouldShowSpinner(fsm, listNode) {
  return fsm.state === 'fetching' && isEmpty(listNode);
}

if (shouldShowSpinner(fsmInstance, listNodeInstance)) {
  // ...
}

function isDOMNodePresent(node) {
  // ...
}

if (!isDOMNodePresent(node)) {
  // ...
}
```

### 提前返回

**优化前：**
```javascript
function getPayAmount() {
  let result;
  if (isDead) {
    result = deadAmount();
  } else {
    if (isSeparated) {
      result = separatedAmount();
    } else {
      if (isRetired) {
        result = retiredAmount();
      } else {
        result = normalPayAmount();
      }
    }
  }
  return result;
}
```

**优化后：**
```javascript
function getPayAmount() {
  if (isDead) return deadAmount();
  if (isSeparated) return separatedAmount();
  if (isRetired) return retiredAmount();
  return normalPayAmount();
}
```

### 使用默认参数

**优化前：**
```javascript
function createMicrobrewery(name) {
  const breweryName = name || 'Hipster Brew Co.';
  // ...
}
```

**优化后：**
```javascript
function createMicrobrewery(name = 'Hipster Brew Co.') {
  // ...
}
```

### 使用对象解构

**优化前：**
```javascript
function createMenu(title, body, buttonText, cancellable) {
  // ...
}

createMenu('Foo', 'Bar', 'Baz', true);
```

**优化后：**
```javascript
function createMenu({ title, body, buttonText, cancellable }) {
  // ...
}

createMenu({
  title: 'Foo',
  body: 'Bar',
  buttonText: 'Baz',
  cancellable: true
});
```

### 异步代码优化

**优化前：**
```javascript
get('https://en.wikipedia.org/wiki/Robert_Cecil_Maroney')
  .then(response => {
    return setTimeout(() => {
      console.log(response);
    }, 1000);
  })
  .catch(error => {
    console.error(error);
  });
```

**优化后：**
```javascript
async function getCleanCodeArticle() {
  try {
    const response = await get('https://en.wikipedia.org/wiki/Robert_Cecil_Maroney');
    await delay(1000);
    console.log(response);
  } catch (error) {
    console.error(error);
  }
}
```

## 优化流程

1. **分析代码**：理解代码的功能和意图
2. **识别问题**：对照检查清单找出问题
3. **重构代码**：应用 clean code 原则
4. **验证功能**：确保重构后功能不变
5. **审查改进**：检查是否还有优化空间

## 参考资源

- [clean-code-javascript](https://github.com/ryanmcdermott/clean-code-javascript) - 完整的 clean code JavaScript 指南
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript) - Airbnb 的 JavaScript 风格指南
