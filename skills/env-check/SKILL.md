---
name: env-check
description: Check prerequisites for China shopping research including macOS support, ego lite or ego-browser availability, deterministic LaTeX PDF toolchain selection, safe task-level environment and login-state caching, required platform login checks, and explicit Sub Agent authorization. Use after needs are clarified and before any deep web collection.
---

# Env Check

## Purpose

Use this skill after requirements are clarified and before collecting data from Chinese social, purchase, or price-comparison platforms.

## Required Checks

1. Run `skills/env-check/check_env.sh "<task_name>"` from the repository root, or set `SHOPPING_TASK_CACHE_DIR` to the task directory created in stage 1.
2. If the OS is not macOS, stop and tell the user ego lite currently supports macOS only.
3. If ego lite or `ego-browser` is missing, direct the user to install it from https://lite.ego.app.
4. Create or reuse the current task cache directory `.cache/<task_name>_<uuid>/`; do not write task files directly under `.cache/`.
5. Deterministically probe the LaTeX export toolchain and cache the result in `.cache/<task_name>_<uuid>/export_toolchain.json`.
6. Select a Chinese-report-capable engine in this fixed order: `xelatex`, `lualatex`, then `tectonic`. A tool is selectable only when it is found and its version probe succeeds.
7. Record `latexmk` and `pandoc` as auxiliary tools only. Neither tool, alone or together, proves that a LaTeX PDF can be compiled.
8. Record `pdflatex` as limited capability only. Do not treat it as the default compiler for a Chinese report and do not mark the LaTeX Chinese-report path ready when it is the only engine found.
9. Append the selected export capability and engine to the task's `progress.md`.
10. Check platform login state only for sites required by the current research.
11. Cache login state in `.cache/<task_name>_<uuid>/login_status.json`.
12. Ask for manual扫码登录 only when the needed login state is missing.
13. Ask whether Sub Agent parallel search is allowed and disclose higher Token cost. This prompt has exactly two options: `不并行（推荐）` and `并行`.

## Task Cache Directory

Every buying task must have one dedicated cache directory:

```text
.cache/<task_name>_<uuid>/
```

Rules:

- `task_name` comes from the user request, product name, or category, sanitized for safe paths.
- `uuid` must be generated with `uuidgen` or an equivalent UUID generator.
- Use `SHOPPING_TASK_CACHE_DIR` when stage 1 already created the task directory.
- Otherwise pass the task name as the first argument, for example `skills/env-check/check_env.sh "扫地机器人"`.
- Store task progress, export-toolchain status, login status, scrape notes, screenshots, logs, temporary browser scripts, and PDF conversion intermediates inside this directory.
- Do not write `.cache/login_status.json`, `.cache/export_toolchain.json`, or other root-level per-task files.

## LaTeX Export Toolchain

`check_env.sh` must write the deterministic probe result to:

```text
.cache/<task_name>_<uuid>/export_toolchain.json
```

Selection rules:

1. Probe all supported commands and distinguish `found` from `usable`. Check `PATH` first, then common macOS and user install locations such as `/Library/TeX/texbin`, `/opt/homebrew/bin`, `/usr/local/bin`, `~/.cargo/bin`, and `~/.local/bin`. `usable` means the resolved executable's version probe completed successfully; it is not merely a shell alias or function.
2. Select the first usable engine in this fixed order: `xelatex`, `lualatex`, `tectonic`.
3. When one of those engines is selected, set `chinese_report_ready` to `true` and `capability` to `chinese_latex_pdf`.
4. When none is usable but `pdflatex` is usable, leave `selected_engine` as `null`, set `chinese_report_ready` to `false`, and set `capability` to `limited_pdflatex`.
5. Otherwise set `capability` to `unavailable`.
6. `latexmk` and `pandoc` are always auxiliary records. Their presence must not change `chinese_report_ready` or choose an engine.
7. Downstream report export should prefer the LaTeX PDF path only when `chinese_report_ready` is `true`; otherwise use the documented non-LaTeX fallback.

`chinese_report_ready` is a deterministic route-selection signal based on executable discovery and a successful version probe. Initialize `runtime_validation.status` as `not_run`; the report-export stage must update it after a real Chinese compilation and validate fonts, text, tables, links, and images before publishing the PDF.

