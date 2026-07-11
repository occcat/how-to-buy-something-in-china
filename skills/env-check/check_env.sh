#!/usr/bin/env bash
set -euo pipefail

# 检查当前环境是否满足前置要求：macOS、ego lite/ego-browser、LaTeX 导出工具链、任务级 .cache 目录。

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
EXPORT_TOOLCHAIN_CACHE="$TASK_CACHE_DIR/export_toolchain.json"

json_escape() {
    local value="${1:-}"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/\\n}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\t'/\\t}"
    printf '%s' "$value"
}

resolve_executable() {
    local tool_name="$1"
    local resolved=""
    local search_dir

    if resolved="$(type -P "$tool_name" 2>/dev/null)" && [[ -n "$resolved" && -x "$resolved" ]]; then
        printf '%s' "$resolved"
        return 0
    fi

    for search_dir in /Library/TeX/texbin /opt/homebrew/bin /usr/local/bin "$HOME/.cargo/bin" "$HOME/.local/bin"; do
        if [[ -x "$search_dir/$tool_name" ]]; then
            printf '%s' "$search_dir/$tool_name"
            return 0
        fi
    done

    return 1
}

probe_tool() {
    local tool_name="$1"
    shift
    local output=""

    PROBE_FOUND=false
    PROBE_USABLE=false
    PROBE_PATH=""
    PROBE_VERSION=""

    if ! PROBE_PATH="$(resolve_executable "$tool_name")" || [[ -z "$PROBE_PATH" ]]; then
        return
    fi

    PROBE_FOUND=true
    if output="$("$PROBE_PATH" "$@" 2>&1)"; then
        PROBE_USABLE=true
        PROBE_VERSION="${output%%$'\n'*}"
        PROBE_VERSION="${PROBE_VERSION//$'\r'/}"
    fi
}

write_tool_entry() {
    local name="$1"
    local found="$2"
    local usable="$3"
    local path="$4"
    local version="$5"
    local trailing_comma="$6"
    local path_json="null"
    local version_json="null"

    if [[ -n "$path" ]]; then
        path_json="\"$(json_escape "$path")\""
    fi
    if [[ -n "$version" ]]; then
        version_json="\"$(json_escape "$version")\""
    fi

    printf '    "%s": { "found": %s, "usable": %s, "path": %s, "version": %s }%s\n' \
        "$name" "$found" "$usable" "$path_json" "$version_json" "$trailing_comma"
}

detect_export_toolchain() {
    probe_tool xelatex --version
    XELATEX_FOUND="$PROBE_FOUND"
    XELATEX_USABLE="$PROBE_USABLE"
    XELATEX_PATH="$PROBE_PATH"
    XELATEX_VERSION="$PROBE_VERSION"

    probe_tool lualatex --version
    LUALATEX_FOUND="$PROBE_FOUND"
    LUALATEX_USABLE="$PROBE_USABLE"
    LUALATEX_PATH="$PROBE_PATH"
    LUALATEX_VERSION="$PROBE_VERSION"

    probe_tool tectonic --version
    TECTONIC_FOUND="$PROBE_FOUND"
    TECTONIC_USABLE="$PROBE_USABLE"
    TECTONIC_PATH="$PROBE_PATH"
    TECTONIC_VERSION="$PROBE_VERSION"

    probe_tool pdflatex --version
    PDFLATEX_FOUND="$PROBE_FOUND"
    PDFLATEX_USABLE="$PROBE_USABLE"
    PDFLATEX_PATH="$PROBE_PATH"
    PDFLATEX_VERSION="$PROBE_VERSION"

    probe_tool latexmk -v
    LATEXMK_FOUND="$PROBE_FOUND"
    LATEXMK_USABLE="$PROBE_USABLE"
    LATEXMK_PATH="$PROBE_PATH"
    LATEXMK_VERSION="$PROBE_VERSION"

    probe_tool pandoc --version
    PANDOC_FOUND="$PROBE_FOUND"
    PANDOC_USABLE="$PROBE_USABLE"
    PANDOC_PATH="$PROBE_PATH"
    PANDOC_VERSION="$PROBE_VERSION"

    CHINESE_REPORT_READY=false
    SELECTED_ENGINE=""
    LATEX_CAPABILITY="unavailable"
    SELECTION_REASON="no usable Chinese-report LaTeX engine was found"

    if [[ "$XELATEX_USABLE" == true ]]; then
        CHINESE_REPORT_READY=true
        SELECTED_ENGINE="xelatex"
    elif [[ "$LUALATEX_USABLE" == true ]]; then
        CHINESE_REPORT_READY=true
        SELECTED_ENGINE="lualatex"
    elif [[ "$TECTONIC_USABLE" == true ]]; then
        CHINESE_REPORT_READY=true
        SELECTED_ENGINE="tectonic"
    fi

    if [[ "$CHINESE_REPORT_READY" == true ]]; then
        LATEX_CAPABILITY="chinese_latex_pdf"
        SELECTION_REASON="selected the first usable Chinese-report engine by fixed priority: xelatex > lualatex > tectonic"
    elif [[ "$PDFLATEX_USABLE" == true ]]; then
        LATEX_CAPABILITY="limited_pdflatex"
        SELECTION_REASON="pdflatex is usable but is not selected by default for Chinese reports"
    fi
}

