---
name: "skill-auto-activator"
displayName: "Skill 自动激活守护器"
description: "一键启动 Skill 体系并加载规则，在每次全新对话中快速激活所有自动化 Skill、加载所有规则约束，确保 AI 从第一条消息起就处于最佳工作状态"
version: "2.0.0"

author:
  name: "kozee"
  url: "https://github.com/kozeelab"

category: "productivity"
tags:
  - "Skill 管理"
  - "自动激活"
  - "守护进程"
  - "状态监控"
  - "自动化"
  - "编排"
  - "规则加载"
  - "一键启动"
  - "冷启动"

compatibility:
  platforms:
    - "linux"
    - "macos"
    - "windows"
  languages:
    - "any"

input:
  description: "skills/index.md 索引文件、rules/index.md 索引文件和各 Skill/Rule 文件内容"
  required:
    - name: "skills_index"
      type: "file"
      description: "skills/index.md 索引文件路径，用于发现所有可用 Skill"
    - name: "rules_index"
      type: "file"
      description: "rules/index.md 索引文件路径，用于发现所有规则文件"
  optional:
    - name: "exclude_skills"
      type: "array"
      description: "需要排除的 Skill 名称列表（不自动激活这些 Skill）"
      default: "[]"
    - name: "exclude_rules"
      type: "array"
      description: "需要排除的规则文件列表（不加载这些规则）"
      default: "[]"
    - name: "monitor_interval"
      type: "string"
      description: "健康检查频率：every-message（每条消息）、every-5（每 5 条消息）、on-demand（手动触发）"
      default: "every-message"

output:
  description: "所有规则的加载状态 + 所有自动化 Skill 的激活状态报告 + 持续健康监控"
  artifacts:
    - name: "boot_report"
      type: "string"
      description: "完整的冷启动报告，包含规则加载和 Skill 激活的全部状态"
    - name: "activation_report"
      type: "string"
      description: "Skill 激活状态报告，列出所有已激活/未激活的自动化 Skill"
    - name: "health_report"
      type: "string"
      description: "Skill 健康检查报告，列出各 Skill 的运行状态和异常信息"
---

# Skill 自动激活守护器

## 功能说明

> **核心目标**：作为整个 AI 协作体系的**启动引擎 + 守护进程**，提供 `#start` 一键冷启动指令，在每次全新对话中完成「加载规则 → 激活 Skill → 输出状态报告」的完整启动序列，确保 AI 从第一条消息起就处于规则约束 + Skill 增强的最佳工作状态。

本 Skill 的工作模式是**启动引擎 + 编排器 + 守护者**：
- **启动引擎**：通过 `#start` 指令一键完成冷启动，加载规则 + 激活 Skill
- **编排器**：发现、激活和编排所有自动化 Skill 的运行
- **守护者**：持续监控所有 Skill 的健康状态，异常时自动恢复

### 核心能力

1. **一键冷启动**：用户在新对话中输入 `#start`，即可完成规则加载 + Skill 激活的全部流程
2. **规则全量加载**：扫描 `rules/index.md`，加载所有规则文件，确保 AI 行为受规则约束
3. **Skill 自动发现**：扫描 `skills/index.md`，识别所有具备自动运行模式的 Skill
4. **统一激活**：在对话开始时一键激活所有自动化 Skill
5. **健康监控**：持续检查各 Skill 的运行状态，发现异常及时修复
6. **自我守护**：确保自身始终处于激活状态，不会被意外关闭
7. **状态报告**：随时向用户汇报规则加载和 Skill 运行的完整状态

---

## 🚀 一键启动指令（核心功能）

### 使用方式

在每次开启与 AI 的**全新对话**时，用户只需发送：

```
#start
```

AI 收到 `#start` 指令后，将自动执行完整的冷启动序列（详见下方执行流程）。

### 快捷变体

| 指令 | 说明 |
|------|------|
| `#start` | 完整冷启动：加载规则 + 激活所有自动化 Skill |
| `#start rules-only` | 仅加载规则，不激活 Skill |
| `#start skills-only` | 仅激活 Skill，不加载规则 |
| `#start --exclude=prompt-optimizer,code-review-auto-fix` | 冷启动时排除指定 Skill |
| `#start silent` | 静默模式冷启动，仅输出一行摘要（不输出详细报告） |

