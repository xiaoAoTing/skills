#!/bin/bash
set -e
shopt -s nullglob

# ============================================
# Skill 同步脚本
# 将 src/ 目录下的 skills 同步到 Cursor / Codex / Qoder / Kiro 的 skills 目录
# ============================================

# ----------------------------
# 配置项（交互式选择同步目标，也支持环境变量覆盖）
# ----------------------------
# 示例：
#   ./sync-skills.sh                              # 交互式选择同步目标
#   SYNC_TO_CURSOR=0 ./sync-skills.sh             # 跳过交互，不同步到 Cursor
#   SYNC_TO_CURSOR=0 SYNC_TO_CODEX=1 ./sync-skills.sh
#   SYNC_TO_KIRO=1 ./sync-skills.sh
#   NO_COLOR=1 ./sync-skills.sh                   # 禁用彩色输出

# 定义源目录（项目中的 skills 目录）
SRC_DIR="$(cd "$(dirname "$0")" && pwd)/src"

# 脚本内置默认配置
DEFAULT_SYNC_TO_CURSOR=1
DEFAULT_SYNC_TO_CODEX=1
DEFAULT_SYNC_TO_QODER=1
DEFAULT_SYNC_TO_KIRO=1
DEFAULT_CURSOR_TARGET_DIR="$HOME/.cursor/skills"
DEFAULT_CODEX_TARGET_DIR="$HOME/.codex/skills"
DEFAULT_QODER_TARGET_DIR="$HOME/.qoder/skills"
DEFAULT_KIRO_TARGET_DIR="$HOME/.kiro/skills"

# 运行时配置（可被环境变量覆盖）
SYNC_TO_CURSOR="${SYNC_TO_CURSOR:-}"
SYNC_TO_CODEX="${SYNC_TO_CODEX:-}"
SYNC_TO_QODER="${SYNC_TO_QODER:-}"
SYNC_TO_KIRO="${SYNC_TO_KIRO:-}"
CURSOR_TARGET_DIR="${CURSOR_TARGET_DIR:-$DEFAULT_CURSOR_TARGET_DIR}"
CODEX_TARGET_DIR="${CODEX_TARGET_DIR:-$DEFAULT_CODEX_TARGET_DIR}"
QODER_TARGET_DIR="${QODER_TARGET_DIR:-$DEFAULT_QODER_TARGET_DIR}"
KIRO_TARGET_DIR="${KIRO_TARGET_DIR:-$DEFAULT_KIRO_TARGET_DIR}"

# 仅在终端输出且未设置 NO_COLOR 时启用颜色。
if [[ -t 1 && -z "${NO_COLOR+x}" && "${TERM:-dumb}" != "dumb" ]]; then
    RESET=$'\033[0m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    RED=$'\033[31m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    BLUE=$'\033[34m'
    CYAN=$'\033[36m'
else
    RESET=""
    BOLD=""
    DIM=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    CYAN=""
fi

print_banner() {
    printf '\n%s%s%s\n' "${BOLD}${CYAN}" "============================================================" "$RESET"
    printf '%s  Skills 同步%s\n' "${BOLD}${CYAN}" "$RESET"
    printf '%s%s%s\n' "${BOLD}${CYAN}" "============================================================" "$RESET"
}

print_section() {
    printf '\n%s%s-- %s --%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
}

log_info() {
    printf '%s[INFO]%s %s\n' "${BOLD}${BLUE}" "$RESET" "$*"
}

log_warn() {
    printf '%s[WARN]%s %s\n' "${BOLD}${YELLOW}" "$RESET" "$*"
}

log_error() {
    printf '%s[ERROR]%s %s\n' "${BOLD}${RED}" "$RESET" "$*" >&2
}

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
            log_error "无效的布尔配置: $1"
            printf '        可用值: 1/0, true/false, yes/no, on/off\n' >&2
            exit 1
            ;;
    esac
}

interactive_select_targets() {
    local -a names=("Cursor" "Codex" "Qoder" "Kiro")
    local -a dirs=("$CURSOR_TARGET_DIR" "$CODEX_TARGET_DIR" "$QODER_TARGET_DIR" "$KIRO_TARGET_DIR")
    local -a selected=("$DEFAULT_SYNC_TO_CURSOR" "$DEFAULT_SYNC_TO_CODEX" "$DEFAULT_SYNC_TO_QODER" "$DEFAULT_SYNC_TO_KIRO")
    local count=${#names[@]}
    local i

    while true; do
        clear 2>/dev/null || printf '\033[2J\033[H'
        printf '%s=========================================%s\n' "${BOLD}${CYAN}" "$RESET"
        printf '%s  选择同步目标（按数字切换，回车确认）%s\n' "${BOLD}${CYAN}" "$RESET"
        printf '%s=========================================%s\n\n' "${BOLD}${CYAN}" "$RESET"

        for ((i = 0; i < count; i++)); do
            local mark
            if is_enabled "${selected[$i]}"; then
                mark="${GREEN}✓${RESET}"
            else
                mark=" "
            fi
            printf '  [%s] %d. %-8s -> %s\n' "$mark" $((i + 1)) "${names[$i]}" "${dirs[$i]}"
        done

        printf '\n  输入数字切换 / 回车确认 / q 退出\n\n'
        printf '请选择: '

        read -r -n 1 key
        printf '\n'

        case "$key" in
            [1-$count])
                local idx=$((key - 1))
                if is_enabled "${selected[$idx]}"; then
                    selected[$idx]=0
                else
                    selected[$idx]=1
                fi
                ;;
            q|Q)
                log_info "已取消同步"
                exit 0
                ;;
            "")
                SYNC_TO_CURSOR="${selected[0]}"
                SYNC_TO_CODEX="${selected[1]}"
                SYNC_TO_QODER="${selected[2]}"
                SYNC_TO_KIRO="${selected[3]}"
                return
                ;;
        esac
    done
}

