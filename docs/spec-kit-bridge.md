# spec-kit 集成映射（v1）

本文档定义：如何把 spec-kit 作为上层流程接入当前脚手架，并保持现有工程治理能力不变。

参考：`https://github.com/github/spec-kit`

## 目标

- 主流程上提：采用 spec-kit 的规格驱动阶段（更面向产品/需求）
- 执行层下沉：复用现有 commands + PR_TEMPLATE + gates（更面向工程落地）
- 避免双规范：只保留一套交付口径（PR_TEMPLATE + gates）

## 双层架构

- 上层（Spec-Driven）：`/speckit.constitution -> /speckit.specify -> /speckit.plan -> /speckit.tasks -> /speckit.implement`
- 下层（Engineering Guardrails）：`/api-search -> /implement-task -> PR_TEMPLATE -> gates -> 项目标准校验命令（优先 make ci，按项目 README）`

## 映射总表

| spec-kit 阶段 | 你们体系落点 | 必须产物 | 必过检查 |
|---|---|---|---|
| `/speckit.constitution` | `.cursor/rules/*.mdc` + 团队规范 | 项目原则（复用/契约/验证） | 项目快速校验命令（如 `make ci-quick`） |
| `/speckit.specify` | `templates/spec_center/<service>/spec.md` | Why/What/DoD/边界 | 规格字段完整性 |
| `/speckit.plan` | `contracts/openapi.yaml` + DB 迁移计划 | 技术方案与影响结论 | 契约一致性预检 |
| `/speckit.tasks` | 任务映射到 commands | 可执行任务清单 | 任务-PR映射检查 |
| `/speckit.implement` | 代码实现 + PR证据 | 代码与PR草稿 | 项目标准校验命令（优先 `make ci`） |

## 字段映射规则（强约束）

### 1) specify/plan -> PR_TEMPLATE

- 业务目标与范围 -> `2) 变更范围（必填）`
- 契约/API影响 -> `3) 契约影响（必填）`
- 验证计划 -> `4) 验证证据（必填）`
- 风险与回滚 -> `5) 风险与回滚（必填）`

### 2) tasks -> commands

- 复用评估任务 -> `/api-search`
- 实现任务 -> `/implement-task`
- 故障修复任务 -> `/be-debug` / `/fe-debug`

### 3) 合并前统一收口

- PR 内容必须按 `PR_TEMPLATE.md` 六段填写
- 合并门槛统一为“项目标准校验命令”（优先 `make ci`；若项目约定为 `mvn verify` 或其他命令，按项目 README）

## specify/plan -> PR_TEMPLATE 2~5（详细映射）

本节用于回答：spec-kit 的高层输出，如何落成你们现有 PR 模板的可审计字段。

### 2) 变更范围（必填）

来源：
- `specify`：业务目标、边界、非目标
- `plan`：技术改动范围（模块/目录/层次）

填写建议：
- `业务目标（1-2 句）`：从 `specify` 的目标原文提炼
- `代码改动范围`：从 `plan` 的模块拆分映射（后端：controller/service/dao/dto/migration；前端：views/components/api/router/store）
- `是否包含 DB 结构变更` / `是否新增或调整路由`：来自 `plan` 的影响结论
- `是否包含跨服务调用改动` / `是否变更权限守卫`：来自 `plan` 的集成或权限设计

触发时机：
- `plan` 完成后先填初稿，实现结束后再校正一次。

### 3) 契约影响（必填）

来源：
- `specify`：是否涉及接口行为变化
- `plan`：API 设计差异（endpoint/参数/返回/错误码/鉴权）

填写建议：
- `受影响 endpoint（逐条）`：来自 `plan` 的接口变更清单
- `契约结论：有变更/无变更`：必须二选一
- `是否更新 openapi.yaml`：与结论一致
- 若“无变更”：写清参数/返回/错误码/鉴权为何不变
- `兼容性评估`：调用方是否需改造

触发时机：
- `plan` 阶段可填写，合并前需与代码实际一致。

### 4) 验证证据（必填）

来源：
- `plan`：测试与验收策略
- 实施阶段：真实执行命令与结果

填写建议：
- `本地验证命令`：可复制执行（不要写“已验证”）
- `关键结果摘要`：通过/失败 + 原因
- `最小回归用例（>=2）`：覆盖成功与异常路径

触发时机：
- `plan` 后填“计划命令”，实现后替换为“实际结果”。

### 5) 风险与回滚（必填）

来源：
- `plan`：风险清单、降级方案、回滚路径
- 实施阶段：最终实现后的风险更新

填写建议：
- `主要风险`：功能/性能/一致性/权限
- `监控与观察点`：日志、指标、告警
- `回滚方案`：步骤 + 触发条件（不是“必要时回滚”）

触发时机：
- `plan` 后有初稿，合并前按最终实现刷新。

## 后端示例（简化）

需求（specify）：
- 新增“隐患列表导出”能力，复用现有筛选条件，不影响现有查询接口。

方案（plan）：
- 新增 `POST /api/hazards/export`
- 复用 existing search service
- 不改 DB

对应 PR 2~5 可写为：
- `2) 变更范围`：controller/service/openapi；DB 变更=否；跨服务=否
- `3) 契约影响`：新增 endpoint，openapi=是，兼容性=现有查询接口不变
- `4) 验证证据`：`mvn -q test`；用例=导出成功、空结果导出
- `5) 风险与回滚`：风险=导出耗时；观察点=接口耗时/失败率；回滚=回退该 PR

## 开发者执行路径（建议）

1. `/speckit.specify` 生成需求规格（what/why）
2. `/speckit.plan` 生成技术方案（包含契约/DB影响）
3. `/speckit.tasks` 拆分执行任务
4. 任务执行时调用 `/api-search` 和 `/implement-task`
5. 填写 `PR_TEMPLATE.md`
6. 运行项目标准校验命令（优先 `make ci`；若项目约定为 `mvn verify` 或其他命令，按项目 README），通过后再合并

## 实施边界（v1）

- 不 fork spec-kit 内核，不维护双套模板
- 不绕过现有 gates
- 不改变现有项目标准校验入口（默认 `make ci`）

## 试点建议

- 先选 1 个后端需求 + 1 个前端需求
- 评估 4 个指标：
  - PR 首轮通过率
  - 返工率
  - 门禁误报率
  - PR 字段完整率

## 升级条件（进入 v2）

若试点证明收益明确，再考虑：
- 增加桥接脚本（自动将 spec-kit 输出填充到 PR 模板草稿）
- 增加 smoke 检查（spec-kit 输出字段与 PR 模板对齐）
