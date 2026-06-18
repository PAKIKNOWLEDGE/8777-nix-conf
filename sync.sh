#!/usr/bin/env bash
# 交互式 dotfiles 同步工具
#
# 用法:
#   ./sync.sh             交互菜单
#   ./sync.sh sync        本地 → 仓库
#   ./sync.sh --deploy    仓库 → 本地
#   ./sync.sh --list      列出托管应用
#   ./sync.sh --help      帮助

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)/dotfiles"
LOCAL_DIR="$HOME/.config"

EXCLUDE=(
  --exclude="*.bak" --exclude="*.log"
  --exclude="lazy-lock.json" --exclude="generated.lua"
  --exclude="completions/" --exclude="conf.d/" --exclude="functions/"
  --exclude="__pycache__/"
)

sync_to_repo() {
  echo ""
  echo "▶ 本地 → 仓库"
  for entry in "$REPO_DIR"/*; do
    name="$(basename "$entry")"
    [ "$name" = "sync.sh" ] || [ "$name" = "debian-archive" ] && continue
    [ ! -e "$LOCAL_DIR/$name" ] && echo "  跳过 $name（本地不存在）" && continue
    if [ -d "$LOCAL_DIR/$name" ]; then
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name/" "$REPO_DIR/$name/"
    else
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name" "$REPO_DIR/$name"
    fi
  done
  echo "✅ 同步完成"
}

deploy_to_local() {
  echo ""
  echo "▶ 仓库 → 本地"
  for entry in "$REPO_DIR"/*; do
    name="$(basename "$entry")"
    [ "$name" = "sync.sh" ] || [ "$name" = "debian-archive" ] && continue
    if [ -d "$REPO_DIR/$name" ]; then
      mkdir -p "$LOCAL_DIR/$name"
      rsync -avh --delete "${EXCLUDE[@]}" "$REPO_DIR/$name/" "$LOCAL_DIR/$name/"
    else
      rsync -avh "${EXCLUDE[@]}" "$REPO_DIR/$name" "$LOCAL_DIR/$name"
    fi
  done
  echo "✅ 部署完成"
}

list_apps() {
  echo ""
  echo "托管的应用："
  for entry in "$REPO_DIR"/*; do
    name="$(basename "$entry")"
    [ "$name" = "sync.sh" ] || [ "$name" = "debian-archive" ] && continue
    [ -e "$LOCAL_DIR/$name" ] && echo "  ✅ $name" || echo "  ⚠  $name"
  done
}

# ===== 交互菜单 =====
interactive_menu() {
  echo "dotfiles 同步工具"
  echo ""

  while true; do
    echo ""
    echo "1) 本地 → 仓库   提交本地修改"
    echo "2) 仓库 → 本地   部署配置到系统"
    echo "3) 查看托管应用"
    echo "4) 帮助"
    echo "q) 退出"
    echo ""
    read -r -p "选择 [1-4/q]: " choice || true

    case "$choice" in
    1) sync_to_repo ;;
    2) deploy_to_local ;;
    3) list_apps ;;
    4)
      echo ""
      echo "自动扫描 dotfiles/ 下的一级内容"
      echo "与 ~/.config/ 下同名条目一一对齐"
      echo "新增应用直接在 dotfiles/ 下创建目录即可"
      ;;
    q | Q | "")
      echo "再见 愿你的运行时沉睡在只读的哀叹冥河。(｡･ω･｡)ﾉ♡"
      exit 0
      ;;
    *) echo "无效选择" ;;
    esac
  done
}

# ===== 入口 =====
if [ $# -eq 0 ]; then
  interactive_menu
  exit 0
fi

case "$1" in
sync) sync_to_repo ;;
--deploy | -d) deploy_to_local ;;
--list | -l) list_apps ;;
--help | -h)
  sed -n '2,10p' "$0"
  exit 0
  ;;
*)
  echo "用法: $0 [sync|--deploy|--list|--help]"
  exit 1
  ;;
esac
