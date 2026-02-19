# cursor-engineering-bootstrap（v2.1.4）

面向存量项目的 Cursor 工程化脚手架。目标是让团队在不大改现有代码结构的前提下，快速建立一致的 AI 开发流程。

## 你将得到什么

- `Spec Center`：统一管理能力索引、OpenAPI 契约、规格文档
- `Backend 模板`：`rules + commands + hooks + PR_TEMPLATE`
- `Frontend 模板`：`rules + commands + hooks + PR_TEMPLATE`
- `init-runner`：通过 `dry-run` 和 `bundle` 生成可审查的落库方案

一句话：先规范“怎么做”，再规范“怎么提交证明做对了”。

---

## 适用场景

- 多服务、前后端分离、存量项目
- 团队希望统一 Cursor 使用方式（不是个人玩法）
- 需要把“复用优先、契约一致、验证可追溯”固化到日常开发

---

## 快速开始（10 分钟）

### 1) 初始化 Spec Center（建议独立仓库）

将 `templates/spec_center` 复制到新仓库（示例：`ehs-service-specs`），按 `templates/spec_center/APPLY.md` 执行。

### 2) 初始化后端仓库

在后端仓库根目录运行：

```bash
bash path/to/cursor-engineering-bootstrap/bin/cursor-init dry-run --mode backend --use-current-dir
bash path/to/cursor-engineering-bootstrap/bin/cursor-init bundle --mode backend --use-current-dir
```

如果你不在目标仓库根目录执行，请显式指定：

```bash
bash path/to/cursor-engineering-bootstrap/bin/cursor-init dry-run --mode backend --target-dir /path/to/target-repo
bash path/to/cursor-engineering-bootstrap/bin/cursor-init bundle --mode backend --target-dir /path/to/target-repo
```

将 `_cursor_init/patch_bundle/backend/` 通过 PR 方式落库。

### 3) 初始化前端仓库

在前端仓库根目录运行：

```bash
bash path/to/cursor-engineering-bootstrap/bin/cursor-init dry-run --mode frontend --use-current-dir
bash path/to/cursor-engineering-bootstrap/bin/cursor-init bundle --mode frontend --use-current-dir
```

如果你不在目标仓库根目录执行，请显式指定：

```bash
bash path/to/cursor-engineering-bootstrap/bin/cursor-init dry-run --mode frontend --target-dir /path/to/target-repo
bash path/to/cursor-engineering-bootstrap/bin/cursor-init bundle --mode frontend --target-dir /path/to/target-repo
```

将 `_cursor_init/patch_bundle/frontend/` 通过 PR 方式落库。

---

## PR 方式落库（一步一步）

“通过 PR 方式落库”指的是：把模板改动当成一次普通代码变更，走分支、评审、合并流程，而不是直接改主分支。

### 标准步骤（backend/frontend 通用）

1. 在目标业务仓创建分支（示例：`chore/cursor-init-bootstrap`）。
2. 运行 `dry-run + bundle`，确认 `_cursor_init/patch_bundle/<mode>/` 已生成。
3. 将 `patch_bundle` 内文件复制到仓库对应位置。
4. 按仓库实际情况校准以下内容：
   - `.cursor/hooks/hooks.json`（构建/校验命令）
   - `.cursor/hooks/gates/config.sh`（目录与命名正则）
   - `PR_TEMPLATE.md`（若团队已有模板，做合并而非覆盖）
5. 本地验证：
   - backend：至少执行测试和 gates
   - frontend：至少执行 lint/tsc 和关键页面自测
6. 提交 commit，发起 PR，说明本次是“Cursor 工程化初始化落库”。
7. 评审通过后再合并到主分支。

### 为什么必须走 PR

- 可审查：规则、命令、门禁都能逐条 review
- 可回滚：发现不适配可整包回退
- 可追溯：知道何时、谁、为何引入这套规范
- 可协同：团队可以在 PR 阶段统一口径，而不是各自改

