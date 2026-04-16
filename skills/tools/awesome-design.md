---
name: "awesome-design"
displayName: "Awesome Design"
description: "从 awesome-design-md 仓库获取知名品牌设计系统，生成 DESIGN.md 文件，让 AI 生成风格一致的 UI"
version: "1.0.0"

author:
  name: "kozee"
  url: "https://github.com/kozeelab"

category: "design"
tags:
  - "DESIGN.md"
  - "设计系统"
  - "UI"
  - "设计模板"
  - "品牌设计"

compatibility:
  platforms:
    - "linux"
    - "macos"
    - "windows"
  languages:
    - "any"
  tools:
    - "curl"

input:
  description: "用户选择的品牌名称或项目类型"
  required:
    - name: "brand_name"
      type: "string"
      description: "目标品牌名称（如 vercel、stripe、claude 等），用于获取对应的 DESIGN.md"
  optional:
    - name: "project_type"
      type: "string"
      description: "项目类型（如开发者工具、SaaS、AI 产品等），用于推荐合适的设计风格"
      default: ""

output:
  description: "在项目根目录生成对应的 DESIGN.md 文件"
  artifacts:
    - name: "design_md"
      type: "file"
      description: "目标品牌的 DESIGN.md 设计系统文件"
---

# Awesome DESIGN.md Skill

## 功能说明

此 Skill 用于利用 [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) 仓库中的 **DESIGN.md** 文件，让 AI 编码助手生成与知名网站风格一致的 UI 界面。

- **DESIGN.md** 是由 Google Stitch 提出的概念：一种纯文本设计系统文档，AI 可以直接读取并据此生成一致的 UI
- 仓库收录了 **58+** 个知名网站的设计系统文件，涵盖 AI、开发工具、设计、金融、汽车等多个领域
- 无需 Figma 导出、JSON Schema 或特殊工具，只需一个 Markdown 文件

> **核心目标**：将目标网站的 DESIGN.md 放入项目根目录，AI 即可据此生成风格一致、像素级匹配的 UI。

---

## DESIGN.md 文件结构

