# 脚手架重测培训手册（精简版）

日常上手请优先看 `README.quickstart.md`。  
本文用于培训/复测场景，保留“完整演练 + 验收口径”。

---

## 1) 固定路径与前提

- 脚手架仓：`/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap`
- 后端目标仓：`/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/ehs-clnt-hazard-parent-runenv`
- 前端目标仓：`/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/forest-fire-monitor-web`
- 依赖：`bash`、`rg`、`rsync`、`git`、`specify`

安装 `specify`（缺失时）：

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

---

## 2) 零基础一键安装（无 spec-kit / spec_center）

后端：

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

前端：

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

最小验收：

```bash
ls -la "/path/to/repo/.specify" "/path/to/repo/specs" "/path/to/repo/spec_center"
rg -n "spec-kit|ERROR|missing|failed" "/path/to/repo/_cursor_init/specify-init.log"
```

---

## 3) 终端重测流程（Backend/Frontend 同模板）

把下面变量替换为目标仓路径执行即可。

```bash
BOOTSTRAP_REPO="/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap"
TARGET_REPO="/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/ehs-clnt-hazard-parent-runenv"  # 或前端仓
```

### Step A: 进入目标仓并建分支

```bash
cd "${TARGET_REPO}"
git checkout -b chore/retest-latest-bootstrap-20260220
```

### Step B: （可选）清理旧生成物

```bash
bash "${BOOTSTRAP_REPO}/bin/cursor-cleanup" \
  --target-dir "${TARGET_REPO}" \
  --include-spec-center-placeholders \
  --include-cursor-scaffold

bash "${BOOTSTRAP_REPO}/bin/cursor-cleanup" \
  --target-dir "${TARGET_REPO}" \
  --include-spec-center-placeholders \
  --include-cursor-scaffold \
  --apply
```

### Step C: 一键编排

```bash
bash "${BOOTSTRAP_REPO}/bin/cursor-bootstrap" \
  --target-dir "${TARGET_REPO}" \
  --mode backend \
  --apply-to-root-cursor \
  --apply-mode merge \
  --with-spec-kit \
  --execute-spec-kit \
  --spec-kit-yes \
  --enrich-spec-center
```

前端仓把 `--mode backend` 改为 `--mode frontend`。

### Step D: 二次调优

```bash
cd "${TARGET_REPO}"
bash bin/cursor-tune --dry-run
bash bin/cursor-tune --mode aggressive
```

### Step E: 固定验收（必跑）

```bash
git status --short
rg -n "managed-by: cursor-tune begin:scan-derived" ".cursor"
rg -n "x-capability-links|operationId|source=" "spec_center"
ls -la "bin/cursor-tune" "bin/cursor-bootstrap" "bin/cursor-cleanup"
```

---

## 4) Cursor 命令版（培训讲解顺序）

在目标仓打开 Cursor 后按顺序执行：

1. 输入：`按工程再优化一遍脚手架`
2. `/init-scan`
3. `/tune-project`（先 dry-run，再 apply）
4. `/check-scaffold`（建议放在 `/tune-project` 后）
5. `/speckit.constitution`（仅在缺失/质量不足时）
6. `/bridge-implement`（开发落地）

---

## 5) 5 分钟讲解提纲

- 为什么做：统一工程口径，减少“看起来成功”的假阳性。
- 怎么做：`cleanup -> bootstrap -> tune -> 固定验收`。
- 怎么判定成功：
  - `.cursor` 有 `managed-by: cursor-tune` 受管块
  - `spec_center` 有 `x-capability-links|operationId|source`
  - 目标仓 `bin/` 有三个 wrapper（`cursor-tune|cursor-bootstrap|cursor-cleanup`）

---

## 6) 现场 FAQ

- Q: 为什么要先 `--dry-run`？  
  A: 先看变更面，避免误改。
- Q: 为什么要固定验收命令？  
  A: 防止“日志成功但文件没落盘”。
- Q: Cursor 命令和终端命令关系？  
  A: Cursor 是体验层，底层仍是脚本，结果应一致。
