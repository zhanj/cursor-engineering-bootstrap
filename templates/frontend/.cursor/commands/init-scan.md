# /init-scan（frontend）

目标：根据 `_cursor_init/*` 与前端真实工程结构，输出可落库的校准方案。

## 校准模型（三层）
- Layer 1 `Existence`：文件/目录是否存在（路径正确）。
- Layer 2 `Compatibility`：内容是否与当前技术栈、目录结构、命名约定匹配。
- Layer 3 `Policy`：在 `overwrite=on/off` 下的动作决策（`created`/`patched`/`skipped`/`overwritten`/`needs_manual_merge`）。

## 输入
- `_cursor_init/report.md`
- `_cursor_init/proposed_tree.md`
- `_cursor_init/hooks.suggested.json`
- 前端项目结构（包管理器、路由、API 目录、UI 组件体系）

## 执行步骤
1. 识别包管理器（pnpm/yarn/npm）与 TypeScript 配置。
2. 校准 `rules`：
   - 检查 `.cursor/rules/*.mdc` 存在性与路径。
   - 校准规则中的目录落点（views/components/api/router/store）与分层边界。
3. 校准 `commands`：
   - 检查 `.cursor/commands/*.md` 存在性与入口完整性（`api-search`、`implement-task`、`init-scan`、`bridge-implement`）。
   - 检查命令输出字段与仓库根 `PR_TEMPLATE.md` 的 1~6 段及关键子项是否对齐。
4. 校准 `hooks`：
   - 对比 `.cursor/hooks/hooks.json` 与 `_cursor_init/hooks.suggested.json`。
   - 检查 API 调用风格是否统一（request 封装、错误处理、鉴权头）。
   - 校验 hooks 命令在当前仓可执行（命令可运行、路径可达、门禁模式符合团队约定）。
   - 命令修正遵循“条件提示优先”：
     - 若发现项目存在自定义安装源/脚本参数需求，先输出 `needs_manual_confirm` 提示，不默认阻断。
     - 仅在有明确信号（README/脚本约定或可复现失败）时，建议 `hooks_action=patched`。
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
- `Rules 状态`（`rules_status=ok|missing|drift|conflict`，`rules_action=created|patched|skipped|overwritten|needs_manual_merge`）
- `Commands 状态`（`commands_status=ok|missing|misaligned`，`template_alignment=pass|fail`，`commands_action=created|patched|skipped|overwritten|needs_manual_merge`）
- `Hooks 状态`（`hooks_status=ok|missing|invalid_command|path_mismatch`，`hooks_cmd_check=pass|fail(+reason)`，`hooks_action=created|patched|skipped|overwritten|needs_manual_merge`）
- `Spec 资产状态`（按状态词输出 `capability-registry/openapi`：`exists`/`missing`/`unreadable`/`path_mismatch`，并标注“待建”项）
- `Constitution 状态`（按状态词输出 `.specify/memory/constitution.md`：`exists`/`missing`/`unreadable`/`path_mismatch`，以及处理结果：已补建/待人工处理）
- `Constitution 质量`（`constitution_quality=ready|placeholder|unknown`；若仍含占位符，标记 `placeholder` 并进入 `needs_manual_confirm`）
- `覆盖开关状态`（`overwrite=on/off` 与实际动作：`created`/`skipped`/`overwritten`）

## 禁止事项
- 不直接改业务代码。
- 不删除已有 `.cursor` 文件；冲突时建议生成 `*.v2`。

## 示例输出（参考）
- `校准结论`：可落库（需先补 1 项、修 1 项命令）。
- `建议改动文件`：
  - `.cursor/hooks/hooks.json`（`frontend:lint` 命令从 `pnpm -s lint` 调整为仓库约定命令）
  - `.cursor/rules/10-structure.mdc`（目录落点补充 `src/modules/*` 约束）
- `待人工确认`：
  - 是否将 `CURSOR_CONTRACT_GATE_MODE` 保持 `warn`（后续何时切 `block`）
  - 前端 API 统一目录是否固定在 `src/api/`
- `验证命令`：
  - `pnpm -s lint`
  - `pnpm -s tsc`
  - `bash .cursor/hooks/gates/contract-check.sh`
- `Rules 状态`：`rules_status=drift`，`rules_action=patched`
- `Commands 状态`：`commands_status=ok`，`template_alignment=pass`，`commands_action=skipped`
- `Hooks 状态`：`hooks_status=invalid_command`，`hooks_cmd_check=fail(frontend:lint command not found)`，`hooks_action=patched`
- `Spec 资产状态`：`capability-registry=exists`，`openapi=missing(path_mismatch)`，`action=created`
- `Constitution 状态`：`constitution=missing`，`action=created`（已按提示词补建）
- `Constitution 质量`：`constitution_quality=placeholder`，`action=needs_manual_confirm`
- `覆盖开关状态`：`overwrite=off`，`action_summary=created+patched+skipped`
