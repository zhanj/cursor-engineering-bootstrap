# /tune-project（frontend）

目标：在 `/init-scan` 后，调用 `bin/cursor-tune` 对本工程执行“存在则改，不存在则增（upsert）”的二次定制，并保留可审计 diff。

## 输入（必须）
- 目标工程根目录（当前工作区根目录）
- 已存在的 `_cursor_init` 产物（若无，先执行 `cursor-init/cursor-bootstrap`）
- 团队偏好（`safe` / `aggressive`）

## 执行步骤（必须按顺序）
1. 先执行 dry-run 预览：
   - `bash bin/cursor-tune --use-current-dir --dry-run`
2. 读取并总结预览产物：
   - `_cursor_init/tune-report.md`
   - `_cursor_init/tune.diff`
3. 若产物为空或与预期不符，先停止并输出原因，不进入 apply。
4. 与用户确认是否执行 apply（建议默认 `safe`，明确同意后可改为 `aggressive`）。
5. 执行 apply：
   - `bash bin/cursor-tune --use-current-dir --mode safe`
   - 或 `bash bin/cursor-tune --use-current-dir --mode aggressive`
6. 再次读取并输出最终产物（report + diff），给出“已修改/建议人工确认”清单。

## 输出格式（必须）
- `调优模式`：`safe|aggressive`
- `执行阶段`：`dry-run|apply`
- `已修改文件`：逐条列出（来自 `_cursor_init/tune-report.md`）
- `待人工确认`：逐条列出（`needs_manual_confirm`）
- `产物路径`：
  - `_cursor_init/tune-report.md`
  - `_cursor_init/tune.diff`

## 禁止事项
- 不跳过 dry-run 直接 apply。
- 不删除业务代码文件。
- 在未展示 `_cursor_init/tune.diff` 前，不给出“已完成调优”结论。
