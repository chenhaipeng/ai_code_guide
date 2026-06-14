# API 与页面接口规范模板

> 目的：定义接口契约、页面接口映射和页面状态要求。
>
> **角色定位**：本 spec 是设计快照（脚手架），完成并确认后先改状态为 `Archived`，再移动到 `docs/superpowers/specs/archive/`。**接口契约真相以 OpenAPI 为准**（如 FastAPI `/openapi.json`，由代码生成）；本文件只记录页面-接口映射和关键契约决策（鉴权、幂等、SSE、错误码），**不逐接口手写请求/响应 schema**——那会迅速过时。详见 `reference/documentation-governance.md`。

## 规格状态

- 状态：[Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived]
- 来源：[Human Input / AI Extracted from Code / AI Draft]
- 最后更新：[YYYY-MM-DD]
- 确认人：[姓名或角色]
- 适用范围：[本 spec 覆盖的产品 / 模块 / 版本]

真实前端必须通过真实后端获取数据。每个页面必须有对应接口和真实数据来源。

## 页面与接口关系

| 页面 | 用户动作 | 前端调用 | 后端职责 |
| --- | --- | --- | --- |
| [页面名] | [动作] | [API 端点] | [职责] |
| ... | ... | ... | ... |

## 接口契约（指向代码，不手写）

> 逐接口的请求/响应 schema、字段、错误码真相以 OpenAPI 为准（由代码生成）。本节只记**页面-接口映射**（上方表格）和**跨接口的关键契约决策**。

关键契约决策：

- 鉴权方案：[Bearer session / JWT / ...]
- 幂等接口与 `Idempotency-Key`：[哪些写接口需要]
- SSE / 流式：[哪些、为什么选 SSE 而非 WebSocket]
- 错误码约定：[核心错误码，详情以 OpenAPI 为准]
- 分页：[limit/cursor 等统一约定]

## 页面状态要求

每个页面必须定义：加载状态、空状态、错误状态、权限不足状态、真实数据展示状态。

## 前后端一致性

前后端不一致时，优先检查文档和原 contract，再决定调整后端字段还是前端适配器。