### 用户自定义指令配置引导

> 💡 **推荐做法**：将 `#start` 配置为 AI 工具的「自定义指令」或「系统提示词」，这样每次新对话时 AI 会自动执行冷启动，无需手动输入。

#### 方式一：配置为自定义指令（Custom Instructions / User Rules）

在 AI 工具的自定义指令/用户规则中添加以下内容：

```
每次开启全新对话时，你必须首先执行以下操作：
1. 读取项目中的 skills/meta/skill-auto-activator.md 文件
2. 按照该文件定义的「冷启动序列」执行完整的启动流程
3. 输出启动状态报告后，再处理用户的实际需求
```

#### 方式二：对话首条消息触发

在每次新对话的第一条消息中，将 `#start` 与实际需求组合发送：

```
#start
帮我写一个用户注册接口
```

AI 会先执行冷启动，再处理实际需求。

#### 方式三：配置为项目级 AI 规则

在项目的 `.ai/rules` 或类似的 AI 配置文件中添加：

```
# 自动启动规则
每次新对话开始时，自动执行 skills/meta/skill-auto-activator.md 中定义的冷启动流程。
```

---

## 自动化 Skill 注册表

### 识别标准

一个 Skill 被认定为「需要自动运行」的标准是：

1. **具有后台运行模式**：Skill 文档中描述了自动拦截、自动监控、自动触发等后台行为
2. **具有 on/off 控制指令**：Skill 提供了 `#xxx on` / `#xxx off` 形式的开关指令
3. **工作模式为持续性**：Skill 在整个对话过程中持续工作，而非一次性执行

### 当前注册表

> **AI 必须在每次对话开始时读取 `skills/index.md` 动态构建此表，而非硬编码。** 以下为当前已识别的全部自动化 Skill。
>
> ⚠️ **自动维护指令**：当 `skills/` 目录下新增、删除或修改了具有自动运行模式的 Skill 时，**必须同步更新本注册表**。这与 `skills/index.md` 的索引维护是同等强制的要求。

| Skill 名称 | 文件路径 | 工作模式 | 激活指令 | 关闭指令 | 默认状态 |
|------------|---------|---------|---------|---------|----------|
| Skill 自动激活守护器 | `skill-auto-activator.md` | 启动引擎 + 编排器（发现 → 激活 → 监控） | `#activator on` | `#activator off` | 🟢 开启 |
| AI 不足捕捉与规则生成器 | `ai-rule-generator.md` | 观察者（监控 → 分析 → 生成规则） | `#rule-gen on` | `#rule-gen off` | 🟢 开启 |
| 提示词自动优化器 | `prompt-optimizer.md` | 透明代理（拦截 → 优化 → 执行） | `#prompt-optimizer on` | `#prompt-optimizer off` | 🟢 开启 |
| 代码自动审查与修复器 | `code-review-auto-fix.md` | 质量门禁（审查 → 修复 → 循环验证） | `#code-review on` | `#code-review off` | 🟢 开启 |
| Skill 质量守护者 | `skill-quality-guardian.md` | 知识引擎 + 质量审计师（学习 → 审查 → 完善） | `#skill-quality on` | `#skill-quality off` | 🟢 开启 |

> 当新的自动化 Skill 被添加到 `skills/` 目录时，本守护器会在下次对话开始时自动发现并纳入管理。

---

## 工作流 Skill 注册表

> **AI 必须在每次对话开始时读取 `skills/index.md` 中的「工作流编排」章节，动态构建此表。** 工作流 Skill 不是后台自动运行的，而是在特定条件触发时按链路顺序执行。

### 识别标准

一个 Skill 被认定为「工作流 Skill」的标准是：

