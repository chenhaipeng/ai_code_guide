# Implementation Constraints 模板

> 目的：定义前后端实现约束和最低验证要求。

## 规格状态

- 状态：[Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived]
- 来源：[Human Input / AI Extracted from Code / AI Draft]
- 最后更新：[YYYY-MM-DD]
- 确认人：[姓名或角色]
- 适用范围：[本 spec 覆盖的产品 / 模块 / 版本]

## 后端约束

- 使用 [数据库] 作为真实数据源。
- 使用 [迁移工具] 管理迁移。
- 使用 [schema 工具] 定义请求和响应结构。
- 使用 [ORM] 作为数据访问层。
- 鉴权方式：[描述鉴权方案]。
- 权限模型：[描述角色和权限]。
- 事务使用场景：[列出必须用事务的操作]。
- 生产流程不使用内存状态作为 source of truth。

## 前端约束

- 使用 [框架 + 版本]。
- 按页面 / 组件拆分，不要把所有逻辑写在一个文件里。
- API client 独立封装，统一处理 base URL、鉴权、错误和响应类型。
- 页面文案使用 [语言]，面向 [用户类型]。
- 所有关键 UI 状态必须来自真实接口响应。
- 空状态、加载状态、错误状态必须有降级展示。

## 验证要求

- 后端测试通过。
- 前端 typecheck / build 通过。
- 关键接口可用真实请求验证。
- 页面在真实浏览器中可访问。
- Console 无新增 JavaScript 错误。
- Network 无失败接口请求。
