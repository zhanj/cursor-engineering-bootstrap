# /check-scaffold（frontend）

目标：对当前工程执行一次“脚手架检查与按工程校准”，重点校准 `.cursor` 与 `spec_center`，并输出可审计证据。

## 执行步骤（必须按顺序）
1. 扫描工程
   - 包管理器与依赖（`pnpm`/`yarn`/`npm`）、路由与 API 目录（如 `src/api`、`src/services`、`src/router`）、状态管理、构建与验证命令。
   - 盘点 `spec_center`：`capability-registry.md`、`<service>/contracts/openapi.yaml`、`<service>/spec.md`、`_raw_contracts` 状态。
2. 优化 `.cursor`
   - 校准 `rules`：为强相关规则补充“本工程约定”（模块名、关键路径、契约位置、构建/验证命令）；若自动维护块（如 `cursor-tune` managed blocks）出现格式异常（如多余 EOF、括号不闭合），一并修正。
   - 校准 `commands`：对齐 `api-search`、`implement-task`、`bridge-implement` 的契约路径、API/路由目录、构建/验证命令；并与仓库根 `PR_TEMPLATE.md` 衔接清晰。
   - 校准 `hooks`：核对 `hooks.json` 与 `gates/*.sh`（如 `config.sh`、`contract-check.sh`）是否匹配当前工程（API 目录、构建命令、校验命令等）；必要时在配置中注明本仓库名称或用途。
3. 优化 `spec_center`
   - 校准 `capability-registry.md` 的检索顺序、OwnerType、契约与实现路径说明，并按业务域扩展同义词（便于 `/api-search` 语义检索）。
   - 校准 `<service>/contracts/openapi.yaml` 与 `<service>/spec.md`，在显眼位置注明“本工程契约路径/实现路径”，便于 AI 与人工对照。
   - 明确 `_raw_contracts/README.md`：本目录仅作归档/兜底，治理契约以主 `openapi.yaml` 为准。
4. 更新文档
   - 若有 `README.md` 或 `doc/DEV.md`，补充/更新环境、构建与运行命令、单测/验证命令、与 Cursor 规则/命令/hooks 的配合说明、`spec_center` 与 PR 流程引用；若无则建议新建（如 `doc/DEV.md`）。

## 输出要求（必须）
- `扫描结论`：模块/API/路由/契约现状。
- `修改项`：按文件列出本次修改与目的。
- `注意点`：后续使用脚手架时的风险或人工确认项。

## 禁止事项
- 不跳过证据段直接给“已完成”结论。
- 不使用“已优化多个文件、效果良好”这类泛化描述替代真实变更。
- 不直接修改业务逻辑代码（仅做脚手架与文档校准）。
