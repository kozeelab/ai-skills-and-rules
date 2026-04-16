# ============================================================================
# AI Skills & Rules — 跨平台安装脚本 (Windows PowerShell)
# ============================================================================
# 用法:
#   .\install.ps1 <目标项目路径>                安装（符号链接入口文件到目标项目）
#   .\install.ps1 -Uninstall <目标路径>         卸载（移除符号链接）
#   .\install.ps1 -Status <目标路径>            查看安装状态
#   .\install.ps1 -Help                        帮助信息
#
# 注意: Windows 创建符号链接需要管理员权限或开启开发者模式
# ============================================================================

param(
    [Parameter(Position = 0)]
    [string]$TargetDir,

    [switch]$Uninstall,
    [switch]$Status,
    [switch]$All,
    [switch]$Help
)

# ── 颜色输出 ──────────────────────────────────────────────────────────────────
function Write-Info    { param([string]$Msg) Write-Host "ℹ  $Msg" -ForegroundColor Blue }
function Write-Success { param([string]$Msg) Write-Host "✅ $Msg" -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host "⚠️  $Msg" -ForegroundColor Yellow }
function Write-Err     { param([string]$Msg) Write-Host "❌ $Msg" -ForegroundColor Red }
function Write-Header  { param([string]$Msg) Write-Host "`n$Msg`n" -ForegroundColor Cyan }

# ── 常量 ──────────────────────────────────────────────────────────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoName = "ai-skills-and-rules"

# 需要链接的平台入口文件及说明
$EntryFiles = [ordered]@{
    "CLAUDE.md"                  = "Claude Code 自动加载入口"
    "GEMINI.md"                  = "Gemini CLI 自动加载入口"
    "gemini-extension.json"      = "Gemini CLI 插件注册"
    "AGENTS.md"                  = "Cursor Agent / 通用 Agent 入口"
    ".cursorrules"               = "Cursor 自动加载规则"
    ".codebuddy/rules/main.md"   = "CodeBuddy 自动加载规则"
    ".trae/rules/main.md"        = "Trae 自动加载规则"
}

# ── 帮助信息 ──────────────────────────────────────────────────────────────────
function Show-Help {
    Write-Host @"

  ╔══════════════════════════════════════════════════════════════╗
  ║          AI Skills & Rules — 安装脚本 (Windows)             ║
  ╚══════════════════════════════════════════════════════════════╝

  将本仓库的平台入口文件通过符号链接安装到你的目标项目中，
  使 AI 编码工具（Claude Code、Cursor、Gemini CLI 等）能够自动加载规则和 Skill。

  用法:
    .\install.ps1 <目标项目路径>                安装到目标项目
    .\install.ps1 -Uninstall <目标项目路径>     从目标项目卸载
    .\install.ps1 -Status <目标项目路径>        查看安装状态
    .\install.ps1 -All <目标项目路径>           安装所有入口文件（跳过交互选择）
    .\install.ps1 -Help                        显示本帮助信息

  示例:
    .\install.ps1 C:\Projects\my-app
    .\install.ps1 -All D:\work\project
    .\install.ps1 -Uninstall C:\Projects\my-app

  注意:
    Windows 创建符号链接需要以下条件之一：
    1. 以管理员身份运行 PowerShell
    2. 已开启 Windows 开发者模式（设置 → 更新和安全 → 开发者选项）

  安装的文件:
    CLAUDE.md                    → Claude Code 自动加载入口
    GEMINI.md                    → Gemini CLI 自动加载入口
    gemini-extension.json        → Gemini CLI 插件注册
    AGENTS.md                    → Cursor Agent / 通用 Agent 入口
    .cursorrules                 → Cursor 自动加载规则
    .codebuddy/rules/main.md     → CodeBuddy 自动加载规则
    .trae/rules/main.md          → Trae 自动加载规则

"@
}

# ── 检查符号链接权限 ──────────────────────────────────────────────────────────
function Test-SymlinkPermission {
    $testLink = Join-Path $env:TEMP "symlink_test_$(Get-Random)"
    $testTarget = $MyInvocation.ScriptName

    try {
        New-Item -ItemType SymbolicLink -Path $testLink -Target $testTarget -ErrorAction Stop | Out-Null
        Remove-Item $testLink -Force
        return $true
    }
    catch {
        return $false
    }
}