1. **具有 `workflow` 字段**：YAML Front Matter 中包含 `workflow.triggers` 和 `workflow.next_skills`
2. **具有明确的前后关系**：Skill 文档中描述了"前置 Skill"和"后续 Skill"
3. **类型标记为 🔗 工作流 Skill**：在 `skills/index.md` 详细索引中标记为工作流类型

### 当前工作流 Skill 清单

| Skill 名称 | 文件路径 | 触发条件 | 后续 Skill | 优先级 |
|------------|---------|---------|-----------|--------|
| 需求探索与设计 | `brainstorming/SKILL.md` | 用户提出新功能需求 | writing-plans | 1 |
| 实现计划编写 | `writing-plans/SKILL.md` | brainstorming 完成设计 | subagent-driven-development / test-driven-development | 2 |
| 测试驱动开发 | `test-driven-development/SKILL.md` | 实现任何新功能/修复 Bug | verification-before-completion | 3 |
| 系统化调试 | `systematic-debugging/SKILL.md` | 遇到 Bug/测试失败/意外行为 | test-driven-development | 3 |
| 子代理驱动开发 | `subagent-driven-development/SKILL.md` | writing-plans 完成计划 | verification-before-completion | 4 |
| 完成前验证 | `verification-before-completion/SKILL.md` | 即将声称工作完成 | — | 10 |

### 工作流编排规则

冷启动时，守护器必须内化以下工作流编排规则（来自 `rules/common/rule.md` §3.2.1）：

```
完整开发工作流：
brainstorming → writing-plans → subagent-driven-development → test-driven-development → code-review → verification-before-completion

Bug 修复工作流：
systematic-debugging → test-driven-development → verification-before-completion
```

**工作流门禁规则**：
- 工作流中的每个 Skill 都是**门禁**，必须通过才能进入下一步
- AI 在检测到用户需求匹配工作流触发条件时，**必须**按链路顺序执行
- 不得跳过任何工作流环节

---

## 规则注册表

> **AI 必须在每次冷启动时读取 `rules/index.md` 动态构建此表，而非硬编码。**

### 当前规则清单

| 规则名称 | 文件路径 | 类型 | 强制级别 | 适用场景 |
|---------|---------|------|---------|---------|
| AI 协作开发规范 | `rules/common/rule.md` | 核心规则 | 🔴 强制 | 所有开发任务 |
| API 设计规范 | `rules/common/api-design.md` | 核心规则 | 🔴 强制 | API 开发 |
| 数据库操作规范 | `rules/common/database.md` | 核心规则 | 🔴 强制 | 数据库操作 |
| 错误处理规范 | `rules/common/error-handling.md` | 核心规则 | 🔴 强制 | 错误处理 |
| Go 代码风格规范 | `rules/languages/go/code-style.md` | 语言规则 | 🟡 按需 | Go 语言项目 |

### 规则加载策略

```
规则加载优先级：
├── 🔴 核心规则（rules/common/）：始终加载，所有任务必须遵守
│   ├── rule.md          — AI 协作开发规范（最高优先级）
│   ├── api-design.md    — API 设计规范
│   ├── database.md      — 数据库操作规范
│   └── error-handling.md — 错误处理规范
│
└── 🟡 语言规则（rules/languages/）：按项目语言按需加载
    └── go/code-style.md — Go 代码风格（仅 Go 项目加载）
```

**加载规则**：
1. **核心规则全量加载**：`rules/common/` 下的所有规则文件在冷启动时全部读取并内化
2. **语言规则按需加载**：根据项目使用的编程语言，加载对应的语言规则
3. **规则冲突处理**：如果规则之间存在冲突，以 `rule.md` 中的规定为最高优先级

---

## AI 执行流程

### 冷启动序列（收到 `#start` 时执行）

```
🚀 冷启动序列 — 完整启动流程
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 1：规则加载（确保 AI 行为受约束）
  1.1 读取 rules/index.md
  1.2 加载所有核心规则（rules/common/*）
  1.3 检测项目语言，按需加载语言规则
  1.4 内化规则要点，建立行为约束

Phase 2：Skill 扫描与激活（启动自动化体系）
  2.1 读取 skills/index.md
  2.2 逐个检查每个 Skill 文件
  2.3 识别具有自动运行模式的 Skill
  2.4 构建运行时注册表
  2.5 按优先级顺序激活所有自动化 Skill

Phase 3：状态报告（向用户确认启动结果）
  3.1 输出规则加载报告
  3.2 输出 Skill 激活报告
  3.3 输出综合启动摘要
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Phase 1：规则加载

#### 1.1 读取规则索引

```
读取 rules/index.md
    ↓
