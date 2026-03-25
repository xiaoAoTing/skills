# 6. 异步

- 使用 Promise 替代回调
- 使用 async/await 替代 Promise 链
- 处理错误

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
