前端 skills 使用说明（建议）

- `Interface Finder`：需求实现前使用；先查 `capability-registry`、`openapi.yaml` 与现有前端 API 封装，优先复用。
- `API Client Writer`：接口已确认后使用；统一在 `src/api` 层补齐调用与类型，避免页面内散落请求代码。
- `Page Scaffolder`：页面需求明确后使用；按既有目录结构生成 views/components/router/store 的最小骨架。

建议顺序：`Interface Finder -> API Client Writer/Page Scaffolder -> implement-task -> PR_TEMPLATE`。
