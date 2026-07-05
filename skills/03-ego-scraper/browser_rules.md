# Ego Browser 安全使用守则

为了做到 "Think of the user"，Agent 驱动 `ego-browser` 进行搜索时必须遵守以下红线：

1. **页面进入即静音 (针对视频网站)**:
   当访问 Bilibili 等含有自动播放视频的页面时，页面加载后应立刻执行此段 JS 代码以防止声音打扰用户：
   ```javascript
   document.querySelectorAll('video').forEach(v => {
       v.muted = true;
       v.pause();
   });
   ```

2. **即用即关 (Tab Cleanup)**:
   严禁留下多余的 Tab。只要提取到了所需的数据（比如价格、评论文本），请立刻关闭对应的页面。

3. **利用缓存 (.cache)**:
   如果需要验证用户是否在某电商平台处于登录态，可以将检查结果存入 `.cache/login_status.json`，减少不必要的反复打开页面。
