# AI Skills & Rules — CodeBuddy 自动加载规则

> 本文件由 CodeBuddy 自动读取。当本仓库作为子模块或平级目录存在时，CodeBuddy 会自动加载以下规则和 Skill 体系。

## 启动指令

每次新对话开始时，你必须：

1. 读取 `rules/common/rule.md` — 核心协作开发规范（强制遵守）
2. 读取 `skills/index.md` — Skill 索引与工作流编排
3. 根据项目语言，读取 `rules/languages/` 下对应的规则文件

## 核心规则（强制遵守）

以下规则文件定义了 AI 协作开发的强制规范，AI 必须严格遵守所有标注「强制」的规则：

- `rules/common/rule.md` — 核心协作开发规范
- `rules/common/api-design.md` — API 设计规范
- `rules/common/error-handling.md` — 错误处理规范
- `rules/common/database.md` — 数据库操作规范

## Skill 索引（按需加载）

- `skills/index.md` — Skill 索引与工作流编排

## 核心行为约束

- 写代码前必须输出「📋 任务启动清单」
- 写完代码后必须输出「✅ 任务完成清单」
- 新功能触发完整开发工作流：brainstorming → writing-plans → subagent-driven-development → TDD → code-review → verification
- Bug 修复触发：systematic-debugging → TDD → verification
- 禁止猜测：缺少关键参考文件时，禁止凭空猜测字段名/类型/结构体定义
- 先读后改：修改已有功能时，必须先读取目标文件完整内容
- 必须参考范本：生成新代码时，必须找到同类实体的现有实现作为范本

## 一键冷启动

用户发送 `#start` 时，读取并执行 `skills/meta/skill-auto-activator.md` 完成完整启动序列。

## 代码质量自检（每段代码生成后必须逐项检查）

- 架构合规：各层职责正确，无越层调用
- 数据安全：参数化查询，无 SQL 拼接
- 错误处理：400/404/500 分类正确，无忽略的错误
- 边界条件：空值/nil/空数组处理
- 代码规范：导出符号有文档注释，统一响应格式
- 性能：无 N+1 查询，大数据量有分页
