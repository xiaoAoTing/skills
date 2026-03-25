# 10. 避免深层嵌套

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
