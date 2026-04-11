# Skill 创建器 Skill

## 功能说明

此 Skill 用于创建**可分发的 Skill 包**（`.zip` 或 `.skill` 文件），每个 Skill 包的根目录包含一个 `SKILL.md` 元数据文件（YAML 格式），用于描述技能的名称、描述等信息。

- 标准化 Skill 的创建流程，确保每个 Skill 包结构一致
- `SKILL.md` 采用 YAML Front Matter + Markdown 正文的格式，兼顾机器可读和人类可读
- 产物为 `.zip` 或 `.skill` 文件（`.skill` 本质是 `.zip`，仅更改扩展名以便识别）

> **核心目标**：提供一套标准化的 Skill 创建流程，让 AI 能够快速生成结构规范、可分发的 Skill 包。

---

## Skill 包结构规范

### 目录结构

```
my-skill/
├── SKILL.md              ← 【必需】技能元数据文件（YAML Front Matter + 正文）
├── README.md             ← 【可选】详细使用说明
├── templates/            ← 【可选】模板文件目录
│   └── ...
├── scripts/              ← 【可选】脚本文件目录
│   └── ...
├── examples/             ← 【可选】示例文件目录
│   └── ...
└── assets/               ← 【可选】静态资源目录
    └── ...
```

### SKILL.md 文件格式

`SKILL.md` 是 Skill 包的核心文件，位于包的根目录。采用 **YAML Front Matter + Markdown 正文** 的格式：

```markdown
---
# ===== 基本信息（必填）=====
name: "skill-name"                    # 技能唯一标识（英文，kebab-case）
displayName: "技能显示名称"             # 技能显示名称（支持中文）
description: "一句话描述这个技能的功能"   # 简要描述
version: "1.0.0"                      # 语义化版本号

# ===== 作者信息（必填）=====
author:
  name: "作者名"
  url: "https://github.com/username"  # 可选

# ===== 分类与标签（必填）=====
category: "development"               # 分类（见下方分类表）
tags:                                  # 关键词标签
  - "标签1"
  - "标签2"

# ===== 兼容性（可选）=====
compatibility:
  platforms:                           # 支持的平台
    - "linux"
    - "macos"
    - "windows"
  languages:                           # 适用的编程语言（如果有限制）
    - "any"
  tools:                               # 依赖的外部工具
    - "git"

# ===== 输入输出（必填）=====
input:
  description: "描述此技能需要的输入"
  required:                            # 必需的输入
    - name: "参数名"
      type: "string"
      description: "参数描述"
  optional:                            # 可选的输入
    - name: "参数名"
      type: "string"
      description: "参数描述"
      default: "默认值"

output:
  description: "描述此技能的输出产物"
  artifacts:                           # 输出产物列表
    - name: "产物名"
      type: "file"
      description: "产物描述"
---

# 技能名称

## 功能说明

在此详细描述技能的功能...

## AI 执行流程

### Step 1：...

### Step 2：...

## 注意事项

- ...
```

### 分类表

| 分类值 | 说明 |
|--------|------|
| `development` | 开发工具与流程 |
| `design` | 设计与 UI |
| `devops` | 运维与部署 |
| `documentation` | 文档生成 |
| `testing` | 测试相关 |
| `security` | 安全相关 |
| `data` | 数据处理 |
| `productivity` | 效率工具 |
| `other` | 其他 |

---

## AI 执行流程

### 用户输入格式

用户可以通过以下方式触发此 Skill：

```
帮我创建一个 Skill，用于 XXX
```

```
帮我把 XXX 功能打包成一个可分发的 Skill
```

```
创建一个新的 .skill 文件，功能是 XXX
```

### AI 执行步骤

#### Step 1：收集技能信息

通过与用户交互，确认以下信息：

| 信息 | 是否必需 | 说明 |
|------|----------|------|
| 技能名称 | ✅ | 英文 kebab-case 标识 + 中文显示名 |
| 功能描述 | ✅ | 一句话描述 |
| 分类 | ✅ | 从分类表中选择 |
| 标签 | ✅ | 关键词列表 |
| 输入参数 | ✅ | 技能需要的输入 |
| 输出产物 | ✅ | 技能的输出 |
| 平台兼容性 | ❌ | 默认全平台 |
| 详细执行流程 | ✅ | 技能的具体步骤 |

> 如果用户已经提供了足够信息，AI 应直接推断并填充，无需逐项询问。

#### Step 2：创建 Skill 目录结构

在临时目录中创建 Skill 包的目录结构：

```bash
# 创建 Skill 目录
SKILL_NAME="my-skill"
SKILL_DIR="/tmp/${SKILL_NAME}"
mkdir -p "${SKILL_DIR}"
```

#### Step 3：生成 SKILL.md 文件

