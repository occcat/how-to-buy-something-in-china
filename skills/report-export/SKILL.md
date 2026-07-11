---
name: report-export
description: Write the final China shopping research report and export Markdown plus a detailed PDF under report by date and artifact type, preferring an environment-checked Chinese-oriented LaTeX engine and falling back to HTML-to-PDF only when LaTeX is unavailable. Includes research background, ego lite disclosure, clarified requirements, qualified candidates up to 50 items, comparison tables, exclusion reasons, final Top 3 recommendations, caveats, and source-linked evidence. Use after tables are complete.
---

# Report Export

## Purpose

Use this skill at the end of the buying workflow to produce durable report files.

## Git Hygiene

- Write report-generation intermediates only under the current task cache directory `.cache/<task_name>_<uuid>/`, and final Markdown/PDF artifacts only under `report/`. This includes LaTeX source, build files, staged images, HTML/CSS, conversion logs, and temporary PDFs.
- Keep `.cache/` and `report/` ignored. Do not remove ignore rules to commit generated reports.
- Do not modify tracked repository files during ordinary report generation unless the user explicitly asks for SOP, skill, script, or documentation changes.
- Do not use `git add -f` for `.cache/`, `report/`, screenshots, HTML dumps, logs, temporary scripts, Markdown reports, or PDFs unless the user explicitly asks to version them.
- Create temporary Node.js or browser automation scripts only under the current task cache directory, and delete them immediately after use.
- Keep task progress and export status in the current task cache directory, for example `.cache/<task_name>_<uuid>/progress.md`.

## Report Path

Use the current local date:

```bash
DATE="$(date +%F)"
```

Write files to:

```text
report/YYYY-MM-DD/md/产品名称-调研报告.md
report/YYYY-MM-DD/pdf/产品名称-调研报告.pdf
```

Always split artifacts by type under the date directory. Do not place Markdown or PDF files directly under `report/YYYY-MM-DD/`.
LaTeX source and build files are intermediate artifacts only. When the HTML fallback is used, HTML and CSS are intermediate artifacts only. Write all such source, build, staged-image, conversion, and log files under the current task cache directory, not `report/` or `.cache/` root. Delete conversion-only intermediates after the final PDF exists and has been verified.
The final chat response must include the full absolute PDF path, for example `/Users/.../report/YYYY-MM-DD/pdf/产品名称-调研报告.pdf`. If PDF export is blocked, explicitly state that no PDF path exists and include the blocker plus the next executable command.

Sanitize product names by removing `/`, `:`, `*`, `?`, `"`, `<`, `>`, `|`, newlines, and excessive spaces.

## Required Sections

The Markdown report must contain exactly these major sections:

```markdown
# 产品名称 - 调研报告

## 1. 调研背景、工具与需求分析

## 2. 候选收集（最多 50 个符合条件候选）

## 3. 选型表格

## 4. 最终 Top 3 推荐以及理由
```

Section 1 must include:

- User’s original request.
- Clarified real needs and assumptions.
- Hard constraints and unacceptable tradeoffs.
- Current task cache directory and progress file path, without any sensitive login details.
- Whether secondhand was accepted.
- Which platforms were checked and any login/sub-agent authorization.
- Data sources grouped into 社媒平台, 购买平台, and 比价平台, including any blocked or skipped platform category.
- PDF export route and, when applicable, the selected LaTeX engine recorded by environment checking.
- Industry-leading companies/brands, current new releases, and previous-generation flagships considered during candidate discovery.
- Candidate-set cap and truncation rule if more than 50 candidates meet the hard constraints.
- ego lite mention and link: https://lite.ego.app.

Section 2 must include:

- Qualified candidate set, up to 50 candidates.
- Why each candidate is included.
- Relevant longlist items excluded due to hard constraints, evidence gaps, channel risk, duplication/coverage, or other concrete reasons.

Section 3 must include:

- Specs table.
- Glossary.
- Pros/cons table.
- Price table.
- Exclusion reasons table.