### 首次落库 PR 描述模板（可直接复制）

```md
## 变更目的
初始化 Cursor 工程化模板，统一团队在存量项目中的 AI 开发流程（复用优先、契约一致、验证可追溯）。

## 落库范围
- 新增/更新 `.cursor/rules`
- 新增/更新 `.cursor/commands`
- 新增/更新 `.cursor/hooks`（含 gates）
- 新增/更新 `.cursorignore`
- 新增/更新 `PR_TEMPLATE.md`

## 校准项
- hooks 命令已按本仓技术栈调整（maven/gradle 或 pnpm/yarn/npm）
- gates/config.sh 已按本仓目录结构校准
- Spec Center 接入方式已确定（submodule/mirror/artifact）

## 验证
- 执行命令：
  - `...`
  - `...`
- 结果：全部通过 / 已说明未通过项与处理计划

## 风险与回滚
- 风险：主要影响开发流程与提交流程，不影响业务运行时逻辑
- 回滚：整包回退本 PR 即可恢复到引入前状态
```

---

## 命令说明（bin/cursor-init）

### 语法

```bash
bash bin/cursor-init dry-run --mode backend|frontend|spec_center --target-dir /path/to/target-repo
bash bin/cursor-init bundle  --mode backend|frontend|spec_center --target-dir /path/to/target-repo
bash bin/cursor-init dry-run --mode backend|frontend|spec_center --use-current-dir
bash bin/cursor-init bundle  --mode backend|frontend|spec_center --use-current-dir
bash bin/cursor-init dry-run --mode backend|frontend|spec_center --target-dir /path/to/target-repo --with-spec-kit --spec-kit-ai cursor-agent
bash bin/cursor-init dry-run --mode backend|frontend|spec_center --target-dir /path/to/target-repo --with-spec-kit --spec-kit-ai cursor-agent --execute-spec-kit --spec-kit-yes
bash bin/cursor-init dry-run --mode backend|frontend|spec_center --target-dir /path/to/target-repo --with-spec-kit --execute-spec-kit --spec-kit-yes --overwrite
bash bin/cursor-init dry-run --mode backend|frontend|spec_center --target-dir /path/to/target-repo --with-spec-kit --spec-kit-ai cursor-agent --execute-spec-kit --spec-kit-dry-run
bash bin/cursor-init bundle --mode backend|frontend|spec_center --target-dir /path/to/target-repo --no-bootstrap-readme
```

spec-kit 集成参数：

- `--target-dir <path>`：指定目标工程根目录（输出固定落在该目录下的 `_cursor_init`）
- `--use-current-dir`：显式指定“当前目录就是目标工程根目录”
- `--with-spec-kit`：启用 spec-kit 环境检查
- `--spec-kit-ai <agent>`：记录并建议后续使用的 AI 参数（默认 `cursor-agent`）
- `--execute-spec-kit`：执行 `specify init . --ai <agent>`（默认关闭）
- `--spec-kit-dry-run`：仅打印将执行的 `specify init` 命令（不执行，需与 `--execute-spec-kit` 同时使用）
- `--spec-kit-yes`：执行前显式确认（真实执行时必填）
- `--overwrite`：允许覆盖已存在的 spec-kit 资产（默认不覆盖）
- `--spec-kit-force`：兼容参数，等价于 `--overwrite`（高风险，需与 `--execute-spec-kit` 同时使用）
- `--no-bootstrap-readme`：不生成 bootstrap README 快照（默认会生成）

说明：

- 阶段 A（低风险）：只使用 `--with-spec-kit`（检查与建议，不执行初始化）
- 阶段 B（可选）：增加 `--execute-spec-kit` 执行初始化
- 安全默认：若检测到 `.cursor`、`.vscode`、`PR_TEMPLATE.md`、`doc/DEV.md`、`spec_center` 已存在：
  - 一律在临时目录执行 spec-kit 初始化，再“仅补齐缺失文件”到目标目录（不覆盖现有文件）
  - 已存在文件保持不变，不会因目录存在而整体跳过
