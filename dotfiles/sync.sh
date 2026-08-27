#!/usr/bin/env bash
# dotfiles 统一同步脚本
#
# 用法:
#   ./sync.sh deploy                仓库 → 本地 (common + 当前主机覆盖, 先预览再确认)
#   ./sync.sh deploy --yes          跳过确认直接部署
#   ./sync.sh deploy --host pain    指定主机目录 (默认按 hostname 自动识别)
#   ./sync.sh sync                  本地 → 仓库 (回写本机改动)
#   ./sync.sh diff                  仅预览差异, 不写任何文件
#   ./sync.sh list                  列出托管应用及本地状态
#   ./sync.sh init-host <代号>      为新机器创建占位符 dotfiles/hosts/<代号>/
#   ./sync.sh fish-links            创建 fish 便利链接 (.fishrc / .fish_history)
#   ./sync.sh --help | -h | help    帮助
#
# 目录规则:
#   common/<app>        所有主机共用
#   hosts/<host>/<app>  仅该主机, 且整体覆盖 common 里同名应用
#   回写归属: 某应用在 host 层存在 → 归 host 层; 否则归 common 层
#
# 安全:
#   deploy 先 dry-run 预览并要求确认 (--yes 跳过)
#   仅对"托管应用"使用 --delete, 绝不波及 ~/.config 里未托管的内容
#   被覆盖/删除的旧文件自动备份到 ~/.config/.dotfiles-backup/<时间戳>/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_DIR="$SCRIPT_DIR/common"
HOSTS_DIR="$SCRIPT_DIR/hosts"
LOCAL_DIR="$HOME/.config"

# 唯一一份排除清单 (旧版每个脚本各抄一份, 改漏一处就漂移)
EXCLUDE=(
  --exclude=".git"
  --exclude=".gitkeep"
  --exclude="*.bak"
  --exclude="*.log"
  --exclude="lazy-lock.json"
  --exclude="generated.lua"
  --exclude="completions/"
  --exclude="conf.d/"
  --exclude="functions/"
  --exclude="__pycache__/"
)

# hostname 与 hosts/ 目录名不一致时在此登记: "机器hostname:目录名"
HOST_ALIASES=(
  "K1llingMyL0v3:thinkpadx250"
)
HOST_ALIASES=(
  "Gater:t430"
)
# ---------- 主机识别 ----------
HOST_ARG=""      # --host 传入的值
HOST_DIR=""      # 命中的 hosts/<name> 目录 (可为空 = 仅 common)
HOST_NAME=""     # 命中的目录名

