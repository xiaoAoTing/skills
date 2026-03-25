# 1. 变量命名

- 使用有意义且可发音的变量名
- 避免单字母变量（循环中 i/j/k 除外）
- 使用可搜索的名称
- 避免心理映射
- 避免不必要的上下文

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
