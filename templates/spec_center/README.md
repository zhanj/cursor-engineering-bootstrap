# Spec Center（契约与能力索引中台）

> 建议作为**独立仓库**：`ehs-service-specs/`

## 目录结构
- capability-registry.md：能力索引（/api-search 入口）
- _raw_contracts/**：Apifox 导出（禁止手改）
- <service>/spec.md：规格（why/what/DoD/边界）
- <service>/contracts/openapi.yaml：治理后的契约（用于门禁与生成）
- spec-template.md：标准 spec 模板（建议新服务从此复制）

## 最小流程
1) Apifox 导出 openapi → _raw_contracts
2) 归一化 → contracts/openapi.yaml
3) 复制 `spec-template.md` 到 `<service>/spec.md` 并补齐
4) 更新 capability-registry

## 检索与优先级约定
- `/api-search` 先检索 `capability-registry.md`，按 `OwnerType` 优先级：
  - `internal-self` -> `internal-other` -> `external-vendor`
- 其次检索治理契约：`<service>/contracts/openapi.yaml`
- 代码实现用于行为确认，不作为第一事实源
- `_raw_contracts/**` 仅用于溯源、冲突排查和缺失补充

## _raw_contracts 使用边界（必须）

### 触发条件（满足其一再使用）
- `contracts/openapi.yaml` 与代码行为不一致，需要溯源。
- `contracts/openapi.yaml` 信息缺失（字段说明/错误码/枚举缺失）。
- 需要确认某字段是上游源头变化还是治理契约变更导致。

### 排查步骤（固定顺序）
1. 先以 `contracts/openapi.yaml` 为主事实源进行判断。
2. 再查 `_raw_contracts/<service>/openapi.yaml` 做来源对比。
3. 若仍有争议，再回到实现代码做行为确认。

### 回写要求（必须）
- 使用 `_raw_contracts` 得到的结论，必须回写到：
  - `contracts/openapi.yaml`（若需修正治理契约）
  - `<service>/spec.md`（若需补充边界说明）
  - PR 描述中的契约影响结论（有变更/无变更依据）
