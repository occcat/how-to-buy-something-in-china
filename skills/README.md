# Skills Directory

这里存放本项目的本地 Agent Skills。每个阶段都是一个标准 Skill 目录，包含 `SKILL.md` 和可选的 `agents/openai.yaml`、脚本、参考文件。

## 阶段目录

- `01-needs-analysis/`：先搜后问，拆解购买需求，识别伪需求，生成调研画像。
- `02-env-check/`：检查 macOS、Lite Ego、登录态缓存和 Sub Agent 授权。
- `03-ego-scraper/`：用 Lite Ego 免打扰采集社媒平台、购买平台、比价平台数据。
- `04-selection-tables/`：把 Top 5 候选整理成配置表、优缺点表和价格表。
- `05-report-export/`：生成最终 Markdown 报告、Top 3 推荐和 PDF。

## 使用方式

执行购买调研时，先读取根目录 `AGENTS.md`，再按阶段读取对应 `SKILL.md`。不要一次性加载无关阶段的参考文件或脚本。

## 目录约束

- `.cache/` 只放登录态缓存、抓取中间数据和临时脚本，必须被 Git 忽略。
- `report/` 只放最终 Markdown/PDF 报告，必须被 Git 忽略。
- 调用浏览器自动化写临时 Node.js 脚本时，只能写入 `.cache/`，结束后删除。
- 不在根目录遗留临时抓取文件、截图、HTML 或调试脚本。
