# /tune-project（backend）

目标：在 `/init-scan` 后，调用 `bin/cursor-tune` 对本工程执行“存在则改，不存在则增（upsert）”的二次定制，并保留可审计 diff。

## 输入（必须）
- 目标工程根目录（当前工作区根目录）
- 已存在的 `_cursor_init` 产物（若无，先执行 `cursor-init/cursor-bootstrap`）
- 团队偏好（`safe` / `aggressive`）
- 目标仓 `bin/` wrapper（`cursor-tune|cursor-bootstrap|cursor-cleanup`，由 tune 自动补齐）

## 执行步骤（必须按顺序）
1. 先执行 dry-run 预览：
   - `bash bin/cursor-tune --use-current-dir --dry-run`
2. 读取并总结预览产物：
   - `_cursor_init/tune-report.md`
   - `_cursor_init/tune.diff`
   - `_cursor_init/project-inventory.md`
3. 若产物为空或与预期不符，先停止并输出原因，不进入 apply。
4. 与用户确认是否执行 apply（建议默认 `safe`，明确同意后可改为 `aggressive`）。
5. 执行 apply：
   - `bash bin/cursor-tune --use-current-dir --mode safe`
   - 或 `bash bin/cursor-tune --use-current-dir --mode aggressive`
6. 再次读取并输出最终产物（report + diff + inventory），给出“已修改/建议人工确认”清单。
7. 输出必须包含“本次 diff Top N 条真实变更”（建议 N=5，不得写泛化描述）。
8. 输出必须包含“变化证据段”：列出本次新增/修改的 3~5 个关键文件，并给出每个文件 1 行变更原因（来自 report/diff）。
9. 核对 `spec_center` 三件套联动一致性：
   - `capability-registry.md`
   - `<service>/spec.md`
   - `<service>/contracts/openapi.yaml`
10. 核对根目录 `.cursor` 是否已按扫描结果写入 managed blocks（rules/commands/hooks）。

## 输出格式（必须）
必须按以下 Markdown 模板输出（保持标题与空行，不得压成一行文本）：

```md
# /tune-project 执行结果

## 调优模式
- `safe|aggressive`

## 执行阶段
- `dry-run`：成功|失败
- `apply`：成功|未执行

## 已修改文件（来自 _cursor_init/tune-report.md）

| 操作 | 路径 |
|---|---|
| patched/created | xxx |

## 本次 diff Top N 条真实变更（N=5）
- 变更 1（文件 + 具体差异）
- 变更 2（文件 + 具体差异）
- 变更 3（文件 + 具体差异）
- 变更 4（文件 + 具体差异）
- 变更 5（文件 + 具体差异）

## 变化证据段（3~5 个关键文件）
- `path/to/fileA`：1 行原因（引用 report/diff 的具体变化）
- `path/to/fileB`：1 行原因（引用 report/diff 的具体变化）
- `path/to/fileC`：1 行原因（引用 report/diff 的具体变化）

## 无效证据反例（禁止）
- “已优化多个文件、效果良好” （未给出具体文件与差异）
- “按预期完成调优” （未给出可审计证据）
- “修改了配置和文档” （未说明具体路径与变更点）

## 有效证据最小示例（参考）
- Top N 真实变更示例：`<具体文件路径>` + `<具体改动点>`（如“新增 capability 条目并补充 synonyms”或“新增路由/接口映射”）。
- 变化证据示例：`<关键文件路径>`：`1 行原因`（必须可在 `_cursor_init/tune.diff` 或 `_cursor_init/tune-report.md` 对应到真实差异）。

## 待人工确认
- 逐条列出 `needs_manual_confirm`
- 若无：`- 无（Suggestions: none）`

## 产物路径
- `_cursor_init/tune-report.md`
- `_cursor_init/tune.diff`
- `_cursor_init/project-inventory.md`

## 联动校验
- `capability-registry.md` ↔ `<service>/spec.md` ↔ `<service>/contracts/openapi.yaml` 是否互相引用
```

## 禁止事项
- 不跳过 dry-run 直接 apply。
- 不删除业务代码文件。
- 在未展示 `_cursor_init/tune.diff` 前，不给出“已完成调优”结论。
