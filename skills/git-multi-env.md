# Git SSH Key 多环境隔离 Skill

## 功能说明

此 Skill 用于配置 Git 多环境隔离，实现：
- **SSH Key 隔离**：不同代码托管平台（GitHub、Gitee、公司内部仓库等）使用不同的 SSH 密钥
- **用户身份隔离**：不同仓库/目录自动使用不同的 `user.name` 和 `user.email`

> **核心目标**：一台机器上同时管理多个 Git 平台账号，互不干扰，自动切换。

---

## 执行步骤

### Step 1：收集用户环境信息

向用户确认以下信息：

| 信息项 | 说明 | 示例 |
|--------|------|------|
| 需要隔离的平台数量 | 几个不同的 Git 托管平台 | 3个（GitHub、Gitee、公司 GitLab） |
| 每个平台的 Host 地址 | SSH 连接的域名 | `github.com`、`gitee.com`、`git.company.com` |
| 每个平台的用户名 | Git 提交时显示的名字 | `zhangsan`、`张三`、`san.zhang` |
| 每个平台的邮箱 | Git 提交时显示的邮箱 | `zhangsan@gmail.com`、`zhangsan@company.com` |
| 每个平台的本地代码目录 | 该平台仓库统一存放的目录 | `~/github/`、`~/gitee/`、`~/work/` |
| 操作系统 | 用于确定路径和命令差异 | Linux / macOS / Windows |

### Step 2：生成 SSH 密钥对

为每个平台生成独立的 SSH 密钥对，**密钥文件名必须区分**：

```bash
# 示例：为三个平台分别生成密钥
# -t ed25519 推荐使用 Ed25519 算法（更安全、更快）
# -C 注释，方便识别密钥用途
# -f 指定密钥文件路径，避免覆盖

# GitHub
ssh-keygen -t ed25519 -C "zhangsan@gmail.com" -f ~/.ssh/id_ed25519_github

# Gitee
ssh-keygen -t ed25519 -C "zhangsan@163.com" -f ~/.ssh/id_ed25519_gitee

# 公司内部仓库
ssh-keygen -t ed25519 -C "san.zhang@company.com" -f ~/.ssh/id_ed25519_company
```

> ⚠️ **注意事项**：
> - 如果目标平台不支持 Ed25519（极少数老旧系统），改用 `-t rsa -b 4096`
> - 生成时会提示设置密码（passphrase），可留空直接回车，也可设置密码增强安全性
> - 生成后会产生两个文件：`id_ed25519_xxx`（私钥）和 `id_ed25519_xxx.pub`（公钥）

### Step 3：配置 SSH Config

编辑 `~/.ssh/config` 文件（不存在则创建），为每个平台配置独立的 Host 别名和密钥：

```ssh-config
# ============================================
# GitHub
# ============================================
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

# ============================================
# Gitee
# ============================================
Host gitee.com
    HostName gitee.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitee
    IdentitiesOnly yes

# ============================================
# 公司内部仓库（示例：GitLab 私有部署）
# ============================================
Host git.company.com
    HostName git.company.com
    User git
    Port 22
    IdentityFile ~/.ssh/id_ed25519_company
    IdentitiesOnly yes
```

> 🔑 **关键参数说明**：
>
> | 参数 | 说明 |
> |------|------|
> | `Host` | 别名，用于 SSH 连接时匹配规则。通常直接使用域名即可 |
> | `HostName` | 实际的服务器域名或 IP |
> | `User` | SSH 用户名，Git 托管平台统一为 `git` |
> | `IdentityFile` | 指定该平台使用的私钥文件路径 |
> | `IdentitiesOnly yes` | **强制**只使用指定的密钥，不尝试其他密钥（避免串用） |
> | `Port` | SSH 端口，默认 22，部分公司内部仓库可能使用非标准端口 |

> 💡 **同一平台多账号场景**（如两个 GitHub 账号）：
>
> ```ssh-config
> # GitHub 个人账号
> Host github-personal
>     HostName github.com
>     User git
>     IdentityFile ~/.ssh/id_ed25519_github_personal
>     IdentitiesOnly yes
>
> # GitHub 工作账号
> Host github-work
>     HostName github.com
>     User git
>     IdentityFile ~/.ssh/id_ed25519_github_work
>     IdentitiesOnly yes
> ```
>
> 此时 clone 仓库需使用别名：
> ```bash
> # 个人账号的仓库
> git clone git@github-personal:username/repo.git
> # 工作账号的仓库
> git clone git@github-work:company/repo.git
> ```

### Step 4：将公钥添加到对应平台

分别将每个公钥添加到对应平台的 SSH Keys 设置中：