resolve_host() {
  local want="$HOST_ARG"
  if [ -z "$want" ]; then
    want="$(hostname 2>/dev/null || true)"
    local mapped
    mapped="$(printf '%s\n' "${HOST_ALIASES[@]}" | awk -F: -v h="$want" '$1==h{print $2}')"
    [ -n "$mapped" ] && want="$mapped"
  fi

  if [ -n "$want" ] && [ -d "$HOSTS_DIR/$want" ]; then
    HOST_DIR="$HOSTS_DIR/$want"; HOST_NAME="$want"; return
  fi

  # 大小写不敏感兜底 (hostname 大小写习惯不统一)
  local lower; lower="$(echo "$want" | tr '[:upper:]' '[:lower:]')"
  local d
  for d in "$HOSTS_DIR"/*/; do
    [ -d "$d" ] || continue
    if [ "$(basename "$d" | tr '[:upper:]' '[:lower:]')" = "$lower" ]; then
      HOST_DIR="${d%/}"; HOST_NAME="$(basename "$d")"; return
    fi
  done

  echo "ℹ 未找到 hosts/$want, 本次仅同步 common (可用 --host 指定)" >&2
}

# ---------- 分层 staging ----------
STAGE_DIR=""
# 注意: 在 EXIT trap 里最后一条命令的退出码会变成脚本退出码, 所以必须显式 return 0
cleanup() { [ -n "$STAGE_DIR" ] && [ -d "$STAGE_DIR" ] && rm -rf "$STAGE_DIR"; return 0; }
trap cleanup EXIT

assemble_stage() {
  STAGE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles.XXXXXX")"

  # 第 1 层: common 全部铺进 staging
  rsync -a "${EXCLUDE[@]}" "$COMMON_DIR/" "$STAGE_DIR/"

  # 第 2 层: host 覆盖 — host 里出现的应用, common 那份整个丢弃, 只留 host 的
  [ -n "$HOST_DIR" ] || return
  local entry name
  for entry in "$HOST_DIR"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    [ "$name" = ".gitkeep" ] && continue
    rm -rf "$STAGE_DIR/$name"
    # 目录源必须加尾斜杠, 否则 rsync 会嵌套成 name/name/
    if [ -d "$entry" ]; then
      rsync -a "${EXCLUDE[@]}" "$entry/" "$STAGE_DIR/$name"
    else
      rsync -a "${EXCLUDE[@]}" "$entry" "$STAGE_DIR/$name"
    fi
  done
}

# ---------- 差异预览 ----------
# 有差异时打印明细并返回 0; 无差异返回 1
show_diff() {
  local any=1
  local entry name dest out
  for entry in "$STAGE_DIR"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    dest="$LOCAL_DIR/$name"

    if [ -d "$entry" ]; then
      out="$(rsync -anvi --delete "${EXCLUDE[@]}" "$entry/" "$dest/" 2>/dev/null || true)"
    else
      out="$(rsync -anvi "${EXCLUDE[@]}" "$entry" "$dest" 2>/dev/null || true)"
    fi

    if [ -n "$out" ]; then
      echo "── $name"
      echo "$out"
      any=0
    fi
  done
  [ "$any" -eq 0 ]
}

# ---------- 部署: 仓库(分层后) → ~/.config ----------
deploy() {
  local yes="$1"
  assemble_stage

  if ! show_diff; then
    echo "✓ 已是最新, 无需部署"
    return 0
  fi

  if [ "$yes" != "1" ]; then
    local ans
    read -r -p "以上将覆盖本地配置, 继续? [y/N] " ans || ans=n
    case "$ans" in
      y|Y) ;;
      *) echo "已取消"; return 1 ;;
    esac
  fi

  # 备份目录: 被覆盖/删除的旧文件都挪到这里, 不污染应用配置目录
  local backup_dir="$LOCAL_DIR/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  local entry name dest
  for entry in "$STAGE_DIR"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    dest="$LOCAL_DIR/$name"

    if [ -d "$entry" ]; then
      mkdir -p "$dest"
      rsync -avh --delete --backup --backup-dir="$backup_dir" "${EXCLUDE[@]}" "$entry/" "$dest/"
    else
      rsync -avh --backup --backup-dir="$backup_dir" "${EXCLUDE[@]}" "$entry" "$dest"
    fi
  done

  echo "✅ 部署完成 (旧文件备份在 ~/.config/.dotfiles-backup/)"
}

# ---------- 回写: 本地 → 仓库 ----------
sync_back() {
  # 托管应用 = common 全部 + 当前 host 全部 (去重)
  local apps=""
  local entry
  for entry in "$COMMON_DIR"/*; do
    [ -e "$entry" ] || continue
    [ "$(basename "$entry")" = ".gitkeep" ] && continue
    apps="$apps $(basename "$entry")"
  done
  if [ -n "$HOST_DIR" ]; then
    for entry in "$HOST_DIR"/*; do
      [ -e "$entry" ] || continue
      [ "$(basename "$entry")" = ".gitkeep" ] && continue
      apps="$apps $(basename "$entry")"
    done
  fi

  local name target
  for name in $apps; do
    if [ ! -e "$LOCAL_DIR/$name" ]; then
      echo "  跳过 $name (本地不存在)"
      continue
    fi

    # 归属规则: host 层存在 → 归 host; 否则归 common
    if [ -n "$HOST_DIR" ] && [ -e "$HOST_DIR/$name" ]; then
      target="$HOST_DIR/$name"
      printf '→ hosts/%s/%s\n' "$HOST_NAME" "$name"
    else
      target="$COMMON_DIR/$name"
      printf '→ common/%s\n' "$name"
    fi

    mkdir -p "$(dirname "$target")"
    if [ -d "$LOCAL_DIR/$name" ]; then
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name/" "$target/"
    else
      rsync -avh "${EXCLUDE[@]}" "$LOCAL_DIR/$name" "$target"
    fi
  done
  echo "✅ 回写完成"
}

# ---------- 列表 ----------
list_apps() {
  echo "托管应用 (${HOST_NAME:-仅 common}):"
  local seen="" entry name mark
  for entry in "$COMMON_DIR"/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    [ "$name" = ".gitkeep" ] && continue
    seen="$seen $name"
    mark="⚠"; [ -e "$LOCAL_DIR/$name" ] && mark="✅"
    printf '  %s %s\n' "$mark" "$name"
  done
  if [ -n "$HOST_DIR" ]; then
    for entry in "$HOST_DIR"/*; do
      [ -e "$entry" ] || continue
      name="$(basename "$entry")"
      [ "$name" = ".gitkeep" ] && continue
      case " $seen " in *" $name "*) continue ;; esac
      mark="⚠"; [ -e "$LOCAL_DIR/$name" ] && mark="✅"
      printf '  %s %s (host:%s)\n' "$mark" "$name" "$HOST_NAME"
    done
  fi
}

# ---------- 新建机器占位符 ----------
# 约定: 每台纳入管理的机器, 无论有无专属配置, 都在 hosts/<代号>/ 留占位符
init_host() {
  local name="${1:-}"
  if [ -z "$name" ]; then
    echo "用法: ./sync.sh init-host <代号>   (代号尽量用 hostname)" >&2
    return 1
  fi
  name="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
  if [[ "$name" =~ [^a-z0-9] ]]; then
    echo "⚠ 代号只允许小写字母和数字 (如 pain / thinkpadx250)" >&2
    return 1
  fi
  mkdir -p "$HOSTS_DIR/$name"
  if [ -e "$HOSTS_DIR/$name/.gitkeep" ]; then
    echo "✓ hosts/$name/.gitkeep 已存在"
  else
    touch "$HOSTS_DIR/$name/.gitkeep"
    echo "✅ 已创建占位符 dotfiles/hosts/$name/.gitkeep"
  fi
  echo "ℹ 该机 deploy 会自动识别 hostname → hosts/$name"
  echo "ℹ 有专属配置就把目录放进 dotfiles/hosts/$name/ 下"
  echo "ℹ NixOS 侧别忘: 1) flake.nix 加 nixosConfigurations.$name"
  echo "                 2) hosts/$name/hardware.nix + default.nix"
}

# ---------- fish 便利链接 ----------
fish_links() {
  local links=(
    ".fishrc:$HOME/.config/fish/config.fish"
    ".fish_history:$HOME/.local/share/fish/fish_history"
  )
  local entry link_name link_target
  for entry in "${links[@]}"; do
    link_name="${entry%%:*}"; link_target="${entry##*:}"
    if [ -L "$HOME/$link_name" ] && [ "$(readlink "$HOME/$link_name")" = "$link_target" ]; then
      echo "  ✅ ~/$link_name → $link_target (已存在)"
    elif [ -e "$HOME/$link_name" ] || [ -L "$HOME/$link_name" ]; then
      echo "  ⚠ ~/$link_name 存在但不是正确链接, 请手动处理"
    else
      ln -s "$link_target" "$HOME/$link_name"
      echo "  ➕ 创建 ~/$link_name → $link_target"
    fi
  done
}

usage() {
  sed -n '2,14p' "$0"
}

# ---------- 入口 ----------
main() {
  local cmd="${1:-help}"
  [ $# -gt 0 ] && shift

  # 兼容旧脚本的 --xxx 写法
  case "$cmd" in
    --deploy|-d) cmd=deploy ;;
    --sync) cmd=sync ;;
    --list|-l) cmd=list ;;
  esac

  case "$cmd" in
    deploy)
      local yes=0
      while [ $# -gt 0 ]; do
        case "$1" in
          --yes|-y) yes=1 ;;
          --host) HOST_ARG="${2:?--host 需要一个参数}"; shift ;;
          *) echo "未知参数: $1" >&2; exit 1 ;;
        esac
        shift
      done
      resolve_host
      deploy "$yes"
      ;;
    sync)
      while [ $# -gt 0 ]; do
        case "$1" in
          --host) HOST_ARG="${2:?--host 需要一个参数}"; shift ;;
          *) echo "未知参数: $1" >&2; exit 1 ;;
        esac
        shift
      done
      resolve_host
      sync_back
      ;;
    diff)
      while [ $# -gt 0 ]; do
        case "$1" in
          --host) HOST_ARG="${2:?--host 需要一个参数}"; shift ;;
          *) echo "未知参数: $1" >&2; exit 1 ;;
        esac
        shift
      done
      resolve_host
      assemble_stage
      if show_diff; then
        :
      else
        echo "✓ 无差异"
      fi
      ;;
    list) resolve_host; list_apps ;;
    init-host) init_host "${1:-}" ;;
    fish-links) fish_links ;;
    -h|--help|help) usage ;;
    *) echo "未知命令: $cmd" >&2; usage >&2; exit 1 ;;
  esac
}

main "$@"
