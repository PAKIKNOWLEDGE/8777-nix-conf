#!/usr/bin/env bash
# 设备专属配置同步模板
#
# 使用方法:
#   1. 在 dotfiles/ 下创建新设备目录: mkdir dotfiles/<hostname>
#   2. 复制本模板:  cp sync-host.sh dotfiles/<hostname>/sync.sh
#   3. 把需要差异化的配置文件放入该目录（结构与 ~/.config/ 对齐）
#   4. 在设备上运行: cd dotfiles/<hostname> && ./sync.sh
#
# 本脚本会自动读取自身所在目录名作为设备标识，无需修改任何内容。

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_DIR="$HOME/.config"

EXCLUDE=(
  --exclude=".git"
  --exclude="*.bak" --exclude="*.log"
  --exclude="lazy-lock.json" --exclude="generated.lua"
  --exclude="completions/" --exclude="conf.d/" --exclude="functions/"
  --exclude="__pycache__/"
)

sync_to_repo() {
  echo ""
  echo "▶ $(basename "$REPO_DIR") → 仓库"
  for entry in "$REPO_DIR"/*; do
    name="$(basename "$entry")"
    [ "$name" = "sync.sh" ] && continue
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
  echo "▶ $(basename "$REPO_DIR") → 本地"
  for entry in "$REPO_DIR"/*; do
    name="$(basename "$entry")"
    [ "$name" = "sync.sh" ] && continue
    if [ -d "$REPO_DIR/$name" ]; then
      mkdir -p "$LOCAL_DIR/$name"
      rsync -avh "${EXCLUDE[@]}" "$REPO_DIR/$name/" "$LOCAL_DIR/$name/"
    else
      rsync -avh "${EXCLUDE[@]}" "$REPO_DIR/$name" "$LOCAL_DIR/$name"
    fi
  done
  echo "✅ 部署完成"
}

interactive_menu() {
  local host
  host="$(basename "$REPO_DIR")"
  echo "dotfiles 同步 ($host)"
  echo ""

  while true; do
    echo "1) 本地 → 仓库"
    echo "2) 仓库 → 本地"
    echo "q) 退出"
    echo ""
    read -r -p "选择 [1-2/q]: " choice || true

    case "$choice" in
    1) sync_to_repo ;;
    2) deploy_to_local ;;
    q | Q | "") exit 0 ;;
    *) echo "无效选择" ;;
    esac
  done
}

if [ $# -eq 0 ]; then
  interactive_menu
  exit 0
fi

case "$1" in
sync) sync_to_repo ;;
--deploy | -d) deploy_to_local ;;
--help | -h)
  echo "用法: $0 [sync|--deploy]"
  exit 0
  ;;
*)
  echo "用法: $0 [sync|--deploy|--help]"
  exit 1
  ;;
esac
