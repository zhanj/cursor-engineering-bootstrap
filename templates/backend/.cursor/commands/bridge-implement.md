# /bridge-implement（backend）

目标：把 spec-kit 上层产物（specify/plan/tasks）转换为可执行开发流程，并与现有 `/api-search -> /implement-task -> PR_TEMPLATE -> gates` 对齐。

## 输入（必须）
- spec-kit 产物（至少包含）：需求规格（spec）、技术计划（plan）、任务清单（tasks）。**路径约定**：由 spec-kit 生成时落在 **`specs/<number>-<short-name>/`**（如 `specs/001-heartbeat-version/spec.md`、`plan.md`、`tasks.md`），当前分支建议为同名 feature 分支（如 `001-heartbeat-version`）。
- 目标服务的 `openapi.yaml`（若涉及接口）
- 当前分支上下文（已有改动、风险点）

## 执行步骤（必须按顺序）
1. 先校验输入产物是否齐全（spec/plan/tasks）；若任一缺失，停止执行并输出缺失项清单。
2. 检查 `.specify/memory/constitution.md` 是否存在；若缺失，停止执行并返回 `/init-scan` 阶段先补建 constitution（参考 `docs/speckit-constitution-prompt.md`）。
3. 读取 spec/plan/tasks，提炼：
   - 业务目标与边界
   - API/DB/跨服务影响
   - 验证与回滚要求
   - 若涉及 DAO 开发或数据库连接改动，优先参考工程内 DB schema 文件（如 `schema.sql`、`db/migration/*`、`db/changelog/*`）再落代码。
4. 执行 `/api-search`，产出可直接粘贴 PR `1) 复用依据` 的内容。
5. 执行 `/implement-task`，完成最小闭环代码实现。
6. 若涉及契约变化，更新 `openapi.yaml`（并在输出中写明影响 endpoint）。
7. 若新增/调整接口，同步更新 `spec_center/capability-registry.md`；若仓库未接入 Spec Center，在 PR 中标注“待建”并给出补建计划。
8. 生成 PR 草稿（严格按仓库根 `PR_TEMPLATE.md` 字段逐条填写，不得省略子项）。
9. 执行项目标准校验命令（优先 `make ci`；若项目约定为 `mvn verify` 或其他命令，按项目 README 执行），记录结果并更新到 PR `4) 验证证据`。

## 输出格式（必须）
- `开发路径（必填）`（已勾选 `主流程`）
- `1) 复用依据（必填）`（来自 `/api-search`）
- `2) 变更范围（必填）`
- `3) 契约影响（必填）`
- `4) 验证证据（必填）`
- `5) 风险与回滚（必填）`
- `6) 提交前自检（勾选）`

## 失败处理（必须）
- 若 spec/plan/tasks 任一缺失：停止执行，输出缺失项与补齐建议，不进入实现阶段。
- 若 `.specify/memory/constitution.md` 缺失：停止执行并返回 `/init-scan` 先补建。
- 若标准校验命令失败：先修复问题再更新 PR 草稿，不允许跳过 gates。
- 若契约影响不明确：默认按“有变更”处理并补充 `openapi.yaml` 或给出强依据说明“无变更”。

## 禁止事项
- 跳过 `/api-search` 直接实现。
- 输出与 `PR_TEMPLATE.md` 字段名不一致。
- 在未通过项目标准校验命令的情况下给出“可合并”结论。