- 执行校验：若 `specify init` 返回成功但未生成 `.specify/`，会标记为失败并提示查看 `specify-init.log`

### `dry-run` 会产出什么

在当前仓库生成 `_cursor_init/`：

- `report.md`：识别结果（构建工具、包管理器、DAO/迁移特征）
- `proposed_tree.md`：建议新增的文件树
- `apply_plan.md`：落库步骤与人工确认项
- `hooks.suggested.json`：自动推断的 hooks 命令建议
- `cursor-bootstrap-readme.md`：bootstrap 说明快照（供 Cursor 检索，默认生成；可用 `--no-bootstrap-readme` 关闭）
- `specify-init.log`：spec-kit 初始化执行日志（仅 `--with-spec-kit` 时生成）

若启用 `--with-spec-kit`，`report.md` 还会包含：

- `spec_kit_requested`：是否启用 spec-kit 检查
- `spec_kit_ai`：建议的 AI 参数
- `spec_kit_status`：检查状态（requested/not_requested）
- `spec_kit_check`：检查结果（ok/degraded/missing_specify）
- `spec_kit_execute_requested`：是否请求执行 spec-kit init
- `spec_kit_dry_run`：是否只做 spec-kit 命令预演
- `spec_kit_yes`：是否提供执行确认开关
- `spec_kit_force`：是否启用 force 模式
- `spec_kit_init`：初始化执行结果（not_requested/skipped/dry_run/ok/ok_non_overwrite_merge/failed/failed_missing_specify_dir/blocked_missing_confirmation）
- `spec_kit_init_cmd`：执行或建议的初始化命令
- `spec_kit_log`：spec-kit 初始化日志路径（排查失败时优先查看）
- `spec_kit_hint`：下一步建议（安装或执行提示）

### 关于 `/init-scan`（常见误解）

- `templates/*/.cursor/commands/init-scan.md` 是 **Cursor 命令模板**，不是 `bin/cursor-init` 自动执行步骤。
- 它需要在 Cursor 中由人/Agent **显式触发**，用于“初始化后校准”：
  - 校准 hooks 命令（maven/gradle、pnpm/yarn/npm）
  - 校准 gates 目录正则
  - 校准 rules/commands 与真实仓库结构的一致性
- 请确认 Cursor 使用的是“项目根目录”的工作区配置，并能读取项目内 `.cursor/`（含 `.cursor/rules/*.mdc`）。
- 若仓库尚无 `capability-registry.md` 或 `<service>/contracts/openapi.yaml`，`/init-scan` 结论中应标注“待建”，先补最小占位文件再执行 `/api-search`。
- 推荐时机：
  1. 执行完 `dry-run + bundle`
  2. 将模板以 PR 落库后
  3. 第一次真实需求开始前

### `bundle` 会产出什么

- `_cursor_init/patch_bundle/<mode>/`：对应模板快照，供 PR 落库使用
- 默认额外包含：`_cursor_init/patch_bundle/<mode>/docs/speckit-constitution-prompt.md`（统一 constitution 提示词）
- 默认额外包含：`_cursor_init/patch_bundle/<mode>/docs/cursor-bootstrap-readme.md`（用于目标仓 Cursor 检索）

其中：

- `patch_bundle`：固定目录名（不会变化）
- `<mode>`：`--mode` 的实际取值，只能是以下三种之一：
  - `backend`
  - `frontend`
  - `spec_center`

对应的真实目录示例：

- `_cursor_init/patch_bundle/backend/`
- `_cursor_init/patch_bundle/frontend/`
- `_cursor_init/patch_bundle/spec_center/`

示例命令与结果：

