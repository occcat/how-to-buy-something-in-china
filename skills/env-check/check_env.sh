#!/usr/bin/env bash
set -euo pipefail

# 检查当前环境是否满足前置要求：macOS、ego lite/ego-browser、任务级 .cache 目录。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CACHE_ROOT="$ROOT_DIR/.cache"

make_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c 'import uuid; print(uuid.uuid4())'
    else
        echo "错误：未找到 uuidgen 或 python3，无法生成任务 UUID。" >&2
        return 1
    fi
}

sanitize_task_name() {
    local raw="${1:-shopping}"
    local safe
    safe="$(printf '%s' "$raw" | tr '/:*?"<>|[:space:]' '_' | sed -E 's/_+/_/g; s/^_+//; s/_+$//')"
    if [[ -z "$safe" ]]; then
        safe="shopping"
    fi
    printf '%s' "$safe"
}

resolve_task_cache_dir() {
    local provided="${SHOPPING_TASK_CACHE_DIR:-}"
    local task_name="${SHOPPING_TASK_NAME:-${1:-shopping}}"

    if [[ -n "$provided" ]]; then
        if [[ "$provided" = /* ]]; then
            printf '%s' "$provided"
        else
            printf '%s/%s' "$ROOT_DIR" "$provided"
        fi
        return
    fi

    local safe_name
    safe_name="$(sanitize_task_name "$task_name")"
    printf '%s/%s_%s' "$CACHE_ROOT" "$safe_name" "$(make_uuid)"
}

TASK_CACHE_DIR="$(resolve_task_cache_dir "${1:-}")"
case "$TASK_CACHE_DIR" in
    "$CACHE_ROOT"/*) ;;
    *)
        echo "错误：任务缓存目录必须位于 $CACHE_ROOT 下，当前为：$TASK_CACHE_DIR"
        exit 1
        ;;
esac
if [[ "$TASK_CACHE_DIR" == *"/../"* || "$TASK_CACHE_DIR" == */.. ]]; then
    echo "错误：任务缓存目录不能包含 .. 路径片段：$TASK_CACHE_DIR"
    exit 1
fi
TASK_CACHE_NAME="$(basename "$TASK_CACHE_DIR")"
if [[ ! "$TASK_CACHE_NAME" =~ ^.+_[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    echo "错误：任务缓存目录名称必须是 <task_name>_<uuid>：$TASK_CACHE_DIR"
    exit 1
fi

LOGIN_CACHE="$TASK_CACHE_DIR/login_status.json"
PROGRESS_FILE="$TASK_CACHE_DIR/progress.md"

find_ego_lite_app() {
    find "/Applications" "$HOME/Applications" -maxdepth 1 -type d -iname "ego lite.app" -print -quit 2>/dev/null
}

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "错误：本项目依赖的 ego lite/ego-browser 目前仅支持 macOS。当前系统不是 macOS，无法继续。"
    exit 1
fi
echo "操作系统检测通过：macOS"

if command -v ego-browser >/dev/null 2>&1; then
    echo "ego-browser CLI 检测通过：$(command -v ego-browser)"
elif [[ -n "$(find_ego_lite_app)" ]]; then
    echo "ego lite app 检测通过，但未发现 ego-browser CLI。后续自动化可能需要确认 CLI 是否可用。"
else
    echo "错误：未检测到 ego lite/ego-browser。请先安装：https://lite.ego.app"
    exit 1
fi

mkdir -p "$TASK_CACHE_DIR"
if [[ ! -f "$LOGIN_CACHE" ]]; then
    printf '{\n  "checked_at": null,\n  "sites": {}\n}\n' > "$LOGIN_CACHE"
fi
if [[ ! -f "$PROGRESS_FILE" ]]; then
    {
        printf '# 任务进展\n\n'
        printf -- '- 环境检查初始化：%s\n' "$(date -Iseconds)"
    } > "$PROGRESS_FILE"
else
    printf -- '- 环境检查复用任务目录：%s\n' "$(date -Iseconds)" >> "$PROGRESS_FILE"
fi

echo "任务缓存目录检测通过：$TASK_CACHE_DIR"
echo "登录态缓存文件：$LOGIN_CACHE"
echo "任务进展文件：$PROGRESS_FILE"
echo "环境检查完毕"
