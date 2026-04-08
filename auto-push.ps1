#!/usr/bin/env powershell

# 自动提交和推送项目更改到远程仓库

# 切换到项目目录
Set-Location -Path $PSScriptRoot

# 检查是否有更改
$changes = git status --porcelain
if ($changes) {
    Write-Host "检测到更改，开始提交..."
    
    # 添加所有更改
    git add .
    
    # 生成提交信息
    $commitMessage = "chore: auto-update rules and skills"
    
    # 提交更改
    git commit -m $commitMessage
    
    # 推送到远程仓库
    git push origin main
    
    Write-Host "更改已成功提交并推送到远程仓库"
} else {
    Write-Host "没有检测到更改，无需提交"
}