# ── 计算相对路径 ──────────────────────────────────────────────────────────────
function Get-RelativePath {
    param(
        [string]$From,
        [string]$To
    )

    # 使用 .NET 方法计算相对路径
    # PowerShell 7+ 支持 [System.IO.Path]::GetRelativePath
    if ([System.IO.Path]::GetRelativePath) {
        try {
            $fromFull = (Resolve-Path $From).Path
            $toFull = (Resolve-Path $To).Path
            return [System.IO.Path]::GetRelativePath($fromFull, $toFull)
        }
        catch {
            # 回退到绝对路径
            return (Resolve-Path $To).Path
        }
    }
    else {
        return (Resolve-Path $To).Path
    }
}

# ── 自动添加本地 Git 忽略 ─────────────────────────────────────────────────────
# 使用 .git/info/exclude 实现仅本地生效的忽略规则（不会推送到远程）
function Add-LocalGitExclude {
    param(
        [string]$Target,
        [string[]]$Files
    )

    $gitDir = Join-Path $Target ".git"
    $excludeFile = Join-Path $gitDir "info\exclude"

    # 检查目标项目是否是 Git 仓库
    if (-not (Test-Path $gitDir -PathType Container)) {
        Write-Warn "目标项目不是 Git 仓库，跳过自动添加本地忽略规则"
        Write-Info "💡 如果需要忽略这些符号链接，请手动处理"
        return
    }

    # 确保 .git/info 目录存在
    $infoDir = Join-Path $gitDir "info"
    if (-not (Test-Path $infoDir)) {
        New-Item -ItemType Directory -Path $infoDir -Force | Out-Null
    }

    # 标记注释（用于识别本脚本添加的内容）
    $marker = "# >>> ai-skills-and-rules (auto-generated, do not edit) >>>"
    $markerEnd = "# <<< ai-skills-and-rules <<<"

    # 如果已经存在标记块，先移除旧的
    if (Test-Path $excludeFile) {
        $content = Get-Content $excludeFile -Raw -ErrorAction SilentlyContinue
        if ($content -and $content.Contains($marker)) {
            $pattern = "(?s)\r?\n?$([regex]::Escape($marker)).*?$([regex]::Escape($markerEnd))\r?\n?"
            $content = [regex]::Replace($content, $pattern, "`n")
            Set-Content -Path $excludeFile -Value $content -NoNewline
        }
    }

    # 追加新的忽略规则
    $lines = @("", $marker)
    foreach ($file in $Files) {
        $lines += $file
    }
    $lines += $markerEnd
    Add-Content -Path $excludeFile -Value ($lines -join "`n")

    Write-Success "已自动添加本地 Git 忽略规则到 .git/info/exclude（仅本地生效，不会推送到远程）"
}