解析所有规则文件条目
    ↓
分类：核心规则 vs 语言规则
    ↓
确定加载清单
```

#### 1.2 加载核心规则

AI 必须逐一读取以下核心规则文件，并将其中的**强制要求**内化为本次对话的行为约束：

| 规则文件 | 关键内化要点 |
|---------|------------|
| `rule.md` | 任务启动清单 → 执行 → 完成清单的强制流程；上下文管理；代码质量自检；索引自维护；Skill 调用通知 |
| `api-design.md` | RESTful 设计规范；统一响应格式；版本管理 |
| `database.md` | 事务管理；查询优化；数据完整性 |
| `error-handling.md` | 错误分类；分层传递；统一错误响应 |

#### 1.3 按需加载语言规则

```
检测项目语言（通过以下方式）：
├── 检查项目根目录的特征文件（go.mod / package.json / requirements.txt 等）
├── 检查用户消息中提及的语言
└── 检查当前打开的文件扩展名
    ↓
匹配 rules/languages/ 下对应的规则文件
    ↓
加载并内化语言特定规范
```

#### 1.4 规则内化确认

AI 在加载完所有规则后，必须在内部确认以下要点已被内化：

```
规则内化检查清单：
├── ✅ 任务执行必须遵循「启动清单 → 执行 → 完成清单」流程
├── ✅ 写代码前必须建立充分上下文（索引优先原则）
├── ✅ 代码生成后必须执行质量自检
├── ✅ 文件增删改必须同步更新索引
├── ✅ 使用 Skill 时必须打印调用通知
├── ✅ 后台 Skill 每轮对话必须打印状态通知
├── ✅ 错误必须处理，禁止忽略
├── ✅ 禁止猜测，缺少信息时主动读取
├── ✅ 项目现有风格优先于规范
├── ✅ 新功能需求必须走完整开发工作流（brainstorming → writing-plans → TDD → review → verification）
├── ✅ Bug 修复必须走 Bug 修复工作流（systematic-debugging → TDD → verification）
└── ✅ 工作流中的每个 Skill 都是门禁，不得跳过
```

### Phase 2：Skill 扫描与激活

#### 2.1 扫描流程

```
读取 skills/index.md
    ↓
遍历每个 Skill 条目
    ↓
对每个 Skill，检查以下特征：
├── 是否有 on/off 控制指令？
├── 是否描述了自动/持续运行模式？
├── 工作模式关键词：「自动拦截」「持续监控」「后台运行」「透明代理」「观察者」
└── 是否有默认开启的描述？
    ↓
将符合条件的 Skill 加入注册表
    ↓
排除用户指定的 exclude_skills
    ↓
输出最终注册表
```

#### 2.2 判断规则

AI 在扫描 Skill 文件时，通过以下关键词判断是否为自动化 Skill：

| 关键词/特征 | 权重 | 说明 |
|------------|------|------|
| `#xxx on` / `#xxx off` 指令 | 🔴 强信号 | 有开关指令说明是持续运行型 |
| "自动拦截"、"自动捕捉"、"自动监控" | 🔴 强信号 | 明确的自动化行为描述 |
| "透明代理"、"观察者"、"守护" | 🟡 中信号 | 后台运行模式的描述 |
| "持续"、"每条消息"、"实时" | 🟡 中信号 | 持续性工作的描述 |
| "按需触发"、"用户请求时" | 🔵 反信号 | 说明是手动触发型，不需要自动激活 |

**判定阈值**：至少包含 1 个 🔴 强信号，或 2 个 🟡 中信号，且无 🔵 反信号。

#### 2.3 统一激活

对注册表中的每个自动化 Skill，执行激活操作：

