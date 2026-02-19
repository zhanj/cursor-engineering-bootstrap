# `/speckit.constitution` 通用提示词（统一版本）

> 用途：在 spec-kit 初始化后，基于当前工程现状生成可执行的 constitution。  
> 建议：优先复制以下整段到 Agent 中执行，避免口径漂移。

```text
/speckit.constitution
请根据当前工程已有内容生成并更新 constitution：
1) 以仓库现有技术栈、目录结构、构建与测试命令为准；
2) 以现有规则与门禁为准（.cursor/rules、hooks/gates、PR_TEMPLATE）；
3) 明确复用优先、契约一致、验证可追溯、风险回滚四类原则；
4) 原则必须可执行、可检查，避免空泛表述；
5) 若与现有规范冲突，优先保持向后兼容并列出差异；
6) 输出后给出“如何在后续 /speckit.specify /plan /tasks /implement 中落地”的简短说明。
```
