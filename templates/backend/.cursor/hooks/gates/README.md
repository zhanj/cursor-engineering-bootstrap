# Gates（阻断/告警门禁）

- `contract-check.sh`：契约一致性门禁（默认告警）
  - API 相关代码变更但未更新 openapi.yaml → 告警/可阻断
  - 新增/调整接口时，需同步 `spec_center/capability-registry.md`
  - 升级：CURSOR_CONTRACT_GATE_MODE=block

- `db-change-check.sh`：DB 一致性门禁（默认告警）
  - 迁移变更但未同步持久层 → 告警/可阻断
  - 持久层变更但未见迁移证据 → 告警/可阻断
  - 升级：CURSOR_DB_GATE_MODE=block

- `pr-dev-path-check.sh`：PR 开发路径门禁（默认告警，建议在 CI 调用）
  - 阶段 1（默认）：检查 PR 是否“二选一”勾选 `主流程 / 快速路径`
  - 阶段 2（预留）：在阶段 1 基础上校验对应证据（主流程需要 spec-kit/bridge 证据；快速路径需要 `/api-search` + `/implement-task` 证据）
  - 升级方式：
    - `CURSOR_DEV_PATH_GATE_MODE=block`
    - `CURSOR_DEV_PATH_GATE_STAGE=2`

> 脚本基于 git staged diff，不同项目目录/命名请按需调整正则。

CI 示例（读取 PR body 文件）：

```bash
bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-body.md
```

## v2.2 更新
- 新增 `config.sh`：把可调参数集中到一个地方（团队只改一处）
- contract gate：支持“目录白名单”触发，减少误报
- db gate：支持 Flyway/Liquibase 真实目录 + MyBatis XML 落点识别

## v2.3 更新
- db gate：当迁移文件变更时，尝试从 SQL/changeset 中提取“疑似受影响表/字段”提示，便于 Cursor 生成/更新 DAO 更精准。

## v2.4 更新
- db gate：在输出“表/字段提示”基础上，进一步尝试给出仓库内的候选文件路径（Entity/Mapper/MyBatis XML），辅助 Cursor 精准落点。
- 可通过 CURSOR_DB_GATE_SUGGEST_FILES=0 关闭；并可调 FIND_MAXDEPTH / MAX_TABLES_HINT 控制耗时。