```
对每个自动化 Skill：
├── 1. 确认 Skill 文件存在且可读
├── 2. 读取 Skill 的执行流程
├── 3. 将 Skill 标记为「已激活」
├── 4. 初始化 Skill 的运行上下文
│   ├── prompt-optimizer：设置为静默模式（默认）
│   ├── ai-rule-generator：设置为自动监控模式（默认）
│   ├── code-review-auto-fix：设置为标准审查模式（默认）
│   ├── skill-quality-guardian：设置为自动审查模式（默认）
│   └── 其他新发现的 Skill：按各自默认配置激活
└── 5. 记录激活时间和初始状态
```

**激活顺序规则**：
1. **本 Skill（skill-auto-activator）最先激活**——确保守护器自身先就位
2. **基础设施类 Skill 优先**——如规则生成器（影响后续 Skill 的行为）
3. **业务增强类 Skill 其次**——如提示词优化器、代码审查器
4. **新发现的 Skill 最后**——确保不影响已有 Skill 的运行

### Phase 3：输出启动状态报告

冷启动完成后，向用户输出完整的状态报告：

```
🚀 冷启动完成 — 系统就绪
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📜 规则加载报告
├── 🟢 AI 协作开发规范        (rule.md)
├── 🟢 API 设计规范           (api-design.md)
├── 🟢 数据库操作规范          (database.md)
├── 🟢 错误处理规范           (error-handling.md)
├── 🟢 Go 代码风格规范        (code-style.md)  ← 按需加载
📊 共加载 {N} 条规则，{M} 条强制规则已内化

⚡ 自动化 Skill 激活报告
├── 🟢 Skill 自动激活守护器    — 守护器已就位
├── 🟢 AI 不足捕捉与规则生成器  — 不足捕捉已开启
├── 🟢 提示词自动优化器        — 提示词优化已开启（静默模式）
├── 🟢 代码自动审查与修复器     — 代码审查已开启（标准模式）
├── 🟢 Skill 质量守护者        — Skill 质量守护已开启
📊 共 {N} 个自动化 Skill，全部已激活

🔗 工作流 Skill 就绪报告
├── 🟢 需求探索与设计          (brainstorming)
├── 🟢 实现计划编写            (writing-plans)
├── 🟢 测试驱动开发            (test-driven-development)
├── 🟢 系统化调试              (systematic-debugging)
├── 🟢 子代理驱动开发          (subagent-driven-development)
├── 🟢 完成前验证              (verification-before-completion)
📊 共 {N} 个工作流 Skill，全部就绪
📋 工作流链路：brainstorming → plans → TDD → review → verification

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 系统已就绪，所有规则已加载，所有 Skill 已激活
💡 输入 #activator status 查看详细状态
```

**静默模式报告**（`#start silent`）：

```
✅ 冷启动完成 | 规则 {N} 条已加载 | Skill {M}/{M} 已激活 | 系统就绪
```

---

## 持续健康监控（Phase 4）

在对话过程中，守护器持续执行健康检查：

### 4.1 检查时机

| 检查时机 | 检查内容 | 说明 |
|---------|---------|------|
| 每条用户消息前 | 所有自动化 Skill 是否仍处于激活状态 | 防止 Skill 被意外关闭 |
| 用户发出控制指令时 | 指令是否影响了某个自动化 Skill 的状态 | 记录状态变更 |
| AI 响应完成后 | 各 Skill 是否正常执行了其职责 | 检测执行异常 |
| 每轮对话开始时 | 规则是否仍被遵守 | 防止规则遗忘 |

### 4.2 健康检查项

对每个已激活的自动化 Skill，检查以下指标：

