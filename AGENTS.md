# AGENTS.md — "在中国买什么"调研 Pipeline

> 一套可复用的、从「某品类产品」调研到「性价比 TOP3 推荐」的端到端流程。
> 全程用 web 检索 + ego-browser 上闲鱼抓真实二手价 + B 站评论区抓真实用户口碑，
> 不刷视频、不读 UP 主口径，只听买卖双方的实战信号。
>
> 本流程源自一次实战：从"一加手机"的需求，产出闲鱼二手价对照表 + B 站评论区优缺点 + 性价比 TOP3 推荐。

---

## 0. 何时使用这一套流程

适用输入形态：「调研一下 _X_ 以及最新的二手价范围，上闲鱼看看，选性价比最高的前三款」。
要求满足以下至少一条：
- 品类在国内电商体系有大量二手/个人闲置交易（手机、笔记本、相机、平板、键盘、游戏机、相机镜头…）
- 品类有活跃的 B 站评测内容（数码 3C、家电、汽车…）
- 用户既关心"现在多少钱能拿下"，又关心"真实用户用了之后骂什么"

不适用：纯软服务、订阅、一次性的尾部冷门品（闲鱼/B 站信号不足），或用户只要一个型号的事实查询。

---

## 1. 工具与前置

| 用途 | 工具 | 备注 |
|---|---|---|
| 产品背景 / 型号清单 / 官方首发价 | `WebSearch` 或 ego-browser 上百度/Bing | 国内品类优先用百度/必应，搜索词要带"型号大全""发布时间""首发价" |
| 闲鱼二手真实挂单价 | `ego-browser` + `Bash` heredoc | 闲鱼无公开 API，必须真浏览器；网页版 = `goofish.com` |
| B 站真实用户口碑 | `ego-browser` + `serverFetch` 调 B 站 reply API | **不要点开视频播放**，只抓评论 API |
| 报告输出 | 直接 Markdown | 表格 + 速查表 |

**前提**：`ego-browser` CLI 已装好（`/Users/huiliu/.local/bin/ego-browser` 可执行）。第一次出错才看 `references/install.md`，否则不要预检。

**两次 session 的核心教训**（已固化进下面的步骤，避免重蹈覆辙）：
1. Baidu 首页搜索框**默认 placeholder 不是搜索值**，必须先 `snapshotText` 拿到最新 `@N` ref 再 `fillInput`，或直接 `js()` 写 `document.getElementById('kw').value = ...` 再 `click`。决不能跨轮复用上一轮的 ref。
2. 闲鱼搜索结果**只在首屏可见文本里有**价格信息，DOM 卡片 class 经常抽不出来。抓 `document.body.innerText` 这种"脏但稳"的方式反而最可靠。
3. B 站评论区是 SPA 懒加载，**点 tab / 等 `.reply-item` 几乎抓不到**。正确路径：用 `api.bilibili.com/x/web-interface/view?bvid=...` 拿 aid → 用 `api.bilibili.com/x/v2/reply/main?type=1&oid={aid}&mode=3&ps=40&next=0` 直接拿 JSON。这是**唯一稳定**的评论区获取方式。
4. **不要打开视频页**——视频会自动播放，吵到用户。`view?bvid=...` 接口拿 aid 完全不进视频页；万一进了视频页，立刻 `document.querySelectorAll('video').forEach(v=>{v.pause();v.muted=true;v.volume=0})` 兜底。
5. 每完成一个阶段就 `completeTaskSpace(task.id, { keep: false })` 关掉任务空间，避免多 Tab 占内存（用户明确要求过）。

---

## 2. Pipeline 总览（5 阶段）

```
[阶段 A] 品类背景调研  →  机型清单 + 首发/配置信息
[阶段 B] 闲鱼二手价抓取  →  每款机型的成交价区间
[阶段 C] B 站评论区抓取  →  每款机型的优/缺点信号
[阶段 D] 综合分析        →  性价比 TOP3 推荐
[阶段 E] 收尾            →  关闭 task space、输出报告
```

每个阶段一个独立 heredoc，**进阶段前先关上一阶段的 task space**（用户要求"看完每个 Tab 后要及时关闭"）。

---

## 3. 各阶段详细 SOP

### 阶段 A · 品类背景调研

**目标**：拿到该品类下"现在还在流通的代表机型清单 + 各自发布时间/处理器（或核心配置）/首发价"。

**输入**：用户给的品类名（如"一加手机"）。

