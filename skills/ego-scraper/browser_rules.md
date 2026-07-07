# Ego Browser 安全使用守则

为了做到 “Think of the user”，Agent 驱动 ego lite/`ego-browser` 搜索时必须遵守这些红线。

## 视频页

进入 Bilibili 等含自动播放视频的页面后，立刻执行：

```javascript
document.querySelectorAll('video').forEach(v => {
  v.muted = true;
  v.pause();
});
```

## Tab 清理

- 提取完所需数据后立即关闭对应 Tab。
- 不把用户登录态页面长期挂在后台。
- 不改变购物车、收藏、关注、地址、付款、订阅等账号状态。

## 任务缓存与临时文件

- 每个任务必须使用自己的任务缓存目录 `.cache/<task_name>_<uuid>/`。
- 自动化脚本、抓取中间数据、任务进展和登录态检查缓存只能放在本任务缓存目录。
- 任务结束后删除临时 Node.js 脚本。
- 根目录不得留下临时 HTML、截图、日志或调试脚本。

## 缓存

登录态检查结果写入 `.cache/<task_name>_<uuid>/login_status.json`，只记录站点、状态、检查时间和备注。不得保存 Cookie、Token、手机号、收货地址、支付信息等敏感数据。