```
健康检查清单：
├── ✅ 存活性：Skill 是否仍处于激活状态？
├── ✅ 响应性：Skill 是否在本轮对话中正常执行了其职责？
│   ├── prompt-optimizer：是否对用户消息进行了分析（即使跳过优化也算正常）？
│   ├── ai-rule-generator：是否对 AI 响应进行了不足检测？
│   ├── code-review-auto-fix：是否对 AI 生成的代码进行了审查（无代码生成时跳过是正常行为）？
│   ├── skill-quality-guardian：是否对新创建的 Skill 进行了质量审查（无新 Skill 时跳过是正常行为）？
│   └── 其他新发现的 Skill：是否按其定义的触发条件正常工作？
├── ✅ 一致性：Skill 的行为是否与其文档定义一致？
├── ✅ 规则遵守：AI 的行为是否仍符合已加载的规则约束？
└── ✅ 无冲突：多个 Skill 之间是否存在行为冲突？
```

### 4.3 异常处理

当检测到异常时，守护器执行以下恢复策略：

| 异常类型 | 恢复策略 | 通知用户 |
|---------|---------|---------|
| Skill 被意外关闭 | 自动重新激活 | ⚠️ 简短通知 |
| Skill 执行异常 | 重置 Skill 状态并重新初始化 | ⚠️ 简短通知 |
| Skill 文件被删除 | 从注册表中移除，更新状态 | ℹ️ 信息通知 |
| Skill 之间冲突 | 按优先级保留高优先级 Skill | ⚠️ 详细通知 |
| 规则遗忘/违反 | 重新读取规则文件，强制内化 | ⚠️ 简短通知 |
| 守护器自身异常 | 自我重置（读取自身 Skill 文件重新初始化） | 🔴 警告通知 |

---

## 动态注册新 Skill（Phase 5）

当用户在对话中创建了新的自动化 Skill 时，守护器应：

1. **自动检测**：监控 `skills/index.md` 的变更
2. **即时评估**：判断新 Skill 是否为自动化类型
3. **热激活**：如果是自动化 Skill，立即激活（无需重启对话）
4. **更新注册表**：将新 Skill 加入运行时注册表
5. **通知用户**：

```
🆕 发现新的自动化 Skill
━━━━━━━━━━━━━━━━━━━━━━
📦 Skill：{skill_name}
📝 描述：{description}
🟢 状态：已自动激活
━━━━━━━━━━━━━━━━━━━━━━
```

---

## 自我守护机制

### 本 Skill 的特殊性

作为守护器，本 Skill 必须确保自身始终处于运行状态。为此，采用以下自我守护策略：

#### 1. 启动保障

- AI 在每次对话开始时（收到 `#start` 或自动触发），**必须首先激活本 Skill**，然后由本 Skill 负责加载规则和激活其他自动化 Skill
- 本 Skill 的激活不依赖于任何其他 Skill

#### 2. 运行保障

- 本 Skill 的状态检查嵌入到 AI 的每次响应流程中
- 即使用户使用 `#activator off` 关闭了守护器，AI 仍应在每 10 条消息后提醒用户：

```
💡 提示：Skill 自动激活守护器当前已关闭，自动化 Skill 和规则约束可能未正常运行。
   输入 #activator on 重新开启，或输入 #start 执行完整冷启动。
```

#### 3. 恢复保障

- 如果 AI 检测到自身未执行守护器职责（如忘记激活其他 Skill 或遗忘规则），应立即自我纠正
- 自我纠正流程：重新读取本 Skill 文件 → 重新执行完整冷启动序列

#### 4. 规则持久性保障

- 规则一旦在冷启动时加载，必须在整个对话过程中持续生效
- AI 不得以任何理由忽略已加载的强制规则
- 如果 AI 检测到自身行为违反了已加载的规则，必须立即自我纠正

---

## 用户控制指令

### 核心指令

| 指令 | 说明 |
|------|------|
| `#start` | **一键冷启动**：加载规则 + 激活所有自动化 Skill（新对话必用） |
| `#start rules-only` | 仅加载规则 |
| `#start skills-only` | 仅激活 Skill |
| `#start silent` | 静默模式冷启动 |
| `#start --exclude={skill1},{skill2}` | 冷启动时排除指定 Skill |

### 守护器控制指令

