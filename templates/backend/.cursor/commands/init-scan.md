# /init-scan（backend）

目标：读取 `_cursor_init/*` 与真实仓库结构，给出“可直接落库”的校准结果。

## 输入
- `_cursor_init/report.md`
- `_cursor_init/proposed_tree.md`
- `_cursor_init/hooks.suggested.json`
- 后端仓库的真实文件结构（构建工具、测试命令、迁移目录、Mapper/Repository 命名）

## 执行步骤
1. 校验仓库类型：Maven/Gradle、MyBatis/JPA、Flyway/Liquibase。
2. 对比 `.cursor/hooks/hooks.json` 与 `_cursor_init/hooks.suggested.json`，输出差异。
3. 校准 `.cursor/hooks/gates/config.sh` 中目录正则（controller/api、migration、mybatis xml）。
4. 检查 `.cursor/rules/*.mdc` 是否与当前仓库分层一致，不一致处给出最小改动。
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
- `Spec 资产状态`：按状态词输出 `capability-registry/openapi`（`exists`/`missing`/`unreadable`/`path_mismatch`）及“待建”项。
- `Constitution 状态`：按状态词输出 `.specify/memory/constitution.md`（`exists`/`missing`/`unreadable`/`path_mismatch`）与处理结果（已补建/待人工处理）。
- `覆盖开关状态`：`overwrite=on/off` 与实际动作（`created`/`skipped`/`overwritten`）。

## 禁止事项
- 不直接改业务代码。
- 不删除已有 `.cursor` 文件；冲突时建议生成 `*.v2`。