write_export_toolchain_cache() {
    local checked_at="$1"
    local selected_engine_json="null"
    local tmp_file="$TASK_CACHE_DIR/.export_toolchain.json.tmp.$$"

    if [[ -n "$SELECTED_ENGINE" ]]; then
        selected_engine_json="\"$(json_escape "$SELECTED_ENGINE")\""
    fi

    {
        printf '{\n'
        printf '  "checked_at": "%s",\n' "$(json_escape "$checked_at")"
        printf '  "latex_pdf": {\n'
        printf '    "chinese_report_ready": %s,\n' "$CHINESE_REPORT_READY"
        printf '    "selected_engine": %s,\n' "$selected_engine_json"
        printf '    "capability": "%s",\n' "$(json_escape "$LATEX_CAPABILITY")"
        printf '    "selection_reason": "%s",\n' "$(json_escape "$SELECTION_REASON")"
        printf '    "runtime_validation": {\n'
        printf '      "status": "not_run",\n'
        printf '      "checked_at": null,\n'
        printf '      "note": "report-export must validate a real Chinese document before publishing"\n'
        printf '    }\n'
        printf '  },\n'
        printf '  "tools": {\n'
        write_tool_entry "xelatex" "$XELATEX_FOUND" "$XELATEX_USABLE" "$XELATEX_PATH" "$XELATEX_VERSION" ","
        write_tool_entry "lualatex" "$LUALATEX_FOUND" "$LUALATEX_USABLE" "$LUALATEX_PATH" "$LUALATEX_VERSION" ","
        write_tool_entry "tectonic" "$TECTONIC_FOUND" "$TECTONIC_USABLE" "$TECTONIC_PATH" "$TECTONIC_VERSION" ","
        write_tool_entry "pdflatex" "$PDFLATEX_FOUND" "$PDFLATEX_USABLE" "$PDFLATEX_PATH" "$PDFLATEX_VERSION" ","
        write_tool_entry "latexmk" "$LATEXMK_FOUND" "$LATEXMK_USABLE" "$LATEXMK_PATH" "$LATEXMK_VERSION" ","
        write_tool_entry "pandoc" "$PANDOC_FOUND" "$PANDOC_USABLE" "$PANDOC_PATH" "$PANDOC_VERSION" ""
        printf '  }\n'
        printf '}\n'
    } > "$tmp_file"
    mv "$tmp_file" "$EXPORT_TOOLCHAIN_CACHE"
}

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

EXPORT_CHECKED_AT="$(date -Iseconds)"
detect_export_toolchain
write_export_toolchain_cache "$EXPORT_CHECKED_AT"
if [[ "$CHINESE_REPORT_READY" == true ]]; then
    EXPORT_SELECTION="${SELECTED_ENGINE}（中文 LaTeX PDF 可用）"
elif [[ "$LATEX_CAPABILITY" == "limited_pdflatex" ]]; then
    EXPORT_SELECTION="未选择（仅 pdflatex，中文报告能力有限）"
else
    EXPORT_SELECTION="未选择（未检测到可用的中文 LaTeX PDF 引擎）"
fi
printf -- '- PDF 导出工具链检查：%s；选择：%s；记录：%s\n' \
    "$EXPORT_CHECKED_AT" "$EXPORT_SELECTION" "$EXPORT_TOOLCHAIN_CACHE" >> "$PROGRESS_FILE"

echo "任务缓存目录检测通过：$TASK_CACHE_DIR"
echo "登录态缓存文件：$LOGIN_CACHE"
echo "任务进展文件：$PROGRESS_FILE"
echo "导出工具链缓存文件：$EXPORT_TOOLCHAIN_CACHE"
echo "LaTeX 中文报告能力：$LATEX_CAPABILITY"
if [[ -n "$SELECTED_ENGINE" ]]; then
    echo "LaTeX 引擎选择：$SELECTED_ENGINE"
else
    echo "LaTeX 引擎选择：未选择"
fi
echo "环境检查完毕"
