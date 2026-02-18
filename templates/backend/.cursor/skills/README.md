后端 skills 使用说明（建议）

- `Interface Finder`：需求实现前使用；先查 `capability-registry`、`openapi.yaml` 与现有代码，定位可复用接口与候选能力。
- `Client Generator`：确认外部/跨服务接口后使用；基于 `openapi.yaml` 生成或更新调用客户端，避免手写漂移。
- `DAO Generator`：涉及表结构或迁移时使用；同步生成或校准 DAO/Mapper/Repository，并配合 DB 一致性 gate 校验。

建议顺序：`Interface Finder -> Client Generator/DAO Generator -> implement-task -> PR_TEMPLATE`。
