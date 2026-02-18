# Spec Center 落库指南（v2.1.4）

建议：Spec Center 独立仓库（如 `ehs-service-specs`），并开启受保护分支（PR + 门禁）。

## 目录职责
- `_raw_contracts/**`：Apifox 导出的原始契约（禁止手改）
- `<service>/contracts/openapi.yaml`：治理后的标准契约（可 review）
- `capability-registry.md`：能力索引（给 `/api-search` 使用）
- `<service>/spec.md`：需求规格（Why/What/DoD/边界，默认描述“自有服务能力”）

第三方服务契约建议：
- 第三方 OpenAPI 建议放到 `_raw_contracts/external/<vendor>/openapi.yaml`
- 不建议把第三方服务作为 `<service>/spec.md` 主体
- 你们自有服务 `spec.md` 中应增加“外部依赖”章节，说明第三方调用边界与风险

能力索引分类建议（写入 capability-registry）：
- `internal-self`：本工程自有能力（优先复用）
- `internal-other`：公司内其他工程能力（次优先）
- `external-vendor`：公司外部能力（最后考虑）

## 建议落库流程（必须）
1. 从 Apifox 导出各服务 OpenAPI 到 `_raw_contracts/<service>/openapi.yaml`。
2. 按 `_raw_contracts/normalize.md` 规则治理并同步到 `<service>/contracts/openapi.yaml`。
3. 在 `capability-registry.md` 增加/更新能力条目和同义词。
4. 复制 `spec-template.md` 到对应 `<service>/spec.md`，并补齐关键章节（Why/What/Rules/DoD/风险回滚）。
5. 发起 PR：说明契约变化、影响服务、兼容性与验证方式。
6. 若本次排查使用了 `_raw_contracts/**`，需按 `README.md` 的“_raw_contracts 使用边界”完成回写。

## 与 FE/BE 仓库的接入关系（必须明确一种）
- 方案 A：git submodule 引入 Spec Center（推荐）
- 方案 B：CI 定时镜像到业务仓只读目录
- 方案 C：发布制品（artifact）供业务仓拉取

接入方案决策树（默认 A）：
1. 团队能接受 git submodule 吗？
   - 能：选 A `submodule`（默认）
   - 不能：看第 2 步
2. 团队是否已有稳定 CI 同步能力？
   - 有：选 B `mirror`
   - 没有：看第 3 步
3. 团队是否已有制品仓库与版本发布流程？
   - 有：选 C `artifact`
   - 没有：先落地 B（后续再演进 C）

选型落地约束（必须）：
- 统一目录名（建议 `spec_center/` 或 `docs/spec_center/`）
- 统一只读规则（业务仓不手改同步内容）
- PR 必须注明所用 Spec Center 版本/快照

## 提交检查清单
- [ ] raw 契约未被手工修改
- [ ] contracts/openapi.yaml 与 raw 差异有治理依据
- [ ] capability-registry 与契约同步更新
- [ ] PR 描述包含兼容性与回滚说明

你们服务域（初始化参考）：
- bw_sys_fcm / bw_sys_operation / bw_sys_supervise / bw_sys_event_dispose
- bw_sys_monitor / bw_sys_event-hazard / bw-sys-sphw
