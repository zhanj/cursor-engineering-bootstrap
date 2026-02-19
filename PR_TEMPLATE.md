> 默认 PR 模板（仓库根目录）。
> 与 `.cursor/commands/*` 的输出字段保持一致，可直接粘贴 `/api-search`、`/implement-task`、`/be-debug`、`/fe-debug` 结果。

## 开发路径（必填）
- [ ] 主流程（Spec-kit 驱动：`/speckit.specify -> /speckit.plan -> /speckit.tasks -> /bridge-implement`）
- [ ] 快速路径（小改动：`/api-search -> /implement-task`）

## 1) 复用依据（必填）
- 需求关键词：
- `/api-search` 检索范围（registry/openapi/controller|src/api/calls|pages）：
- 候选能力（>=3，含 endpoint/页面 + 复用理由；若不足 3 个请说明检索范围与结论）：
  - 候选 A：
  - 候选 B：
  - 候选 C：
- 最终选择（1个）与原因（成本/兼容/稳定性）：
- 若未复用现有能力，给出理由：

## 2) 变更范围（必填）
- 业务目标（1-2 句）：
- 代码改动范围（backend: controller/service/dao/dto/migration；frontend: views/components/api/router/store）：
- 是否包含 DB 结构变更：是/否/不适用
- 是否包含跨服务调用改动：是/否/不适用
- 是否新增或调整路由：是/否/不适用
- 是否变更权限守卫：是/否/不适用

## 3) 契约影响（必填）
- 受影响 endpoint/接口（逐条）：
- 契约结论：`有变更` / `无变更`
- 是否更新 `openapi.yaml`：是/否
- 若“无变更”，请说明依据（参数/返回/错误码/鉴权为何不变）：
- 向后兼容性评估（调用方/页面是否需要改动）：

## 4) 验证证据（必填）
- 本地验证命令：
  - ``
  - ``
- 关键结果摘要（通过/失败与原因）：
- 最小回归用例（至少 2 条）：
  - 用例 1：
  - 用例 2：
- 关键截图/录屏说明（如适用）：

## 5) 风险与回滚（必填）
- 主要风险（功能/性能/数据一致性/权限/兼容性）：
- 监控与观察点（日志、指标、告警）：
- 回滚方案（步骤 + 触发条件）：

## 6) 提交前自检（勾选）
- [ ] 已明确开发路径并勾选（主流程 / 快速路径 二选一）
- [ ] 已执行复用检索，且记录候选能力 >= 3
- [ ] 改动范围与任务目标一致，无无关重构
- [ ] 契约结论明确（有变更/无变更）并附依据
- [ ] 若新增/调整接口，已同步 `spec_center/capability-registry.md` 与 `contracts/openapi.yaml`（未接入 Spec Center 则已标注“待建”）
- [ ] 验证命令可复制执行，结果可追溯
- [ ] 风险与回滚方案明确
