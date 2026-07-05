---
name: 02-env-check
description: Check prerequisites for China shopping research including macOS support, Lite Ego or ego-browser availability, safe login-state caching, required platform login checks, and explicit Sub Agent authorization. Use after needs are clarified and before any deep web collection.
---

# 02 Env Check

## Purpose

Use this skill after requirements are clarified and before collecting data from Chinese ecommerce or social platforms.

## Required Checks

1. Run `skills/02-env-check/check_env.sh` from the repository root.
2. If the OS is not macOS, stop and tell the user Lite Ego currently supports macOS only.
3. If Lite Ego or `ego-browser` is missing, direct the user to install it from https://lite.ego.app.
4. Create `.cache/` if it does not exist.
5. Check platform login state only for sites required by the current research.
6. Cache login state in `.cache/login_status.json`.
7. Ask for manual扫码登录 only when the needed login state is missing.
8. Ask whether Sub Agent parallel search is allowed and disclose higher Token cost.

## Platform Selection

Use the clarified requirements to decide required login checks:

- Bilibili: product reviews, comments, video evidence.
- 知乎: long-form owner experience and complaints.
- 小红书: lifestyle usage, planted/anti-planted notes.
- 京东/淘宝/天猫: live new-item prices and reviews.
- 慢慢买: historical low and price trend.
- 闲鱼: secondhand price, seller exit reasons, resale risk.
- 官网/品牌商城: official specs, MSRP, warranty language.

If the user does not accept secondhand, do not require 闲鱼 login unless resale value is a decision factor.

## Login Cache Schema

Store only non-sensitive state:

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

Prefer selectable option UI when available. If not available, use the numbered Markdown prompts below. Always keep the recommended/default option first.

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
3. 仅在价格/评价信息不足时再询问我
```

## Output Contract

End the stage with:

- OS result.
- Lite Ego/`ego-browser` result.
- Required sites and login status.
- Whether secondhand research is enabled.
- Whether Sub Agent parallel search is authorized.
- Any blocked platforms and agreed fallback.
