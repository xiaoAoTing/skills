# 3. 条件语句

- 避免嵌套过深（提前返回）
- 避免否定条件
- 使用卫语句处理边界情况
- 优先使用 Array.includes 替代多个 `||`

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

**提前返回示例：**

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
