# /cleanup-project（frontend）

目标：调用 `bin/cursor-cleanup` 清理脚手架生成物，默认先预览（dry-run），明确确认后再执行 `--apply`。

## 输入（必须）
- 目标工程根目录（当前工作区根目录）
- 清理范围选择：
  - 仅 `_cursor_init`（默认）
  - 加占位 `spec_center`（`--include-spec-center-placeholders`）
  - 加 `.cursor` 脚手架（`--include-cursor-scaffold` 或 `--include-cursor-scaffold-force`）

## 执行步骤（必须按顺序）
1. 先 dry-run 预览：
   - `bash bin/cursor-cleanup --use-current-dir`
2. 若用户要求扩展范围，再分别 dry-run：
   - `bash bin/cursor-cleanup --use-current-dir --include-spec-center-placeholders`
   - `bash bin/cursor-cleanup --use-current-dir --include-cursor-scaffold`
   - `bash bin/cursor-cleanup --use-current-dir --include-cursor-scaffold-force`
3. 读取 dry-run 输出中的 delete candidates，并逐条说明影响范围。
4. 与用户确认后再执行 apply（命令需与 dry-run 参数保持一致，仅追加 `--apply`）。
5. apply 后再次执行同参数 dry-run，输出“剩余待清理项（如有）”。

## 输出格式（必须）
- `执行阶段`：`dry-run|apply`
- `清理范围`：`bootstrap_output|spec_center_placeholders|cursor_scaffold_safe|cursor_scaffold_force`
- `删除候选`：逐条列出
- `执行结果`：`done|aborted|needs_confirm`

## 禁止事项
- 不得跳过 dry-run 直接 apply。
- 未经确认不得使用 `--include-cursor-scaffold-force`。
- 不得删除业务源码文件。