每个 DESIGN.md 遵循 [Stitch DESIGN.md 格式](https://stitch.withgoogle.com/docs/design-md/format/)，包含以下标准章节：

| # | 章节 | 内容 |
|---|------|------|
| 1 | Visual Theme & Atmosphere | 整体风格、视觉密度、设计哲学 |
| 2 | Color Palette & Roles | 语义化颜色名 + Hex 值 + 功能角色 |
| 3 | Typography Rules | 字体族、完整的排版层级表 |
| 4 | Component Stylings | 按钮、卡片、输入框、导航等组件及其状态 |
| 5 | Layout Principles | 间距比例、网格系统、留白哲学 |
| 6 | Depth & Elevation | 阴影系统、层级关系 |
| 7 | Do's and Don'ts | 设计护栏和反模式 |
| 8 | Responsive Behavior | 断点、触控目标、折叠策略 |
| 9 | Agent Prompt Guide | 快速颜色参考、可直接使用的提示词 |

每个网站还附带：

| 文件 | 用途 |
|------|------|
| `DESIGN.md` | 设计系统文档（AI 读取的核心文件） |
| `preview.html` | 可视化目录：色板、字体比例、按钮、卡片预览 |
| `preview-dark.html` | 暗色主题版本的可视化目录 |

---

## 可用的设计系统列表

### AI & 机器学习
| 网站 | 风格描述 |
|------|----------|
| [Claude](https://getdesign.md/claude/design-md) | 暖色赤陶色调，干净的编辑式布局 |
| [Cohere](https://getdesign.md/cohere/design-md) | 鲜艳渐变，数据丰富的仪表盘风格 |
| [ElevenLabs](https://getdesign.md/elevenlabs/design-md) | 暗色电影感 UI，音频波形美学 |
| [Mistral AI](https://getdesign.md/mistral.ai/design-md) | 法式极简主义，紫色调 |
| [Ollama](https://getdesign.md/ollama/design-md) | 终端优先，单色简约 |
| [Replicate](https://getdesign.md/replicate/design-md) | 干净白色画布，代码优先 |
| [VoltAgent](https://getdesign.md/voltagent/design-md) | 纯黑画布，翡翠绿强调色，终端原生 |

### 开发工具 & 平台
| 网站 | 风格描述 |
|------|----------|
| [Cursor](https://getdesign.md/cursor/design-md) | 精致暗色界面，渐变强调色 |
| [Linear](https://getdesign.md/linear.app/design-md) | 超极简，精确，紫色强调 |
| [Vercel](https://getdesign.md/vercel/design-md) | 黑白精确，Geist 字体 |
| [Supabase](https://getdesign.md/supabase/design-md) | 暗色翡翠主题，代码优先 |
| [Raycast](https://getdesign.md/raycast/design-md) | 精致暗色铬，鲜艳渐变强调 |
| [Resend](https://getdesign.md/resend/design-md) | 极简暗色主题，等宽字体强调 |
| [Sentry](https://getdesign.md/sentry/design-md) | 暗色仪表盘，数据密集，粉紫强调 |
| [PostHog](https://getdesign.md/posthog/design-md) | 刺猬品牌，开发者友好暗色 UI |
| [Warp](https://getdesign.md/warp/design-md) | 现代终端，暗色 IDE 风格界面 |
| [Stripe](https://getdesign.md/stripe/design-md) | 标志性紫色渐变，font-weight 300 优雅感 |

### 设计 & 生产力
| 网站 | 风格描述 |
|------|----------|
| [Figma](https://getdesign.md/figma/design-md) | 多彩活泼，专业又不失趣味 |
| [Notion](https://getdesign.md/notion/design-md) | 温暖极简，衬线标题，柔和表面 |
| [Framer](https://getdesign.md/framer/design-md) | 大胆黑蓝，动效优先 |
| [Webflow](https://getdesign.md/webflow/design-md) | 蓝色强调，精致营销网站风格 |

### 金融 & 加密
| 网站 | 风格描述 |
|------|----------|
| [Coinbase](https://getdesign.md/coinbase/design-md) | 干净蓝色，信任导向，机构感 |
| [Revolut](https://getdesign.md/revolut/design-md) | 精致暗色界面，渐变卡片，金融科技精确感 |

### 企业 & 消费者
| 网站 | 风格描述 |
|------|----------|
| [Apple](https://getdesign.md/apple/design-md) | 高端留白，SF Pro 字体，电影感图像 |
| [Airbnb](https://getdesign.md/airbnb/design-md) | 暖珊瑚强调色，摄影驱动，圆角 UI |
| [Spotify](https://getdesign.md/spotify/design-md) | 暗底鲜绿，粗体排版，专辑封面驱动 |
| [Uber](https://getdesign.md/uber/design-md) | 大胆黑白，紧凑排版，都市能量 |
| [SpaceX](https://getdesign.md/spacex/design-md) | 纯粹黑白，全出血图像，未来感 |
| [Tesla](https://getdesign.md/tesla/design-md) | 极致减法，电影级全视口摄影 |

### 汽车品牌
| 网站 | 风格描述 |
|------|----------|
| [BMW](https://getdesign.md/bmw/design-md) | 暗色高端表面，精确的德式工程美学 |
| [Ferrari](https://getdesign.md/ferrari/design-md) | 明暗对比编辑风格，法拉利红极致留白 |
| [Lamborghini](https://getdesign.md/lamborghini/design-md) | 纯黑殿堂，金色强调，定制新怪诞字体 |

> **完整列表**请参考：https://github.com/VoltAgent/awesome-design-md

---

## AI 执行流程

### 用户输入格式

用户可以通过以下方式触发此 Skill：

```
帮我用 Vercel 的设计风格创建一个落地页
```

```
我想让我的项目 UI 看起来像 Linear，帮我配置 DESIGN.md
```

```
帮我下载 Stripe 的 DESIGN.md 到项目中
```

### AI 执行步骤

#### Step 1：确认目标设计风格

根据用户需求，从上方「可用的设计系统列表」中匹配目标网站。如果用户未指定具体网站，根据项目类型推荐合适的设计风格：

| 项目类型 | 推荐风格 |
|----------|----------|
| 开发者工具 / CLI | Vercel、Warp、Raycast |
| SaaS 产品 / 仪表盘 | Linear、Sentry、PostHog |
| AI 产品 | Claude、VoltAgent |
| 文档站点 | Mintlify、Notion |
| 电商 / 消费者产品 | Airbnb、Apple |
| 金融产品 | Stripe、Coinbase、Revolut |

#### Step 2：获取 DESIGN.md 文件

从 `getdesign.md` 网站下载对应的 DESIGN.md 文件到项目根目录：

```bash
# 示例：下载 Vercel 的 DESIGN.md
curl -sL "https://getdesign.md/vercel/design-md" -o DESIGN.md
```

> ⚠️ **注意**：`getdesign.md` 网站返回的是网页而非纯文本。如果 curl 下载的内容不是纯 Markdown，需要从 GitHub 仓库直接获取：
>
> ```bash
> # 从 GitHub 仓库直接获取（推荐）
> curl -sL "https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/designs/{网站名}/DESIGN.md" -o DESIGN.md
> ```

#### Step 3：将 DESIGN.md 放入项目

将下载的 DESIGN.md 文件放置在项目根目录：

```
项目根目录/
├── DESIGN.md          ← 设计系统文件
├── AGENTS.md          ← （可选）编码规范文件
├── src/
└── ...
```

#### Step 4：基于 DESIGN.md 生成 UI

AI 在生成 UI 代码时，**必须读取并遵循项目根目录下的 DESIGN.md**，确保：

1. **颜色**：严格使用 DESIGN.md 中定义的色板和语义化颜色角色
2. **排版**：使用指定的字体族和排版层级
3. **组件**：按照定义的组件样式（按钮、卡片、输入框等）及其状态来实现
4. **布局**：遵循间距比例、网格系统和留白哲学
5. **深度**：使用定义的阴影系统和层级关系
6. **响应式**：遵循断点和折叠策略
7. **Do's and Don'ts**：避免反模式，遵循设计护栏

---

## 注意事项

1. DESIGN.md 中的设计 Token 来自公开可见的 CSS 值，仓库不声明对任何网站视觉标识的所有权
2. 这些文件旨在帮助 AI 生成一致的 UI，而非用于商业品牌冒充
3. 如果需要自定义设计系统，可以基于现有 DESIGN.md 进行修改，调整颜色、字体等以适配自己的品牌
4. 仓库持续更新中，如需特定网站的 DESIGN.md，可在 https://getdesign.md/request 提交请求