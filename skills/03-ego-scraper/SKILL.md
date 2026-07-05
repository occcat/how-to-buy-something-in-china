---
name: 03-ego-scraper
description: Collect China ecommerce and social evidence with Lite Ego or ego-browser while avoiding user disruption. Use for Bilibili, Zhihu, Xiaohongshu, Taobao, JD, Xianyu, Manmanbuy, official specs, comments, prices, and linked source notes. Treat Pinduoduo only as indirect price clues from social/review/price-comparison sources.
---

# 03 Ego Scraper

## Purpose

Use this skill for all deep collection from Chinese sites after requirements and environment checks are complete.

## Safety Rules

- Use Lite Ego/`ego-browser` for login-bound, SPA, anti-bot, ecommerce, and social pages.
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

## Collection Plan

For each Top 5 candidate, collect:

- Official specs: official site, brand store, or trusted spec database.
- MSRP and current new price: official store, JD, Taobao/Tmall.
- Pinduoduo price clues: only from social posts, reviews, or price-comparison platforms; mark as not directly verified.
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
{"candidate":"产品 A","site":"bilibili","type":"negative","claim":"游戏发热明显","url":"https://...","quote":"用户原话短摘","checked_at":"2026-07-06T12:00:00+08:00"}
```

Do not quote long copyrighted content. Keep only short claim snippets and links.

## Platform Hints

- Bilibili: pause/mute first, then inspect title, comments, review conclusions, long-term updates.
- 知乎: separate high-effort answers from short emotional comments.
- 小红书: watch for planted content; prefer repeated complaints across multiple accounts.
- 闲鱼: seller “出坑/换机/暗病” language is useful negative evidence, but treat as anecdotal.
- 慢慢买: use for history and threshold bands, not as the only live price.
- 京东/淘宝: distinguish official/self-operated, third-party, coupons, presale, and after-subsidy price.
- 拼多多: do not perform login-state checks or direct web collection; record only public subsidy/price clues mentioned by social, review, or price-comparison sources, and mark them as not directly verified.
- 官网: use for specs and MSRP, not as the best buying price by default.

## Output Contract

End collection with:

- Top 5 candidate list and why each remains in scope.
- Evidence notes grouped by candidate.
- Source links ready for the three final tables.
- Any missing platform/data and the reason.
