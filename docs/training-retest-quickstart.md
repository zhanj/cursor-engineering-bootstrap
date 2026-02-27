# 脚手架重测培训手册（终端 + Cursor 命令）

目标：用于研发培训时“一次讲清 + 现场照跑”，帮助团队快速完成脚手架重测与验收。

适用对象：已经有目标仓库、希望用最新 `cursor-engineering-bootstrap` 进行一次标准化重测的同学。

---

## 一、培训前准备

- 脚手架仓库路径：`/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap`
- 后端目标仓路径（示例）：`/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/ehs-clnt-hazard-parent-runenv`
- 前端目标仓路径（示例）：`/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/forest-fire-monitor-web`
- 建议先确认：
  - 目标仓当前分支干净（或明确哪些改动是可保留的）
  - 已安装 `bash`、`rg`、`rsync`

---

## 二、零基础安装（目标仓无 spec_center / spec-kit）

适用前提：目标仓里还没有 `.specify/`、`specs/`、`spec_center/` 等资产。

### 1) 先确认 spec-kit CLI（specify）可用

```bash
specify --version
```

若提示 command not found，可先安装：

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

### 2) backend 目标仓一键安装

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

### 3) frontend 目标仓一键安装

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

### 4) 安装后最小验收（backend/frontend 通用）

```bash
ls -la "/path/to/your-repo/.specify"
ls -la "/path/to/your-repo/specs"
ls -la "/path/to/your-repo/spec_center"
rg -n "spec-kit|ERROR|missing|failed|direct init|temp bootstrap" "/path/to/your-repo/_cursor_init/specify-init.log"
```

---

## 三、终端命令版（完整重测流程）

### A. 后端目标仓（backend）

### 0) 更新脚手架

```bash
cd "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap"
git pull
clear
```

### 1) 进入目标仓并创建测试分支

```bash
cd "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/ehs-clnt-hazard-parent-runenv"
git checkout -b chore/retest-latest-bootstrap-20260220
clear
```

### 2) （可选）清理旧生成物（先 dry-run，再 apply）

```bash
bash "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap/bin/cursor-cleanup" \
  --target-dir "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/ehs-clnt-hazard-parent-runenv" \
  --include-spec-center-placeholders \
  --include-cursor-scaffold

bash "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap/bin/cursor-cleanup" \
  --target-dir "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/ehs-clnt-hazard-parent-runenv" \
  --include-spec-center-placeholders \
  --include-cursor-scaffold \
  --apply
clear
```

### 3) 一键编排（自动生成 `bin` wrappers）

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
clear
```

### 4) 预览调优

```bash
bash bin/cursor-tune --dry-run
clear
```

### 5) 正式调优

```bash
bash bin/cursor-tune --mode aggressive
clear
```

### 6) 二次校准（建议执行）

完成 `cursor-tune` 后，建议在 Cursor Chat 中补一次按工程校准：

1. 输入：`按工程再优化一遍脚手架`
2. 执行：`/check-scaffold`

这样可以把“终端已落盘结果”再按当前工程语义复核一遍，减少漏配与路径漂移。

### 7) 固定验收（避免“看起来成功但没落盘”）

```bash
git status --short
rg -n "managed-by: cursor-tune begin:scan-derived" ".cursor"
rg -n "x-capability-links|operationId|source=" "spec_center"
ls -la "bin/cursor-tune" "bin/cursor-bootstrap" "bin/cursor-cleanup"
```

### B. 前端目标仓（frontend）

### 1) 进入前端仓并创建测试分支

```bash
cd "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/forest-fire-monitor-web"
git checkout -b chore/retest-latest-bootstrap-20260220
clear
```

### 2) （可选）清理旧生成物（先 dry-run，再 apply）

```bash
bash "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap/bin/cursor-cleanup" \
  --target-dir "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/forest-fire-monitor-web" \
  --include-spec-center-placeholders \
  --include-cursor-scaffold

bash "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/cursor-engineering-bootstrap/bin/cursor-cleanup" \
  --target-dir "/Users/zhanjie/Library/CloudStorage/OneDrive-Personal/code/forest-fire-monitor-web" \
  --include-spec-center-placeholders \
  --include-cursor-scaffold \
  --apply
clear
```

### 3) 一键编排（frontend）

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
clear
```

### 4) 预览调优（frontend）

```bash
bash bin/cursor-tune --dry-run
clear
```

### 5) 正式调优（frontend）

```bash
bash bin/cursor-tune --mode aggressive
clear
```

### 6) 二次校准（frontend，建议执行）

完成 `cursor-tune` 后，建议在 Cursor Chat 中补一次按工程校准：

1. 输入：`按工程再优化一遍脚手架`
2. 执行：`/check-scaffold`

这样可以把“终端已落盘结果”再按当前工程语义复核一遍，减少漏配与路径漂移。

### 7) 固定验收（frontend）

```bash
git status --short
rg -n "managed-by: cursor-tune begin:scan-derived" ".cursor"
rg -n "x-capability-links|operationId|source=" "spec_center"
ls -la "bin/cursor-tune" "bin/cursor-bootstrap" "bin/cursor-cleanup"
```

---

## 四、Cursor 命令版（Chat 内执行）

在目标仓打开 Cursor 后，按顺序输入：

1. 输入：`按工程再优化一遍脚手架`（建议先执行，触发工程化校准语境）
2. `/init-scan`
3. `/tune-project`（先 dry-run，再确认 apply）
4. `/check-scaffold`（backend/frontend 都可用；建议放在 `/tune-project` 后做二次校准）
5. 若提示 constitution 缺失或质量不足：`/speckit.constitution`
6. 开发落地时执行：`/bridge-implement`

说明：wrapper 自动生成后，`/tune-project` 调用 `bin/cursor-tune` 的稳定性更高。

---

## 五、培训讲解建议（5 分钟版）

- 先讲“为什么”：目标是让规则/命令/hooks/spec_center 与真实工程对齐，并且可审计。
- 再讲“怎么做”：先清理、再 bootstrap、再 tune、最后固定验收。
- 最后讲“怎么判断成功”：
  - `.cursor` 出现 `managed-by: cursor-tune` 的受管块
  - `spec_center` 出现 `x-capability-links/operationId/source`
  - 目标仓 `bin/` 下有三个 wrapper 脚本

---

## 六、常见问题（培训现场可直接回答）

- `Q: 为什么先 dry-run？`
  - `A:` 先看变更面，再做 apply，避免误改。
- `Q: 为什么要固定验收命令？`
  - `A:` 防止“日志成功但文件未落盘”的假阳性。
- `Q: Cursor 命令和终端命令有什么关系？`
  - `A:` Cursor 命令是体验层，底层仍依赖脚本；两条路径应得到一致结果。
