# 11. DRY 原则（Don't Repeat Yourself）

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
