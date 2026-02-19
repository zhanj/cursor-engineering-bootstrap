# /init-scan（frontend）

目标：根据 `_cursor_init/*` 与前端真实工程结构，输出可落库的校准方案。

## 输入
- `_cursor_init/report.md`
- `_cursor_init/proposed_tree.md`
- `_cursor_init/hooks.suggested.json`
- 前端项目结构（包管理器、路由、API 目录、UI 组件体系）

## 执行步骤
1. 识别包管理器（pnpm/yarn/npm）与 TypeScript 配置。
2. 对比 `.cursor/hooks/hooks.json` 与 `_cursor_init/hooks.suggested.json`。
3. 校准规则中的目录落点（views/components/api/router/store）。
4. 检查 API 调用风格是否统一（request 封装、错误处理、鉴权头）。
5. 检查 `spec_center/capability-registry.md` 与 `<service>/contracts/openapi.yaml` 是否可访问；缺失时明确标注“待建”并给出创建建议。
6. 检查 `.specify/memory/constitution.md` 是否存在；若缺失，先按 `docs/speckit-constitution-prompt.md` 执行 `/speckit.constitution`，并确认文件已生成后再继续。
7. 输出落库清单与风险点。

## 输出格式（必须）
- `校准结论`
- `建议改动文件`
- `待人工确认`
- `验证命令`
- `Spec 资产状态`（`capability-registry/openapi` 的存在性与“待建”项）
- `Constitution 状态`（`.specify/memory/constitution.md` 的存在性与处理结果：已存在/已补建/待人工处理）