**操作**：
1. `WebSearch` 搜 "{品类} 型号大全 发布时间 价格"、"最新款 {品类} 2026"
2. 如 WebSearch 信号薄（国内品类常见），用 ego-browser 开 `https://www.baidu.com`：
   ```js
   await openOrReuseTab('https://www.baidu.com', { wait: true, timeout: 20 })
   await js(String.raw`(() => {
     const ta = document.getElementById('kw');
     ta.value = '{品类} 型号及发布时间';
     ta.dispatchEvent(new Event('input', { bubbles: true }));
     document.getElementById('su').click();
   })()`)
   await wait(4)
   const snap = await snapshotText()   // 注意：snapshotText 才能拿到 #content_left 的语义树
   ```
3. 从快照里提取候选机型 + 关键参数。

**输出**：一份"机型 → (发布时间 / 核心配置 / 首发价)"清单，5~8 款即可，不要贪多。

**坑**：百度快照里夹杂热搜、图片卡片、爱采购等噪声，只看 `#content_left` 下含型号文字 + 价格数字的 anchor 段落。

---

### 阶段 B · 闲鱼二手价抓取

**目标**：对阶段 A 清单里**每一款**机型，在闲鱼抓 10~20 条个人闲置挂单，归纳出"按配置的二手成交价区间"。

**核心约束**：闲鱼无 API、强反爬，只能真浏览器开搜索页抓 `innerText`。

**Herisdoc 模板**（每款机型跑一次，**不同机型复用同一个 task space**——不要每次新建）：

```js
ego-browser nodejs <<'EOF'
const task = await useOrCreateTaskSpace('xianyu search')   // 复用同一个

// URL 直接走搜索路径，避免点搜索框（搜索框 ref 不稳定）
const q = encodeURIComponent('一加13');   // ← 改这里
await openOrReuseTab('https://www.goofish.com/search?q=' + q, { wait: true, timeout: 20 })
await wait(3)
await scrollBy(300)       // 触发更多挂单懒加载
await wait(1)

// 闲鱼的挂单 DOM class 抽不出来，直接拿 body 文本最稳
const txt = await js(String.raw`(() => document.body.innerText.substring(0, 3000))()`)
cliLog("=== 一加13 闲鱼结果 ===")   // ← 改这里
cliLog(txt)

// 重要：最后**一款**搜完才关 task space。中间不要关、不要 keep
EOF
```

**关键技巧**：
- **永远用 URL 直接进搜索结果**，不要点首页搜索框（闲鱼首页搜索框 placeholder 是上次热门词，不是你的查询；ref 不稳定）。
- `goofish.com` 是闲鱼网页版正确域名，`xianyu.com` 会跳转重定向。
- **抓 `document.body.innerText` 而不是 `.feed-item` 这类 class**——闲鱼 class 名是混淆过的、跨版本不一致，innerText 永远在。
- 每张挂单的模式固定是：`<标题描述>\nX小时前发布\n¥\n<价格>\nX人想要\n\n<地区>`，价格 + 配置都能从纯文本里人眼/正则提取。
- 如要更结构化，可在 innerText 上跑正则提 `(¥)(\d{3,5})` 抽价格序列，但要人工剔除噪声（首页热搜词、搜索建议）。

**输出**：每款机型一行表：
```
| {型号} | {配置} | {下限~上限} |
```
下限 = 带瑕疵（磕碰/划痕/轻微屏老）的挂单价；上限 = 几乎全新/全套/在保。

**收尾**：最后一款搜完，单独发一个 heredoc `await completeTaskSpace(task.id, { keep: false })` 关掉释放内存，再进阶段 C。

---

### 阶段 C · B 站评论区抓取

**目标**：对清单里每款机型，找 1~2 个高播放评测视频，抓"按点赞排序的热门评论"，归纳优/缺点。

**绝对铁律**：**不打开视频页播放视频**。用户明确说"太吵了"。

#### Step C1：搜出评测视频的 BV 号