```bash
bash bin/cursor-init bundle --mode backend --use-current-dir
# => 生成 _cursor_init/patch_bundle/backend/

bash bin/cursor-init bundle --mode frontend --use-current-dir
# => 生成 _cursor_init/patch_bundle/frontend/

bash bin/cursor-init bundle --mode spec_center --use-current-dir
# => 生成 _cursor_init/patch_bundle/spec_center/
```

---

## 推荐落地顺序（团队视角）

1. 先落地 Spec Center（契约与能力索引中心）
2. 再落地 Backend 模板
3. 最后落地 Frontend 模板
4. 统一培训一次“spec-kit 优先 + bridge 执行链路”流程

### 存量项目最短路径（spec-kit 优先）

推荐默认流程（需求开发）：

1. `dry-run -> bundle -> PR 落库`
2. 在项目里执行 `/init-scan` 完成校准
3. 若缺 `.specify/memory/constitution.md`，先执行 `/speckit.constitution`（提示词见 `docs/speckit-constitution-prompt.md`）
4. 执行 `/speckit.specify -> /speckit.plan -> /speckit.tasks`
5. 执行 `/bridge-implement`
6. 执行项目标准校验命令（优先 `make ci`，否则按 README）
7. 按 `PR_TEMPLATE.md` 提交 PR

小改动快速路径（可选）：

- 仅在“需求清晰、低风险、无需完整 spec-kit 拆解”时使用：
  - `/api-search -> /implement-task -> 项目标准校验命令 -> PR_TEMPLATE`

---

## 研发日常怎么用（最关键）

### 开发前

- 默认先走 spec-kit 流程：`/speckit.specify -> /speckit.plan -> /speckit.tasks`
- 确保 `.specify/memory/constitution.md` 已存在（缺失先补建）
- 低风险小改动可走快速路径：先执行 `/api-search`

### 开发中

- spec-kit 优先：用 `/bridge-implement` 对齐到工程执行链路
- 快速路径：用 `/implement-task` 做最小闭环实现
- 遵守 `rules/*.mdc` 的边界约束

### 提交前

- 运行 hooks 对应验证（lint/tsc/test + gates）
- 使用仓库根目录 `PR_TEMPLATE.md` 填写交付证据（字段与 `.cursor/commands/*` 输出一一对应，可直接粘贴）

### PR 填写建议（v2.1.3+ 已对齐）

- spec-kit 优先时：`/bridge-implement` 输出按字段直接填 `PR_TEMPLATE` `1)~6)`
- 快速路径时：`/api-search` 输出贴 `1)`，`/implement-task` 输出贴 `2)~5)`
- `/be-debug` / `/fe-debug` 输出可直接补充 `4)~5)`

### Gate 与 GitHub Actions 的关系（避免混淆）

- `gate`：具体检查规则（例如 contract/db 一致性检查、smoke 测试断言）
- `scripts/smoke/*`：gate 的脚本实现（可手动执行，也可被 CI 调用）
- `GitHub Actions`：自动运行这些 gate 的平台（调度器），不是规则本身

常见执行方式：

- 手动执行 gate：本地运行 `make ci`（或 `make smoke`）
- 快速本地检查：运行 `make ci-quick`（跳过 gates，适合改文档/模板时快速自检）
- 自动执行 gate：在 PR/push 时由 GitHub Actions 运行同一脚本
- 若脚本退出码非 0，workflow 失败；启用分支保护后可阻止合并

### 契约门禁策略与新接口约定（建议默认）

- 契约门禁策略：`CURSOR_CONTRACT_GATE_MODE=warn`（默认告警，便于存量项目渐进接入）。
- 收敛后可加严：将 `CURSOR_CONTRACT_GATE_MODE` 调整为 `block`，在契约未同步时直接阻断合并。
- DB 门禁策略：`CURSOR_DB_GATE_MODE=warn`（默认告警，可按团队阶段改为 `block`）。
- 开发路径门禁（建议先告警）：
  - `CURSOR_DEV_PATH_GATE_MODE=warn`（阶段 1 默认）
  - `CURSOR_DEV_PATH_GATE_STAGE=1`：仅检查 PR 是否勾选且只勾选一个开发路径（主流程 / 快速路径）
  - `CURSOR_DEV_PATH_GATE_STAGE=2`：在阶段 1 基础上，额外校验路径证据（主流程需 spec-kit/bridge 证据；快速路径需 `/api-search` + `/implement-task` 证据）