# ── 安装 ──────────────────────────────────────────────────────────────────────
function Install-Plugin {
    param(
        [string]$Target,
        [bool]$InstallAll
    )

    Write-Header "🔌 AI Skills & Rules — 安装"

    Write-Info "仓库路径:   $ScriptDir"
    Write-Info "目标项目:   $Target"
    Write-Host ""

    # 检查符号链接权限
    if (-not (Test-SymlinkPermission)) {
        Write-Err "没有创建符号链接的权限！"
        Write-Host ""
        Write-Host "请尝试以下方式之一：" -ForegroundColor Yellow
        Write-Host "  1. 以管理员身份运行 PowerShell" -ForegroundColor Yellow
        Write-Host "  2. 开启 Windows 开发者模式：" -ForegroundColor Yellow
        Write-Host "     设置 → 更新和安全 → 开发者选项 → 开启开发者模式" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "或者使用 mklink 命令（需管理员权限的 CMD）：" -ForegroundColor Yellow

        foreach ($file in $EntryFiles.Keys) {
            $source = Join-Path $ScriptDir $file
            $target = Join-Path $Target $file
            Write-Host "  mklink `"$target`" `"$source`"" -ForegroundColor Gray
        }
        return
    }

    # 计算相对路径
    $relPath = Get-RelativePath -From $Target -To $ScriptDir
    Write-Info "相对路径:   $relPath"
    Write-Host ""

    # 选择要安装的文件
    $selectedFiles = @()

    if ($InstallAll) {
        $selectedFiles = @($EntryFiles.Keys)
        Write-Info "安装所有入口文件"
    }
    else {
        Write-Host "请选择要安装的入口文件（输入编号，多个用空格分隔，输入 a 全选）：" -ForegroundColor White
        Write-Host ""

        $i = 1
        foreach ($file in $EntryFiles.Keys) {
            $desc = $EntryFiles[$file]
            $targetFile = Join-Path $Target $file
            $status = ""
            if (Test-Path $targetFile) {
                $status = " (已存在)"
            }
            Write-Host "  $i. $file  — $desc$status"
            $i++
        }
        Write-Host ""

        $choices = Read-Host "请输入选择 [a/1 2 3...]"

        if ($choices -eq "a" -or $choices -eq "A") {
            $selectedFiles = @($EntryFiles.Keys)
        }
        else {
            $fileKeys = @($EntryFiles.Keys)
            foreach ($choice in ($choices -split '\s+')) {
                $idx = [int]$choice - 1
                if ($idx -ge 0 -and $idx -lt $fileKeys.Count) {
                    $selectedFiles += $fileKeys[$idx]
                }
                else {
                    Write-Warn "忽略无效选择: $choice"
                }
            }
        }
    }

    if ($selectedFiles.Count -eq 0) {
        Write-Warn "未选择任何文件，退出"
        return
    }

    Write-Host ""
    Write-Header "📦 开始安装"

    $installed = 0
    $skipped = 0
    $failed = 0

    foreach ($file in $selectedFiles) {
        $source = Join-Path $ScriptDir $file
        $targetFile = Join-Path $Target $file

        # 检查源文件是否存在
        if (-not (Test-Path $source)) {
            Write-Err "$file — 源文件不存在，跳过"
            $failed++
            continue
        }

        # 如果是目录型入口文件，确保父目录存在
        $parentDir = Split-Path $targetFile -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            Write-Info "创建目录: $(Split-Path $file -Parent)"
        }

        # 检查目标是否已存在
        $item = Get-Item $targetFile -ErrorAction SilentlyContinue
        if ($null -ne $item) {
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                # 已经是符号链接
                $existingTarget = $item.Target
                if ($existingTarget -like "*$RepoName*") {
                    Write-Info "$file — 已安装，跳过"
                    $skipped++
                    continue
                }
                else {
                    Write-Warn "$file — 已存在不同的符号链接 → $existingTarget"
                    $overwrite = Read-Host "  是否覆盖？[y/N]"
                    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
                        $skipped++
                        continue
                    }
                    Remove-Item $targetFile -Force
                }
            }
            else {
                # 普通文件
                Write-Warn "$file — 目标已存在普通文件"
                $overwrite = Read-Host "  是否备份并覆盖？[y/N]"
                if ($overwrite -ne "y" -and $overwrite -ne "Y") {
                    $skipped++
                    continue
                }
                Move-Item $targetFile "$targetFile.bak" -Force
                Write-Info "$file — 已备份为 $file.bak"
            }
        }

        # 创建符号链接（使用相对路径）
        $linkTarget = Join-Path $relPath $file
        try {
            New-Item -ItemType SymbolicLink -Path $targetFile -Target $source -ErrorAction Stop | Out-Null
            Write-Success "$file → $linkTarget"
            $installed++
        }
        catch {
            Write-Err "$file — 创建符号链接失败: $_"
            $failed++
        }
    }

    # 汇总
    Write-Host ""
    Write-Header "📊 安装完成"
    if ($installed -gt 0) { Write-Success "已安装: $installed 个文件" }
    if ($skipped -gt 0)   { Write-Info "已跳过: $skipped 个文件" }
    if ($failed -gt 0)    { Write-Err "失败:   $failed 个文件" }

    if ($installed -gt 0) {
        Write-Host ""
        Write-Info "现在你可以在 $Target 中使用 AI 编码工具，"
        Write-Info "它们会自动加载本仓库的规则和 Skill 体系。"

        # 自动添加本地 Git 忽略规则
        Write-Host ""
        Add-LocalGitExclude -Target $Target -Files $selectedFiles
    }
}

