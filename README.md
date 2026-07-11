# 在中国买东西指南（how-to-buy-something-in-china）

> 通过 AI 极大简化在中国做购买决策的流程：把一个模糊的「我想买某某」拆解成清晰的需求维度，再把调研网页分成社媒平台、购买平台和比价平台三类，横向抓价格、口碑、优缺点与避坑点，并参考社媒平台或比价平台里的拼多多价格线索，最后产出一份详细的购买指南 PDF。

## 项目简介

在中国买东西，表面上选择极多，真正做决定却很难：

- 商品型号繁杂、参数虚标、评测软广泛滥；
- 不同平台价格、售后、保修政策差异巨大；
- 「性价比」常常被营销话术包装得难以比较。

本项目用 AI 把「购买决策」这件事工程化：

1. **需求拆解**：把模糊的购买意图拆成「预算 / 使用场景 / 关键指标 / 不可妥协项 / 可妥协项」等维度。
2. **信息检索**：先扫描行业头部公司、当前新品、前几代旗舰和仍在售高端型号，再针对符合条件的候选方案按三类网页采集证据：社媒平台（知乎、Bilibili、小红书等）负责真实体验与口碑；购买平台（京东、淘宝/天猫、拼多多、官网等）负责当前价格、库存、版本和售后；比价平台（什么值得买、慢慢买等）负责历史价、好价阈值和补贴线索。拼多多仅作为社媒平台或比价平台里的价格线索参考，不做登录态检查或直接网页采集。
3. **对比分析**：建立候选长名单，筛出最多 50 个符合条件候选并逐维度打分，标注优点、缺点、踩坑点和未入选原因。
4. **指南产出**：汇总成一份结构清晰、可打印的《购买指南 PDF》，包含固定的四章分析、四张选型表格、最终 Top 3、避坑清单与购买链接。若电脑上有可正常处理中文的 LaTeX 引擎，优先通过 LaTeX 生成详细 PDF；否则降级为 HTML→PDF。无论采用哪条导出链路，报告大纲、内容架构和最终目录都不变，PDF 默认不带工具自动添加的页眉页脚。

## 运行依赖

当前仅支持 **macOS**。本项目依赖 ego lite 在隔离浏览器中访问中国社媒平台、购买平台和比价平台；如果运行环境不是 macOS，或没有安装 ego lite/`ego-browser`，Agent 必须直接退出并提示安装，不应继续搜索、提问或推荐。

必备依赖：

- **macOS**：当前唯一支持的系统环境。
- **Git**：用于从 GitHub 克隆本仓库。
- **支持 Plan 模式可选项 UI 的 Agent 客户端**：需求澄清阶段必须用可选择选项向用户提问。
- **ego lite/`ego-browser`**：用于免打扰地复用登录态、隔离打开网页、采集社媒和购买平台证据。

可选但优先使用的 PDF 导出依赖：

- **中文 LaTeX 工具链**：若系统中的 XeLaTeX、LuaLaTeX 等引擎能够正常编译中文内容，Agent 应优先使用 LaTeX 排版并生成详细 PDF；没有可用中文 LaTeX 引擎不会阻断调研，届时改用 HTML→PDF 链路。
- **HTML-to-PDF 工具或浏览器打印能力**：仅在中文 LaTeX 链路不可用时作为降级方案，且必须关闭默认页眉页脚。

两条导出链路都必须保留同一份报告结构：调研背景与需求分析、候选收集、四张选型表格、最终 Top 3 推荐。Markdown 与 PDF 仍分别写入 `report/YYYY-MM-DD/md/` 和 `report/YYYY-MM-DD/pdf/`；LaTeX 源文件、编译辅助文件或 HTML/CSS 等转换资源只放在本次任务缓存目录，PDF 生成并验证后立即清理。

ego lite 安装方式：

