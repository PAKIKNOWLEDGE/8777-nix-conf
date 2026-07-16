#!/usr/bin/env bash
# 交互式 dotfiles 同步工具
#
# 目录结构:
#   dotfiles/common/   → 两台设备共用的配置
#   dotfiles/<host>/   → 设备专属覆盖（按主机名自动识别）
#
# 用法:
#   ./sync.sh                 交互菜单
#   ./sync.sh sync            本地 → 仓库（仅 common）
#   ./sync.sh sync --host     本地 → 仓库（common + 设备专属）
#   ./sync.sh --deploy        仓库 → 本地（仅 common）
#   ./sync.sh --deploy --host pain  仓库 → 本地（common + pain 专属覆盖）
#   ./sync.sh --list          列出托管应用
#   ./sync.sh fish-setup      fish 便利链接
#   ./sync.sh --help          帮助

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)/dotfiles"
LOCAL_DIR="$HOME/.config"
HOST="$(hostname)"

EXCLUDE=(
  --exclude=".git"
  --exclude="*.bak" --exclude="*.log"
  --exclude="lazy-lock.json" --exclude="generated.lua"
  --exclude="completions/" --exclude="conf.d/" --exclude="functions/"
  --exclude="__pycache__/"
)

# ===== 本地 → 仓库 =====
sync_common_to_repo() {
  echo ""
  echo "▶ common → 仓库"
  for entry in "$REPO_DIR"/common/*; do
    [ ! -e "$entry" ] && continue
    name="$(basename "$entry")"
    [ ! -e "$LOCAL_DIR/$name" ] && echo "  跳过 $name（本地不存在）" && continue
    if [ -d "$LOCAL_DIR/$name" ]; then
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name/" "$REPO_DIR/common/$name/"
    else
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name" "$REPO_DIR/common/$name"
    fi
  done
}

sync_host_to_repo() {
  local host_dir="$REPO_DIR/$HOST"
  if [ ! -d "$host_dir" ]; then
    echo ""
    echo "⚠  $HOST 目录不存在，跳过设备专属同步"
    return
  fi
  echo ""
  echo "▶ $HOST → 仓库"
  for entry in "$host_dir"/*; do
    [ ! -e "$entry" ] && continue
    name="$(basename "$entry")"
    if [ -d "$LOCAL_DIR/$name" ]; then
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name/" "$host_dir/$name/"
    else
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name" "$host_dir/$name" 2>/dev/null || true
    fi
  done
}

sync_to_repo() {
  sync_common_to_repo
  [ "${WITH_HOST:-}" = "1" ] && sync_host_to_repo
  echo "✅ 同步完成"
}

# ===== 仓库 → 本地 =====
deploy_common_to_local() {
  echo ""
  echo "▶ 仓库 → 本地 (common)"
  for entry in "$REPO_DIR"/common/*; do
    [ ! -e "$entry" ] && continue
    name="$(basename "$entry")"
    if [ -d "$REPO_DIR/common/$name" ]; then
      mkdir -p "$LOCAL_DIR/$name"
      rsync -avh --delete "${EXCLUDE[@]}" "$REPO_DIR/common/$name/" "$LOCAL_DIR/$name/"
    else
      rsync -avh "${EXCLUDE[@]}" "$REPO_DIR/common/$name" "$LOCAL_DIR/$name"
    fi
  done
}

deploy_host_to_local() {
  local host_dir="$REPO_DIR/$HOST"
  if [ ! -d "$host_dir" ]; then
    echo ""
    echo "⚠  $HOST 目录不存在，跳过设备专属部署"
    return
  fi
  echo ""
  echo "▶ 仓库 → 本地 ($HOST 覆盖)"
  for entry in "$host_dir"/*; do
    [ ! -e "$entry" ] && continue
    name="$(basename "$entry")"
    if [ -d "$host_dir/$name" ]; then
      mkdir -p "$LOCAL_DIR/$name"
      rsync -avh "${EXCLUDE[@]}" "$host_dir/$name/" "$LOCAL_DIR/$name/"
    else
      rsync -avh "${EXCLUDE[@]}" "$host_dir/$name" "$LOCAL_DIR/$name"
    fi
  done
}

deploy_to_local() {
  deploy_common_to_local
  [ "${WITH_HOST:-}" = "1" ] && deploy_host_to_local
  echo "✅ 部署完成"
}

# ===== 查看托管应用 =====
list_apps() {
  echo ""
  echo "托管的应用 (common)："
  for entry in "$REPO_DIR"/common/*; do
    [ ! -e "$entry" ] && continue
    name="$(basename "$entry")"
    [ -e "$LOCAL_DIR/$name" ] && echo "  ✅ $name" || echo "  ⚠  $name"
  done
  if [ -d "$REPO_DIR/$HOST" ]; then
    echo ""
    echo "设备专属覆盖 ($HOST)："
    for entry in "$REPO_DIR/$HOST"/*; do
      [ ! -e "$entry" ] && continue
      name="$(basename "$entry")"
      echo "  📌 $name → 覆盖 common/$name"
    done
  fi
}

# ===== fish 便利设置 =====
fish_setup() {
  echo ""
  echo "▶ fish 便利链接检查"

  links=(
    ".fishrc:$HOME/.config/fish/config.fish"
    ".fish_history:$HOME/.local/share/fish/fish_history"
  )

  any_missing=false

  for entry in "${links[@]}"; do
    link_name="${entry%%:*}"
    link_target="${entry##*:}"
    link_path="$HOME/$link_name"

    if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$link_target" ]; then
      echo "  ✅ ~/$link_name → $link_target  (已存在，跳过)"
    else
      any_missing=true
      if [ -e "$link_path" ] || [ -L "$link_path" ]; then
        echo "  ⚠  ~/$link_name 存在但不是指向正确目标，跳过（手动处理）"
      else
        echo "  ➕ 创建 ~/$link_name → $link_target"
        ln -s "$link_target" "$link_path"
      fi
    fi
  done

  if [ "$any_missing" = false ]; then
    echo "  一切就绪，无需操作。"
  fi
  echo ""
}

# ===== 主机选择 =====
HOSTS=()
for d in "$REPO_DIR"/*/; do
  name="$(basename "$d")"
  [ "$name" = "common" ] && continue
  HOSTS+=("$name")
done
HOST="${HOSTS[0]:-$(hostname)}"

select_host() {
  echo ""
  echo "可用的设备配置："
  local i=1
  for h in "${HOSTS[@]}"; do
    if [ "$h" = "$HOST" ]; then
      echo "  $i) $h  ← 当前"
    else
      echo "  $i) $h"
    fi
    ((i++))
  done
  echo ""
  read -r -p "选择 [1-${#HOSTS[@]}]: " idx || true
  if [ -n "$idx" ] && [ "$idx" -ge 1 ] 2>/dev/null && [ "$idx" -le "${#HOSTS[@]}" ] 2>/dev/null; then
    HOST="${HOSTS[$((idx-1))]}"
    echo "  → 已切换到: $HOST"
  else
    echo "  → 未改变"
  fi
}

# ===== 交互菜单 =====
interactive_menu() {
  echo "dotfiles 同步工具"
  echo ""

  while true; do
    echo ""
    echo "当前主机: $HOST"
    echo ""
    echo "1) 本地 → 仓库   仅 common"
    echo "2) 本地 → 仓库   common + $HOST 专属"
    echo "3) 仓库 → 本地   仅 common"
    echo "4) 仓库 → 本地   common + $HOST 专属覆盖"
    echo "5) 查看托管应用"
    echo "6) fish 便利链接"
    echo "7) 切换设备"
    echo "q) 退出"
    echo ""
    read -r -p "选择 [1-7/q]: " choice || true

    case "$choice" in
    1) WITH_HOST=0 sync_to_repo ;;
    2) WITH_HOST=1 sync_to_repo ;;
    3) WITH_HOST=0 deploy_to_local ;;
    4) WITH_HOST=1 deploy_to_local ;;
    5) list_apps ;;
    6) fish_setup ;;
    7) select_host ;;
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

WITH_HOST=0
HOST_OVERRIDE=""
case "$1" in
sync)
  shift
  if [ "${1:-}" = "--host" ]; then
    WITH_HOST=1
    [ -n "${2:-}" ] && HOST_OVERRIDE="$2"
  fi
  [ -n "$HOST_OVERRIDE" ] && HOST="$HOST_OVERRIDE"
  sync_to_repo
  ;;
--deploy | -d)
  shift
  if [ "${1:-}" = "--host" ]; then
    WITH_HOST=1
    [ -n "${2:-}" ] && HOST_OVERRIDE="$2"
  fi
  [ -n "$HOST_OVERRIDE" ] && HOST="$HOST_OVERRIDE"
  deploy_to_local
  ;;
--list | -l) list_apps ;;
fish-setup) fish_setup ;;
--help | -h)
  sed -n '2,16p' "$0"
  exit 0
  ;;
*)
  echo "用法: $0 [sync [--host <name>]] [--deploy [--host <name>]] [--list] [--help]"
  exit 1
  ;;
esac
