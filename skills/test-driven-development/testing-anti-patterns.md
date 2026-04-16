# 测试反模式

> 在添加 mock 或测试工具时，阅读此文件以避免常见陷阱。

## 反模式 1：测试 Mock 行为而非真实行为

```go
// ❌ 错误：测试 mock 的行为
func TestUserService(t *testing.T) {
    mockRepo := new(MockUserRepo)
    mockRepo.On("FindByID", 1).Return(&User{Name: "test"}, nil)
    
    svc := NewUserService(mockRepo)
    user, _ := svc.GetUser(1)
    
    mockRepo.AssertCalled(t, "FindByID", 1)  // 测试 mock 被调用了，不是测试行为
}

// ✅ 正确：测试真实行为
func TestUserService(t *testing.T) {
    repo := NewInMemoryUserRepo()
    repo.Save(&User{ID: 1, Name: "test"})
    
    svc := NewUserService(repo)
    user, err := svc.GetUser(1)
    
    assert.NoError(t, err)
    assert.Equal(t, "test", user.Name)  // 测试实际返回值
}
```

**为什么是反模式：** Mock 验证的是"代码调用了什么"，而非"代码做了什么"。当你重构实现时，mock 测试会失败，即使行为没变。

## 反模式 2：为生产类添加测试专用方法

```go
// ❌ 错误：为了测试而污染生产代码
type UserService struct {
    repo UserRepo
}

func (s *UserService) TestGetInternalState() map[string]any {  // 测试专用方法
    return map[string]any{"repo": s.repo}
}

// ✅ 正确：通过公共接口测试
func TestUserServiceBehavior(t *testing.T) {
    svc := NewUserService(repo)
    result, err := svc.GetUser(1)  // 通过公共 API 测试
    assert.Equal(t, expected, result)
}
```

**为什么是反模式：** 测试专用方法暴露内部实现，导致测试与实现耦合。

## 反模式 3：不理解依赖就使用 Mock

```go
// ❌ 错误：mock 了不理解的依赖
func TestHandler(t *testing.T) {
    mockDB := new(MockDB)
    mockDB.On("Query", mock.Anything).Return(nil, nil)  // 不知道真实行为是什么
    
    handler := NewHandler(mockDB)
    handler.Handle(req)
    // 测试通过了，但你不知道真实 DB 会返回什么
}

// ✅ 正确：使用真实依赖或理解后再 mock
func TestHandler(t *testing.T) {
    db := setupTestDB(t)  // 使用真实的测试数据库
    db.Insert(&User{ID: 1, Name: "test"})
    
    handler := NewHandler(db)
    resp := handler.Handle(req)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
}
```

**为什么是反模式：** 不理解依赖的 mock 会隐藏真实的集成问题。

## 反模式 4：过度 Mock

```go
// ❌ 错误：mock 了所有东西
func TestCalculateTotal(t *testing.T) {
    mockCalc := new(MockCalculator)
    mockCalc.On("Add", 1, 2).Return(3)
    mockCalc.On("Multiply", 3, 1.1).Return(3.3)
    
    result := CalculateTotal(mockCalc, items)
    assert.Equal(t, 3.3, result)
    // 你在测试 mock 的数学，不是你的数学
}

// ✅ 正确：只 mock 外部依赖
func TestCalculateTotal(t *testing.T) {
    items := []Item{{Price: 100, Qty: 2}, {Price: 50, Qty: 1}}
    result := CalculateTotal(items, 0.1)  // 10% 税
    assert.Equal(t, 275.0, result)  // (100*2 + 50*1) * 1.1
}
```

**为什么是反模式：** 纯逻辑不需要 mock。只 mock 你无法控制的外部依赖（网络、文件系统、第三方 API）。

## 何时使用 Mock

| 场景 | 是否 Mock | 原因 |
|------|----------|------|
| 纯计算逻辑 | ❌ 不 mock | 直接测试真实逻辑 |
| 数据库操作 | ⚠️ 优先用测试 DB | 真实 DB 行为更可靠 |
| 外部 API 调用 | ✅ Mock | 不可控、不稳定 |
| 文件系统 | ⚠️ 优先用临时目录 | 真实文件操作更可靠 |
| 时间相关 | ✅ Mock | 需要可控的时间 |
| 随机数 | ✅ Mock | 需要可预测的结果 |

## 总结

- **优先使用真实依赖**，只在必要时 mock
- **测试行为，不测试实现**
- **不要为了测试而修改生产代码**
- **理解依赖后再决定是否 mock**