The file schema is:

```json
{
  "checked_at": "2026-07-11T12:00:00+08:00",
  "latex_pdf": {
    "chinese_report_ready": true,
    "selected_engine": "xelatex",
    "capability": "chinese_latex_pdf",
    "selection_reason": "selected the first usable Chinese-report engine by fixed priority: xelatex > lualatex > tectonic",
    "runtime_validation": {
      "status": "not_run",
      "checked_at": null,
      "note": "report-export must validate a real Chinese document before publishing"
    }
  },
  "tools": {
    "xelatex": {
      "found": true,
      "usable": true,
      "path": "/Library/TeX/texbin/xelatex",
      "version": "XeTeX ..."
    },
    "lualatex": { "found": false, "usable": false, "path": null, "version": null },
    "tectonic": { "found": false, "usable": false, "path": null, "version": null },
    "pdflatex": { "found": false, "usable": false, "path": null, "version": null },
    "latexmk": { "found": false, "usable": false, "path": null, "version": null },
    "pandoc": { "found": false, "usable": false, "path": null, "version": null }
  }
}
```

Do not store environment variables, shell configuration, document contents, or other unrelated machine details in this file.

## Platform Selection

Use the clarified requirements to decide required login checks. Classify every target site into one of these three platform types:

- 社媒平台: Bilibili, 知乎, 小红书, forums/communities, media reviews, and comment areas; use for product reviews, owner experience, complaints, video evidence, and reputation.
- 购买平台: 京东, 淘宝/天猫, 拼多多, 闲鱼, 官网/品牌商城; use for live prices, inventory, versions, official specs, warranty, after-sales terms, and purchase links.
- 比价平台: 什么值得买, 慢慢买; use for historical lows, price trends, price thresholds, and public subsidy clues.

Site-specific rules:

- 拼多多: do not check login state or collect pages directly; use only public price clues from 社媒平台 or 比价平台.
- 闲鱼: check login state only when secondhand is accepted or resale value is a decision factor.
- 官网/品牌商城: usually does not need login; use for official specs, MSRP, warranty language, and official purchase references.

If the user does not accept secondhand, do not require 闲鱼 login unless resale value is a decision factor.

## Login Cache Schema

Store only non-sensitive state at `.cache/<task_name>_<uuid>/login_status.json`:

```json
{
  "checked_at": "2026-07-06T12:00:00+08:00",
  "sites": {
    "bilibili": {
      "status": "logged_in",
      "checked_at": "2026-07-06T12:00:00+08:00",
      "note": "able to access comments"
    },
    "xianyu": {
      "status": "missing",
      "checked_at": "2026-07-06T12:00:00+08:00",
      "note": "needed only if user accepts secondhand"
    }
  }
}
```

Allowed `status` values: `logged_in`, `missing`, `unknown`, `not_required`.

Never store cookies, tokens, phone numbers, shipping addresses, payment data, or account identifiers.

## User Prompts

Use the Plan-mode selectable option UI for prompts. If it is unavailable, stop the buying workflow and ask the user to switch to Plan mode. Always keep the recommended/default option first.

When login is missing:

```markdown
我需要检查/使用这些登录态：Bilibili、淘宝、闲鱼。
请选择：
1. 现在手动扫码登录这些平台（推荐）：数据最完整，能看到评论、闲鱼和真实价格
2. 跳过需要登录的平台，只使用公开数据：更快，但评价和价格证据可能不足
3. 只登录其中一部分平台：告诉我要跳过哪些平台
```

When asking about Sub Agents:

```markdown
是否允许启动 Sub Agent 并行搜索来加速信息收集？
1. 不允许（推荐）：我串行搜索，速度慢一些但更省 Token
2. 允许：更快，但 Token 消耗会明显增加
```

## Output Contract

End the stage with:

- OS result.
- ego lite/`ego-browser` result.
- Task cache directory.
- Task progress file.
- Export toolchain cache file, selected LaTeX engine, and Chinese-report readiness.
- Required sites and login status.
- Whether secondhand research is enabled.
- Whether Sub Agent parallel search is authorized.
- Any blocked platforms and agreed fallback.
