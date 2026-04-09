# Git SSH Key 多环境隔离 Skill

## 功能说明

此 Skill 用于配置 Git 多环境隔离，实现：
- **SSH Key 隔离**：不同代码托管平台（GitHub、Gitee、公司内部仓库等）使用不同的 SSH 密钥
- **用户身份隔离**：根据远程仓库 URL（域名）自动切换 `user.name` 和 `user.email`，**无需按目录分类存放项目**

> **核心目标**：一台机器上同时管理多个 Git 平台账号，互不干扰，自动切换。即使所有项目都放在同一个目录下，也能根据远程仓库域名自动使用正确的身份。

---

## AI 执行流程

> **极简交互**：用户只需提供 **域名、用户名、邮箱**，AI 直接执行所有配置并输出公钥。

### 用户输入格式

用户只需告诉 AI 以下信息（支持一次配置多个平台）：

```
帮我生成 SSH Key：
- 域名：github.com，用户名：zhangsan，邮箱：zhangsan@gmail.com
- 域名：gitee.com，用户名：张三，邮箱：zhangsan@163.com
- 域名：git.company.com，用户名：san.zhang，邮箱：san.zhang@company.com
```

### AI 执行步骤

收到用户信息后，AI **按顺序自动执行以下所有步骤**，无需额外确认：

#### Step 1：从域名提取平台标识

从域名中提取简短标识，用于命名密钥文件：

| 域名 | 平台标识 | 密钥文件名 |
|------|----------|-----------|
| `github.com` | `github` | `id_ed25519_github` |
| `gitee.com` | `gitee` | `id_ed25519_gitee` |
| `git.company.com` | `company`（取第二段） | `id_ed25519_company` |
| `gitlab.example.org` | `example`（取第二段） | `id_ed25519_example` |

> 提取规则：优先使用知名平台名（github/gitee/gitlab），否则取域名第二段作为标识。

#### Step 2：生成 SSH 密钥对

为每个平台执行密钥生成命令：

```bash
ssh-keygen -t ed25519 -C "{EMAIL}" -f ~/.ssh/id_ed25519_{PLATFORM} -N ""
```

> ⚠️ **注意**：
> - 如果密钥文件已存在，**先询问用户是否覆盖**，避免误删已有密钥
> - `-N ""` 表示不设置密码，方便自动化使用
> - 如果目标平台不支持 Ed25519（极少数老旧系统），改用 `-t rsa -b 4096`

#### Step 3：追加 SSH Config

向 `~/.ssh/config` 文件**追加**（不覆盖已有内容）该平台的配置：

```ssh-config
# ============================================
# {PLATFORM} ({HOST})
# ============================================
Host {HOST}
    HostName {HOST}
    User git
    IdentityFile ~/.ssh/id_ed25519_{PLATFORM}
    IdentitiesOnly yes
```

> ⚠️ **注意**：
> - 追加前检查文件中是否已存在该 Host 的配置，如果已存在则**更新**而非重复追加
> - `IdentitiesOnly yes` 是关键，强制只使用指定密钥，防止串用
> - 如果文件不存在，先创建并设置权限 `chmod 600 ~/.ssh/config`

#### Step 4：配置 Git 用户身份（基于远程仓库 URL 自动匹配）

利用 Git 的 `includeIf "hasconfig:remote.*.url:..."` 功能，**根据远程仓库的 URL 域名自动切换用户身份**。

> 💡 **为什么不用 `gitdir` 按目录匹配？**
> 因为用户的不同平台项目可能混放在同一个目录下（如 `~/projects/` 下同时有 GitHub 和公司仓库的项目），按目录无法区分。
> `hasconfig:remote.*.url` 是按仓库的实际远程地址匹配，无论项目放在哪个目录都能正确识别。

##### 4.1 在 `~/.gitconfig` 中追加条件包含

```ini
# 根据远程仓库 URL 自动切换身份
# 匹配所有远程地址包含 {HOST} 的仓库

[includeIf "hasconfig:remote.*.url:*{HOST}*"]
    path = ~/.gitconfig-{PLATFORM}
```

> ⚠️ **重要说明**：
> - `hasconfig:remote.*.url:` 需要 **Git 2.36+** 版本支持
> - 通配符 `*{HOST}*` 会匹配所有包含该域名的远程 URL（SSH 和 HTTPS 均可匹配）
> - 例如 `*github.com*` 会匹配 `git@github.com:user/repo.git` 和 `https://github.com/user/repo.git`
> - 追加前检查是否已存在该平台的 includeIf 配置，避免重复

