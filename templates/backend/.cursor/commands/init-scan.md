# /init-scan（backend）

目标：读取 `_cursor_init/*` 与真实仓库结构，给出“可直接落库”的校准结果。

## 校准模型（三层）
- Layer 1 `Existence`：文件/目录是否存在（路径正确）。
- Layer 2 `Compatibility`：内容是否与当前技术栈、目录结构、命名约定匹配。
- Layer 3 `Policy`：在 `overwrite=on/off` 下的动作决策（`created`/`patched`/`skipped`/`overwritten`/`needs_manual_merge`）。

## 输入
- `_cursor_init/report.md`
- `_cursor_init/proposed_tree.md`
- `_cursor_init/hooks.suggested.json`
- 后端仓库的真实文件结构（构建工具、测试命令、迁移目录、Mapper/Repository 命名）

## 执行步骤
1. 校验仓库类型：Maven/Gradle、MyBatis/JPA、Flyway/Liquibase。
2. 校准 `rules`：
   - 检查 `.cursor/rules/*.mdc` 存在性与路径。
   - 检查规则是否覆盖契约一致、DB/DAO 一致、模块边界等关键约束，并与仓库分层匹配。
   - 若不一致，输出最小 patch 建议（优先 `patched`，冲突时 `needs_manual_merge`）。
3. 校准 `commands`：
   - 检查 `.cursor/commands/*.md` 存在性与入口完整性（`api-search`、`implement-task`、`init-scan`、`bridge-implement`）。
   - 检查命令输出字段与仓库根 `PR_TEMPLATE.md` 的 1~6 段及关键子项是否对齐。
4. 校准 `hooks`：
   - 对比 `.cursor/hooks/hooks.json` 与 `_cursor_init/hooks.suggested.json`，输出差异。
   - 校准 `.cursor/hooks/gates/config.sh` 中目录正则（controller/api、migration、mybatis xml）。
   - 校验 hooks 命令在当前仓可执行（命令可运行、路径可达、门禁模式符合团队约定）。
   - Maven settings 仅做“条件提示，不强制”：
     - 若仓库存在 `settings-*.xml`，输出 `needs_manual_confirm` 提示，建议评估 `backend:unit-test` 是否需要 `mvn ... -s <settings-file>`。
     - 仅当存在明确信号（如 README/脚本已要求 `-s` 或直接验证失败且原因明确）时，再建议 `hooks_action=patched`。
   - 多模块与迁移目录仅做“建议校准，不强制”：
     - 若检测到多模块路径（如 `*/src/main/java/*`），建议调整 API 白名单正则以匹配模块前缀。
     - 若检测到非常规迁移目录（如 `doc/sql/`），建议补充 `CURSOR_MIGRATION_DIR_EXTRA_RE`。
5. 对 `spec_center` 与 `constitution` 执行“补缺不覆盖”策略（与 `--overwrite` 开关对齐）：
   - `spec_center` 缺失 + `overwrite=off`：补建最小资产（至少 `capability-registry.md` 与 `<service>/contracts/openapi.yaml` 占位）。
   - `spec_center` 已存在 + `overwrite=off`：保持现状，不覆盖。
   - `spec_center` 已存在 + `overwrite=on`：允许按团队策略覆盖/重建（需在输出中标注覆盖范围）。
   - `constitution` 缺失 + `overwrite=off`：按 `docs/speckit-constitution-prompt.md` 执行 `/speckit.constitution` 并补建。
   - `constitution` 已存在 + `overwrite=off`：保持现状，不覆盖。
   - `constitution` 已存在 + `overwrite=on`：允许更新（需在输出中标注差异与原因）。
7. 输出落库清单（新增/修改/保留）与风险点。

## 输出格式（必须）
- `校准结论`：一句话给出是否可落库。
- `建议改动文件`：逐文件列出改动原因。
- `待人工确认`：最多 5 条。
- `验证命令`：可直接复制执行。
- `Rules 状态`：`rules_status=ok|missing|drift|conflict`，`rules_action=created|patched|skipped|overwritten|needs_manual_merge`。
- `Commands 状态`：`commands_status=ok|missing|misaligned`，`template_alignment=pass|fail`，`commands_action=created|patched|skipped|overwritten|needs_manual_merge`。
- `Hooks 状态`：`hooks_status=ok|missing|invalid_command|path_mismatch`，`hooks_cmd_check=pass|fail(+reason)`，`hooks_action=created|patched|skipped|overwritten|needs_manual_merge`。
- `Spec 资产状态`：按状态词输出 `capability-registry/openapi`（`exists`/`missing`/`unreadable`/`path_mismatch`）及“待建”项。
- `Constitution 状态`：按状态词输出 `.specify/memory/constitution.md`（`exists`/`missing`/`unreadable`/`path_mismatch`）与处理结果（已补建/待人工处理）。
- `Constitution 质量`：`constitution_quality=ready|placeholder|unknown`（若仍含 `[PROJECT_NAME]` / `[PRINCIPLE_1_NAME]` 等占位符，标记 `placeholder`，默认走 `needs_manual_confirm`，不阻断）。
- `覆盖开关状态`：`overwrite=on/off` 与实际动作（`created`/`skipped`/`overwritten`）。

## 禁止事项
- 不直接改业务代码。
- 不删除已有 `.cursor` 文件；冲突时建议生成 `*.v2`。

## 示例输出（参考）
- `校准结论`：可落库（需先补 1 项、修 1 项命令）。
- `建议改动文件`：
  - `.cursor/hooks/hooks.json`（`backend:unit-test` 命令从 `mvn -q test` 调整为仓库约定命令）
  - `.cursor/hooks/gates/config.sh`（补充 migration 目录正则）
- `待人工确认`：
  - 是否将 `CURSOR_CONTRACT_GATE_MODE` 保持 `warn`（后续何时切 `block`）
  - Spec Center 接入路径是否统一为 `spec_center/`
  - 如仓库存在 `settings-*.xml`，是否将 `backend:unit-test` 增加 `-s <settings-file>`（仅建议，不强制）
- `验证命令`：
  - `mvn -q test`
  - `bash .cursor/hooks/gates/contract-check.sh`
  - `bash .cursor/hooks/gates/db-change-check.sh`
- `Rules 状态`：`rules_status=drift`，`rules_action=patched`
- `Commands 状态`：`commands_status=ok`，`template_alignment=pass`，`commands_action=skipped`
- `Hooks 状态`：`hooks_status=invalid_command`，`hooks_cmd_check=fail(backend:unit-test command not found)`，`hooks_action=patched`
- `Spec 资产状态`：`capability-registry=exists`，`openapi=missing(path_mismatch)`，`action=created`
- `Constitution 状态`：`constitution=missing`，`action=created`（已按提示词补建）
- `Constitution 质量`：`constitution_quality=placeholder`，`action=needs_manual_confirm`
- `覆盖开关状态`：`overwrite=off`，`action_summary=created+patched+skipped`
