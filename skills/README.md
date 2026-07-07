# Skills Directory

这里存放本项目的本地 Agent Skills。每个阶段都是一个标准 Skill 目录，包含 `SKILL.md` 和可选的 `agents/openai.yaml`、脚本、参考文件。

## 阶段目录

- `needs-analysis/`：阶段 1，先搜后问，拆解购买需求，识别伪需求，生成调研画像。
- `env-check/`：阶段 2，检查 macOS、ego lite、登录态缓存和 Sub Agent 授权。
- `ego-scraper/`：阶段 3，用 ego lite 免打扰扫描行业头部公司、新品、前几代旗舰，并采集社媒平台、购买平台、比价平台数据。
- `selection-tables/`：阶段 4，把最多 50 个符合条件候选整理成配置表、优缺点表、价格表和未入选原因表。
- `report-export/`：阶段 5，生成最终 Markdown 报告、Top 3 推荐和 PDF；PDF 必须先经由临时 HTML 中间格式生成。

## 使用方式

执行购买调研时，先读取根目录 `AGENTS.md`，再按阶段读取对应 `SKILL.md`。不要一次性加载无关阶段的参考文件或脚本。

## 目录约束

- `.cache/` 只作为任务缓存目录父目录，必须被 Git 忽略；每个任务必须创建 `.cache/<task_name>_<uuid>/`。
- 登录态缓存、任务进展、抓取中间数据、截图、日志和临时脚本只能放在本任务缓存目录，不得写入 `.cache/` 根层。
- PDF 导出用的临时 HTML/CSS/资源文件只能放在本任务缓存目录，PDF 生成并验证后必须删除，不得作为最终产物保留。
- `report/` 只放最终 Markdown/PDF 报告，必须被 Git 忽略；同一日期下按 `report/YYYY-MM-DD/{md,pdf}/` 拆分产物类型。
- 调用浏览器自动化写临时 Node.js 脚本时，只能写入本任务缓存目录，结束后删除。
- 不在根目录遗留临时抓取文件、截图、HTML 或调试脚本。
