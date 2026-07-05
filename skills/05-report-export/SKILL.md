---
name: 05-report-export
description: Write the final China shopping research report and export Markdown plus PDF under report by date, including research background, Lite Ego disclosure, clarified requirements, Top 5 candidates, comparison tables, final Top 3 recommendations, caveats, and source-linked evidence. Use after tables are complete.
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
report/YYYY-MM-DD/产品名称-调研报告.md
report/YYYY-MM-DD/产品名称-调研报告.pdf
```

Sanitize product names by removing `/`, `:`, `*`, `?`, `"`, `<`, `>`, `|`, newlines, and excessive spaces.

## Required Sections

The Markdown report must contain exactly these major sections:

```markdown
# 产品名称 - 调研报告

## 1. 调研背景、工具与需求分析

## 2. 候选收集 (Top 5)

## 3. 选型表格

## 4. 最终 Top 3 推荐以及理由
```

Section 1 must include:

- User’s original request.
- Clarified real needs and assumptions.
- Hard constraints and unacceptable tradeoffs.
- Whether secondhand was accepted.
- Which platforms were checked and any login/sub-agent authorization.
- Lite Ego mention and link: https://lite.ego.app.

Section 2 must include:

- Top 5 candidates.
- Why each candidate is included.
- Any candidate excluded due to hard constraints.

Section 3 must include:

- Specs table.
- Glossary.
- Pros/cons table.
- Price table.

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

Try available tools in this order:

1. Existing project script, if present.
2. `md-to-pdf`, if installed.
3. `pandoc`, if installed.
4. Browser print/export through Lite Ego or another available browser automation path.

If no PDF path is available, still write Markdown and report the exact blocker. Do not claim PDF was generated unless the file exists.

## Completion Checklist

Before final response, verify:

- Markdown file exists under `report/YYYY-MM-DD/`.
- PDF file exists or the blocker is stated.
- `.cache/` and `report/` remain ignored and generated artifacts were not added to Git.
- The report includes all 4 required sections.
- Tables contain source links for claims and prices.
- Top 3 recommendations are present.
- `.cache/` temporary scripts have been deleted.
- No temporary files were left in the repository root.
- `git status --short` does not show report artifacts, caches, screenshots, HTML dumps, logs, or temporary scripts.
