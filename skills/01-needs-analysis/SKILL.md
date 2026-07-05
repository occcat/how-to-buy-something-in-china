---
name: 01-needs-analysis
description: Clarify China shopping requests before research by doing lightweight background search, asking option-based questions, identifying pseudo-needs, and producing a structured requirement profile. Use when a user provides a product category or model such as 手机 or 一加 15T and expects buying advice.
---

# 01 Needs Analysis

## Purpose

Use this skill at the start of every buying task. Do not recommend products until at least one round of background search and user clarification is complete.

## Workflow

1. Perform lightweight background search for the category or model.
   - Identify current market language, popular selling points, known pain points, model variants, rough price range, and common traps.
   - Keep this search shallow; the goal is better questions, not final conclusions.
2. Ask tailored questions.
   - Ask only questions that reduce decision uncertainty.
   - Every question must provide at least 3 concrete default options.
   - Prefer selectable option UI when the runtime supports it, such as Plan-mode choices. Otherwise use numbered Markdown options.
   - Put the recommended/default option first and label it as 推荐.
   - Include an open supplement such as “也可以直接补充你的真实情况”.
3. Identify possible pseudo-needs.
   - Translate surface preferences into possible underlying needs.
   - Confirm rather than assert. Example: “你说想要顶配，我理解可能是想多用几年不卡，还是主要为了游戏帧率？”
4. Repeat at most 3 rounds.
   - Each round must incorporate the user’s previous answer.
   - Stop early once budget, hard constraints, key scenarios, and unacceptable tradeoffs are clear.
5. Produce the requirement profile for later stages.

## Question Design

For a broad category request such as “手机”, ask about:

- Budget: `2000 元以内` / `2000-4000 元` / `4000-6000 元` / `6000 元以上`.
- Main scenario: `拍照/视频` / `游戏性能` / `续航和充电` / `轻薄手感` / `老人或备用机`.
- Preference: `安卓` / `iPhone` / `无品牌偏好` / `只考虑某几个品牌`.
- Hard no: `发热` / `系统广告` / `重` / `拍照差` / `售后弱` / `二手风险`.
- Channel: `只买全新国行` / `接受官方二手或官翻` / `接受闲鱼二手` / `只看低价渠道`.

When no selectable UI is available, format questions like:

```markdown
预算先按哪档筛选？
1. 2000-4000 元（推荐）：覆盖主流高性价比机型，选择最多
2. 4000-6000 元：可以买到更好的影像、屏幕和质感
3. 6000 元以上：优先旗舰体验和长期使用
也可以直接补充你的真实预算。
```

For a specific model such as “一加 15T”, ask model-specific questions:

- Version: `12G+256G` / `16G+512G` / `16G+1T` / `看价格决定`.
- Condition: `只接受全新` / `接受官方翻新/充新` / `接受闲鱼二手`.
- Motivation: `已经看中外观/品牌` / `看中性能` / `看中价格` / `想确认有没有坑`.
- Alternatives: `只和同品牌比` / `可和竞品比` / `只要同价位最优`.
- Risk sensitivity: `不能接受发热` / `不能接受系统问题` / `不能接受续航短` / `不能接受售后麻烦`.

## Pseudo-Need Checks

Always look for these mismatches:

- “顶配” may mean long useful life, not maximum storage.
- “性价比” may mean low total cost, not lowest launch price.
- “拍照好” may mean child/pet motion capture, night scenes, selfies, or video stabilization.
- “轻薄” may conflict with battery life and cooling.
- “二手便宜” may conflict with warranty, battery health, hidden repairs, or account locks.
- “品牌偏好” may be social identity, ecosystem lock-in, or after-sales trust.

Ask the user to confirm the underlying need when it affects candidate selection.

## Output Contract

End the stage with a compact profile:

```markdown
### 需求画像
- 原始需求：
- 预算：
- 核心场景：
- 硬约束：
- 软偏好：
- 明确雷点：
- 是否接受二手：
- 需要登录的平台：
- 已确认真实需求：
- 待验证伪需求：
- Top 5 候选方向：
```

If the user refuses to answer, continue with explicit assumptions and mark them as assumptions.