根据收集到的信息，生成 `SKILL.md` 文件。**必须严格遵循上方的 SKILL.md 文件格式**，包含完整的 YAML Front Matter 和 Markdown 正文。

正文部分应包含：
1. **功能说明**：详细描述技能的功能
2. **AI 执行流程**：分步骤描述 AI 如何执行此技能
3. **注意事项**：使用时的注意事项和限制

#### Step 4：添加附属文件（可选）

根据技能的复杂度，可选择性添加：

- `README.md`：面向人类的详细使用说明
- `templates/`：模板文件（如代码模板、配置模板）
- `scripts/`：辅助脚本
- `examples/`：使用示例

#### Step 5：打包为 .skill 或 .zip 文件

```bash
# 打包为 .zip
cd /tmp && zip -r "${SKILL_NAME}.zip" "${SKILL_NAME}/"

# 或打包为 .skill（本质是 .zip，仅更改扩展名）
cd /tmp && zip -r "${SKILL_NAME}.skill" "${SKILL_NAME}/"
```

#### Step 6：输出结果

向用户展示：

1. 生成的文件路径
2. SKILL.md 的内容预览
3. 包内文件列表
4. 使用说明

---

## SKILL.md 编写规范

### YAML Front Matter 规范

1. **name**：必须是英文 kebab-case 格式（如 `git-multi-env`），全局唯一
2. **displayName**：支持中文，用于展示
3. **description**：一句话，不超过 100 字
4. **version**：遵循 [语义化版本](https://semver.org/lang/zh-CN/)（MAJOR.MINOR.PATCH）
5. **tags**：3-8 个关键词，便于搜索和匹配
6. **input/output**：必须清晰定义，让 AI 知道需要什么、产出什么

### Markdown 正文规范

1. **功能说明**：用 `>` 引用块突出核心目标
2. **AI 执行流程**：每个步骤用 `#### Step N：标题` 格式，步骤内容要具体可执行
3. **注意事项**：用有序或无序列表列出

### 质量检查清单

生成 SKILL.md 后，AI 必须自检：

- [ ] YAML Front Matter 语法正确（可被解析）
- [ ] 所有必填字段已填写
- [ ] name 为 kebab-case 格式
- [ ] version 为语义化版本格式
- [ ] description 简洁明了，不超过 100 字
- [ ] tags 数量在 3-8 个之间
- [ ] input/output 定义清晰
- [ ] 正文包含完整的功能说明和执行流程
- [ ] 执行流程的每个步骤具体可执行，无模糊描述

---

## 示例：创建一个简单的 Skill

### 输入

```
帮我创建一个 Skill，用于快速初始化 Go 项目结构
```

### 生成的 SKILL.md

```markdown
---
name: "go-project-init"
displayName: "Go 项目初始化"
description: "快速生成标准化的 Go 项目目录结构，包含常用配置文件和代码模板"
version: "1.0.0"

author:
  name: "kozee"
  url: "https://github.com/kozeelab"

category: "development"
tags:
  - "go"
  - "golang"
  - "项目初始化"
  - "脚手架"
  - "模板"

compatibility:
  platforms:
    - "linux"
    - "macos"
    - "windows"
  languages:
    - "go"
  tools:
    - "go"
    - "git"

input:
  description: "项目名称和基本配置信息"
  required:
    - name: "project_name"
      type: "string"
      description: "项目名称（用作 go module 名和目录名）"
  optional:
    - name: "module_path"
      type: "string"
      description: "Go module 路径"
      default: "github.com/username/project_name"
    - name: "with_docker"
      type: "boolean"
      description: "是否包含 Dockerfile"
      default: "true"

output:
  description: "完整的 Go 项目目录结构"
  artifacts:
    - name: "项目目录"
      type: "directory"
      description: "包含标准目录结构、配置文件和代码模板的 Go 项目"
---

# Go 项目初始化

## 功能说明

快速生成标准化的 Go 项目目录结构...

## AI 执行流程

### Step 1：确认项目信息
...

### Step 2：创建目录结构
...
```

### 打包产物

```
go-project-init.skill (或 .zip)
├── SKILL.md
├── templates/
│   ├── main.go.tmpl
│   ├── Makefile.tmpl
│   └── Dockerfile.tmpl
└── examples/
    └── demo-project/
```

---

## 注意事项

1. `.skill` 文件本质是 `.zip` 格式，仅通过扩展名区分，方便识别和管理
2. `SKILL.md` 必须位于包的根目录（解压后的第一层）
3. YAML Front Matter 必须以 `---` 开头和结尾，中间为合法的 YAML
4. 技能的 `name` 字段应全局唯一，建议使用有意义的 kebab-case 命名
5. 如果技能依赖外部工具（如 git、docker），必须在 `compatibility.tools` 中声明
6. 打包时不要包含 `.git/`、`node_modules/` 等无关目录