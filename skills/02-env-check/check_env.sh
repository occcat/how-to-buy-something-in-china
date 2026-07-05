#!/bin/bash
# 检查当前环境是否满足前置要求 (macOS, ego-browser)

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ 错误: 本项目依赖的 ego-browser 目前仅支持 macOS。当前系统不是 macOS，无法继续。"
    exit 1
fi
echo "✅ 操作系统检测通过 (macOS)"

if ! command -v ego-browser &> /dev/null; then
    echo "❌ 错误: 未安装 ego-browser (Lite Ego)。"
    echo "👉 请指引用户前往 https://lite.ego.app 下载并安装。"
    exit 1
fi
echo "✅ ego-browser 检测通过"

# 检查 .cache 目录是否创建
mkdir -p ../../.cache
echo "✅ 环境检查完毕！"
