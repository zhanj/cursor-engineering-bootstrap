# Frontend Cursor 工程包落库指南（生产版）

复制到仓库根目录：
- .cursor/
- .cursorignore
- PR_TEMPLATE.md（可选）
- 参考 `_cursor_init/hooks.suggested.json` 校准 `.cursor/hooks/hooks.json`

校准：
- hooks.json 的 pnpm/yarn/npm 命令
- Spec Center 获取方式（submodule/镜像/只读拉取）

Spec Center 接入建议（至少选一种并写入团队规范）：
- `submodule`：在仓库根目录挂载 `spec_center/`（推荐）
- `mirror`：通过 CI 同步到 `docs/spec_center/`（只读）
- `artifact`：在构建时拉取并放到固定只读目录

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

建议提交流程（v2.1.3）：
1. 先跑 `/api-search`，输出直接粘贴到 PR 的 `1) 复用依据`
2. 再跑 `/implement-task`，输出直接粘贴到 PR 的 `2)~5)`
3. 若走 debug 修复，补充 `/fe-debug` 输出到 PR 的 `4)~5)`
