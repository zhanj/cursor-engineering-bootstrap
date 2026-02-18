# /api-search（frontend）

目标：在前端侧优先复用已有 API 能力与调用封装。

## 检索顺序（必须）
1. `capability-registry.md`：按能力和同义词检索，并按 `OwnerType` 优先级选择候选：`internal-self` -> `internal-other` -> `external-vendor`。
2. `contracts/openapi.yaml`：核对参数、返回、分页、鉴权（以治理契约为准）。
3. `src/api` 与业务页：确认现有 client 与调用方式。
4. `_raw_contracts/**`：仅在信息冲突、字段溯源、治理契约缺失时作为兜底检索。
5. 历史页面：评估复用成本与兼容性。

## 输出格式（必须）
- 按 `PR_TEMPLATE.md` 的 **1) 复用依据（必填）** 原样输出以下字段：
  - `需求关键词`
  - `/api-search` 检索范围（registry/openapi/src/api/pages）
  - `候选能力（>=3，含接口/页面复用理由）`
  - `最终选择（1个）与原因`
  - `若未复用现有能力，给出理由`

## 复制规则（必须）
- 输出时直接使用 PR 模板字段名，不改写标题。
- 结果应可直接复制到 PR 的 **1) 复用依据（必填）**。

## 禁止事项
- 新增接口调用前不做复用检索。
- 跳过 `contracts/openapi.yaml` 直接依据 `_raw_contracts` 或页面现状做实现决策。
- 页面直接散落 fetch/axios，而不走统一 API 封装。
