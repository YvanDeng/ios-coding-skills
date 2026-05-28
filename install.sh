#!/bin/bash
#
# install.sh — 一键安装 ios-coding-skills 到 Claude Code
#
# 用法:
#   ./install.sh                        # 安装为用户级 Skill（~/.claude/skills/）
#   ./install.sh -p /path/to/project    # 安装为项目级 Skill
#   ./install.sh --project /path/to/project
#
# 依赖: 无。仅需 bash 和 cp。

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_usage() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --project <路径>   安装为项目级 Skill，指定项目根目录路径"
    echo "  -h, --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                          # 安装到 ~/.claude/skills/"
    echo "  $0 -p ~/Downloads/StaryReader  # 安装到项目 StaryReader"
}

# 解析参数
TARGET_DIR=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--project)
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}错误: --project 需要指定项目路径${NC}"
                print_usage
                exit 1
            fi
            TARGET_DIR="$2/.claude/skills"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知参数 '$1'${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# 默认用户级安装
if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="$HOME/.claude/skills"
fi

# 获取脚本所在目录（仓库根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 需要安装的目录
SKILL_DIRS=("figma-to-ios-uikit-code" "oc-to-swift" "docs")

echo "============================================"
echo "  iOS Coding Skills 安装脚本"
echo "============================================"
echo ""
echo "安装目标: ${TARGET_DIR}"
echo ""

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 逐项安装
INSTALL_COUNT=0
for dir in "${SKILL_DIRS[@]}"; do
    SRC="${SCRIPT_DIR}/${dir}"
    DST="${TARGET_DIR}/${dir}"

    if [[ ! -d "$SRC" ]]; then
        echo -e "${RED}✗ 源目录不存在: ${SRC}${NC}"
        echo "  请确保在仓库根目录下运行此脚本。"
        exit 1
    fi

    # 删除旧目录（如果存在）
    if [[ -d "$DST" ]]; then
        echo -e "${YELLOW}  ⚠ 覆盖已存在的: ${dir}${NC}"
        rm -rf "$DST"
    fi

    cp -r "$SRC" "$DST"
    echo -e "${GREEN}  ✓ 已安装: ${dir}${NC}"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
done

echo ""
echo -e "${GREEN}安装完成！已安装 ${INSTALL_COUNT} 项到:${NC}"
echo "  ${TARGET_DIR}"
echo ""

# 检查安装结果
if [[ -f "${TARGET_DIR}/docs/ios-ui-code-standard.md" ]]; then
    echo "Skill 列表:"
    echo "  - figma-to-ios-uikit-code"
    echo "  - oc-to-swift"
else
    echo -e "${RED}警告: 规范文档未正确安装，Skill 可能无法正常工作${NC}"
fi

echo ""
echo "现在即可在 Claude Code 对话中使用这些 Skill。"
echo ""
echo "使用示例："
echo "  把这个 Figma 设计稿应用一下：https://www.figma.com/design/xxx"
echo "  把 HYUserProfileView.m 转成 Swift"
