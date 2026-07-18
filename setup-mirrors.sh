#!/usr/bin/env bash
# 新机首次配置：先把国内镜像写入 /etc/nix/nix.conf，再跑 switch
# 用法：sudo ./setup-mirrors.sh && nixos-rebuild switch --flake . ThinkPadX250
set -euo pipefail

CONF="/etc/nix/nix.conf"
MIRRORS="substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirror.sjtu.edu.cn/nix-channels/store https://mirrors.nju.edu.cn/nix-channels/store https://cache.nixos.org/"

if [ "$(id -u)" -ne 0 ]; then
  echo "请用 sudo 运行：sudo $0"
  exit 1
fi

if [ -f "$CONF" ] && grep -q "mirrors.ustc.edu.cn" "$CONF"; then
  echo "镜像已配置，跳过"
else
  # 备份旧配置
  [ -f "$CONF" ] && cp "$CONF" "${CONF}.bak.$(date +%s)"

  # 写入镜像（保留已有配置）
  if [ -f "$CONF" ]; then
    sed -i '/^substituters/d' "$CONF"
    echo "$MIRRORS" >> "$CONF"
  else
    echo "$MIRRORS" > "$CONF"
  fi
  echo "镜像已写入 $CONF"
fi
