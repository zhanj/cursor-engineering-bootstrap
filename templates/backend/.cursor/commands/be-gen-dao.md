# /be-gen-dao（backend）

目标：基于 schema/migration 生成或更新 DAO 层，保持与表结构一致。

## 输入
- migration SQL（Flyway/Liquibase）
- 目标表与主键、索引信息
- 现有 DAO/Mapper 命名规范

## 执行步骤
1. 解析表结构变化（新增列、类型变化、索引变化）。
2. 更新 Entity/Mapper/Repository/SQL XML（按仓库风格最小修改）。
3. 检查读写路径是否受影响（分页、排序、条件查询）。
4. 增加最小测试：至少覆盖 1 条受影响 SQL 路径。

## 输出格式（必须）
- `Schema Diff`
- `DAO Diff`
- `兼容性说明`
- `验证命令`

## 禁止事项
- 跳过 migration 直接改持久层。
- 生成大量无关 CRUD 代码。