##### 4.2 创建平台独立 gitconfig 文件

```ini
# ~/.gitconfig-{PLATFORM}
[user]
    name = {USERNAME}
    email = {EMAIL}
```

#### Step 5：输出公钥供用户复制

执行 `cat ~/.ssh/id_ed25519_{PLATFORM}.pub` 并将公钥内容直接展示给用户，同时告知添加路径：

```
🔑 {PLATFORM} ({HOST}) 的公钥如下，请复制到对应平台：

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... zhangsan@gmail.com

📋 添加路径：
- GitHub：Settings → SSH and GPG keys → New SSH key
- Gitee：设置 → SSH公钥 → 添加公钥
- GitLab：Preferences → SSH Keys → Add new key
```

#### Step 6：验证连接

```bash
ssh -T git@{HOST}
```

---

## 关键技术方案：基于远程 URL 的身份自动切换

### 方案对比

| 方案 | 匹配依据 | 优点 | 缺点 | 适用场景 |
|------|----------|------|------|----------|
| `includeIf "gitdir:..."` | 仓库所在目录 | 简单直观，Git 2.13+ 即支持 | 要求不同平台项目放在不同目录 | 项目按平台分目录存放 |
| `includeIf "hasconfig:remote.*.url:..."` | 远程仓库 URL | **项目可混放在任意目录** | 需要 Git 2.36+ | **项目混放在同一目录（推荐）** |
| 仓库级 `.git/config` 手动配置 | 每个仓库单独设置 | 最灵活 | 每个仓库都要手动配 | 极少数特殊仓库 |

### hasconfig 匹配规则详解

```ini
# 匹配所有远程 URL 包含 github.com 的仓库
[includeIf "hasconfig:remote.*.url:*github.com*"]
    path = ~/.gitconfig-github

# 匹配所有远程 URL 包含 gitee.com 的仓库
[includeIf "hasconfig:remote.*.url:*gitee.com*"]
    path = ~/.gitconfig-gitee

# 匹配所有远程 URL 包含 git.company.com 的仓库
[includeIf "hasconfig:remote.*.url:*git.company.com*"]
    path = ~/.gitconfig-company
```

> **匹配逻辑**：
> - `remote.*.url` 中的 `*` 匹配任意远程名称（origin、upstream 等）
> - 值部分的 `*github.com*` 是 glob 模式，`*` 匹配任意字符
> - SSH URL `git@github.com:user/repo.git` ✅ 匹配
> - HTTPS URL `https://github.com/user/repo.git` ✅ 匹配

### Git 版本要求

```bash
# 检查 Git 版本
git --version
# 需要 Git 2.36+ 才支持 hasconfig

# 如果版本过低，升级方法：
# Ubuntu/Debian
sudo add-apt-repository ppa:git-core/ppa && sudo apt update && sudo apt install git
# macOS
brew install git
# CentOS/RHEL
sudo yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm && sudo yum install git
```

### 降级方案：Git 版本低于 2.36

如果用户的 Git 版本低于 2.36，无法使用 `hasconfig`，提供以下降级方案：

**方案 A：使用 `gitdir` 按目录匹配（需要按平台分目录存放项目）**

```ini
[includeIf "gitdir:~/github/"]
    path = ~/.gitconfig-github
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-company
```

**方案 B：使用 Git Hook 自动设置（项目可混放）**

创建全局 `post-checkout` hook，在 clone/checkout 时自动根据远程 URL 设置用户身份：

```bash
#!/bin/bash
# ~/.config/git/hooks/post-checkout
# 全局 hook：根据远程 URL 自动设置用户身份

REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if echo "$REMOTE_URL" | grep -q "github.com"; then
    git config user.name "zhangsan"
    git config user.email "zhangsan@gmail.com"
elif echo "$REMOTE_URL" | grep -q "gitee.com"; then
    git config user.name "张三"
    git config user.email "zhangsan@163.com"
elif echo "$REMOTE_URL" | grep -q "git.company.com"; then
    git config user.name "san.zhang"
    git config user.email "san.zhang@company.com"
fi
```

启用全局 hook：
```bash
git config --global core.hooksPath ~/.config/git/hooks
chmod +x ~/.config/git/hooks/post-checkout
```

---

## 同一平台多账号场景

当同一个平台（如 GitHub）需要使用多个账号时，SSH config 中使用 **Host 别名** 区分：

