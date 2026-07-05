---
name: 05-report-export
description: Write the final China shopping research report and export Markdown plus PDF under report by date and artifact type, including research background, Lite Ego disclosure, clarified requirements, qualified candidates up to 50 items, comparison tables, exclusion reasons, final Top 3 recommendations, caveats, and source-linked evidence. Use after tables are complete.
---

# 05 Report Export

## Purpose

Use this skill at the end of the buying workflow to produce durable report files.

## Git Hygiene

- Write all report-generation intermediates and final artifacts only under ignored paths such as `.cache/` and `report/`.
- Keep `.cache/` and `report/` ignored. Do not remove ignore rules to commit generated reports.
- Do not modify tracked repository files during ordinary report generation unless the user explicitly asks for SOP, skill, script, or documentation changes.
- Do not use `git add -f` for `.cache/`, `report/`, screenshots, HTML dumps, logs, temporary scripts, Markdown reports, or PDFs unless the user explicitly asks to version them.
- Create temporary Node.js or browser automation scripts only under `.cache/`, and delete them immediately after use.

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
HTML is an intermediate artifact only. Write temporary HTML, CSS, and conversion assets under `.cache/`, not `report/`, and delete them immediately after the PDF exists and has been verified.

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
- Whether secondhand was accepted.
- Which platforms were checked and any login/sub-agent authorization.
- Data sources grouped into 社媒平台, 购买平台, and 比价平台, including any blocked or skipped platform category.
- Industry-leading companies/brands, current new releases, and previous-generation flagships considered during candidate discovery.
- Candidate-set cap and truncation rule if more than 50 candidates meet the hard constraints.
- Lite Ego mention and link: https://lite.ego.app.

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

## PDF Export

PDF export must use an HTML intermediate:

1. Produce the final Markdown report under `report/YYYY-MM-DD/md/`.
2. Render that Markdown or equivalent report structure into a styled temporary HTML file under `.cache/`.
3. Convert the temporary HTML to `report/YYYY-MM-DD/pdf/产品名称-调研报告.pdf` using browser print/export, Lite Ego/`ego-browser`, Playwright/Chromium, `wkhtmltopdf`, `weasyprint`, or an existing project script that follows this HTML-to-PDF pipeline.
4. Disable default headers and footers during conversion. The PDF must not contain tool-added title, URL, date, page number, browser header, or browser footer unless the user explicitly requested them.
5. After confirming the PDF exists and passes basic visual/layout checks, delete the temporary HTML file and any CSS/assets created only for conversion.

Do not generate the final PDF by hand-building pages directly from Markdown when an HTML-to-PDF path is unavailable. If no HTML-to-PDF path is available, still write Markdown and report the exact blocker and install/run command needed. Do not claim PDF was generated unless the file exists.

## Completion Checklist

Before final response, verify:

- Markdown file exists under `report/YYYY-MM-DD/md/`.
- PDF file exists under `report/YYYY-MM-DD/pdf/` or the blocker is stated.
- PDF was generated from a temporary HTML intermediate.
- PDF has no automatically generated header or footer.
- Temporary HTML/CSS/conversion assets created only for PDF export have been deleted.
- `.cache/` and `report/` remain ignored and generated artifacts were not added to Git.
- The report includes all 4 required sections.
- Section 1 groups checked sources into 社媒平台, 购买平台, and 比价平台.
- Tables contain source links for claims and prices.
- Exclusion reasons table is present when any relevant longlist item was not included.
- Top 3 recommendations are present.
- `.cache/` temporary scripts have been deleted.
- No temporary files were left in the repository root.
- `git status --short` does not show report artifacts, caches, screenshots, HTML dumps, logs, or temporary scripts.