# 如果用户没有通过环境变量显式指定，且终端支持交互，则弹出选择菜单
if [[ -z "$SYNC_TO_CURSOR" && -z "$SYNC_TO_CODEX" && -z "$SYNC_TO_QODER" && -z "$SYNC_TO_KIRO" ]] && [[ -t 0 ]]; then
    interactive_select_targets
fi

# 回退到默认值
SYNC_TO_CURSOR="${SYNC_TO_CURSOR:-$DEFAULT_SYNC_TO_CURSOR}"
SYNC_TO_CODEX="${SYNC_TO_CODEX:-$DEFAULT_SYNC_TO_CODEX}"
SYNC_TO_QODER="${SYNC_TO_QODER:-$DEFAULT_SYNC_TO_QODER}"
SYNC_TO_KIRO="${SYNC_TO_KIRO:-$DEFAULT_SYNC_TO_KIRO}"

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

if is_enabled "$SYNC_TO_QODER"; then
    TARGET_LABELS+=("Qoder")
    TARGET_DIRS+=("$QODER_TARGET_DIR")
fi

if is_enabled "$SYNC_TO_KIRO"; then
    TARGET_LABELS+=("Kiro")
    TARGET_DIRS+=("$KIRO_TARGET_DIR")
fi

if [[ ${#TARGET_DIRS[@]} -eq 0 ]]; then
    log_error "没有启用任何同步目标，请至少开启一个：SYNC_TO_CURSOR / SYNC_TO_CODEX / SYNC_TO_QODER / SYNC_TO_KIRO"
    exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
    log_error "源目录不存在: $SRC_DIR"
    exit 1
fi

skill_dirs=("$SRC_DIR"/*/)
valid_skill_dirs=()
skipped_skill_names=()

for skill_dir in "${skill_dirs[@]}"; do
    skill_name=$(basename "$skill_dir")
    if [[ -f "${skill_dir}SKILL.md" ]]; then
        valid_skill_dirs+=("$skill_dir")
    else
        skipped_skill_names+=("$skill_name")
    fi
done

sync_skill_to_target() {
    local skill_name="$1"
    local skill_dir="$2"
    local target_label="$3"
    local target_root="$4"
    local dest_dir="$target_root/$skill_name"
    local state="更新"

    if [[ ! -d "$dest_dir" ]]; then
        if ! mkdir -p "$dest_dir"; then
            log_error "无法创建 $target_label 目录: $dest_dir"
            return 1
        fi
        state="新建"
    fi

    if ! cp -R "${skill_dir%/}/." "$dest_dir/"; then
        log_error "同步失败: $skill_name -> $dest_dir"
        return 1
    fi

    printf '    %s✓%s %-8s %s %s(%s)%s\n' "$GREEN" "$RESET" "$target_label" "$dest_dir" "$DIM" "$state" "$RESET"
}

print_banner
print_section "同步配置"
printf '  %s源目录%s    %s\n' "$DIM" "$RESET" "$SRC_DIR"
printf '  %sSkills%s    %d 个\n' "$DIM" "$RESET" "${#valid_skill_dirs[@]}"
printf '  %s目标目录%s  %d 个\n' "$DIM" "$RESET" "${#TARGET_DIRS[@]}"
for i in "${!TARGET_DIRS[@]}"; do
    printf '    %s•%s %-8s %s\n' "$CYAN" "$RESET" "${TARGET_LABELS[$i]}" "${TARGET_DIRS[$i]}"
done

print_section "准备目标目录"
for i in "${!TARGET_DIRS[@]}"; do
    target_label="${TARGET_LABELS[$i]}"
    target_dir="${TARGET_DIRS[$i]}"

    if [[ ! -d "$target_dir" ]]; then
        if ! mkdir -p "$target_dir"; then
            log_error "无法创建 $target_label 目标目录: $target_dir"
            exit 1
        fi
        printf '  %s+%s %-8s %s %s(已创建)%s\n' "$BLUE" "$RESET" "$target_label" "$target_dir" "$DIM" "$RESET"
    else
        printf '  %s✓%s %-8s %s %s(已存在)%s\n' "$GREEN" "$RESET" "$target_label" "$target_dir" "$DIM" "$RESET"
    fi
done

print_section "同步 Skills"
for skill_name in "${skipped_skill_names[@]}"; do
    log_warn "跳过 $skill_name：未找到 SKILL.md 文件"
done

synced_skill_count=0
total_skill_count=${#valid_skill_dirs[@]}
for skill_dir in "${valid_skill_dirs[@]}"; do
    skill_name=$(basename "$skill_dir")
    synced_skill_count=$((synced_skill_count + 1))

    printf '\n  %s[%d/%d]%s %s%s%s\n' "$CYAN" "$synced_skill_count" "$total_skill_count" "$RESET" "$BOLD" "$skill_name" "$RESET"
    for i in "${!TARGET_DIRS[@]}"; do
        sync_skill_to_target "$skill_name" "$skill_dir" "${TARGET_LABELS[$i]}" "${TARGET_DIRS[$i]}"
    done
done

sync_operation_count=$((synced_skill_count * ${#TARGET_DIRS[@]}))
print_section "完成"
printf '  %s%s✓ 同步完成%s：%d 个 skills × %d 个目标 = %d 次同步\n' "$BOLD" "$GREEN" "$RESET" "$synced_skill_count" "${#TARGET_DIRS[@]}" "$sync_operation_count"
printf '\n'