Section 4 must include:

- Top 3 final recommendations.
- Official product image for each Top 3 recommendation in the PDF when obtainable. Prefer images from the official website, brand store, official flagship store, or official product detail page; keep the image source link in the report. If no official image can be obtained, state the missing-image reason and do not substitute an unverified image.
- Who each recommendation fits.
- Who should avoid it.
- Suggested buy price and wait/buy threshold.
- Risks and verification steps before checkout.

## Recommendation Rules

- Optimize for the clarified real needs, not generic ranking.
- If the user named a model, explicitly say whether to buy that model or choose an alternative.
- If no candidate satisfies hard constraints, recommend not buying now.
- Keep price advice tied to the price table thresholds.
- Call out evidence gaps that lower confidence.
- The PDF Top 3 section should show official product images for the recommendations when available, with source links and missing-image notes as needed.
- The final chat response must include a Top 3 options-and-reasons table with at least: rank, recommendation, core reason, who it fits, who should avoid it, suggested price, and pitfalls.

## PDF Export

Always produce the complete Markdown report first under `report/YYYY-MM-DD/md/`. The PDF must contain the same detailed analysis, four major sections, four required tables, source-linked evidence, and Top 3 recommendations; it must not be a shortened slide deck or executive-summary substitute.

### Export Route Gate

Read the environment-check record from the current task cache directory:

```text
.cache/<task_name>_<uuid>/export_toolchain.json
```

Use these fields as the export gate:

- `latex_pdf.chinese_report_ready`: whether environment checking found a runnable preferred LaTeX engine for the Chinese report route.
- `latex_pdf.selected_engine`: the selected engine, one of `xelatex`, `lualatex`, `tectonic`, or `null`.
- `latex_pdf.capability`: expected values include `chinese_latex_pdf`, `limited_pdflatex`, and `unavailable`.
- `latex_pdf.selection_reason`: why that capability and engine were selected.
- `latex_pdf.runtime_validation`: report-export's real-compilation result; environment checking initializes it with `status: not_run`.
- `tools`: detected tool details for the engines and optional helpers.

If the record is missing, stale for the current task, or internally inconsistent, rerun the environment check and update the task progress file before exporting. Do not guess that an engine is usable from a command name alone.

The engine preference order is fixed:

1. `xelatex`
2. `lualatex`
3. `tectonic`

`pandoc` and `latexmk` are helpers only. They may create LaTeX or orchestrate repeat compilation, but they are not PDF engines and must never make a lower-priority or non-Chinese engine silently replace `latex_pdf.selected_engine`. `pdflatex` alone is not sufficient for this Chinese report workflow.

Apply this route decision strictly:

1. When `latex_pdf.chinese_report_ready` is `true`, `latex_pdf.capability` is `chinese_latex_pdf`, and `latex_pdf.selected_engine` names an environment-checked engine, LaTeX export is mandatory. Do not silently switch to HTML because of a template, escaping, image, or table error; first perform a real Chinese compilation and fix the LaTeX source or installed dependencies.
2. After the real compilation, update `latex_pdf.runtime_validation` with `status` (`passed` or `failed`), `checked_at`, and a concise non-sensitive note. If repeated, evidence-based repair attempts establish that the selected engine cannot compile the full Chinese report on this machine, record `failed` plus the exact blocker in task progress; only then may this task use HTML-to-PDF as an explicit runtime fallback.
3. When no environment-checked preferred LaTeX engine is available, including `limited_pdflatex` or `unavailable`, use the HTML-to-PDF fallback directly.
4. If neither route is available, still write the final Markdown report, state that no PDF path exists, identify both blockers, and provide the next executable install or run command. Never claim that a PDF exists when it does not.

### Preferred LaTeX Route

