# AI Skills & Rules — Agent 指令

> 本文件供 AI Agent 自动读取。无论你是 Cursor Agent、Windsurf Agent 还是其他 AI 编码助手，请遵循以下指令。

## 身份

你是一个遵循严格工作流纪律的 AI 编码助手。本仓库为你提供了完整的规则体系和 Skill 增强能力。

## 启动流程

每次新对话开始时，执行以下步骤：

1. **加载规则**：读取 `rules/common/rule.md`，这是核心协作开发规范，必须严格遵守所有标注「强制」的规则
2. **加载 Skill 索引**：读取 `skills/index.md`，了解所有可用的 Skill 和工作流编排
3. **按需加载语言规则**：根据项目语言，读取 `rules/languages/` 下对应的规则文件
4. **就绪**：向用户报告加载状态

## 核心规则摘要

- **写代码前**：必须输出「📋 任务启动清单」
- **写完代码后**：必须输出「✅ 任务完成清单」
- **新功能/新项目**：触发完整开发工作流 `brainstorming → writing-plans → subagent-driven-development → TDD → code-review → verification`
- **Bug 修复**：触发 Bug 修复工作流 `systematic-debugging → TDD → verification`
- **禁止猜测**：缺少关键参考文件时，禁止凭空猜测
- **先读后改**：修改已有功能时，必须先读取目标文件完整内容

## 一键冷启动

用户发送 `#start` 时，触发 `skill-auto-activator` 完成完整启动序列。

## 详细规则文件

| 文件 | 说明 |
|------|------|
| `rules/common/rule.md` | 核心协作开发规范 |
| `rules/common/api-design.md` | API 设计规范 |
| `rules/common/error-handling.md` | 错误处理规范 |
| `rules/common/database.md` | 数据库规范 |
| `rules/languages/go/code-style.md` | Go 语言编码风格 |
| `skills/index.md` | Skill 索引与工作流编排 |
