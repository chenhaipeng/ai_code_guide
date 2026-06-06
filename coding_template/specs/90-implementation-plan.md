# Implementation Plan 模板

> 目的：把规格拆成可执行、可验证的小步骤。实现前必须先写计划。

## 规格状态

- 状态：[Draft / AI Extracted / Human Confirmed / Frozen / Deprecated]
- 来源：[Human Input / AI Extracted from Code / AI Draft]
- 最后更新：[YYYY-MM-DD]
- 确认人：[姓名或角色]
- 适用范围：[本计划覆盖的产品 / 模块 / 版本]

## 目标

[一句话说明本计划交付什么]

## 输入文档

- Idea Brief：[路径]
- Product Spec：[路径]
- Architecture Spec：[路径]
- API Contract：[路径]
- E2E Acceptance：[路径]

## Phase 列表

### Phase [N]：[名称]

目标：[说明]

输入：

- [依赖文档 / 已完成 Phase / 现有模块]

输出：

- [新增能力 / 文件 / 验证报告]

依赖：

- 前置 Phase：[编号或无]
- 外部条件：[账号 / 服务 / 数据 / 无]

修改范围：

- 新增：[文件]
- 修改：[文件]
- 禁止修改：[文件]

步骤：

1. [步骤]
2. [步骤]
3. [步骤]

验证：

- 构建命令：[命令]
- 测试命令：[命令]
- E2E 路径：[路径]
- 验收报告：[docs/e2e/verify/... 或不适用]

失败处理：

- 验证失败时：[停止 / 回滚 / 修复范围]
- 回滚方式：[命令或文件恢复策略]
- 需记录的决策：[docs/decision.md 条目或无]

禁止事项：

- [禁止事项]

## 完成标准

- [标准 1]
- [标准 2]
- [标准 3]