```js
ego-browser nodejs <<'EOF'
const task = await useOrCreateTaskSpace('bilibili research')
async function bvList(kw) {
  const u = 'https://search.bilibili.com/all?keyword=' + encodeURIComponent(kw) + '&order=click';
  await openOrReuseTab(u, { wait: true, timeout: 20 })
  await wait(4); await scrollBy(400); await wait(1)
  return await js(String.raw`(() => {
    const anchors = [...document.querySelectorAll('a[href*="/video/BV"]')];
    const seen = new Set(); const out = [];
    for (const a of anchors) {
      const href = a.href.split('#')[0].split('?')[0];
      if (seen.has(href)) continue;
      seen.add(href);
      const bv = (href.match(/BV[a-zA-Z0-9]+/) || [])[0] || '';
      out.push({ bv });
      if (out.length >= 6) break;
    }
    return out;
  })()`)
}
cliLog(JSON.stringify(await bvList("一加13 优缺点 评测")))   // ← 改机型
EOF
```

> ⚠️ 别用 `api.bilibili.com/x/web-interface/search/type` 搜视频——返回 412。搜索页的 DOM 是唯一稳的入口。

#### Step C2：BV → aid → 评论 API（全程不碰视频页）

```js
ego-browser nodejs <<'EOF'
const task = await useOrCreateTaskSpace('bilibili research')

async function aidOf(bv) {
  // view 接口直接拿 aid，不进视频页 = 不可能播放视频
  const body = await serverFetch('https://api.bilibili.com/x/web-interface/view?bvid=' + bv)
  return JSON.parse(body)?.data?.aid || null
}

async function comments(bv, label) {
  const aid = await aidOf(bv)
  if (!aid) { cliLog("no aid for " + bv); return }
  const url = 'https://api.bilibili.com/x/v2/reply/main?type=1&oid=' + aid + '&mode=3&ps=40&next=0'
  const p = JSON.parse(await serverFetch(url))
  if (!p.data?.replies) { cliLog("no replies " + label + " code=" + p.code); return }
  cliLog("\n=== " + label + " (共" + (p.data.cursor?.all_count) + "条) ===")
  const out = p.data.replies
    .map(r => ({ like: r.like||0, text: (r.content?.message||'').replace(/\n+/g,' ').trim().slice(0,240) }))
    .filter(c => c.text)
    .sort((a,b)=>b.like-a.like)
  out.slice(0, 15).forEach(c => cliLog("👍" + c.like + " | " + c.text))
}

// 多机型可以一次 heredoc 里连跑
await comments("BV1m2fGYKEk8", "Ace5 横评")       // ← 用 C1 搜出来的 BV
await comments("BV1LF4m1F7K3", "Ace3 深度评测")
await comments("BV1VDS7YqExD", "一加13 专项评测")

await completeTaskSpace(task.id, { keep: false })   // ★ 抓完立刻关，省内存
EOF
```

**为什么这条路径烂不掉**：
- `view?bvid=` 接口只读元数据，不会创建播放会话，视频不会自动播。
- `reply/main` mode=3 是热门排序，前 15 条点赞高、信号密度极大，远比按时间排序的 mode=2 有用。
- `ps=40` 一页够用，热门评论几乎都在第一页。
- 如果某 BV 评论极少（<50 条），换 C1 里更高播放量的下一个 BV；评论量 < 100 的视频通常信号噪音比很差，不值得整理。

#### Step C3：万一不小心进了视频页的兜底

如果出于任何原因 `openOrReuseTab` 了视频页（例如想抓 video 标题验证），立刻：
```js
await js(String.raw`(() => {
  document.querySelectorAll('video').forEach(v => { v.pause(); v.muted = true; v.volume = 0 })
})()`)
```
并**不要再回去**——优先用 C2 的纯 API 路径，视频页能不开就不开。

---

### 阶段 D · 综合分析 + TOP3

**目标**：用阶段 B 的"价格带"+阶段 C 的"口啤信号"做交叉，产出 TOP3。

**分析框架（每款机型填一格）**：

```
{机型} - {配置} - {二手价区间}
优点：← 从 B 站高赞评论里挑 2~3 条
缺点：← 从 B 站高赞评论里挑 2~3 条（注意区分"喷定价"和"喷产品"）
适合人群：根据优缺点反推
避坑提醒：← 闲鱼挂单里反复出现的瑕疵关键词
```

**TOP3 选择原则**：
1. **价格分层**：不要把三款都放在同一价位段，要覆盖"低/中/高"三档预算。
2. **信号密度优先**：B 站评论数 >500、且闲鱼挂单数 >15 的机型信号才足，才适合首发推荐。
3. **明确推荐第几名**：第一档选"次旗舰甜点位"（通常是上代旗舰芯片 + 大内存的国补跳水机），第二档选"千元够用"，第三档选"旗舰打骨折"。
4. **同时列出"不推荐"组合**：被新机型价格挤压到失去性价比的老款——这条很重要，是真懂行的标志。

