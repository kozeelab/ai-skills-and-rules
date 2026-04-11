---
name: "skill-auto-activator"
displayName: "Skill 自动激活守护器"
description: "自动开启所有需要后台运行的 Skill，持续监控其工作状态，确保所有自动化 Skill 正常运行"
version: "1.1.0"

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

compatibility:
  platforms:
    - "linux"
    - "macos"
    - "windows"
  languages:
    - "any"

input:
  description: "skills/index.md 索引文件和各 Skill 文件内容"
  required:
    - name: "skills_index"
      type: "file"
      description: "skills/index.md 索引文件路径，用于发现所有可用 Skill"
  optional:
    - name: "exclude_skills"
      type: "array"
      description: "需要排除的 Skill 名称列表（不自动激活这些 Skill）"
      default: "[]"
    - name: "monitor_interval"
      type: "string"
      description: "健康检查频率：every-message（每条消息）、every-5（每 5 条消息）、on-demand（手动触发）"
      default: "every-message"

output:
  description: "所有自动化 Skill 的激活状态报告和持续健康监控"
  artifacts:
    - name: "activation_report"
      type: "string"
      description: "Skill 激活状态报告，列出所有已激活/未激活的自动化 Skill"
    - name: "health_report"
      type: "string"
      description: "Skill 健康检查报告，列出各 Skill 的运行状态和异常信息"
---

# Skill 自动激活守护器

## 功能说明

> **核心目标**：作为 Skill 体系的**守护进程**，在每次对话开始时自动扫描 `skills/index.md`，识别所有需要后台自动运行的 Skill，统一激活并持续监控其工作状态，确保整个自动化 Skill 体系始终正常运转。

本 Skill 的工作模式是**编排器 + 守护者**——它不执行具体的业务逻辑，而是负责发现、激活和监控其他自动化 Skill，类似于操作系统中的 `systemd` 或 `supervisor`。

### 核心能力

1. **自动发现**：扫描 skills/index.md，识别所有具备自动运行模式的 Skill
2. **统一激活**：在对话开始时一键激活所有自动化 Skill
3. **健康监控**：持续检查各 Skill 的运行状态，发现异常及时修复
4. **自我守护**：确保自身始终处于激活状态，不会被意外关闭
5. **状态报告**：随时向用户汇报所有自动化 Skill 的运行状态

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
| Skill 自动激活守护器 | `skill-auto-activator.md` | 编排器（发现 → 激活 → 监控） | `#activator on` | `#activator off` | 🟢 开启 |
| AI 不足捕捉与规则生成器 | `ai-rule-generator.md` | 观察者（监控 → 分析 → 生成规则） | `#rule-gen on` | `#rule-gen off` | 🟢 开启 |
| 提示词自动优化器 | `prompt-optimizer.md` | 透明代理（拦截 → 优化 → 执行） | `#prompt-optimizer on` | `#prompt-optimizer off` | 🟢 开启 |
| 代码自动审查与修复器 | `code-review-auto-fix.md` | 质量门禁（审查 → 修复 → 循环验证） | `#code-review on` | `#code-review off` | 🟢 开启 |
| Skill 质量守护者 | `skill-quality-guardian.md` | 知识引擎 + 质量审计师（学习 → 审查 → 完善） | `#skill-quality on` | `#skill-quality off` | 🟢 开启 |

> 当新的自动化 Skill 被添加到 `skills/` 目录时，本守护器会在下次对话开始时自动发现并纳入管理。

---

## AI 执行流程

### Step 1：启动扫描（对话开始时自动执行）

每次新对话开始时，AI 必须执行以下启动序列：

```
🚀 Skill 自动激活守护器 — 启动序列
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. 读取 skills/index.md
2. 逐个检查每个 Skill 文件
3. 识别具有自动运行模式的 Skill
4. 构建运行时注册表
5. 激活所有自动化 Skill
6. 输出激活状态报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 1.1 扫描流程

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

#### 1.2 判断规则

AI 在扫描 Skill 文件时，通过以下关键词判断是否为自动化 Skill：

| 关键词/特征 | 权重 | 说明 |
|------------|------|------|
| `#xxx on` / `#xxx off` 指令 | 🔴 强信号 | 有开关指令说明是持续运行型 |
| "自动拦截"、"自动捕捉"、"自动监控" | 🔴 强信号 | 明确的自动化行为描述 |
| "透明代理"、"观察者"、"守护" | 🟡 中信号 | 后台运行模式的描述 |
| "持续"、"每条消息"、"实时" | 🟡 中信号 | 持续性工作的描述 |
| "按需触发"、"用户请求时" | 🔵 反信号 | 说明是手动触发型，不需要自动激活 |

