# Capability Registry（能力索引｜给 /api-search 用）

## OwnerType 定义（必须）
- `internal-self`：本工程自有服务能力（优先复用）
- `internal-other`：公司内其他工程服务能力（次优先）
- `external-vendor`：公司外部第三方厂商能力（最后考虑）

## /api-search 推荐检索顺序（必须）
1. `capability-registry.md`（先按 `OwnerType` 优先级检索）
2. `<service>/contracts/openapi.yaml`（治理契约）
3. 代码实现（controller/service 或 src/api/pages）
4. `_raw_contracts/**`（仅用于溯源、冲突排查、补充信息）

同义词示例：
- 隐患 = hazard, risk, defect
- 检查 = inspection, check, audit

能力表（示例，建议按服务补齐）：
| Capability | OwnerType | OwnerService | OwnerTeam | Endpoint | SLA/Tier | Notes | Synonyms |
|---|---|---|---|---|---|---|---|
| 获取安全检查列表（分页） | internal-self | inspection | ehs-platform | GET /api/inspections | core | pageNo/pageSize | 检查列表, inspection list |
| 获取隐患基础信息（共享） | internal-other | risk-center | ehs-shared | GET /api/risk/hazards | shared | 公司内共享能力，依赖变更需同步评估 | 隐患查询, risk hazard |
| OCR 证照识别 | external-vendor | vendor-ocr | n/a | POST /v1/ocr/license | external | 受限流和配额影响，需降级策略 | 识别, 证照OCR |