# ── 卸载 ──────────────────────────────────────────────────────────────────────
function Uninstall-Plugin {
    param([string]$Target)

    Write-Header "🗑️  AI Skills & Rules — 卸载"

    Write-Info "目标项目: $Target"
    Write-Host ""

    $removed = 0
    $notFound = 0

    foreach ($file in $EntryFiles.Keys) {
        $targetFile = Join-Path $Target $file

        $item = Get-Item $targetFile -ErrorAction SilentlyContinue
        if ($null -ne $item) {
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                $linkTarget = $item.Target
                if ($linkTarget -like "*$RepoName*") {
                    Remove-Item $targetFile -Force
                    Write-Success "$file — 已移除"
                    $removed++
                }
                else {
                    Write-Warn "$file — 符号链接指向其他位置 ($linkTarget)，跳过"
                }
            }
            else {
                Write-Warn "$file — 是普通文件而非符号链接，跳过（请手动处理）"
            }
        }
        else {
            Write-Info "$file — 不存在，跳过"
            $notFound++
        }
    }

    # 恢复备份
    foreach ($file in $EntryFiles.Keys) {
        $backup = Join-Path $Target "$file.bak"
        if (Test-Path $backup) {
            Move-Item $backup (Join-Path $Target $file) -Force
            Write-Info "$file — 已从备份恢复"
        }
    }

    # 清理 .git/info/exclude 中的本地忽略规则
    $excludeFile = Join-Path $Target ".git\info\exclude"
    $marker = "# >>> ai-skills-and-rules (auto-generated, do not edit) >>>"
    $markerEnd = "# <<< ai-skills-and-rules <<<"
    if (Test-Path $excludeFile) {
        $content = Get-Content $excludeFile -Raw -ErrorAction SilentlyContinue
        if ($content -and $content.Contains($marker)) {
            $pattern = "(?s)\r?\n?$([regex]::Escape($marker)).*?$([regex]::Escape($markerEnd))\r?\n?"
            $content = [regex]::Replace($content, $pattern, "`n")
            Set-Content -Path $excludeFile -Value $content -NoNewline
            Write-Success "已清理 .git/info/exclude 中的本地忽略规则"
        }
    }

    Write-Host ""
    Write-Header "📊 卸载完成"
    if ($removed -gt 0)  { Write-Success "已移除: $removed 个文件" }
    if ($notFound -gt 0) { Write-Info "未找到: $notFound 个文件" }
}

# ── 状态查看 ──────────────────────────────────────────────────────────────────
function Show-Status {
    param([string]$Target)

    Write-Header "📋 AI Skills & Rules — 安装状态"

    Write-Info "目标项目: $Target"
    Write-Host ""

    Write-Host ("  {0,-25} {1,-15} {2}" -f "文件", "状态", "详情") -ForegroundColor White
    Write-Host ("  {0,-25} {1,-15} {2}" -f ("─" * 25), ("─" * 15), ("─" * 25))

    foreach ($file in $EntryFiles.Keys) {
        $targetFile = Join-Path $Target $file
        $status = ""
        $detail = ""

        $item = Get-Item $targetFile -ErrorAction SilentlyContinue
        if ($null -ne $item) {
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                $linkTarget = $item.Target
                if ($linkTarget -like "*$RepoName*") {
                    $status = "✅ 已安装"
                    $detail = "→ $linkTarget"
                    Write-Host ("  {0,-25} " -f $file) -NoNewline
                    Write-Host ("{0,-15} " -f $status) -ForegroundColor Green -NoNewline
                    Write-Host $detail
                }
                else {
                    $status = "⚠️  其他链接"
                    $detail = "→ $linkTarget"
                    Write-Host ("  {0,-25} " -f $file) -NoNewline
                    Write-Host ("{0,-15} " -f $status) -ForegroundColor Yellow -NoNewline
                    Write-Host $detail
                }
            }
            else {
                $status = "⚠️  普通文件"
                $detail = "非符号链接"
                Write-Host ("  {0,-25} " -f $file) -NoNewline
                Write-Host ("{0,-15} " -f $status) -ForegroundColor Yellow -NoNewline
                Write-Host $detail
            }
        }
        else {
            $status = "❌ 未安装"
            Write-Host ("  {0,-25} " -f $file) -NoNewline
            Write-Host ("{0,-15}" -f $status) -ForegroundColor Red
        }
    }
    Write-Host ""
}

# ── 主入口 ────────────────────────────────────────────────────────────────────
if ($Help) {
    Show-Help
    exit 0
}

if ([string]::IsNullOrEmpty($TargetDir)) {
    Show-Help
    exit 0
}

# 转换为绝对路径
$TargetDir = Resolve-Path $TargetDir -ErrorAction SilentlyContinue
if ($null -eq $TargetDir) {
    Write-Err "目标路径不存在: $TargetDir"
    exit 1
}
$TargetDir = $TargetDir.Path

# 检查目标不是本仓库自身
if ($TargetDir -eq $ScriptDir) {
    Write-Err "目标路径不能是本仓库自身"
    exit 1
}

if ($Uninstall) {
    Uninstall-Plugin -Target $TargetDir
}
elseif ($Status) {
    Show-Status -Target $TargetDir
}
else {
    Install-Plugin -Target $TargetDir -InstallAll $All.IsPresent
}