```bash
# 查看公钥内容，复制到对应平台
cat ~/.ssh/id_ed25519_github.pub    # → 添加到 GitHub Settings > SSH Keys
cat ~/.ssh/id_ed25519_gitee.pub     # → 添加到 Gitee 设置 > SSH公钥
cat ~/.ssh/id_ed25519_company.pub   # → 添加到公司 GitLab Settings > SSH Keys
```

各平台添加路径：
- **GitHub**：Settings → SSH and GPG keys → New SSH key
- **Gitee**：设置 → SSH公钥 → 添加公钥
- **GitLab**：Preferences → SSH Keys → Add new key

### Step 5：配置 Git 用户身份隔离（gitconfig 条件包含）

利用 Git 的 **Conditional Includes**（条件包含）功能，根据仓库所在目录自动切换用户身份。

#### 5.1 编辑全局 gitconfig

编辑 `~/.gitconfig`（全局配置），添加条件包含规则：

```ini
# 全局默认配置（兜底）
[user]
    name = 默认用户名
    email = default@example.com

# 根据目录自动切换身份
# 注意：路径末尾的 / 不能省略，表示匹配该目录及其所有子目录

# GitHub 项目目录
[includeIf "gitdir:~/github/"]
    path = ~/.gitconfig-github

# Gitee 项目目录
[includeIf "gitdir:~/gitee/"]
    path = ~/.gitconfig-gitee

# 公司项目目录
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-company
```

> ⚠️ **重要注意事项**：
> - `gitdir:` 后面的路径**末尾必须加 `/`**，表示匹配该目录及所有子目录
> - 路径支持 `~` 表示 HOME 目录
> - 路径支持通配符 `*`，如 `gitdir:~/projects/*/company/`
> - Windows 用户路径使用 `/` 而非 `\`，如 `gitdir:C:/Users/zhangsan/github/`
> - 条件包含的配置会**覆盖**全局默认配置中的同名项

#### 5.2 创建各平台的独立 gitconfig 文件

```bash
# ~/.gitconfig-github
[user]
    name = zhangsan
    email = zhangsan@gmail.com

# ~/.gitconfig-gitee
[user]
    name = 张三
    email = zhangsan@163.com

# ~/.gitconfig-company
[user]
    name = san.zhang
    email = san.zhang@company.com
```

> 💡 **除了 user 信息，还可以在独立 gitconfig 中配置其他差异化设置**：
>
> ```ini
> # ~/.gitconfig-company 示例：公司仓库可能需要代理
> [user]
>     name = san.zhang
>     email = san.zhang@company.com
> [http]
>     proxy = http://proxy.company.com:8080
> [core]
>     autocrlf = input
> ```

### Step 6：验证配置

#### 6.1 验证 SSH 连接

```bash
# 测试 GitHub 连接
ssh -T git@github.com
# 期望输出：Hi zhangsan! You've successfully authenticated...

# 测试 Gitee 连接
ssh -T git@gitee.com
# 期望输出：Hi 张三! You've successfully authenticated...

# 测试公司仓库连接
ssh -T git@git.company.com
# 期望输出取决于公司 GitLab 配置
```

#### 6.2 验证用户身份切换

```bash
# 进入 GitHub 项目目录，检查身份
cd ~/github/some-repo
git config user.name   # 应输出：zhangsan
git config user.email  # 应输出：zhangsan@gmail.com

# 进入公司项目目录，检查身份
cd ~/work/some-repo
git config user.name   # 应输出：san.zhang
git config user.email  # 应输出：san.zhang@company.com
```

#### 6.3 调试 SSH 连接问题

```bash
# 使用 -v 参数查看详细的 SSH 连接过程，确认使用了正确的密钥
ssh -vT git@github.com

# 关注输出中的这一行，确认加载了正确的密钥文件：
# debug1: Offering public key: /home/user/.ssh/id_ed25519_github ED25519 ...
```

---

## 完整配置文件模板

### 模板使用说明

将以下模板中的占位符替换为实际值：

| 占位符 | 说明 |
|--------|------|
| `{PLATFORM}` | 平台标识（如 github、gitee、company） |
| `{HOST}` | 平台域名（如 github.com） |
| `{EMAIL}` | 该平台使用的邮箱 |
| `{USERNAME}` | 该平台使用的用户名 |
| `{DIR}` | 该平台仓库存放的本地目录 |
| `{PORT}` | SSH 端口（默认 22） |

### ~/.ssh/config 模板

```ssh-config
# ============================================
# {PLATFORM}
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
[includeIf "gitdir:{DIR}"]
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
| 提交后用户名/邮箱不对 | 条件包含路径配置错误 | 1. 检查 `gitdir:` 路径末尾是否有 `/` 2. 在仓库目录下执行 `git config user.name` 验证 |
| SSH 连接超时 | 网络问题 / 端口被封 | 1. 检查网络 2. 尝试使用 HTTPS 端口：在 config 中设置 `Port 443`（GitHub 支持） |
| `ssh-agent` 缓存了错误的密钥 | agent 中加载了多个密钥 | 1. `ssh-add -D` 清除所有缓存 2. 确保 config 中设置了 `IdentitiesOnly yes` |
| Windows 下路径不生效 | 路径格式错误 | 使用 `/` 而非 `\`，如 `gitdir:C:/Users/xxx/github/` |
| 同一平台多账号冲突 | Host 相同导致无法区分 | 使用 Host 别名（见 Step 3 中的多账号场景） |

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

## 一键初始化脚本

> 以下脚本仅供参考，AI 应根据用户实际信息生成定制化脚本。

```bash
#!/bin/bash
# Git 多环境隔离一键初始化脚本
# 使用方法：根据实际情况修改下方配置后执行

