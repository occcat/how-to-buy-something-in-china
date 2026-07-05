#!/usr/bin/env bash
set -euo pipefail

# 检查当前环境是否满足前置要求：macOS、Lite Ego/ego-browser、.cache。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CACHE_DIR="$ROOT_DIR/.cache"
LOGIN_CACHE="$CACHE_DIR/login_status.json"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "错误：本项目依赖的 Lite Ego/ego-browser 目前仅支持 macOS。当前系统不是 macOS，无法继续。"
    exit 1
fi
echo "操作系统检测通过：macOS"

if command -v ego-browser >/dev/null 2>&1; then
    echo "ego-browser CLI 检测通过：$(command -v ego-browser)"
elif [[ -d "/Applications/ego lite.app" || -d "/Applications/Ego Lite.app" || -d "$HOME/Applications/ego lite.app" || -d "$HOME/Applications/Ego Lite.app" ]]; then
    echo "Lite Ego App 检测通过，但未发现 ego-browser CLI。后续自动化可能需要确认 CLI 是否可用。"
else
    echo "错误：未检测到 Lite Ego/ego-browser。请先安装：https://lite.ego.app"
    exit 1
fi

mkdir -p "$CACHE_DIR"
if [[ ! -f "$LOGIN_CACHE" ]]; then
    printf '{\n  "checked_at": null,\n  "sites": {}\n}\n' > "$LOGIN_CACHE"
fi

echo ".cache 检测通过：$CACHE_DIR"
echo "登录态缓存文件：$LOGIN_CACHE"
echo "环境检查完毕"
