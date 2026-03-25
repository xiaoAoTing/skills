#!/bin/bash
set -e

# ============================================
# Skill 同步脚本
# 将 src/ 目录下的 skills 同步到 ~/.cursor/skills-cursor/
# ============================================

# 定义源目录（项目中的 skills 目录）
SRC_DIR="$(cd "$(dirname "$0")" && pwd)/src"

# 定义目标目录（Cursor skills 存放目录）
TARGET_DIR="$HOME/.cursor/skills-cursor"

# 检查源目录是否存在
if [[ ! -d "$SRC_DIR" ]]; then
    echo "[ERROR] 源目录不存在: $SRC_DIR"
    exit 1
fi

# 检查目标目录是否存在，不存在则创建
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "[INFO] 目标目录不存在，创建: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# 遍历 src/ 下的每个 skill 目录
for skill_dir in "$SRC_DIR"/*/; do
    # 获取 skill 名称（目录名）
    skill_name=$(basename "$skill_dir")
    skill_file="${skill_dir}SKILL.md"

    # 检查 SKILL.md 文件是否存在
    if [[ ! -f "$skill_file" ]]; then
        echo "[WARN] 跳过 $skill_name：未找到 SKILL.md 文件"
        continue
    fi

    # 目标路径
    dest_dir="$TARGET_DIR/$skill_name"
    dest_file="$dest_dir/SKILL.md"

    # 如果目标目录不存在则创建
    if [[ ! -d "$dest_dir" ]]; then
        echo "[INFO] 创建目录: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    # 复制文件（本项目的 skill 会覆盖 cursor 已有的同名 skill）
    echo "[SYNC] $skill_name -> $dest_file"
    cp "$skill_file" "$dest_file"
done

echo ""
echo "[DONE] 同步完成！共同步 $(find "$SRC_DIR" -maxdepth 1 -type d | tail -n +2 | wc -l | tr -d ' ') 个 skills 到 $TARGET_DIR"