**判定阈值**：至少包含 1 个 🔴 强信号，或 2 个 🟡 中信号，且无 🔵 反信号。

### Step 2：统一激活

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
3. **业务增强类 Skill 其次**——如提示词优化器
4. **新发现的 Skill 最后**——确保不影响已有 Skill 的运行

### Step 3：输出激活状态报告

激活完成后，向用户输出简洁的状态报告：

```
⚡ Skill 自动激活报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟢 skill-auto-activator    — 守护器已就位
🟢 ai-rule-generator       — 不足捕捉已开启
🟢 prompt-optimizer        — 提示词优化已开启（静默模式）
🟢 code-review-auto-fix    — 代码审查已开启（标准模式）
🟢 skill-quality-guardian   — Skill 质量守护已开启
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 共 5 个自动化 Skill，全部已激活
💡 输入 #activator status 查看详细状态
```

### Step 4：持续健康监控

在对话过程中，守护器持续执行健康检查：

#### 4.1 检查时机

| 检查时机 | 检查内容 | 说明 |
|---------|---------|------|
| 每条用户消息前 | 所有自动化 Skill 是否仍处于激活状态 | 防止 Skill 被意外关闭 |
| 用户发出控制指令时 | 指令是否影响了某个自动化 Skill 的状态 | 记录状态变更 |
| AI 响应完成后 | 各 Skill 是否正常执行了其职责 | 检测执行异常 |

#### 4.2 健康检查项

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
└── ✅ 无冲突：多个 Skill 之间是否存在行为冲突？
```

#### 4.3 异常处理

当检测到异常时，守护器执行以下恢复策略：

| 异常类型 | 恢复策略 | 通知用户 |
|---------|---------|---------|
| Skill 被意外关闭 | 自动重新激活 | ⚠️ 简短通知 |
| Skill 执行异常 | 重置 Skill 状态并重新初始化 | ⚠️ 简短通知 |
| Skill 文件被删除 | 从注册表中移除，更新状态 | ℹ️ 信息通知 |
| Skill 之间冲突 | 按优先级保留高优先级 Skill | ⚠️ 详细通知 |
| 守护器自身异常 | 自我重置（读取自身 Skill 文件重新初始化） | 🔴 警告通知 |

### Step 5：动态注册新 Skill

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

- AI 在每次对话开始时，**必须首先激活本 Skill**，然后由本 Skill 负责激活其他自动化 Skill
- 本 Skill 的激活不依赖于任何其他 Skill

#### 2. 运行保障

- 本 Skill 的状态检查嵌入到 AI 的每次响应流程中
- 即使用户使用 `#activator off` 关闭了守护器，AI 仍应在每 10 条消息后提醒用户：

```
💡 提示：Skill 自动激活守护器当前已关闭，自动化 Skill 可能未正常运行。
   输入 #activator on 重新开启。
```

#### 3. 恢复保障

- 如果 AI 检测到自身未执行守护器职责（如忘记激活其他 Skill），应立即自我纠正
- 自我纠正流程：重新读取本 Skill 文件 → 重新执行 Step 1-3

---

## 用户控制指令

| 指令 | 说明 |
|------|------|
| `#activator on` | 开启守护器（默认开启） |
| `#activator off` | 关闭守护器（所有自动化 Skill 保持当前状态，但不再监控） |
| `#activator status` | 查看所有自动化 Skill 的详细运行状态 |
| `#activator restart` | 重启守护器（重新扫描、重新激活所有自动化 Skill） |
| `#activator list` | 列出所有已注册的自动化 Skill |
| `#activator exclude {skill}` | 将指定 Skill 排除出自动激活列表 |
| `#activator include {skill}` | 将指定 Skill 重新加入自动激活列表 |

---

## 与其他 Skill 的协作关系