set -e

# ==================== 配置区 ====================
# 格式：平台标识|域名|端口|用户名|邮箱|本地目录
CONFIGS=(
    "github|github.com|22|zhangsan|zhangsan@gmail.com|~/github/"
    "gitee|gitee.com|22|张三|zhangsan@163.com|~/gitee/"
    "company|git.company.com|22|san.zhang|san.zhang@company.com|~/work/"
)
# ==================== 配置区 ====================

SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 备份已有配置
[ -f "$SSH_DIR/config" ] && cp "$SSH_DIR/config" "$SSH_DIR/config.bak.$(date +%Y%m%d%H%M%S)"
[ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$HOME/.gitconfig.bak.$(date +%Y%m%d%H%M%S)"

# 初始化 SSH config
SSH_CONFIG=""
GIT_CONFIG_INCLUDES=""

for config in "${CONFIGS[@]}"; do
    IFS='|' read -r platform host port username email dir <<< "$config"

    key_file="$SSH_DIR/id_ed25519_$platform"

    # 生成 SSH 密钥（如果不存在）
    if [ ! -f "$key_file" ]; then
        echo "🔑 为 $platform 生成 SSH 密钥..."
        ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
        echo "✅ 密钥已生成：$key_file"
    else
        echo "⏭️  $platform 密钥已存在，跳过生成"
    fi

    # 拼接 SSH config
    SSH_CONFIG+="
# ============================================
# $platform
# ============================================
Host $host
    HostName $host
    User git
    Port $port
    IdentityFile $key_file
    IdentitiesOnly yes
"

    # 创建平台独立 gitconfig
    cat > "$HOME/.gitconfig-$platform" << EOF
[user]
    name = $username
    email = $email
EOF
    echo "📝 已创建 ~/.gitconfig-$platform"

    # 拼接 gitconfig 条件包含
    # 展开 ~ 为实际路径
    expanded_dir="${dir/#\~/$HOME}"
    GIT_CONFIG_INCLUDES+="
[includeIf \"gitdir:$dir\"]
    path = ~/.gitconfig-$platform
"

    # 创建目录（如果不存在）
    mkdir -p "$expanded_dir"
done

# 写入 SSH config
echo "$SSH_CONFIG" > "$SSH_DIR/config"
chmod 600 "$SSH_DIR/config"
echo "✅ SSH config 已写入"

# 写入全局 gitconfig（保留已有的非 includeIf 配置）
cat > "$HOME/.gitconfig" << EOF
[user]
    name = default
    email = default@example.com
$GIT_CONFIG_INCLUDES
EOF
echo "✅ 全局 gitconfig 已写入"

# 输出公钥信息
echo ""
echo "=========================================="
echo "📋 请将以下公钥分别添加到对应平台："
echo "=========================================="
for config in "${CONFIGS[@]}"; do
    IFS='|' read -r platform host port username email dir <<< "$config"
    echo ""
    echo "🔗 $platform ($host):"
    echo "---"
    cat "$SSH_DIR/id_ed25519_$platform.pub"
    echo "---"
done

echo ""
echo "🎉 配置完成！添加公钥后，可使用以下命令验证连接："
for config in "${CONFIGS[@]}"; do
    IFS='|' read -r platform host port username email dir <<< "$config"
    echo "  ssh -T git@$host"
done
```

---

## 适用场景总结

| 场景 | 解决方案 |
|------|----------|
| 不同平台使用不同 SSH Key | SSH config 中为每个 Host 指定不同的 IdentityFile |
| 不同仓库使用不同用户名/邮箱 | gitconfig 条件包含（includeIf gitdir） |
| 同一平台多个账号 | SSH config 中使用 Host 别名区分 |
| 公司仓库需要代理 | 在平台独立 gitconfig 中配置 http.proxy |
| 22 端口被封 | 使用 443 端口（GitHub 支持 ssh.github.com:443） |
