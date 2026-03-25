# 9. 避免过早抽象 (Premature Abstraction)

**核心问题**：不要为还不存在的行为创建抽象层。无意义的 `computed` 会增加维护成本并造成职责模糊。

**典型反模式**：当数据已由服务端过滤，前端再创建一个等价的 `computed`：

```typescript
// ❌ 错误：无意义的 computed，只是原数据的镜像
const myGiftCards = ref<MyGiftCard[]>([])
const filteredMyGiftCards = computed(() => myGiftCards.value) // 无任何加工逻辑
```

**问题分析**：
1. **冗余逻辑**：computed 的核心是派生状态，如果没有任何处理逻辑，属于"无功用"
2. **职责模糊**：两个变量指向同一数据源，让后续开发者困惑哪个才是"可靠的数据源"
3. **维护负担**：看到 `filteredMyGiftCards` 会试图寻找过滤逻辑，结果发现什么都没有

**优化方案**：

**方案 A：直接删减（推荐）**
```typescript
const myGiftCards = ref<MyGiftCard[]>([])
// 模板中直接使用 myGiftCards
```

**方案 B：只在需要时使用 computed**
```typescript
const searchQuery = ref('')
const filteredMyGiftCards = computed(() => {
  return myGiftCards.value.filter(card => card.name.includes(searchQuery.value))
})
```

**判断标准**：只有当 `computed` 内部存在实际的数据转换（过滤、排序、映射等）时才使用 computed，否则直接使用原数据。