- 新增或调整接口时，必须同步两处：
  - `spec_center/capability-registry.md`（登记能力条目与同义词）
  - `spec_center/<service>/contracts/openapi.yaml`（更新 endpoint/参数/返回/鉴权/错误码）
- 若仓库暂未接入 Spec Center，PR 必须标注 `Spec 资产待建`，并给出补建计划与时点。

### Smoke tests（已内置）

仓库内置了 3 类 smoke tests + 1 个总入口：

- `scripts/smoke/01-cursor-init-outputs.sh`
  - 断言 `bin/cursor-init` 在 `backend/frontend/spec_center` 三种 mode 下都能产出预期文件
- `scripts/smoke/02-gates-behavior.sh`
  - 在临时 git 仓库模拟典型 diff，断言 contract/db gates 在 `block/warn` 模式下退出码符合预期
- `scripts/smoke/03-template-integrity.sh`
  - 检查关键模板是否存在、PR 字段是否完整、commands 与 PR 模板字段是否对齐
- `scripts/smoke/run-all.sh`
  - 一键运行全部 smoke tests

本地执行：

```bash
make ci
make ci-full
```

或使用 Makefile（推荐）：

```bash
make smoke
make ci-quick
make ci-full
make smoke-init
make smoke-gates
make smoke-templates
```

CI 自动执行：

- `.github/workflows/ci.yml` 会在 `pull_request` 和 `push(main/master)` 时自动运行（执行入口为 `make ci`）。

---

## Spec Center 接入方式（A/B/C）

请在团队内统一选择一种，不要混用：

- A `submodule`（推荐）：版本可追溯、治理最稳
- B `mirror`：CI 定时镜像到业务仓只读目录
- C `artifact`：按版本发布，业务仓按版本拉取

详细决策树见：

- `templates/spec_center/APPLY.md`
- `templates/backend/APPLY.md`
- `templates/frontend/APPLY.md`

---

## Spec 文档边界（自有服务 vs 第三方）

`templates/spec_center/<service>/spec.md` 默认描述的是“你们自有服务能力”（你们负责实现与演进的能力）。

第三方服务也可以纳入治理，但建议按以下方式处理：

- 第三方原始契约放在：`_raw_contracts/external/<vendor>/openapi.yaml`
- 自有服务 spec 仍放在：`<service>/spec.md`
- 在自有服务 spec 中增加“外部依赖”章节，说明：
  - 依赖的第三方 endpoint
  - 鉴权/限流/超时/重试策略
  - 失败降级与回滚策略

这样可以保证职责边界清晰：你们的 spec 是“主”，第三方契约是“依赖输入”。

---

## spec-kit 接入（双层流程）

你可以把 spec-kit 作为上层主流程接入，把本脚手架作为下层执行与治理层保留。

- 上层（面向产品/需求）：`/speckit.constitution -> /speckit.specify -> /speckit.plan -> /speckit.tasks -> /speckit.implement`
- 下层（面向工程落地）：`/api-search -> /implement-task -> PR_TEMPLATE -> gates -> 项目标准校验命令（如 make ci）`

推荐原则：

- 不维护双套交付标准（统一以 `PR_TEMPLATE + make ci` 为准）
- 不绕过 gates（契约/DB 一致性仍强制检查）
- 不重度 fork spec-kit（优先适配层集成）

建议在 spec-kit 初始化后第一步执行 `/speckit.constitution`。  
统一提示词见：`docs/speckit-constitution-prompt.md`（单一维护，避免多处漂移）。