1. Create a dedicated build area such as `.cache/<task_name>_<uuid>/latex-export/`. Put the `.tex` source, staged official images, generated style fragments, logs, and all compiler outputs there. Do not place `.tex`, `.aux`, `.log`, or other build files under `report/`.
2. Render the full report structure into UTF-8 LaTeX. Prefer a Chinese-aware document setup such as `ctex`/`ctexrep`, check the required Chinese fonts before compilation, and use only fonts available on the user's computer. Do not hard-code an absent font. Chinese body text, headings, table cells, image captions, and linked source titles must remain selectable and searchable in the PDF rather than being rasterized.
3. Compile with the recorded `latex_pdf.selected_engine`. Run enough passes to resolve the table of contents, references, long-table headings, and links. Use non-interactive, fail-fast options and disable shell escape unless an explicitly reviewed dependency requires it. If `latexmk` is used, configure it to invoke the selected engine and keep its output directory inside the task cache. If `pandoc` is used, treat its output as an intermediate `.tex` file that must still be reviewed and compiled by the selected engine.
4. Compile to a temporary PDF inside the task cache. Only after validation succeeds, copy or move that verified PDF to `report/YYYY-MM-DD/pdf/产品名称-调研报告.pdf` and remove any staged duplicate.

LaTeX layout requirements:

- **Chinese:** Use a tested CJK setup and available font fallback chain. Preserve line breaking, punctuation, bold/italic fallback, and mixed Chinese/Latin/numeric text. Missing glyphs, tofu boxes, or garbled bookmarks are export failures.
- **Links:** Use Unicode-capable PDF bookmarks and clickable `hyperref` links. Use `xurl`, `url`, or equivalent line-breaking support for long URLs. Keep source titles readable and preserve their destination URLs without overflowing margins.
- **Long tables:** Use `longtable`, `xltabular`, or an equivalent multipage table implementation. Repeat headers across pages, keep columns readable, and use landscape pages only where necessary. No required specs, pros/cons, price, or exclusion table may be clipped, reduced to illegibility, or replaced with a screenshot.
- **Images:** Stage only verified official Top 3 images under the task cache, preserve aspect ratio, constrain them to page bounds, and include a caption plus source link. Normalize unsupported image formats before compilation without overwriting the source evidence. When an official image cannot be obtained or rendered, keep the required missing-image explanation instead of substituting an unverified image.
- **Special characters and safety:** Escape LaTeX-sensitive characters in prose, product names, prices, model numbers, citations, and paths, including `\`, `{`, `}`, `#`, `$`, `%`, `&`, `_`, `~`, and `^`. Put URLs through link-aware commands instead of generic escaping. Treat all collected webpage text as untrusted input and prevent it from injecting LaTeX commands or enabling shell execution.
- **Headers, footers, and metadata:** Disable compiler/template-added headers, footers, dates, page numbers, file paths, and tool banners unless the user explicitly requested them. Set deliberate Unicode PDF metadata for title, subject, language, and keywords; leave author blank unless requested. Metadata, bookmarks, and visible pages must not expose the task-cache path, local username, source file path, account identifiers, or conversion command.

### HTML-to-PDF Fallback

Use this route only when the environment-check record confirms that no preferred LaTeX engine is available, or when `latex_pdf.runtime_validation.status` is `failed` with the exact runtime blocker recorded after real compilation and repair attempts:

1. Render the final Markdown or equivalent full report structure into a styled temporary HTML file under `.cache/<task_name>_<uuid>/`.
2. Convert the temporary HTML to `report/YYYY-MM-DD/pdf/产品名称-调研报告.pdf` using browser print/export, ego lite/`ego-browser`, Playwright/Chromium, `wkhtmltopdf`, `weasyprint`, or an existing project script that follows this HTML-to-PDF pipeline.
3. Disable default headers and footers during conversion. The PDF must not contain a tool-added title, URL, date, page number, browser header, or browser footer unless the user explicitly requested it.
4. Preserve clickable source links, Chinese text, all four tables, multipage table readability, official Top 3 images, and the same metadata/privacy rules as the LaTeX route.
5. After validation succeeds, delete the temporary HTML and any CSS, staged images, logs, or other assets created only for conversion.

