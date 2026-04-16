#!/usr/bin/env bash
# ============================================================================
# AI Skills & Rules — 跨平台安装脚本 (macOS / Linux)
# ============================================================================
# 用法:
#   ./install.sh <目标项目路径>          安装（符号链接入口文件到目标项目）
#   ./install.sh --uninstall <目标路径>  卸载（移除符号链接）
#   ./install.sh --status <目标路径>     查看安装状态
#   ./install.sh --help                 帮助信息
# ============================================================================

set -euo pipefail

# ── 颜色定义 ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # 无颜色

# ── 工具函数 ──────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ${NC}  $*"; }
success() { echo -e "${GREEN}✅${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠️${NC}  $*"; }
error()   { echo -e "${RED}❌${NC} $*" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}$*${NC}\n"; }

# ── 常量 ──────────────────────────────────────────────────────────────────────
# 本仓库的根目录（脚本所在目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="ai-skills-and-rules"

# 需要链接的平台入口文件
ENTRY_FILES=(
    "CLAUDE.md"              # Claude Code 自动加载入口
    "GEMINI.md"              # Gemini CLI 自动加载入口
    "gemini-extension.json"  # Gemini CLI 插件注册
    "AGENTS.md"              # Cursor Agent / 通用 Agent 入口
    ".cursorrules"           # Cursor 自动加载规则
)

# 文件说明映射
declare -A FILE_DESC=(
    ["CLAUDE.md"]="Claude Code 自动加载入口"
    ["GEMINI.md"]="Gemini CLI 自动加载入口"
    ["gemini-extension.json"]="Gemini CLI 插件注册"
    ["AGENTS.md"]="Cursor Agent / 通用 Agent 入口"
    [".cursorrules"]="Cursor 自动加载规则"
)

# ── 帮助信息 ──────────────────────────────────────────────────────────────────
show_help() {
    cat << 'EOF'

  ╔══════════════════════════════════════════════════════════════╗
  ║          AI Skills & Rules — 安装脚本                       ║
  ╚══════════════════════════════════════════════════════════════╝

  将本仓库的平台入口文件通过符号链接安装到你的目标项目中，
  使 AI 编码工具（Claude Code、Cursor、Gemini CLI 等）能够自动加载规则和 Skill。

  用法:
    ./install.sh <目标项目路径>                安装到目标项目
    ./install.sh --uninstall <目标项目路径>    从目标项目卸载
    ./install.sh --status <目标项目路径>       查看安装状态
    ./install.sh --all <目标项目路径>          安装所有入口文件（跳过交互选择）
    ./install.sh --help                       显示本帮助信息

  示例:
    ./install.sh ~/projects/my-app
    ./install.sh --all /path/to/project
    ./install.sh --uninstall ~/projects/my-app

  安装的文件:
    CLAUDE.md              → Claude Code 自动加载入口
    GEMINI.md              → Gemini CLI 自动加载入口
    gemini-extension.json  → Gemini CLI 插件注册
    AGENTS.md              → Cursor Agent / 通用 Agent 入口
    .cursorrules           → Cursor 自动加载规则

EOF
}

# ── 计算相对路径 ────────────────────────────────────────────────────────────
# 用法: get_relative_path <from_dir> <to_dir>
# 返回从 from_dir 到 to_dir 的相对路径
get_relative_path() {
    local from_dir="$1"
    local to_dir="$2"

    # 使用 Python 计算相对路径（macOS 和 Linux 都有 Python）
    if command -v python3 &>/dev/null; then
        python3 -c "import os.path; print(os.path.relpath('$to_dir', '$from_dir'))"
    elif command -v python &>/dev/null; then
        python -c "import os.path; print(os.path.relpath('$to_dir', '$from_dir'))"
    else
        # 回退：使用 realpath（Linux 通常有，macOS 可能没有）
        if command -v realpath &>/dev/null; then
            realpath --relative-to="$from_dir" "$to_dir"
        else
            # 最终回退：使用绝对路径
            warn "无法计算相对路径，将使用绝对路径"
            echo "$to_dir"
        fi
    fi
}

