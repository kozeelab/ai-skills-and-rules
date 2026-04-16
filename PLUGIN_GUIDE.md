# AI Skills & Rules — 插件化使用指南

> 本仓库是一个**可插拔的 AI 增强插件**，可以为任何 AI 编码助手（Cursor、Windsurf、Copilot、Claude Code、Gemini CLI 等）注入完整的工作流纪律、代码质量保障和自进化规则体系。

## 快速开始

### 1. 克隆仓库

```bash
# 放在你的项目平级目录下
cd /path/to/your/projects
git clone https://github.com/kozeelab/ai-skills-and-rules.git
```

### 2. 配置 AI 工具

#### 方式 A：原生自动加载（推荐）

本仓库已为主流 AI 编码工具提供了原生入口文件，**无需手动配置**，工具会自动识别并加载：

| AI 工具 | 入口文件 | 加载方式 |
|---------|---------|----------|
| **Claude Code** | `CLAUDE.md` | 自动读取项目根目录的 CLAUDE.md |
| **Gemini CLI** | `GEMINI.md` + `gemini-extension.json` | 通过 extension.json 注册插件 |
| **Cursor** | `.cursorrules` | 自动读取项目级规则 |
| **Cursor Agent** | `AGENTS.md` | Agent 模式自动读取 |
| **通用 Agent** | `AGENTS.md` | 作为 Agent 指令入口 |

只需将本仓库克隆到项目目录下（作为子模块或平级目录），对应工具即可自动加载。

#### 方式 B：手动配置（通用方式）

如果你的 AI 工具不在上述列表中，可以在自定义指令（Custom Instructions / User Rules）中添加：

```
每次开启全新对话时，你必须首先执行以下操作：
1. 读取项目平级目录下的 ai-skills-and-rules 仓库
2. 遵守 rules/ 目录下的所有规则
3. 当需要使用 skill 时，优先查看 skills/index.md 索引匹配合适的 Skill
```

### 3. 一键冷启动（推荐）

在每次新对话中发送：

```
#start
```

AI 会自动加载所有规则 + 激活所有自动化 Skill + 就绪所有工作流 Skill。

## 仓库架构

```
ai-skills-and-rules/
├── CLAUDE.md                 ← Claude Code 自动加载入口
├── GEMINI.md                 ← Gemini CLI 自动加载入口
├── gemini-extension.json     ← Gemini CLI 插件注册
├── AGENTS.md                 ← Cursor Agent / 通用 Agent 入口
├── .cursorrules              ← Cursor 自动加载规则
├── PLUGIN_GUIDE.md           ← 插件使用指南（本文件）
│
├── rules/                    ← 规则体系（AI 行为约束）
│   ├── index.md              ← 规则索引
│   ├── common/               ← 通用规则（所有项目适用）
│   └── languages/            ← 语言特定规则（按需加载）
│
└── skills/                   ← Skill 体系（AI 能力增强）
    ├── index.md              ← Skill 索引（含工作流编排）
    │
    ├── 📦 元能力层            ← 你的独有优势
    │   ├── skill-auto-activator.md    一键冷启动
    │   ├── ai-rule-generator.md       规则自进化
    │   ├── skill-quality-guardian.md   Skill 质量守护
    │   ├── prompt-optimizer.md        提示词优化
    │   └── skill-creator.md           Skill 创建器
    │
    ├── 🔗 工作流层            ← 开发流程纪律
    │   ├── brainstorming/             需求探索与设计
    │   ├── writing-plans/             实现计划编写
    │   ├── test-driven-development/   测试驱动开发
    │   ├── systematic-debugging/      系统化调试
    │   ├── verification-before-completion/  完成前验证
    │   └── subagent-driven-development/    子代理驱动开发
    │
    └── 🧰 工具层              ← 实用工具
        ├── code-review-auto-fix.md    代码审查
        ├── project-summary.md         项目总结
        ├── git-multi-env.md           Git 多环境
        └── awesome-design.md          设计系统
```

## 核心工作流

### 完整开发工作流（新功能/新项目）

```
brainstorming → writing-plans → subagent-driven-development → TDD → code-review → verification
```

### Bug 修复工作流

```
systematic-debugging → TDD → verification
```

## 与 superpowers 的对比

| 维度 | obra/superpowers | 本仓库 |
|------|-----------------|--------|
| 工作流闭环 | ✅ | ✅ |
| 对抗性设计 | ✅ | ✅ |
| 元数据规范 | ❌ 极简 | ✅ 完整 YAML |
| 索引管理 | ❌ | ✅ 动态索引 |
| 规则自进化 | ❌ | ✅ |
| Skill 质量保障 | ❌ | ✅ |
| 一键冷启动 | ❌ | ✅ |
| 提示词优化 | ❌ | ✅ |
| 中文支持 | ❌ | ✅ |
| 插件化使用 | ⚠️ 需配置 | ✅ 即插即用 |
| 多平台原生支持 | ✅ Claude/Gemini/Cursor | ✅ Claude/Gemini/Cursor/通用 Agent |

## 自定义与扩展

### 添加项目特定规则

在 `rules/` 目录下添加你的项目规则：

```bash
# 添加新的通用规则
echo "# 你的规则" > rules/common/your-rule.md

# 添加语言特定规则
echo "# 你的规则" > rules/languages/python/code-style.md
```

### 创建自定义 Skill

使用 `skill-creator` Skill 快速创建：

```
帮我创建一个 Skill，用于 [你的需求]
```

或手动创建：
- 简单 Skill：`skills/your-skill.md`
- 复杂 Skill：`skills/your-skill/SKILL.md` + 附属文件

### 关闭不需要的功能

```
#start --exclude=prompt-optimizer,skill-quality-guardian
```

## 许可

MIT License