---

### 阶段 E · 收尾

1. **关掉所有 task space**（如果阶段 B/C 末尾忘关，这里补一次 `listTaskSpaces` + 逐个 `completeTaskSpace`）。
2. 输出 Markdown 报告，结构固定：
   - 闲鱼二手价对照表（按机型/配置/价区）
   - 价格分档速查（按预算）
   - B 站评论区优缺点（每机型 优/缺/口碑一句话）
   - 性价比 TOP3 推荐（带理由 + 避坑）
3. 报告结尾问用户："要不要按某个具体维度（影像/指纹/续航）再深扒某款？"——通常用户下个问句会聚焦某一款，留个钩子省一轮试探。

---

## 4. 输出格式模板（直接抄）

```markdown
# {品类} 二手行情 & 性价比 TOP3

## 一、闲鱼价格范围
| 型号 | 发布信息 / 首发价 | 配置 | 闲鱼二手价范围 |
|---|---|---|---|
| {型号} | {时间/处理器} / ¥{首发价} 起 | {配置} | ¥{下限~上限} |

## 二、性价比 TOP3 推荐
### 🥇 {型号} ({配置}, ~¥{价位}) —— 一句话定位
- 核心卖点：
- 为什么是它：
- 适合人群：
- 避坑提醒：

### 🥈 ...
### 🥉 ...

## 三、不推荐组合（避雷）
- {被挤压的老款} ...

## 四、综合一句话
- 预算 ¥X → {机型}
- ...

> ⚠️ 闲鱼买二手通用提醒：原装无拆无修、优先在保机、避开已 root、问清电池效率、当面验机。
```

---

## 5. 反模式 / 不要做的事

- ❌ **跨 heredoc 复用 `@N` ref**——每个 heredoc 是独立 Node 进程，ref 上下文丢了。
- ❌ **点百度首页搜索框直接 fillInput**——placeholder 不是你的查询，要么先 snapshotText 拿最新 ref，要么直接 `js()` 写 DOM。
- ❌ **依赖闲鱼 feed-item 这种 class 抓挂单**——混淆、变。直接 `body.innerText`。
- ❌ **点开 B 站视频页等评论区懒加载**——几乎抓不到。直接走 view + reply API。
- ❌ **`online` 调 B 站 search API**——412。搜索页 DOM 才稳。
- ❌ **不关 task space**——多 Tab 内存上飘，用户明确要求及时关闭。
- ❌ **TOP3 全选同一价位段**——失去"性价比"的指导意义。

## 6. 通用化 checklist（换品类时只改这 5 处）

1. 阶段 A：`{品类}` 替换词，列 5~8 款代表型号
2. 阶段 B：闲鱼搜索词 + 配置维度（手机=内存存储 / 相机=机身+镜头 / 笔记本=CPU+内存+屏幕）
3. 阶段 C：B 站搜索词"{品类} 优缺点 评测"
4. 阶段 D：价格分档（千元 / 中端 / 旗舰是手机的三档；笔记本可能是 2000 / 4000 / 7000）
5. 阶段 E：报告里的"避坑提醒"按品类定制（手机的 root/碎屏、笔记本的硬盘通电时长、相机的快门次数…）

---

## 7. 一次实战回放（用来对照本流程）

输入「调研一加手机 + 闲鱼二手价 + 选 Top3」时这套流程实际产出：
- **阶段 A**：列出一加13、12、Ace5、Ace3 Pro、Ace3 五款主流机型 + 各自发布/芯片/首发价
- **阶段 B**：闲鱼搜 5 款 → 抓出价格带（Ace3 12+256 ¥888~979 最低，13 16+512 ¥2230~2600 最高）
- **阶段 C**：B 站 4 个高评评测视频 → 评论 API 拿 ~2 万条评论 → 提炼出"短焦指纹是 Ace5/13 公认硬伤""一加13 长焦退步""Ace3 芯片只是中端"等关键信号
- **阶段 D**：TOP3 = Ace5（甜点）/ Ace3（千元）/ 一加13（旗舰跳水），同时列出"Ace3 Pro 被新产品挤压、一加12 被夹击"避雷
- **阶段 E**：关 task space、Markdown 输出、留"按维度深扒"的钩子

整个流程 7~9 个 heredoc 即可跑完，不播放任何视频，闲鱼真实价格 + B 站真实口碑双路信号闭环。