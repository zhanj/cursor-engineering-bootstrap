# Install Kit Index

这个目录是“安装与培训交付包”的最小入口。

> 只拷贝本目录给研发同学时，请务必使用 `--package-url` 模式安装；不需要拷贝整个仓库。

## 先看顺序

1. 日常使用：先看 `README.quickstart.md`
2. 完整说明：再看 `README.md`
3. 培训重测：看 `docs/training-retest-quickstart.md`

## 安装脚本位置

- macOS/Linux:
  - `install/install.sh`
  - `install/uninstall.sh`
- Windows (WSL2-first):
  - `install/install.ps1`
  - `install/uninstall.ps1`

## 常用安装命令

macOS/Linux（发布包 URL）：

```bash
bash install/install.sh --package-url "https://github.com/zhanj/cursor-engineering-bootstrap/releases/download/vX.Y.Z/bootstrap-package.tgz"
```

Windows PowerShell（WSL2-first）：

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install.ps1 -PackageUrl "https://github.com/zhanj/cursor-engineering-bootstrap/releases/download/vX.Y.Z/bootstrap-package.tgz"
```

发布页（选择实际版本）：

`https://github.com/zhanj/cursor-engineering-bootstrap/releases`

## 默认安装路径

- 安装根目录：`~/.cursor-bootstrap/<version>/`
- 当前版本链接：`~/.cursor-bootstrap/current`
- 命令入口目录：`~/.local/bin`

> Windows + WSL2 下以上路径位于 WSL 用户目录（非 `C:\Users\...`）。
