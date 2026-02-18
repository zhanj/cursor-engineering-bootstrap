# 扫描说明（v2）

v2 扫描分两层：

## 1) 离线轻扫描（bin/cursor-init）
- 只基于文件指纹推断：构建工具、包管理器、DAO 框架、迁移工具
- 不执行任何构建命令，安全、快速
- 输出：`_cursor_init/report.md / proposed_tree.md / apply_plan.md`

## 2) Cursor 深扫描（/init-scan 命令）
- 在 Cursor 内运行，通过 Agent 阅读真实目录结构/关键文件
- 用于“校准” hooks/rules/commands（例如你们实际是 gradle、或 pnpm 脚本不同）

> 建议流程：先脚本 dry-run → 再在 Cursor 运行 /init-scan → 最后 PR 落库。
