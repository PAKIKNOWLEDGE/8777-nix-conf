# colorize — 极简配色开关

IMAGE="${1}"
if [ -z "$IMAGE" ]; then
  echo "壁纸路径（拖入或输入，留空=使用上次）："
  read -r IMAGE
fi

# 去掉拖入文件时终端自动加的单引号
IMAGE="${IMAGE//\'/}"

# 把配置和模板同步到 ~/.config/matugen/（matugen 默认读取位置）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "${HOME}/.config/matugen/templates"
cp "${SCRIPT_DIR}/config.toml" "${HOME}/.config/matugen/"
cp -r "${SCRIPT_DIR}/templates/"* "${HOME}/.config/matugen/templates/"

if [ -n "$IMAGE" ] && [ ! -f "$IMAGE" ]; then
  echo "❌ 文件不存在: $IMAGE"
  exit 1
fi

# 不带路径参数 = 重新用上次的配色（不变更壁纸）
if [ -n "$IMAGE" ]; then
  matugen image "$IMAGE"
else
  matugen
fi

echo "✅ 配色已刷新"
