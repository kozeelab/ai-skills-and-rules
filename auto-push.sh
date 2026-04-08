#!/bin/bash

# 自动提交和推送项目更改到远程仓库

# 切换到项目目录
cd "$(dirname "$0")"

# 检查是否有更改
if git status --porcelain | grep -q .; then
    echo "检测到更改，开始提交..."
    
    # 添加所有更改
    git add .
    
    # 生成提交信息
    commit_message="chore: auto-update rules and skills"
    
    # 提交更改
    git commit -m "$commit_message"
    
    # 推送到远程仓库
    git push origin main
    
    echo "更改已成功提交并推送到远程仓库"
else
    echo "没有检测到更改，无需提交"
fi
