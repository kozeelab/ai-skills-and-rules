# AI Skills & Rules — Claude Code 自动加载入口

> 本文件由 Claude Code 自动读取。当本仓库作为子模块或平级目录存在时，Claude Code 会自动加载以下规则和 Skill 体系。

## 核心规则（强制遵守）

@./rules/common/rule.md
@./rules/common/api-design.md
@./rules/common/error-handling.md
@./rules/common/database.md

## Skill 索引（按需加载）

@./skills/index.md

## 使用说明

1. **规则体系**：上述规则文件定义了 AI 协作开发的强制规范，包括架构约束、代码质量自检、索引维护等。AI 必须严格遵守所有标注「强制」的规则。
2. **Skill 体系**：当用户的需求匹配特定 Skill 时，AI 应按 `skills/index.md` 中的工作流编排执行。
3. **一键冷启动**：发送 `#start` 可触发完整的规则加载 + Skill 激活流程。
4. **语言特定规则**：根据项目语言，按需加载 `rules/languages/` 目录下的对应规则文件。
