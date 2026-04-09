# 代码风格规范

> **强制**：所有代码必须遵守本文件中的编码规范

## 1. 格式化与代码限制

### 1.1 代码格式化
- 所有代码必须使用 `gofmt` + `goimports` 格式化
- 建议使用 IDE 的自动格式化功能，确保代码风格一致

### 1.2 代码长度限制
- 文件长度：≤ 800 行
- 函数长度：≤ 80 行
- 单测文件：≤ 1600 行
- 单测函数：≤ 160 行

### 1.3 行宽限制
- 建议一行不超过 120 列（函数签名、struct tag、长字符串等例外）
- 超过行宽的代码应适当换行，保持可读性

## 2. 命名规范

### 2.1 文件名
- 小写 + 下划线（如 `agent_service.go`）
- 文件名应能清晰反映文件内容

### 2.2 包名
- 小写单词，与目录一致
- 禁止使用 `util`/`common` 等无意义包名
- 包名应简短且能准确描述包的功能

### 2.3 结构体
- 驼峰命名，使用名词短语
- 禁止使用 `Data`/`Info` 等宽泛名称
- 多行声明和初始化时，使用缩进对齐

```go
// ✅ 正确
type User struct {
    ID   uint   `json:"id"`
    Name string `json:"name"`
}

// ❌ 错误
type user struct {
    id   uint
    name string
}
```

### 2.4 变量/常量
- 驼峰式命名
- 私有变量/常量小写开头
- 特有名词如 `HTTPClient`、`userID`、`APIClient` 保持原有大小写

### 2.5 常量
- 枚举类型先创建类型
- 驼峰式命名，禁止全大写+下划线
- 常量应放在 `internal/constant` 目录下

```go
// ✅ 正确
type OrderStatus int

const (
    OrderStatusPending OrderStatus = iota
    OrderStatusPaid
    OrderStatusShipped
)

// ❌ 错误
const (
    ORDER_STATUS_PENDING = iota
    ORDER_STATUS_PAID
)
```

### 2.6 函数
- 驼峰式命名
- 接口单函数以 `er` 后缀
- 函数名应能清晰反映函数功能

### 2.7 方法接收器
- 类名首字母小写
- 禁止使用 `me`/`this`/`self`

```go
// ✅ 正确
func (u *User) GetName() string {
    return u.Name
}

// ❌ 错误
func (self *User) GetName() string {
    return self.Name
}
```

## 3. 注释规范

### 3.1 文档注释
- 每个导出的类型/函数/方法/常量/变量必须有文档注释
- 格式：`// 符号名 描述信息`
- 包注释格式：`// Package 包名 描述`（main 包除外）

### 3.2 结构体内注释
- 结构体内导出成员如意义不明确需注释
- 注释应清晰说明字段含义、枚举值、默认值和约束

### 3.3 代码注释
- 复杂逻辑应有注释说明
- 注释掉的代码提交前必须删除（或附注释说明保留原因）
- 注释应使用中文，保持与代码风格一致

## 4. 控制结构

### 4.1 if 语句
- 变量在左常量在右
- bool 直接判断，不与 true/false 比较
- 尽早 return，减少嵌套

```go
// ✅ 正确
if err != nil {
    return nil, err
}

// ❌ 错误
if nil != err {
    return nil, err
}

// ❌ 错误
if ok == true {
    // do something
}
```

### 4.2 range 语句
- 只需 key 时省略第二个值
- 只需 value 时使用 `_, v`

```go
// ✅ 正确
for i := range items {
    // 使用 i
}

for _, v := range items {
    // 使用 v
}

// ❌ 错误
for i, _ := range items {
    // 使用 i
}
```

### 4.3 switch 语句
- 必须有 default 分支
- 简洁明了，避免复杂逻辑

### 4.4 其他控制结构
- 禁止使用 goto（业务代码）
- 嵌套深度不超过 4 层
- 禁止在循环中使用 defer
- defer 必须在错误检查之后

## 5. 函数与参数

### 5.1 参数数量
- 参数数量不超过 4 个（含 ctx）
- 过多参数应封装为结构体

### 5.2 参数传递
- 尽量值传递
- map/slice/chan/interface 不传指针

### 5.3 变量声明
- 变量声明遵循就近原则
- 禁止使用魔法数字

## 6. 导入规范

### 6.1 导入分组
- 标准库 → 第三方包 → 内部包
- 按字母排序
- 禁止使用相对路径

```go
// ✅ 正确
import (
    "fmt"
    "time"

    "github.com/gin-gonic/gin"

    "yourproject/internal/entity"
    "yourproject/internal/service"
)

// ❌ 错误
import (
    "yourproject/internal/entity"
    "fmt"
    "github.com/gin-gonic/gin"
    "time"
)
```