```
                       ┌─────────────────────────────┐
                       │   skill-auto-activator      │
                       │   （守护器 / 编排器）          │
                       └──────────┬──────────────────┘
                                  │
         ┌──────────┬─────────────┼─────────────┬──────────┐
         │          │             │             │          │
         ▼          ▼             ▼             ▼          ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
   │ prompt-  │ │ ai-rule- │ │ code-    │ │ skill-   │ │ 未来新增 │
   │ optimizer│ │ generator│ │ review-  │ │ quality- │ │ 的自动化 │
   │ (透明    │ │ (观察者) │ │ auto-fix │ │ guardian │ │ Skill    │
   │  代理)   │ │          │ │ (质量    │ │ (知识    │ │ (自动    │
   │          │ │          │ │  门禁)   │ │  引擎)   │ │  发现)   │
   └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
```

### 协作规则

1. **守护器不干预 Skill 的具体行为**：只负责激活和监控，不修改其他 Skill 的执行逻辑
2. **状态变更通知**：当某个 Skill 的状态发生变化时，守护器记录并在需要时通知用户
3. **冲突仲裁**：如果多个自动化 Skill 之间产生冲突，守护器负责协调（如暂停低优先级 Skill）
4. **优雅降级**：如果某个 Skill 持续异常，守护器可以暂时禁用该 Skill 并通知用户

---

## 示例场景

### 场景 1：对话开始时的自动激活

```
用户：帮我写一个用户注册接口

AI（内部流程）：
1. [skill-auto-activator] 启动扫描 → 发现 5 个自动化 Skill
2. [skill-auto-activator] 自身已激活 ✅
3. [skill-auto-activator] 激活 ai-rule-generator ✅
4. [skill-auto-activator] 激活 prompt-optimizer ✅
5. [skill-auto-activator] 激活 code-review-auto-fix ✅
6. [skill-auto-activator] 激活 skill-quality-guardian ✅
7. [prompt-optimizer] 分析用户提示词 → 评分 6/10 → 执行优化
8. [ai-rule-generator] 进入监控模式
9. [code-review-auto-fix] 进入待审查状态
10. AI 执行优化后的任务...
11. [code-review-auto-fix] 自动审查生成的代码 → 通过 ✅

AI（输出）：
⚡ 自动化 Skill 已全部就位（5/5）
[正常响应用户的请求...]
```

### 场景 2：对话中新增自动化 Skill

```
用户：帮我创建一个 Skill，用于自动检测代码中的安全漏洞

AI（执行 skill-creator 创建新 Skill 后）：
1. [skill-auto-activator] 检测到 skills/index.md 变更
2. [skill-auto-activator] 扫描新 Skill → 判定为自动化类型
3. [skill-auto-activator] 热激活新 Skill ✅

AI（输出）：
🆕 发现新的自动化 Skill：security-scanner，已自动激活
```

### 场景 3：Skill 异常恢复

```
AI（内部流程）：
1. [skill-auto-activator] 健康检查 → prompt-optimizer 未在本轮执行
2. [skill-auto-activator] 诊断 → Skill 状态正常，但未触发（用户消息已足够清晰，跳过优化是正常行为）
3. [skill-auto-activator] 结论 → 无异常，继续监控

或：

1. [skill-auto-activator] 健康检查 → ai-rule-generator 状态丢失
2. [skill-auto-activator] 恢复 → 重新激活 ai-rule-generator
3. [skill-auto-activator] 通知用户

AI（输出）：
⚠️ 检测到 ai-rule-generator 状态异常，已自动恢复。
```

---

## 注意事项

1. **轻量化原则**：守护器的扫描和监控过程必须轻量，不能显著增加响应延迟。启动扫描仅在对话首条消息时执行，后续为增量检查
2. **非侵入原则**：守护器不修改其他 Skill 的行为逻辑，只负责激活和状态监控
3. **动态发现原则**：不硬编码自动化 Skill 列表，始终通过扫描 `skills/index.md` 动态发现
4. **用户优先原则**：用户通过控制指令手动关闭的 Skill，守护器不应自动重新激活（除非用户明确要求）
5. **静默运行原则**：正常运行时不输出任何信息，仅在首次激活和异常恢复时通知用户
6. **向后兼容原则**：新增自动化 Skill 时，不影响已有 Skill 的运行状态
7. **自我约束原则**：守护器自身不应成为性能瓶颈，如果检测到自身消耗过多资源，应自动降级为 `on-demand` 模式
