# /api-search（backend）

目标：为当前需求找到“优先复用”的后端能力，避免重复造轮子。

## 检索顺序（必须）
1. `capability-registry.md`：按能力关键词与同义词检索，并按 `OwnerType` 优先级选择候选：`internal-self` -> `internal-other` -> `external-vendor`。
2. `contracts/openapi.yaml`：确认 endpoint、参数、返回、错误码、鉴权（以治理契约为准）。
3. 仓库内 `controller/service`：确认真实行为是否与契约一致。
4. `_raw_contracts/**`：仅在信息冲突、字段溯源、治理契约缺失时作为兜底检索。
5. 调用方与历史 PR：确认复用成本和兼容性。

## 输出格式（必须）
- 按 `PR_TEMPLATE.md` 的 **1) 复用依据（必填）** 原样输出以下字段：
  - `需求关键词`
  - `/api-search` 检索范围（registry/openapi/controller/calls）
  - `候选能力（>=3，含 endpoint + 复用理由）`
  - `最终选择（1个）与原因（成本/兼容/稳定性）`
  - `若不复用既有能力，给出理由`

## 复制规则（必须）
- 输出时直接使用 PR 模板字段名，不要改写标题。
- 结果应可直接复制到 PR 的 **1) 复用依据（必填）**。

## 禁止事项
- 不看 capability-registry 就直接新增接口。
- 跳过 `contracts/openapi.yaml` 直接依据 `_raw_contracts` 或代码做实现决策。
- 只看 controller 不核对 openapi 契约。
