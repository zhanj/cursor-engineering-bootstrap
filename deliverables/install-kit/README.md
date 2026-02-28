# cursor-engineering-bootstrap

面向存量项目的 Cursor 工程化脚手架：统一规则、命令、门禁与证据输出，让团队可复制地使用 AI 开发流程。

快速上手请先看：`README.quickstart.md`

## 一句话版本（先看这个）

- 安装命令入口（`cursor-bootstrap` / `cursor-tune` / `cursor-cleanup`）
- 在目标仓落地 `.cursor` 与 `spec_center`（默认补缺不覆盖）
- 用 `/init-scan`、`/tune-project`、`/check-scaffold` 做持续校准
- 通过 GitHub Releases 分发安装包，保证全员版本一致

---

## 运行环境

- 推荐：`macOS`、`Linux`、`Windows + WSL2`
- 依赖：`bash`、`rg`（ripgrep）、`rsync`、`git`
- Windows 建议统一在 WSL2 执行脚本，不建议直接在 CMD 跑 `bin/*`

---

## 快速开始（5~10 分钟）

### 1) 安装命令入口

仓库内安装（适合维护者）：

```bash
bash install/install.sh --repo "$(pwd)"
cursor-tools --version
cursor-tools self-check
```

从发布包安装（适合研发同学）：

```bash
bash install/install.sh --package-url "https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/bootstrap-package.tgz"
```

默认安装路径：安装根目录为 `~/.cursor-bootstrap/<version>/`，当前版本链接为 `~/.cursor-bootstrap/current`，命令入口在 `~/.local/bin`。

自定义安装目录（可选）：

```bash
bash install/install.sh \
  --package-url "https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/bootstrap-package.tgz" \
  --install-root "/custom/path/.cursor-bootstrap" \
  --bin-dir "/custom/path/bin"
```

### 2) 初始化目标仓（推荐一键）

后端示例：

```bash
bash "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap/bin/cursor-bootstrap" \
  --target-dir "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/ehs-clnt-hazard-parent-runenv" \
  --mode backend \
  --apply-to-root-cursor \
  --apply-mode merge \
  --with-spec-kit \
  --execute-spec-kit \
  --spec-kit-yes \
  --enrich-spec-center
```

前端示例：

```bash
bash "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap/bin/cursor-bootstrap" \
  --target-dir "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/forest-fire-monitor-web" \
  --mode frontend \
  --apply-to-root-cursor \
  --apply-mode merge \
  --with-spec-kit \
  --execute-spec-kit \
  --spec-kit-yes \
  --enrich-spec-center
```

### 3) 二次调优（建议）

```bash
cd /path/to/target-repo
bin/cursor-tune --dry-run
bin/cursor-tune --mode aggressive
```

### 4) Cursor Chat 推荐顺序

1. 输入：`按工程再优化一遍脚手架`
2. `/init-scan`
3. `/tune-project`
4. `/check-scaffold`
5. `/speckit.constitution`（仅在缺失/质量不足时）
6. `/bridge-implement`（进入开发落地）

---

## 安装后本地产物

- 安装根目录：`~/.cursor-bootstrap/<version>/`
- 当前版本软链：`~/.cursor-bootstrap/current`
- 命令 shim 目录：`~/.local/bin`
  - `cursor-init`
  - `cursor-bootstrap`
  - `cursor-tune`
  - `cursor-cleanup`
  - `cursor-tools`

卸载：

```bash
bash install/uninstall.sh --remove-all
```

---

## 发布安装包（GitHub Releases）

### 两步法

```bash
# 1) 打包
bash scripts/release/package.sh --output-dir /tmp/cursor-bootstrap-pkg --version vX.Y.Z

# 2) 发布
bash scripts/release/publish.sh --tag vX.Y.Z --archive /tmp/cursor-bootstrap-pkg/bootstrap-package.tgz --repo <owner>/<repo>
```

### 一步法（推荐）

```bash
bash scripts/release/cut-release.sh --tag vX.Y.Z --repo <owner>/<repo>
```

只做本地演练（不发布）：

```bash
bash scripts/release/cut-release.sh --tag vX.Y.Z --skip-publish
```

发布后安装 URL 固定为：

`https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/bootstrap-package.tgz`

---

## 命令速查

`cursor-init`（产出审查材料）：

```bash
cursor-init dry-run --mode backend --target-dir /path/to/repo
cursor-init bundle  --mode backend --target-dir /path/to/repo
```

`cursor-bootstrap`（一键落地）：

```bash
cursor-bootstrap --target-dir /path/to/repo --mode backend --apply-to-root-cursor --apply-mode merge --with-spec-kit --execute-spec-kit --spec-kit-yes --enrich-spec-center
```

`cursor-tune`（按工程再优化）：

```bash
bin/cursor-tune --dry-run
bin/cursor-tune --mode safe
bin/cursor-tune --mode aggressive
```

`cursor-cleanup`（清理生成物）：

```bash
cursor-cleanup --target-dir /path/to/repo --include-spec-center-placeholders --include-cursor-scaffold
cursor-cleanup --target-dir /path/to/repo --include-spec-center-placeholders --include-cursor-scaffold --apply
```

---

## 研发日常建议

- 开发前：先跑 `/init-scan`，确认规则与契约路径
- 开发中：优先 `/api-search`，再 `/implement-task` 或 `/bridge-implement`
- 提交前：补齐 `PR_TEMPLATE.md`，确保 gate 所需证据完整
- 存量仓首次接入：默认 `merge`，尽量不覆盖已有 `.cursor` 资产

---

## 文档导航（详细版）

- 快速重测与培训：`docs/training-retest-quickstart.md`
- 讲师口播稿：`docs/training-retest-speaker-notes.md`
- `spec-kit` 流程产物：
  - `specs/001-installer-packaging/spec.md`
  - `specs/001-installer-packaging/plan.md`
  - `specs/001-installer-packaging/tasks.md`

---

## FAQ（精简）

### Q1: 为什么要走 PR 落库？

A：可审查、可回滚、可追溯，能避免“每人一套规则”的漂移。

### Q2: 目标仓已经有 `.cursor`，还能用吗？

A：可以。先 `dry-run`，再用 `merge` 策略补缺，不建议直接覆盖。

### Q3: 为什么安装 URL 里有 `releases/download`？

A：这是 GitHub Releases 附件下载的固定路径格式，不是脚本自定义。

### Q4: Windows 可以直接用吗？

A：可以，推荐 WSL2。PowerShell 负责启动，脚本在 WSL 内执行最稳定。