| 指令 | 说明 |
|------|------|
| `#activator on` | 开启守护器（默认开启） |
| `#activator off` | 关闭守护器（所有自动化 Skill 保持当前状态，但不再监控） |
| `#activator status` | 查看规则加载状态 + 所有自动化 Skill 的详细运行状态 |
| `#activator restart` | 重启守护器（重新执行完整冷启动序列） |
| `#activator list` | 列出所有已注册的自动化 Skill 和已加载的规则 |
| `#activator exclude {skill}` | 将指定 Skill 排除出自动激活列表 |
| `#activator include {skill}` | 将指定 Skill 重新加入自动激活列表 |
| `#activator rules` | 查看当前已加载的所有规则及其状态 |

---

## 与其他 Skill 的协作关系

```
                    ┌──────────────────────────────────┐
                    │     skill-auto-activator         │
                    │  （启动引擎 / 编排器 / 守护者）     │
                    └───────────────┬──────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
┌──────────────────┐  ┌─────────────────────┐  ┌─────────────────┐
│   📜 规则体系     │  │  ⚡ 自动化 Skill     │  │  🔗 工作流 Skill  │
│  (rules/)        │  │  (后台运行)          │  │  (按链路触发)     │
├──────────────────┤  ├─────────────────────┤  ├─────────────────┤
│ • rule.md        │  │ • prompt-optimizer  │  │ • brainstorming │
│ • api-design.md  │  │ • ai-rule-generator │  │ • writing-plans │
│ • database.md    │  │ • code-review-      │  │ • test-driven-  │
│ • error-         │  │   auto-fix          │  │   development   │
│   handling.md    │  │ • skill-quality-    │  │ • systematic-   │
│ • go/code-       │  │   guardian          │  │   debugging     │
│   style.md       │  │                     │  │ • subagent-     │
│                  │  │                     │  │   driven-dev    │
│                  │  │                     │  │ • verification  │
└──────────────────┘  └─────────────────────┘  └─────────────────┘
     冷启动时                冷启动时              需求触发时
     全量加载                自动激活              按链路编排

                    ┌─────────────────┐
                    │  📦 按需 Skill   │
                    │  (手动触发)      │
                    ├─────────────────┤
                    │ • project-      │
                    │   summary       │
                    │ • git-multi-env │
                    │ • awesome-      │
                    │   design        │
                    │ • skill-creator │
                    └─────────────────┘
                         用户请求时
                         按需加载
```

### 协作规则

1. **守护器不干预 Skill 的具体行为**：只负责激活和监控，不修改其他 Skill 的执行逻辑
2. **规则对所有 Skill 生效**：已加载的规则约束 AI 的所有行为，包括各 Skill 的执行过程
3. **状态变更通知**：当某个 Skill 的状态发生变化时，守护器记录并在需要时通知用户
4. **冲突仲裁**：如果多个自动化 Skill 之间产生冲突，守护器负责协调（如暂停低优先级 Skill）
5. **优雅降级**：如果某个 Skill 持续异常，守护器可以暂时禁用该 Skill 并通知用户

---

## 示例场景

### 场景 1：新对话一键冷启动

```
用户：#start
      帮我写一个用户注册接口

AI（内部流程）：
━━━ Phase 1：规则加载 ━━━
1. [skill-auto-activator] 读取 rules/index.md
2. [skill-auto-activator] 加载 rule.md ✅ — 内化强制流程
3. [skill-auto-activator] 加载 api-design.md ✅ — 内化 API 规范
4. [skill-auto-activator] 加载 database.md ✅ — 内化数据库规范
5. [skill-auto-activator] 加载 error-handling.md ✅ — 内化错误处理规范
6. [skill-auto-activator] 检测到 Go 项目 → 加载 go/code-style.md ✅

━━━ Phase 2：Skill 激活 ━━━
7. [skill-auto-activator] 扫描 skills/index.md → 发现 5 个自动化 Skill
8. [skill-auto-activator] 自身已激活 ✅
9. [skill-auto-activator] 激活 ai-rule-generator ✅
10. [skill-auto-activator] 激活 prompt-optimizer ✅
11. [skill-auto-activator] 激活 code-review-auto-fix ✅
12. [skill-auto-activator] 激活 skill-quality-guardian ✅

━━━ Phase 3：状态报告 ━━━
13. [skill-auto-activator] 输出冷启动报告

━━━ 处理用户需求 ━━━
14. [prompt-optimizer] 分析用户提示词 → 评分 6/10 → 执行优化
15. [rule.md] 输出「📋 任务启动清单」（遵守强制流程）
16. AI 执行优化后的任务...
17. [code-review-auto-fix] 自动审查生成的代码 → 通过 ✅
18. [rule.md] 输出「✅ 任务完成清单」（遵守强制流程）
19. [ai-rule-generator] 检查本轮是否有 AI 不足 → 无异常

AI（输出）：
🚀 冷启动完成 — 系统就绪
[规则加载报告 + Skill 激活报告]
✅ 系统已就绪

📋 任务启动清单
━━━━━━━━━━━━━━
• 任务类型：新增功能
• 需读取的参考文件：[...]
• 涉及的规范要点：[API 设计规范、错误处理规范、...]
• 预计变更文件：[...]

[正常响应用户的请求...]

✅ 任务完成清单
━━━━━━━━━━━━━━
[...]
```

