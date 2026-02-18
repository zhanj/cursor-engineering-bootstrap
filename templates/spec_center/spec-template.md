# <service>｜<能力名称>（spec-template）

> 用法：复制本文件为 `<service>/spec.md`，补齐各章节后提交 PR。

## 1) Why（为什么做）
- 业务背景：
- 当前痛点：
- 目标收益（量化优先）：

## 2) What（做什么）

### 2.1 能力范围（In Scope）
- 
- 

### 2.2 非范围（Out of Scope）
- 
- 

## 3) 用户与场景（Who / Scenarios）
- 角色 A：
- 角色 B：

关键场景：
- 场景 1：
- 场景 2：

## 4) 业务规则（Rules）
- 规则 1：
- 规则 2：
- 规则 3：

## 5) API / Contract 影响
- 影响契约文件：`<service>/contracts/openapi.yaml`
- 受影响 endpoint（逐条）：
  - 
  - 
- 兼容策略（向后兼容/迁移方案）：

## 6) 数据与迁移影响（可选）
- 是否涉及 DB 结构变更：是/否
- 迁移脚本位置（若有）：
- 回滚与数据修复方案（若有）：

## 7) DoD（完成定义）
- [ ] spec 与 `openapi.yaml` 已同步
- [ ] capability-registry 已更新能力条目与同义词
- [ ] 最小回归场景通过（成功/异常至少各 1 条）
- [ ] PR 风险与回滚说明完整

## 8) 风险与回滚
- 主要风险：
- 监控与观察点：
- 回滚方案（步骤 + 触发条件）：

## 9) 外部依赖（若有）
- 第三方契约位置：`_raw_contracts/external/<vendor>/openapi.yaml`
- 调用边界（鉴权/限流/超时/重试）：
- 降级策略：
