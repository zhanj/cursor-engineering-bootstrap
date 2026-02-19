# /init-scan（backend）

目标：读取 `_cursor_init/*` 与真实仓库结构，给出“可直接落库”的校准结果。

## 输入
- `_cursor_init/report.md`
- `_cursor_init/proposed_tree.md`
- `_cursor_init/hooks.suggested.json`
- 后端仓库的真实文件结构（构建工具、测试命令、迁移目录、Mapper/Repository 命名）

## 执行步骤
1. 校验仓库类型：Maven/Gradle、MyBatis/JPA、Flyway/Liquibase。
2. 对比 `.cursor/hooks/hooks.json` 与 `_cursor_init/hooks.suggested.json`，输出差异。
3. 校准 `.cursor/hooks/gates/config.sh` 中目录正则（controller/api、migration、mybatis xml）。
4. 检查 `.cursor/rules/*.mdc` 是否与当前仓库分层一致，不一致处给出最小改动。
5. 检查 `spec_center/capability-registry.md` 与 `<service>/contracts/openapi.yaml` 是否可访问；缺失时明确标注“待建”并给出创建建议。
6. 检查 `.specify/memory/constitution.md` 是否存在；若缺失，先按 `docs/speckit-constitution-prompt.md` 执行 `/speckit.constitution`，并确认文件已生成后再继续。
7. 输出落库清单（新增/修改/保留）与风险点。

## 输出格式（必须）
- `校准结论`：一句话给出是否可落库。
- `建议改动文件`：逐文件列出改动原因。
- `待人工确认`：最多 5 条。
- `验证命令`：可直接复制执行。
- `Spec 资产状态`：`capability-registry/openapi` 的存在性与“待建”项。
- `Constitution 状态`：`.specify/memory/constitution.md` 存在性与处理结果（已存在/已补建/待人工处理）。

## 禁止事项
- 不直接改业务代码。
- 不删除已有 `.cursor` 文件；冲突时建议生成 `*.v2`。
