#!/bin/bash
set -e
shopt -s nullglob

# ============================================
# Skill 同步脚本
# 将 src/ 目录下的 skills 同步到 Cursor / Codex 的 skills 目录
# ============================================

# ----------------------------
# 配置项（默认直接同步到 Cursor / Codex，也支持环境变量覆盖）
# ----------------------------
# 示例：
#   ./sync-skills.sh
#   SYNC_TO_CURSOR=0 ./sync-skills.sh
#   SYNC_TO_CURSOR=0 SYNC_TO_CODEX=1 ./sync-skills.sh

# 定义源目录（项目中的 skills 目录）
SRC_DIR="$(cd "$(dirname "$0")" && pwd)/src"

# 脚本内置默认配置
DEFAULT_SYNC_TO_CURSOR=1
DEFAULT_SYNC_TO_CODEX=1
DEFAULT_CURSOR_TARGET_DIR="$HOME/.cursor/skills-cursor"
DEFAULT_CODEX_TARGET_DIR="$HOME/.codex/skills"

# 运行时配置（可被环境变量覆盖）
SYNC_TO_CURSOR="${SYNC_TO_CURSOR:-$DEFAULT_SYNC_TO_CURSOR}"
SYNC_TO_CODEX="${SYNC_TO_CODEX:-$DEFAULT_SYNC_TO_CODEX}"
CURSOR_TARGET_DIR="${CURSOR_TARGET_DIR:-$DEFAULT_CURSOR_TARGET_DIR}"
CODEX_TARGET_DIR="${CODEX_TARGET_DIR:-$DEFAULT_CODEX_TARGET_DIR}"

is_enabled() {
    local value
    value=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')

    case "$value" in
        1|true|yes|on)
            return 0
            ;;
        0|false|no|off|"")
            return 1
            ;;
        *)
            echo "[ERROR] 无效的布尔配置: $1"
            echo "        可用值: 1/0, true/false, yes/no, on/off"
            exit 1
            ;;
    esac
}

sync_skill_to_target() {
    local skill_name="$1"
    local skill_dir="$2"
    local target_label="$3"
    local target_root="$4"
    local dest_dir="$target_root/$skill_name"

    # 如果目标目录不存在则创建
    if [[ ! -d "$dest_dir" ]]; then
        echo "[INFO] 创建 $target_label 目录: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    # 同步整个 skill 目录，保留 references/assets/scripts 等附属文件
    echo "[SYNC][$target_label] $skill_name -> $dest_dir"
    cp -R "${skill_dir%/}/." "$dest_dir/"
}

TARGET_LABELS=()
TARGET_DIRS=()

if is_enabled "$SYNC_TO_CURSOR"; then
    TARGET_LABELS+=("Cursor")
    TARGET_DIRS+=("$CURSOR_TARGET_DIR")
fi

if is_enabled "$SYNC_TO_CODEX"; then
    TARGET_LABELS+=("Codex")
    TARGET_DIRS+=("$CODEX_TARGET_DIR")
fi

if [[ ${#TARGET_DIRS[@]} -eq 0 ]]; then
    echo "[ERROR] 没有启用任何同步目标，请至少开启一个：SYNC_TO_CURSOR / SYNC_TO_CODEX"
    exit 1
fi

# 检查源目录是否存在
if [[ ! -d "$SRC_DIR" ]]; then
    echo "[ERROR] 源目录不存在: $SRC_DIR"
    exit 1
fi

for i in "${!TARGET_DIRS[@]}"; do
    target_label="${TARGET_LABELS[$i]}"
    target_dir="${TARGET_DIRS[$i]}"

    if [[ ! -d "$target_dir" ]]; then
        echo "[INFO] $target_label 目标目录不存在，创建: $target_dir"
        mkdir -p "$target_dir"
    fi
done

skill_dirs=("$SRC_DIR"/*/)
synced_skill_count=0

# 遍历 src/ 下的每个 skill 目录
for skill_dir in "${skill_dirs[@]}"; do
    # 获取 skill 名称（目录名）
    skill_name=$(basename "$skill_dir")
    skill_file="${skill_dir}SKILL.md"

    # 检查 SKILL.md 文件是否存在
    if [[ ! -f "$skill_file" ]]; then
        echo "[WARN] 跳过 $skill_name：未找到 SKILL.md 文件"
        continue
    fi

    for i in "${!TARGET_DIRS[@]}"; do
        sync_skill_to_target "$skill_name" "$skill_dir" "${TARGET_LABELS[$i]}" "${TARGET_DIRS[$i]}"
    done

    synced_skill_count=$((synced_skill_count + 1))
done

echo ""
echo "[DONE] 同步完成！共同步 $synced_skill_count 个 skills 到 ${#TARGET_DIRS[@]} 个目标目录："
for target_dir in "${TARGET_DIRS[@]}"; do
    echo "       - $target_dir"
done