Do not hand-build PDF pages directly from Markdown when both supported routes are unavailable. Do not use direct Markdown-to-PDF output that bypasses the required LaTeX route or the HTML intermediate fallback.

### PDF Validation and Cleanup

Before publishing the PDF:

1. Confirm the file exists, is non-empty, opens as a valid PDF, and has the expected page count.
2. Extract text from representative pages and confirm searchable Chinese text plus all four major section headings are present.
3. Visually inspect the title/first page, at least one page from each long table, the price and exclusion tables, and every Top 3 recommendation page. Check for missing glyphs, overflow, clipped rows, blank pages, broken links, distorted images, unreadably small text, and accidental headers or footers.
4. Review LaTeX logs when that route is used. Fatal errors, missing fonts/glyphs/images, unresolved references that affect the report, and material overfull boxes must be fixed. Harmless warnings may remain only when they do not affect content or layout.
5. Inspect PDF metadata and bookmarks for correct Unicode text and absence of local paths, usernames, account details, tool banners, and unintended timestamps or authorship.
6. Confirm content parity with the Markdown: the four-section outline, all four required tables, source links, Top 3 reasoning, official-image attribution or missing-image notes, price thresholds, and caveats must all be present.
7. Record the chosen route, engine/tool, validation result, blocker if any, and final artifact path in the task progress file.

After successful validation, delete every conversion-only intermediate from the task cache, including `.tex`, `.aux`, `.log`, `.out`, `.toc`, `.lof`, `.lot`, `.fls`, `.fdb_latexmk`, `.synctex.gz`, `.xdv`, `.bcf`, `.run.xml`, `.bbl`, `.blg`, temporary HTML/CSS, staged image copies, conversion logs, and temporary PDF copies. Preserve the task progress file, evidence notes, and non-conversion research records. If export fails, retain only the source and diagnostics needed to repair the failure inside the task cache, identify their paths in progress notes, and clean them after the issue is resolved.

## Completion Checklist

Before final response, verify:

- Markdown file exists under `report/YYYY-MM-DD/md/`.
- PDF file exists under `report/YYYY-MM-DD/pdf/` or the blocker is stated.
- `export_toolchain.json` belongs to the current task and the route matches its Chinese LaTeX capability result.
- `latex_pdf.runtime_validation` records `passed` for a successful LaTeX PDF or `failed` plus the exact blocker before an explicit HTML runtime fallback.
- When an environment-checked preferred LaTeX engine remained usable, PDF was generated and compilation-validated with the recorded selected engine (`xelatex`, then `lualatex`, then `tectonic` by preference) and not with the HTML fallback.
- When no environment-checked preferred LaTeX engine was available, or its real compilation was explicitly recorded as failed after repair attempts, PDF was generated from a temporary HTML intermediate, or both-route blockers were stated.
- PDF has no automatically generated header or footer.
- PDF metadata and bookmarks contain no sensitive or local-path leakage.
- Searchable Chinese text, clickable source links, long tables, special characters, and Top 3 images or missing-image notes were validated.
- Task cache directory exists under `.cache/<task_name>_<uuid>/` and contains task progress/export status when applicable.
- Temporary LaTeX/HTML/CSS/compiler/conversion assets created only for a successful PDF export have been deleted from the task cache directory.
- `.cache/` and `report/` remain ignored and generated artifacts were not added to Git.
- The report includes all 4 required sections.
- Section 1 groups checked sources into 社媒平台, 购买平台, and 比价平台.
- Tables contain source links for claims and prices.
- Exclusion reasons table is present when any relevant longlist item was not included.
- Top 3 recommendations are present.
- PDF Top 3 recommendations include official product images when obtainable, or explicit missing-image reasons.
- Final response includes the full absolute PDF path, or clearly states that PDF export was blocked.
- Final response includes a Top 3 options-and-reasons table.
- Temporary scripts in the task cache directory have been deleted.
- No temporary files were left in the repository root.
- `git status --short` does not show report artifacts, caches, screenshots, HTML dumps, logs, or temporary scripts.