### spec-kit 桥接命令与场景

桥接目标：让研发先按 spec-kit 明确需求与方案，再落回本脚手架的执行与治理链路。

命令分层：

- 上层（spec-kit）：
  - `/speckit.specify`：定义需求（what/why）
  - `/speckit.plan`：形成技术方案（how）
  - `/speckit.tasks`：拆分任务
- 下层（本脚手架）：
  - `/api-search`：先查能力索引，再查契约/代码
  - `/implement-task`：按最小闭环实现
  - `/bridge-implement`：把 spec-kit 产物直接桥接到 `/api-search -> /implement-task -> PR_TEMPLATE -> 项目标准校验命令`

推荐使用场景：

- 使用 spec-kit 上层命令（`/speckit.*`）：
  - 新需求不清晰，需要先做规格澄清
  - 影响面较大，需要正式计划与任务拆分
  - 涉及跨模块协作，需要统一任务语义
- 使用 `/bridge-implement`：
  - 已有 `spec/plan/tasks`，希望一键进入工程执行链路
  - 需要确保输出直接对齐 `PR_TEMPLATE`（1~6 段）
- 仅使用 `/api-search + /implement-task`：
  - 小改动、低风险、需求清晰
  - 不需要完整 spec-kit 规格流程

桥接后的推荐路径：

1. `/speckit.specify` -> `/speckit.plan` -> `/speckit.tasks`
2. `/bridge-implement`
3. 执行项目标准校验命令（优先 `make ci`；若项目约定为 `mvn verify` 或其他命令，按项目 README）
4. 按 `PR_TEMPLATE.md` 提交 PR

映射设计详情见：

- `docs/spec-kit-bridge.md`

参考项目：

- [github/spec-kit](https://github.com/github/spec-kit)

---

## 边界与非目标（v2.1.4）

- 不会自动修改业务代码
- 不会覆盖已有 `.cursor` 资产
- 只生成建议文件与可审查补丁包
- `hooks.suggested.json` 仅给建议，不自动写回
- gates 已加强配置缺失保护与 macOS/Bash 兼容

---

## 目录总览

```text
cursor-engineering-bootstrap/
  bin/
    cursor-init
  templates/
    spec_center/
    backend/
    frontend/
  scanner/
    scan.md
    fingerprints.md
```

说明：

- `scanner/` 当前定位为“扫描设计文档”，用于说明识别方法与指纹依据。
- `scanner/` 文件当前不参与 `bin/cursor-init` 的自动执行逻辑。
- 若后续需要可执行化，可将指纹规则结构化（如 yaml/json）并由脚本直接读取。

---

## 常见问题（FAQ）

### Q1: 为什么要单独建 Spec Center 仓库？

A: 把“契约治理”和“业务实现”解耦，避免每个业务仓各自维护一份不一致的接口事实。

### Q2: 我们仓库已经有 `.cursor`，还能用吗？

A: 可以。建议先 `dry-run` 查看 `proposed_tree`，冲突文件通过 PR 人工合并，不直接覆盖。

### Q3: 为什么 PR 模板这么严格？

A: 目的是把“做了什么”升级为“为什么这样做 + 如何验证 + 如何回滚”的工程证据，便于协作与审计。

### Q4: 命令执行提示缺少 `rg` 怎么办？

A: 安装 ripgrep 后重试。`cursor-init` 依赖 `rg` 保证扫描性能与一致性。

### Q5: `.cursor/rules/*.mdc` 没生效怎么办？

A: 先确认 Cursor 当前打开的是“目标仓库根目录”而非上级目录，并确保项目根目录的 `.cursor/` 已落库。若规则仍未生效，先用 `/init-scan` 输出“规则加载与目录映射检查”结果再排查。

---

## 后续规划（v3）

- `init --apply`：让 Agent 直接生成落库 PR（可回滚）
- `init --calibrate`：基于真实项目样例自动校准 DAO 生成与 gate 阈值
