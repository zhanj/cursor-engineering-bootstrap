# cursor-engineering-bootstrap Quickstart

给研发同学的极简上手版（目标：10 分钟跑通）。

## 1) 安装命令

从 Release 安装（推荐）：

```bash
bash install/install.sh --package-url "https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/bootstrap-package.tgz"
```

自定义安装目录（可选）：

```bash
bash install/install.sh \
  --package-url "https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/bootstrap-package.tgz" \
  --install-root "/custom/path/.cursor-bootstrap" \
  --bin-dir "/custom/path/bin"
```

如果你是脚手架维护者，在仓库内安装：

```bash
bash install/install.sh --repo "$(pwd)"
cursor-tools --version
cursor-tools self-check
```

## 2) 初始化目标仓

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

说明：`--apply-mode merge` 表示仅补齐缺失资产；`--with-spec-kit --execute-spec-kit --spec-kit-yes` 表示同时生成 spec-kit 资产。

## 3) 二次调优（建议）

```bash
cd /path/to/target-repo
bin/cursor-tune --dry-run
bin/cursor-tune --mode aggressive
```

## 4) Cursor Chat 推荐顺序

1. 输入：`按工程再优化一遍脚手架`
2. `/init-scan`
3. `/tune-project`
4. `/check-scaffold`
5. `/speckit.constitution`（仅缺失/质量不足时）
6. `/bridge-implement`

## 5) 常见问题

- 目标仓已有 `.cursor`：可以，默认 `merge` 补缺不覆盖。
- 安装链接里有 `releases/download`：这是 GitHub Release 资产固定下载路径。
- Windows：建议 WSL2 内执行脚本和命令。

## 6) 维护者发版

```bash
# 一步：打包 + 发布 + 输出安装命令
bash scripts/release/cut-release.sh --tag vX.Y.Z --repo <owner>/<repo>
```

仅本地演练（不发布）：

```bash
bash scripts/release/cut-release.sh --tag vX.Y.Z --skip-publish
```