1. 打开 [https://lite.ego.app](https://lite.ego.app)。
2. 下载并安装 macOS 版本的 ego lite。
3. 安装后确认你的 Agent 能调用 ego lite 或 `ego-browser`；如果不能调用，请先修复环境，再启动购买调研。

## 目录结构

```
.
├── .gitignore                         # 忽略缓存、报告产物和本地环境文件
├── AGENTS.md                          # 给 AI Agent 的工作说明与执行 SOP
├── CLAUDE.md                          # Claude/Codex 类 Agent 入口提示
├── README.md                          # 你正在看的这份
├── skills/                            # 各阶段可复用的 Agent Skills
│   ├── README.md                      # Skills 目录说明
│   ├── needs-analysis/                # 阶段 1：需求澄清与伪需求识别
│   │   ├── SKILL.md
│   │   └── agents/openai.yaml
│   ├── env-check/                     # 阶段 2：环境、登录态和并行授权检查
│   │   ├── SKILL.md
│   │   ├── check_env.sh
│   │   └── agents/openai.yaml
│   ├── ego-scraper/                   # 阶段 3：ego lite 采集与浏览器规则
│   │   ├── SKILL.md
│   │   ├── browser_rules.md
│   │   └── agents/openai.yaml
│   ├── selection-tables/              # 阶段 4：候选集和选型表格
│   │   ├── SKILL.md
│   │   └── agents/openai.yaml
│   └── report-export/                 # 阶段 5：Markdown/PDF 报告导出
│       ├── SKILL.md
│       └── agents/openai.yaml
├── .cache/                            # 任务级运行时缓存父目录，Git 忽略
│   └── <task_name>_<uuid>/            # 单次任务的登录态、进展、抓取笔记、临时脚本和 LaTeX/HTML 等 PDF 中间文件
└── report/                            # 最终调研报告输出目录，Git 忽略
    └── YYYY-MM-DD/                    # 按执行日期归档
        ├── md/                        # Markdown 报告
        └── pdf/                       # PDF 报告
```

## 适用场景

- 想买某类商品但不知道怎么挑（相机、键盘、净水器、扫地机器人……）；
- 已锁定几个候选型号，想快速横向比较；
- 想要一份可存档、可分享的购买依据，而不是一堆散乱的浏览器标签页。

## 推荐使用方式：优先使用 Plan 模式

**强烈推荐优先使用 Plan 模式**来运行本项目的购买调研流程。需求澄清阶段会频繁向用户提供预算、偏好、雷点、二手接受度、登录授权等默认选项；Plan 模式能提供更接近原生选择器的选项体验，用户可以更顺手地选择，而不是在普通对话里反复输入编号。

### 复制给 Agent 的启动提示词

把下面 Markdown 代码块整体复制给你的 Agent 即可。默认使用 GitHub 仓库作为 SOP 来源，并把仓库固定放在当前用户的系统临时目录下：已有就更新，不存在就只浅克隆最新一层；这个克隆目录就是本次调研的临时工作区，避免污染当前项目。

```markdown
请用 GitHub 上的购买调研 SOP 帮我做一次完整选购分析：https://github.com/occcat/how-to-buy-something-in-china

先在当前用户的系统临时目录准备 SOP 仓库，不要污染我当前项目。用 `TMP_ROOT="${TMPDIR:-/tmp}"` 和 `SOP_DIR="${TMP_ROOT%/}/.how-to-buy-something-in-china"` 确定路径；如果 `$SOP_DIR` 已是 Git clone，就执行 `git -C "$SOP_DIR" pull --ff-only`，如果不存在，就执行 `git clone --depth 1 https://github.com/occcat/how-to-buy-something-in-china "$SOP_DIR"` 只抓最新一层历史。如果该路径存在但不是 Git clone，请停下说明冲突，不要覆盖。

然后按下面要求执行：

1. 必须使用支持 Plan 模式可选项 UI 的工作方式；如果无法提供，请直接告诉我切换环境并退出，不要继续调研。
2. 阅读临时仓库里的 `README.md` 和 `AGENTS.md`，再按 `AGENTS.md` 的阶段流程与 `skills/` 目录执行。
3. 继续前检查运行依赖：仅支持 macOS，且必须安装并能调用 ego lite/`ego-browser`；不满足时说明原因、给出 https://lite.ego.app 并退出。
4. 在 Plan 模式中先问我“这次想买什么”，再用可选择选项澄清预算、场景、雷点、二手接受度、登录授权和并行搜索授权。
5. 完成需求澄清、环境检查、候选长名单、证据采集、固定四章、四张选型表格和最终 Top 3 推荐；每次任务必须创建 `.cache/<task_name>_<uuid>/`，登录态、进展、抓取笔记、临时脚本和 PDF 中间文件都放在这个任务目录里。
6. 导出 PDF 前检查电脑上是否有能够正常处理中文的 LaTeX 引擎；若可用，优先用 LaTeX 生成详细 PDF，若不可用则降级为 HTML→PDF。两条链路都必须保持报告大纲和内容架构不变；LaTeX/HTML 及其辅助文件只放在本任务缓存目录，PDF 生成并验证后立即清理。
7. 报告输出位置分两种情况：如果本次是按上文 clone/pull 得到 `$SOP_DIR`，则 `$SOP_DIR` 就是临时工作区，把 Markdown/PDF 输出到 `$SOP_DIR/report/YYYY-MM-DD/md/` 与 `$SOP_DIR/report/YYYY-MM-DD/pdf/`；如果你已经在本地已有项目里执行，则输出到该项目根目录的 `report/YYYY-MM-DD/md/` 与 `report/YYYY-MM-DD/pdf/`。最终回复给出 PDF 完整路径和 Top 3 理由表格。
```

如果你的 Agent 无法访问 GitHub，可以把本仓库手动下载到本地临时目录后，再把本地路径补充给它。无论使用哪种 Agent 客户端，都必须提供 Plan 模式的可选项 UI；否则 Agent 会按仓库 SOP 在阶段 1 直接退出。

如果当前环境无法提供 Plan 模式那种可选择选项体验，Agent 会在对话中说明并要求切换到 Plan 模式后重新发起购买调研，不会降级为 Markdown 编号选项继续执行。

## 工具策略与致谢：[ego lite browser](https://lite.ego.app)

**强制约束**：当 AI Agent 需要到 B 站、闲鱼、小红书、淘宝等社媒平台或购买平台执行搜索、比价或抓取评论时，**默认且必须使用 ego lite 浏览器（`ego-browser` CLI）**。普通网页抓取工具在这些平台会遭遇严重的反爬拦截、SPA 路由或登录墙阻拦。拼多多归入购买平台，但不作为直接网页采集平台，只记录来自社媒平台或比价平台的公开价格线索。

🙏 **特别致谢**：感谢 [ego lite](https://lite.ego.app) 提供免费、强大且对 AI Agent 极度友好的隔离浏览器环境。没有 ego lite 浏览器，本项目中依赖用户登录态且免打扰的社媒自动化数据挖掘将无法实现。

## 推广

本项目实测使用 [OpenCode](https://opencode.ai/go?ref=BXAWHZCQMB) 驱动的 **GLM-5.2** 来实现搜索与需求分析需求，效果良好。欢迎通过下面的邀请链接体验 OpenCode Go：

👉 **https://opencode.ai/go?ref=BXAWHZCQMB**
（邀请码：`BXAWHZCQMB`）

## License

MIT