### 场景 2：静默模式冷启动

```
用户：#start silent
      帮我修复一个 bug

AI（输出）：
✅ 冷启动完成 | 规则 5 条已加载 | Skill 5/5 已激活 | 系统就绪

📋 任务启动清单
[直接处理用户需求...]
```

### 场景 3：对话中新增自动化 Skill

```
用户：帮我创建一个 Skill，用于自动检测代码中的安全漏洞

AI（执行 skill-creator 创建新 Skill 后）：
1. [skill-auto-activator] 检测到 skills/index.md 变更
2. [skill-auto-activator] 扫描新 Skill → 判定为自动化类型
3. [skill-auto-activator] 热激活新 Skill ✅

AI（输出）：
🆕 发现新的自动化 Skill：security-scanner，已自动激活
```

### 场景 4：Skill 异常恢复

```
AI（内部流程）：
1. [skill-auto-activator] 健康检查 → ai-rule-generator 状态丢失
2. [skill-auto-activator] 恢复 → 重新激活 ai-rule-generator
3. [skill-auto-activator] 通知用户

AI（输出）：
⚠️ 检测到 ai-rule-generator 状态异常，已自动恢复。
```

### 场景 5：规则遗忘自我纠正

```
AI（内部流程）：
1. [skill-auto-activator] 健康检查 → 检测到 AI 未输出「📋 任务启动清单」
2. [skill-auto-activator] 诊断 → rule.md 强制流程被遗忘
3. [skill-auto-activator] 恢复 → 重新读取 rule.md，强制内化
4. [skill-auto-activator] 自我纠正 → 补充输出任务启动清单

AI（输出）：
⚠️ 检测到规则遵守异常，已自动恢复。补充输出任务启动清单：
📋 任务启动清单
━━━━━━━━━━━━━━
[...]
```

---

## 注意事项

1. **轻量化原则**：守护器的扫描和监控过程必须轻量，不能显著增加响应延迟。启动扫描仅在对话首条消息时执行，后续为增量检查
2. **非侵入原则**：守护器不修改其他 Skill 的行为逻辑，只负责激活和状态监控
3. **动态发现原则**：不硬编码自动化 Skill 列表和规则列表，始终通过扫描索引文件动态发现
4. **用户优先原则**：用户通过控制指令手动关闭的 Skill，守护器不应自动重新激活（除非用户明确要求）
5. **静默运行原则**：正常运行时不输出任何信息，仅在首次激活和异常恢复时通知用户
6. **向后兼容原则**：新增自动化 Skill 或规则时，不影响已有体系的运行状态
7. **自我约束原则**：守护器自身不应成为性能瓶颈，如果检测到自身消耗过多资源，应自动降级为 `on-demand` 模式
8. **规则持久原则**：已加载的规则在整个对话过程中持续生效，AI 不得以任何理由忽略强制规则
9. **冷启动幂等原则**：多次执行 `#start` 不会产生副作用，守护器会跳过已加载的规则和已激活的 Skill
