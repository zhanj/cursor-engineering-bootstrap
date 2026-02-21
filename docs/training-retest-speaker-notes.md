# 脚手架重测培训口播稿（3-5 分钟）

用途：讲师现场逐句讲解，帮助研发同学快速理解“为什么做、怎么做、怎么验收”。

---

## 1) 开场（约 30 秒）

大家好，今天这 5 分钟我们只做一件事：  
把最新脚手架在目标仓里重跑一遍，并且确保结果“真的落盘、可验证、可复用”。

我们的目标不是改业务代码，而是把 `.cursor`、`spec_center`、`hooks`、命令流程校准到当前工程真实结构。  
这套流程同时适用于 backend 和 frontend 仓库，差异主要在 `cursor-bootstrap --mode backend|frontend`。

---

## 2) 为什么要重测（约 40 秒）

你会看到“命令执行成功”，但如果没有固定验收，很容易出现“看起来成功、实际没落盘”。  
所以今天流程里会有两个关键动作：

1. 先 `dry-run` 再 `apply`
2. 最后用固定验收命令检查关键证据

这样能保证团队后续执行一致，不靠个人经验。

---

## 3) 标准流程（约 2 分钟）

下面按标准流程走，顺序不要变：

1. 更新脚手架仓库到最新代码。  
2. 进入目标仓，创建独立重测分支。  
3. 可选执行 `cursor-cleanup`，先 dry-run 再 apply，清理旧生成物。  
4. 执行 `cursor-bootstrap` 一键编排，参数使用 merge 模式（后端用 `--mode backend`，前端用 `--mode frontend`）。  
5. 执行 `cursor-tune --dry-run` 先看预览。  
6. 确认后执行 `cursor-tune --mode aggressive` 正式调优。  
7. 执行固定验收命令，确认关键内容已写入。

这个流程就是我们培训和回归的统一基线。

---

## 4) Cursor 命令版（约 50 秒）

如果你在 Cursor Chat 内操作，顺序是：

1. 先输入：`按工程再优化一遍脚手架`
2. `/init-scan`
3. `/tune-project`（先 dry-run，再 apply）
4. `/check-scaffold`（放在 `/tune-project` 后做按工程二次校准）
5. 若提示 constitution 缺失或质量不足，再执行 `/speckit.constitution`
6. 进入开发落地时用 `/bridge-implement`

终端版和 Cursor 命令版本质一致：  
体验层可以不同，但最终产物与验收证据必须一致。

---

## 5) 怎么判断“成功”（约 40 秒）

请只看三类硬证据：

- `.cursor` 里出现 `managed-by: cursor-tune` 的受管块  
- `spec_center` 里能看到 `x-capability-links`、`operationId`、`source` 等联动字段  
- 目标仓 `bin/` 下有 `cursor-tune`、`cursor-bootstrap`、`cursor-cleanup` 三个 wrapper

三条都满足，才算这次重测真正完成。

---

## 6) 收尾（约 20 秒）

如果现场只记住一句话：  
**先预览、再应用、最后验收。**  
不要跳步骤，不要凭感觉判断成功。