# ── 安装 ──────────────────────────────────────────────────────────────────────
do_install() {
    local target_dir="$1"
    local install_all="${2:-false}"

    header "🔌 AI Skills & Rules — 安装"

    info "仓库路径:   ${BOLD}${SCRIPT_DIR}${NC}"
    info "目标项目:   ${BOLD}${target_dir}${NC}"
    echo ""

    # 计算相对路径（使符号链接可移植）
    local rel_path
    rel_path="$(get_relative_path "$target_dir" "$SCRIPT_DIR")"
    info "相对路径:   ${BOLD}${rel_path}${NC}"
    echo ""

    # 选择要安装的文件
    local selected_files=()

    if [[ "$install_all" == "true" ]]; then
        selected_files=("${ENTRY_FILES[@]}")
        info "安装所有入口文件"
    else
        echo -e "${BOLD}请选择要安装的入口文件（输入编号，多个用空格分隔，输入 a 全选）：${NC}"
        echo ""
        for i in "${!ENTRY_FILES[@]}"; do
            local file="${ENTRY_FILES[$i]}"
            local desc="${FILE_DESC[$file]}"
            local status=""
            if [[ -e "${target_dir}/${file}" ]]; then
                status=" ${YELLOW}(已存在)${NC}"
            fi
            echo -e "  ${BOLD}$((i+1))${NC}. ${file}  — ${desc}${status}"
        done
        echo ""

        read -rp "请输入选择 [a/1 2 3...]: " choices

        if [[ "$choices" == "a" || "$choices" == "A" ]]; then
            selected_files=("${ENTRY_FILES[@]}")
        else
            for choice in $choices; do
                if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#ENTRY_FILES[@]} )); then
                    selected_files+=("${ENTRY_FILES[$((choice-1))]}")
                else
                    warn "忽略无效选择: $choice"
                fi
            done
        fi
    fi

    if [[ ${#selected_files[@]} -eq 0 ]]; then
        warn "未选择任何文件，退出"
        exit 0
    fi

    echo ""
    header "📦 开始安装"

    local installed=0
    local skipped=0
    local failed=0

    for file in "${selected_files[@]}"; do
        local source="${SCRIPT_DIR}/${file}"
        local target="${target_dir}/${file}"
        local link_target="${rel_path}/${file}"

        # 检查源文件是否存在
        if [[ ! -f "$source" ]]; then
            error "${file} — 源文件不存在，跳过"
            ((failed++))
            continue
        fi

        # 检查目标是否已存在
        if [[ -L "$target" ]]; then
            # 已经是符号链接
            local existing_link
            existing_link="$(readlink "$target")"
            if [[ "$existing_link" == "$link_target" || "$existing_link" == "$source" ]]; then
                info "${file} — 已安装，跳过"
                ((skipped++))
                continue
            else
                warn "${file} — 已存在不同的符号链接 → ${existing_link}"
                read -rp "  是否覆盖？[y/N]: " overwrite
                if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
                    ((skipped++))
                    continue
                fi
                rm "$target"
            fi
        elif [[ -f "$target" ]]; then
            warn "${file} — 目标已存在普通文件"
            read -rp "  是否备份并覆盖？[y/N]: " overwrite
            if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
                ((skipped++))
                continue
            fi
            mv "$target" "${target}.bak"
            info "${file} — 已备份为 ${file}.bak"
        fi

        # 创建符号链接
        if ln -s "$link_target" "$target" 2>/dev/null; then
            success "${file} → ${link_target}"
            ((installed++))
        else
            error "${file} — 创建符号链接失败"
            ((failed++))
        fi
    done

    # 汇总
    echo ""
    header "📊 安装完成"
    [[ $installed -gt 0 ]] && success "已安装: ${installed} 个文件"
    [[ $skipped -gt 0 ]]   && info "已跳过: ${skipped} 个文件"
    [[ $failed -gt 0 ]]    && error "失败:   ${failed} 个文件"

    if [[ $installed -gt 0 ]]; then
        echo ""
        info "现在你可以在 ${BOLD}${target_dir}${NC} 中使用 AI 编码工具，"
        info "它们会自动加载本仓库的规则和 Skill 体系。"
        echo ""
        info "💡 提示: 建议将这些符号链接添加到项目的 ${BOLD}.gitignore${NC} 中："
        echo ""
        for file in "${selected_files[@]}"; do
            echo "  ${file}"
        done
    fi
}

# ── 卸载 ──────────────────────────────────────────────────────────────────────
do_uninstall() {
    local target_dir="$1"

    header "🗑️  AI Skills & Rules — 卸载"

    info "目标项目: ${BOLD}${target_dir}${NC}"
    echo ""

    local removed=0
    local not_found=0

    for file in "${ENTRY_FILES[@]}"; do
        local target="${target_dir}/${file}"

        if [[ -L "$target" ]]; then
            local link_target
            link_target="$(readlink "$target")"
            # 检查是否指向本仓库
            if [[ "$link_target" == *"${REPO_NAME}"* ]]; then
                rm "$target"
                success "${file} — 已移除"
                ((removed++))
            else
                warn "${file} — 符号链接指向其他位置 (${link_target})，跳过"
            fi
        elif [[ -f "$target" ]]; then
            warn "${file} — 是普通文件而非符号链接，跳过（请手动处理）"
        else
            info "${file} — 不存在，跳过"
            ((not_found++))
        fi
    done

    # 恢复备份
    for file in "${ENTRY_FILES[@]}"; do
        local backup="${target_dir}/${file}.bak"
        if [[ -f "$backup" ]]; then
            mv "$backup" "${target_dir}/${file}"
            info "${file} — 已从备份恢复"
        fi
    done

    echo ""
    header "📊 卸载完成"
    [[ $removed -gt 0 ]]    && success "已移除: ${removed} 个文件"
    [[ $not_found -gt 0 ]]  && info "未找到: ${not_found} 个文件"
}

# ── 状态查看 ──────────────────────────────────────────────────────────────────
do_status() {
    local target_dir="$1"

    header "📋 AI Skills & Rules — 安装状态"

    info "目标项目: ${BOLD}${target_dir}${NC}"
    echo ""

    printf "  ${BOLD}%-25s %-12s %s${NC}\n" "文件" "状态" "详情"
    printf "  %-25s %-12s %s\n" "─────────────────────────" "────────────" "──────────────────────"

    for file in "${ENTRY_FILES[@]}"; do
        local target="${target_dir}/${file}"
        local status=""
        local detail=""

        if [[ -L "$target" ]]; then
            local link_target
            link_target="$(readlink "$target")"
            if [[ "$link_target" == *"${REPO_NAME}"* ]]; then
                status="${GREEN}✅ 已安装${NC}"
                detail="→ ${link_target}"
            else
                status="${YELLOW}⚠️  其他链接${NC}"
                detail="→ ${link_target}"
            fi
        elif [[ -f "$target" ]]; then
            status="${YELLOW}⚠️  普通文件${NC}"
            detail="非符号链接"
        else
            status="${RED}❌ 未安装${NC}"
            detail=""
        fi

        printf "  %-25s " "$file"
        echo -e "${status}  ${detail}"
    done
    echo ""
}

# ── 参数解析 ──────────────────────────────────────────────────────────────────
main() {
    local action="install"
    local install_all="false"
    local target_dir=""

    # 无参数时显示帮助
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --uninstall|-u)
                action="uninstall"
                shift
                ;;
            --status|-s)
                action="status"
                shift
                ;;
            --all|-a)
                install_all="true"
                shift
                ;;
            -*)
                error "未知选项: $1"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done

    # 验证目标目录
    if [[ -z "$target_dir" ]]; then
        error "请指定目标项目路径"
        echo "使用 --help 查看帮助信息"
        exit 1
    fi

    # 转换为绝对路径
    target_dir="$(cd "$target_dir" 2>/dev/null && pwd)" || {
        error "目标路径不存在: $target_dir"
        exit 1
    }

    # 检查目标不是本仓库自身
    if [[ "$target_dir" == "$SCRIPT_DIR" ]]; then
        error "目标路径不能是本仓库自身"
        exit 1
    fi

    # 执行操作
    case "$action" in
        install)   do_install "$target_dir" "$install_all" ;;
        uninstall) do_uninstall "$target_dir" ;;
        status)    do_status "$target_dir" ;;
    esac
}

main "$@"
