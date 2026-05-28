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

# 需要安装的 Skill（位于 skills/ 子目录中）
SKILL_NAMES=("figma-to-ios-uikit-code" "oc-to-swift")

echo "============================================"
echo "  iOS Coding Skills 安装脚本"
echo "============================================"
echo ""
echo "安装目标: ${TARGET_DIR}"
echo ""

# 创建目标目录
mkdir -p "$TARGET_DIR"

INSTALL_COUNT=0

# -------- 安装 Skills --------
for name in "${SKILL_NAMES[@]}"; do
    SRC="${SCRIPT_DIR}/skills/${name}"
    DST="${TARGET_DIR}/${name}"

    if [[ ! -d "$SRC" ]]; then
        echo -e "${RED}✗ 源目录不存在: ${SRC}${NC}"
        echo "  请确保在仓库根目录下运行此脚本。"
        exit 1
    fi

    if [[ -d "$DST" ]]; then
        echo -e "${YELLOW}  ⚠ 覆盖已存在的: ${name}${NC}"
        rm -rf "$DST"
    fi

    cp -r "$SRC" "$DST"

    # 修正规范文档引用路径：仓库中 skills/X/ → ../../docs/，安装后 X/ → ../docs/
    sed -i '' 's|../../docs/|../docs/|g' "${DST}/SKILL.md" 2>/dev/null || true

    echo -e "${GREEN}  ✓ 已安装: ${name}${NC}"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
done

# -------- 安装公共文档 --------
DOCS_SRC="${SCRIPT_DIR}/docs"
DOCS_DST="${TARGET_DIR}/docs"

if [[ ! -d "$DOCS_SRC" ]]; then
    echo -e "${RED}✗ 源目录不存在: ${DOCS_SRC}${NC}"
    exit 1
fi

if [[ -d "$DOCS_DST" ]]; then
    echo -e "${YELLOW}  ⚠ 覆盖已存在的: docs${NC}"
    rm -rf "$DOCS_DST"
fi

cp -r "$DOCS_SRC" "$DOCS_DST"
echo -e "${GREEN}  ✓ 已安装: docs${NC}"
INSTALL_COUNT=$((INSTALL_COUNT + 1))

# -------- 完成 --------
echo ""
echo -e "${GREEN}安装完成！已安装 ${INSTALL_COUNT} 项到:${NC}"
echo "  ${TARGET_DIR}"
echo ""

# 检查安装结果
ALL_OK=true
for name in "${SKILL_NAMES[@]}"; do
    if [[ ! -f "${TARGET_DIR}/${name}/SKILL.md" ]]; then
        echo -e "${RED}  ✗ 缺失: ${name}/SKILL.md${NC}"
        ALL_OK=false
    fi
done
if [[ ! -f "${TARGET_DIR}/docs/ios-ui-code-standard.md" ]]; then
    echo -e "${RED}  ✗ 缺失: docs/ios-ui-code-standard.md${NC}"
    ALL_OK=false
fi

if $ALL_OK; then
    echo "已安装的 Skill:"
    for name in "${SKILL_NAMES[@]}"; do
        echo "  - ${name}"
    done
else
    echo -e "${RED}部分文件安装失败，请检查。${NC}"
    exit 1
fi

echo ""
echo "现在即可在 Claude Code 对话中使用这些 Skill。"
echo ""
echo "使用示例："
echo "  把这个 Figma 设计稿应用一下：https://www.figma.com/design/xxx"
echo "  把 HYUserProfileView.m 转成 Swift"
