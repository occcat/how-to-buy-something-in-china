---
name: 04-selection-tables
description: Build structured Top 5 product comparison tables for China buying reports, including ranked specs with medals, linked pros and cons from real user evidence, linked price bands, glossary explanations, and defensible thresholds. Use after evidence collection.
---

# 04 Selection Tables

## Purpose

Use this skill after Top 5 candidates and source notes are collected. The output is the analysis core of the final report.

## Candidate Rules

- Keep exactly Top 5 unless the category has fewer viable products or the user explicitly narrows the scope.
- Include the user’s named model when the request names one, even if it may not win.
- If a candidate violates a hard constraint, remove it or mark why it is only a reference comparison.
- Preserve source links from collection; do not invent links.
- Preserve platform categories from collection: 社媒平台, 购买平台, 比价平台.

## Specs Table

Create a Markdown table with products as columns and parameters as rows.

Required behavior:

- Mark top 3 sortable values with 🥇, 🥈, 🥉.
- Decide ranking direction per metric.
- Use “未确认” when no reliable source is available.
- Put source links in the cell when concise, or in a separate “参数来源” row if cells become unreadable.

Example shape:

```markdown
| 参数 | 产品 A | 产品 B | 产品 C | 产品 D | 产品 E |
|---|---:|---:|---:|---:|---:|
| 到手价 | 🥇 ¥2999 | 🥈 ¥3299 | 🥉 ¥3499 | ¥3999 | ¥4299 |
| 重量 | 🥈 190g | 🥇 184g | 205g | 🥉 193g | 210g |
```

Common ranking direction:

- Lower is better: price, weight, thickness, noise, charging time, repair cost.
- Higher is better: battery capacity, charging power, brightness, refresh rate, storage, warranty length.
- Contextual: screen size, camera megapixels, benchmark scores, AI features, water resistance.

## Glossary

Below the specs table, explain each professional metric in plain language:

```markdown
**名词解释**
- SoC/处理器：决定性能和能效，类似汽车发动机；同代旗舰芯片通常游戏帧率更稳。
- 屏幕峰值亮度：强光下看清屏幕的能力，不等于日常一直这么亮。
```

Keep explanations practical and tied to buying decisions.

## Pros And Cons Table

Focus on real user experience and keep links:

```markdown
| 产品 | 主要优点 | 主要缺点 | 适合人群 |
|---|---|---|---|
| 产品 A | [续航很稳](https://...), [系统流畅](https://...) | [游戏发热](https://...), [拍照偏色](https://...) | 重度续航用户 |
```

Rules:

- Prefer 社媒平台 links for user experience claims; purchase-platform reviews can supplement but should be labeled as purchase-platform evidence when material.
- Separate review-channel opinions, ordinary user feedback, and Xianyu seller exit reasons when possible.
- Combine repeated claims with comma-separated links.
- Do not over-weight a single viral complaint unless multiple independent sources support it.
- Mention uncertainty when reviews appear sponsored or too new.

## Price Table

Create price bands with linked sources:

```markdown
| 产品 | 全新 | 二手 | 神价 | 好价 | 正常价 | 官价 |
|---|---|---|---|---|---|---|
| 产品 A | [¥3299](https://...) | [¥2600-2800](https://...) | < ¥2999 | ¥2999-3299 | ¥3299-3699 | [¥3999](https://...) |
```

Rules:

- Include “二手” only when allowed or useful for resale analysis.
- Define 神价/好价/正常价 by separating 购买平台 live prices, 比价平台 history/thresholds, and 社媒平台 price clues.
- Official price is reference only, not a recommendation by itself.
- Clarify coupon, subsidy, presale, third-party, and warranty caveats.
- Mark Pinduoduo clues as not directly verified unless they come from an accessible purchase page explicitly checked in scope.

## Output Contract

End with:

- Candidate list and one-line positioning.
- Specs table with medals and glossary.
- Pros/cons table with linked claims.
- Price table with linked prices, threshold logic, and source platform category distinctions.
- Known data gaps and how they affect confidence.
