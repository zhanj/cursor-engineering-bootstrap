# /init-scan（frontend）

目标：根据 `_cursor_init/*` 与前端真实工程结构，输出可落库的校准方案。

## 输入
- `_cursor_init/report.md`
- `_cursor_init/proposed_tree.md`
- `_cursor_init/hooks.suggested.json`
- 前端项目结构（包管理器、路由、API 目录、UI 组件体系）

## 执行步骤
1. 识别包管理器（pnpm/yarn/npm）与 TypeScript 配置。
2. 对比 `.cursor/hooks/hooks.json` 与 `_cursor_init/hooks.suggested.json`。
3. 校准规则中的目录落点（views/components/api/router/store）。
4. 检查 API 调用风格是否统一（request 封装、错误处理、鉴权头）。
5. 对 `spec_center` 与 `constitution` 执行“补缺不覆盖”策略（与 `--overwrite` 开关对齐）：
   - `spec_center` 缺失 + `overwrite=off`：补建最小资产（至少 `capability-registry.md` 与 `<service>/contracts/openapi.yaml` 占位）。
   - `spec_center` 已存在 + `overwrite=off`：保持现状，不覆盖。
   - `spec_center` 已存在 + `overwrite=on`：允许按团队策略覆盖/重建（需在输出中标注覆盖范围）。
   - `constitution` 缺失 + `overwrite=off`：按 `docs/speckit-constitution-prompt.md` 执行 `/speckit.constitution` 并补建。
   - `constitution` 已存在 + `overwrite=off`：保持现状，不覆盖。
   - `constitution` 已存在 + `overwrite=on`：允许更新（需在输出中标注差异与原因）。
7. 输出落库清单与风险点。

## 输出格式（必须）
- `校准结论`
- `建议改动文件`
- `待人工确认`
- `验证命令`
- `Spec 资产状态`（按状态词输出 `capability-registry/openapi`：`exists`/`missing`/`unreadable`/`path_mismatch`，并标注“待建”项）
- `Constitution 状态`（按状态词输出 `.specify/memory/constitution.md`：`exists`/`missing`/`unreadable`/`path_mismatch`，以及处理结果：已补建/待人工处理）
- `覆盖开关状态`（`overwrite=on/off` 与实际动作：`created`/`skipped`/`overwritten`）

## 禁止事项
- 不直接改业务代码。
- 不删除已有 `.cursor` 文件；冲突时建议生成 `*.v2`。
