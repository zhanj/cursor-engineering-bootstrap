# /bridge-implement（backend）

目标：把 spec-kit 上层产物（specify/plan/tasks）转换为可执行开发流程，并与现有 `/api-search -> /implement-task -> PR_TEMPLATE -> gates` 对齐。

## 输入（必须）
- spec-kit 产物（至少包含）：
  - 需求规格（spec）
  - 技术计划（plan）
  - 任务清单（tasks）
- 目标服务的 `openapi.yaml`（若涉及接口）
- 当前分支上下文（已有改动、风险点）

## 执行步骤（必须按顺序）
1. 先校验输入产物是否齐全（spec/plan/tasks）；若任一缺失，停止执行并输出缺失项清单。
2. 读取 spec/plan/tasks，提炼：
   - 业务目标与边界
   - API/DB/跨服务影响
   - 验证与回滚要求
3. 执行 `/api-search`，产出可直接粘贴 PR `1) 复用依据` 的内容。
4. 执行 `/implement-task`，完成最小闭环代码实现。
5. 若涉及契约变化，更新 `openapi.yaml`（并在输出中写明影响 endpoint）。
6. 若新增/调整接口，同步更新 `spec_center/capability-registry.md`；若仓库未接入 Spec Center，在 PR 中标注“待建”并给出补建计划。
7. 生成 PR 草稿（严格按仓库根 `PR_TEMPLATE.md` 字段逐条填写，不得省略子项）。
8. 执行项目标准校验命令（优先 `make ci`；若项目约定为 `mvn verify` 或其他命令，按项目 README 执行），记录结果并更新到 PR `4) 验证证据`。

## 输出格式（必须）
- `1) 复用依据（必填）`（来自 `/api-search`）
- `2) 变更范围（必填）`
- `3) 契约影响（必填）`
- `4) 验证证据（必填）`
- `5) 风险与回滚（必填）`
- `6) 提交前自检（勾选）`

## 失败处理（必须）
- 若 spec/plan/tasks 任一缺失：停止执行，输出缺失项与补齐建议，不进入实现阶段。
- 若标准校验命令失败：先修复问题再更新 PR 草稿，不允许跳过 gates。
- 若契约影响不明确：默认按“有变更”处理并补充 `openapi.yaml` 或给出强依据说明“无变更”。

## 禁止事项
- 跳过 `/api-search` 直接实现。
- 输出与 `PR_TEMPLATE.md` 字段名不一致。
- 在未通过项目标准校验命令的情况下给出“可合并”结论。
