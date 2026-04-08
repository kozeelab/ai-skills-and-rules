# 自动提交规则

## 规则说明

本文件定义了项目的自动提交规则，确保所有修改都能及时推送到远程仓库。

## 触发条件

- 任何代码或配置文件的修改
- 任何规则文件的更新
- 任何文档的变更

## 提交规范

- **提交信息格式**：`chore: auto-update rules and skills`
- **提交范围**：所有修改的文件
- **推送目标**：`origin main`

## 执行流程

1. 检测项目更改
2. 添加所有更改到暂存区
3. 生成标准化的提交信息
4. 提交更改
5. 推送到远程仓库

## 注意事项

- 确保远程仓库连接正常
- 确保工作目录干净，避免冲突
- 推送前验证更改内容

## 执行命令

在 Windows 环境中，执行以下命令：
```powershell
git add .; git commit -m "chore: auto-update rules and skills"; git push origin main
```

在 Linux 或 macOS 环境中，执行以下命令：
```bash
git add . && git commit -m "chore: auto-update rules and skills" && git push origin main
```