```ssh-config
# GitHub 个人账号
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_personal
    IdentitiesOnly yes

# GitHub 工作账号
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_work
    IdentitiesOnly yes
```

此时 clone 仓库需使用别名替代域名：
```bash
# 个人账号的仓库
git clone git@github-personal:username/repo.git
# 工作账号的仓库
git clone git@github-work:company/repo.git
```

对应的 gitconfig 身份匹配也需要使用别名：
```ini
[includeIf "hasconfig:remote.*.url:*github-personal*"]
    path = ~/.gitconfig-github-personal
[includeIf "hasconfig:remote.*.url:*github-work*"]
    path = ~/.gitconfig-github-work
```

---

## 完整配置文件模板

### 占位符说明

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `{PLATFORM}` | 平台标识 | `github`、`gitee`、`company` |
| `{HOST}` | 平台域名 | `github.com`、`git.company.com` |
| `{EMAIL}` | 该平台使用的邮箱 | `zhangsan@gmail.com` |
| `{USERNAME}` | 该平台使用的用户名 | `zhangsan` |
| `{PORT}` | SSH 端口（默认 22） | `22`、`443` |

### ~/.ssh/config 模板

```ssh-config
# ============================================
# {PLATFORM} ({HOST})
# ============================================
Host {HOST}
    HostName {HOST}
    User git
    Port {PORT}
    IdentityFile ~/.ssh/id_ed25519_{PLATFORM}
    IdentitiesOnly yes
```

### ~/.gitconfig 条件包含模板

```ini
[includeIf "hasconfig:remote.*.url:*{HOST}*"]
    path = ~/.gitconfig-{PLATFORM}
```

### ~/.gitconfig-{PLATFORM} 模板

```ini
[user]
    name = {USERNAME}
    email = {EMAIL}
```

---

## 常见问题排查

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| `Permission denied (publickey)` | 公钥未添加到平台 / 使用了错误的密钥 | 1. 确认公钥已添加到平台 2. `ssh -vT git@host` 检查加载的密钥是否正确 |
| 提交后用户名/邮箱不对 | `hasconfig` 未生效 | 1. 检查 Git 版本 ≥ 2.36 2. 确认仓库有远程 URL（`git remote -v`） 3. 检查 `~/.gitconfig` 中的 includeIf 语法 |
| 新 clone 的仓库身份不对 | `hasconfig` 在首次 clone 时可能不生效 | clone 完成后执行 `git config user.name` 验证，如不对可手动 `git config user.name "xxx"` 或重新进入目录 |
| SSH 连接超时 | 网络问题 / 端口被封 | 1. 检查网络 2. 尝试使用 HTTPS 端口：在 config 中设置 `Port 443`（GitHub 支持） |
| `ssh-agent` 缓存了错误的密钥 | agent 中加载了多个密钥 | 1. `ssh-add -D` 清除所有缓存 2. 确保 config 中设置了 `IdentitiesOnly yes` |
| Windows 下路径不生效 | 路径格式错误 | 使用 `/` 而非 `\`，如 `C:/Users/xxx/.ssh/id_ed25519_github` |
| 同一平台多账号冲突 | Host 相同导致无法区分 | 使用 Host 别名（见「同一平台多账号场景」） |
| `hasconfig` 不识别 | Git 版本低于 2.36 | 升级 Git 或使用降级方案（见「降级方案」） |

---

## GitHub 443 端口备用方案

部分网络环境下 22 端口被封，GitHub 支持通过 443 端口进行 SSH 连接：

```ssh-config
Host github.com
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
```

---

## 适用场景总结

| 场景 | 解决方案 |
|------|----------|
| 不同平台使用不同 SSH Key | SSH config 中为每个 Host 指定不同的 IdentityFile |
| 不同仓库使用不同用户名/邮箱（项目混放） | gitconfig `hasconfig:remote.*.url` 按远程 URL 匹配（推荐，需 Git 2.36+） |
| 不同仓库使用不同用户名/邮箱（项目分目录） | gitconfig `gitdir` 按目录匹配（Git 2.13+ 即可） |
| 同一平台多个账号 | SSH config 中使用 Host 别名区分 |
| 公司仓库需要代理 | 在平台独立 gitconfig 中配置 http.proxy |
| 22 端口被封 | 使用 443 端口（GitHub 支持 ssh.github.com:443） |
| Git 版本低于 2.36 | 使用 gitdir 方案或全局 Git Hook 方案 |
