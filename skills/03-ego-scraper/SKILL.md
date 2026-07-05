---
name: 03-ego-scraper
description: Collect China social-platform, purchase-platform, and price-comparison evidence with Lite Ego or ego-browser while avoiding user disruption. Use for Bilibili, Zhihu, Xiaohongshu, Taobao, JD, Xianyu, Manmanbuy, official specs, comments, prices, and linked source notes. Treat Pinduoduo only as indirect price clues from 社媒平台 or 比价平台.
---

# 03 Ego Scraper

## Purpose

Use this skill for all deep collection from Chinese social, purchase, and price-comparison sites after requirements and environment checks are complete.

## Safety Rules

- Use Lite Ego/`ego-browser` for login-bound, SPA, anti-bot, 社媒平台, 购买平台, and 比价平台 pages.
- Close every tab immediately after extracting the needed information.
- On video pages, inject this immediately after load:

```javascript
document.querySelectorAll('video').forEach(v => {
  v.muted = true;
  v.pause();
});
```

- Keep temporary browser automation scripts under `.cache/`.
- Delete temporary scripts after the task.
- Do not leave screenshots, HTML dumps, debug logs, or scrape scripts in the repository root.
- Do not change user account settings, cart, favorites, address, payment, follow state, or subscriptions.

## Platform Categories

Classify every collected webpage into exactly one of these categories:

- 社媒平台: Bilibili, 知乎, 小红书, forums/communities, media reviews, and comment areas. Use these for positive/negative experience, owner feedback, review conclusions, complaints, and reputation signals.
- 购买平台: 京东, 淘宝/天猫, 拼多多, 闲鱼, 官网/品牌商城. Use these for current buyable prices, stock, variants, official specs, warranty, after-sales terms, and purchase links.
- 比价平台: 什么值得买, 慢慢买. Use these for historical lows, good-price/normal-price thresholds, price trends, coupon logic, and public subsidy clues.

Pinduoduo is categorized as a 购买平台, but do not perform login-state checks or direct page collection for it. Record only public Pinduoduo price clues mentioned by 社媒平台 or 比价平台, and mark them as not directly verified.

## Collection Plan

For each Top 5 candidate, collect:

- Official specs: official site, brand store, or trusted spec database.
- MSRP and current new price: official store, JD, Taobao/Tmall.
- Pinduoduo price clues: only from 社媒平台 or 比价平台; mark as not directly verified.
- Historical low: 慢慢买 or other price history page.
- Secondhand range: 闲鱼 only when user accepts secondhand or resale value matters.
- Positive experience: review videos/articles and owner comments.
- Negative experience: comments, complaint posts, 闲鱼 exit reasons, long-term reviews.

Minimum evidence per candidate:

- 1 reliable specs source.
- 1 current price source.
- 1 historical or threshold price source when available.
- 2 positive experience links.
- 2 negative experience links.

If evidence cannot be found, mark it as missing rather than filling the gap with assumptions.

## Source Notes

Record source notes in a structured scratch format, preferably `.cache/research_notes.jsonl`:

```json
{"candidate":"产品 A","platform_category":"社媒平台","site":"bilibili","type":"negative","claim":"游戏发热明显","url":"https://...","quote":"用户原话短摘","checked_at":"2026-07-06T12:00:00+08:00"}
```

Do not quote long copyrighted content. Keep only short claim snippets and links.

## Platform Hints

社媒平台:

- Bilibili: pause/mute first, then inspect title, comments, review conclusions, long-term updates.
- 知乎: separate high-effort answers from short emotional comments.
- 小红书: watch for planted content; prefer repeated complaints across multiple accounts.

购买平台:

- 闲鱼: seller “出坑/换机/暗病” language is useful negative evidence, but treat as anecdotal.
- 京东/淘宝: distinguish official/self-operated, third-party, coupons, presale, and after-subsidy price.
- 拼多多: do not perform login-state checks or direct web collection; record only public subsidy/price clues mentioned by 社媒平台 or 比价平台, and mark them as not directly verified.
- 官网: use for specs and MSRP, not as the best buying price by default.

比价平台:

- 慢慢买: use for history and threshold bands, not as the only live price.
- 什么值得买: use for deal context, coupon logic, and user comments about whether a price is repeatable.

## Output Contract

End collection with:

- Top 5 candidate list and why each remains in scope.
- Evidence notes grouped by candidate and platform category.
- Source links ready for the three final tables, preserving 社媒平台, 购买平台, and 比价平台 distinctions.
- Any missing platform/data and the reason.
