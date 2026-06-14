# AI 产品工程 Prompt 模板

> 目的：驱动 AI 从 idea 到交付产品。具体内容写入 `.template/specs/` 对应模板，避免把所有细节塞进 prompt。
>
> 原则：
> - 只读取当前阶段相关文档；做完立刻验证；不验证不进入下一阶段。
> - **产出归位**：每阶段产出的信息归到它的天然源头，而不是堆进 spec——
>   - 现状（接口 / 数据 / 行为）→ 写进代码（OpenAPI / ORM / 测试），spec 不手写这些
>   - 决策（为什么这么选）→ 追加到 `docs/decision.md`
>   - 状态（到哪了）→ 更新 `docs/progress.md`
>   - spec 本体 → 思考脚手架，用完归档（见 `reference/documentation-governance.md`）

---

## 阶段 1：Idea Brief

```text
我想做一个 [产品名称]。

目标用户：[描述用户群体]
使用场景：[用户在什么时候使用]
解决问题：[痛点]
带来结果：[用户获得什么]

请按 `.template/specs/00-idea-brief.md` 生成 Idea Brief。

要求：
1. 压缩成一句话产品定义
2. 明确目标用户、非目标用户
3. 列出 MVP 必做和明确不做
4. 列出 3-5 个对标产品
5. 给出可验证成功标准
6. 写入规格状态：初稿为 `Draft`，从已有代码/文档提取为 `AI Extracted`，人类确认后才能标记为 `Human Confirmed`

验证：如果边界不清、MVP 超过 5 个核心能力、没有明确不做项，则不进入下一阶段。
```

---

## 阶段 2：Product Spec

```text
Idea Brief：[路径]

请按 `.template/specs/01-product-spec.md` 生成 Product Spec。

要求：
1. 定义用户角色和核心用户路径
2. 列出 MVP 页面和非 MVP 页面
3. 每个页面必须包含：目的、操作、字段、字段来源、依赖接口、输入校验、关键业务规则、加载/空/错误/权限状态、权限矩阵、验收标准
4. 明确非功能要求：性能、安全、可用性、可观测性
5. 写入规格状态：初稿为 `Draft`，从已有代码/文档提取为 `AI Extracted`，人类确认后才能标记为 `Human Confirmed`

验证：每个页面必须有状态定义、字段来源、权限矩阵和验收标准；没有空状态/错误状态或无法追踪到数据来源的页面不通过。
```

---

## 阶段 3：Domain Research / Data Discovery

```text
Idea Brief：[路径]
Product Spec：[路径]
已有研究 / 数据来源 / 竞品材料：[路径或无]

请按 `.template/specs/05-domain-research.md` 生成 Domain Research / Data Discovery，并将目标项目产物写入 `docs/research/05-domain-research.md`。

要求：
1. 建立 `docs/research/` 分类目录：competitors、data-sources、data-lineage、user-flows、evidence，并维护 `assumptions.md`
2. 分析 3-5 个同类产品或竞品；不适用时必须说明原因
3. 定义领域术语、用户使用闭环、数据来源清单、数据源到系统模型映射、数据流闭环
4. 每个核心数据来源必须说明：来源、获取方式、授权、可信度、更新频率、失败模式和证据
5. 每个关键结论必须有稳定 ID：COMP / TERM / SRC / MAP / FLOW / LOOP / RISK / ASM，供后续 specs 引用
6. 明确哪些长期事实需要回写到 Product Spec、Data Design、API 或 E2E；研究证据保留在 `docs/research/`
7. 写入规格状态；外部调研或 AI 推断内容不能标记为 `Human Confirmed`

验证：如果核心字段无法追溯到数据来源或待确认假设、没有用户闭环、没有数据流闭环、P0 数据风险未关闭，则不进入 UX / Prototype 或 Architecture / System Design。
```

---

## 阶段 4：UX / Prototype（按需）

```text
如果产品涉及 C 端体验、复杂页面、视觉设计或原型，请执行本阶段；否则跳过。

Product Spec：[路径]
Domain Research / Data Discovery：[路径]

请按 `.template/specs/10-ux-prototype.md` 生成 UX / Prototype Spec，并创建可交互原型。

要求：
1. 定义视觉方向、页面结构、关键组件和响应式规则
2. 原型必须可直接打开或运行
3. 原型中的示例数据、页面结构和用户闭环必须来自 Product Spec 和 Domain Research，不得随意编造
4. 原型可包含示例数据，但必须标注不能作为生产验收数据
5. 明确原型复用边界：可复用结构/交互/文案，不复用假数据
6. 写入规格状态，冻结原型后标记为 `Frozen`

验证：用浏览器打开原型，逐页检查导航、表单、按钮、空状态、错误状态和响应式表现。
```

---

## 阶段 5：Architecture / System Design

```text
Idea Brief：[路径]
Product Spec：[路径]
Domain Research / Data Discovery：`docs/research/05-domain-research.md`
UX / Prototype：[路径或无]
AGENTS.md / CLAUDE.md：[路径]

请先读取 Domain Research / Data Discovery 的研究结论和待确认假设，再生成系统设计。

设计输入校验必须覆盖：
- `SRC` / `MAP` / `FLOW` 是否已覆盖核心数据来源、模型映射和数据流闭环
- `LOOP` 是否已覆盖用户从进入到完成核心目标的闭环
- `RISK` / `ASM` 中是否仍有阻塞架构的 P0 风险或待确认假设
- 哪些结果需要可解释、可追溯或可审计
- 是否涉及权限、余额、支付、额度、审批或其他关键风险
- 实时性、失败恢复、降级策略如何处理
- 哪些能力第一版明确不做

然后按需生成：
- 架构：`.template/specs/20-architecture.md`
- 数据设计：`.template/specs/30-data-design.md`
- API 与页面接口：`.template/specs/40-api-and-pages.md`
- 实现约束：`.template/specs/50-implementation-constraints.md`

凡涉及数据库、外部服务、权限、支付、额度、异步任务、复杂前后端接口、多角色流程或生产数据链路，不得跳过对应设计规格。
生成的设计规格必须写入规格状态；从现有代码反填的内容标记为 `AI Extracted`。

验证：产品规格里的字段、页面、操作，都必须能在架构、数据、API 或实现约束中找到来源。
```

---

## 阶段 6：E2E Acceptance Spec

```text
Product Spec：[路径]
Domain Research / Data Discovery：`docs/research/05-domain-research.md`
Architecture / API / Data Specs：[路径]

请按 `.template/specs/02-e2e-acceptance.md` 生成开发前 E2E 验收规范。

要求：
1. 按核心用户路径拆分 E2E 用例
2. 每个用例包含前置条件、操作步骤、页面断言、接口断言、数据断言、Console/Network 断言
3. 覆盖正常路径、空状态、错误状态、权限不足、数据链路追踪
4. 指定验收报告目录：`docs/e2e/verify/`
5. 复杂项目必须一份 spec 对应一份 verify 报告；总体验收另写 overall verify 报告
6. 写入规格状态；验收标准经人类确认后才能标记为 `Human Confirmed`

验证：没有 E2E 验收规范，不进入实施计划。
```

---

## 阶段 7：Implementation Plan

```text
已完成文档：
- Idea Brief：[路径]
- Product Spec：[路径]
- E2E Acceptance：[路径]
- 相关 Domain Research / Architecture / Data / API / UX specs：[路径]

请按 `.template/specs/90-implementation-plan.md` 生成实施计划。

要求：
1. 每个 Phase 是独立可验证的交付单元
2. 每个 Phase 包含目标、输入、输出、依赖、修改范围、禁止事项、验收命令、E2E 路径、失败处理、回滚方式
3. 修改范围必须明确到文件或目录
4. 验收命令必须可复制执行
5. 写入规格状态；计划经人类确认后才能标记为 `Human Confirmed`

验证：Phase 依赖不能断裂；没有验证命令或 E2E 路径的 Phase 不通过。
```

---

## 阶段 8：分阶段开发

```text
请实现 [Phase 编号]: [Phase 名称]。

必须遵守：
- AGENTS.md / CLAUDE.md：[路径]
- Implementation Plan：[路径]
- 当前 Phase 相关 specs：[路径]
- docs/research/：[路径或无]

执行要求：
1. 只读取当前 Phase 直接相关文档和研究结论，禁止一次性加载所有 spec / research
2. 按计划逐步实现，不做计划外功能
3. 每完成一个关键改动就运行对应验证
4. 遇到决策默认选择推荐方案，并记录选项、选择和理由
5. 如果验证失败，先修复，不继续下一个 Phase

完成后更新 `docs/progress.md`，并输出：修改内容、验证结果、未验证项、偏离计划情况。
```

---

## 阶段 9：前端原型对齐（按需）

```text
如果产品有原型或 C 端 UI，请执行本阶段；否则跳过。

原型：[路径]
前端地址：[地址]

请用浏览器对比原型和实现。

检查：
- 页面结构、信息层级、交互元素、视觉风格、响应式是否一致
- 页面标题与路由 / 菜单一致
- 首屏包含核心业务信息，不是空表格或调试面板
- 查询、筛选、刷新、分页、空状态、错误状态可用
- 操作按钮靠近所属功能区
- 危险操作有确认弹窗
- 自动刷新或倒计时必须真实请求后端
- 弹窗 / 抽屉关闭后状态恢复正确

输出：必须修复项、可接受差异、截图证据。必须修复项为 0 才通过。完成后更新 `docs/progress.md`。
```

---

## 阶段 10：全量 E2E 验收

```text
请按 `.template/specs/02-e2e-acceptance.md` 和项目实际 E2E 规范执行全量验收。

前端地址：[地址]
后端地址：[地址]
测试用户：[账号]
管理员：[账号]

要求：
1. 执行 E2E 前置环境检查
2. 逐条执行核心用户路径
3. 记录页面截图、关键 API 返回、关键数据 ID、Console/Network 结果
4. 按缺陷分级记录 Blocker / Critical / Major / Minor
5. 验收报告写入 `docs/e2e/verify/<topic>-overall-verify.md`
6. 数据链路专项报告写入 `docs/e2e/verify/<topic>-data-flow-verify.md`（如适用）

最终结论只能是：通过 / 有条件通过 / 不通过。
完成后更新 `docs/progress.md` 的最新验证、风险和下一步。
```

---

## 阶段 11：Delivery Report

```text
请按 `.template/specs/03-delivery-report.md` 生成交付报告。

输入：
- Implementation Plan：[路径]
- E2E 验收报告：[路径]
- 相关验证输出：[路径或摘要]

报告必须包含：交付范围、修改摘要、验证摘要、真实证据、风险与未验证项、交付门禁、最终结论。

验证：没有真实证据、缺少未验证项说明、缺少交付门禁、或使用"应该可以"，均不算完成交付。
完成后更新 `docs/progress.md`，并将相关长期事实回写到全量 spec。
```

---

## 通用 Prompt

### 已交付产品增量迭代

```text
我想在已交付的 [产品名称] 上新增 / 修改：[需求描述]。

请先做增量影响分析，不要直接实现。

输出：
1. 需求分类：新功能 / Bug 修复 / 体验优化 / 架构调整 / 数据修正
2. 受影响 spec、页面、接口、数据表、E2E 用例
3. 明确不受影响范围
4. Delta Spec（只描述本次变化，不重写全量文档）
5. 小步实施计划和回归 E2E 范围
6. 判断哪些变化必须回写全量 spec：页面/接口/数据/验收/技术约束等长期事实必须同步回写，临时验证结果只写 verify 或 delivery report
7. 更新 `docs/progress.md` 的当前任务、风险和下一步

未经确认，不要开始写代码。
```

### 代码审查

```text
请审查以下代码变更：[文件或 diff]

重点检查：是否遵守 AGENTS.md、是否过度实现、是否误用 mock、是否遗漏鉴权/错误处理/数据验证、是否缺少真实验证。

输出每个问题的位置、原因和修复建议。
```

### 决策记录

```text
请记录以下决策：[决策问题]

格式：问题、选项、选择、理由、影响范围、相关文件。
```

### Session 恢复

```text
上一个 session 在 [任务] 中断。

已完成：[内容]
进行中：[内容]
未完成：[内容]
问题：[内容]

请读取相关文件后从中断点继续，不要重复已完成工作。
优先读取 `docs/progress.md` 判断当前阶段、已完成、进行中、未完成、阻塞和下一步。
```

### 全量实现（ultracode 模式）

```text
按 docs/ 目录下的设计文档和原型设计实现并完善整个系统。

要求：
1. 严格遵守 CLAUDE.md / AGENTS.md 中的所有约束，不得绕过验证流程。
2. 按 docs/specs/ 已有规格和 docs/research/ 已确认研究结论实现；规格不足的部分先记录假设和决策，不能用未验证的竞品想象替代事实。
3. 遇到决策时，默认按推荐方案或最优实践执行，但必须记录到 docs/decision.md：
   - 决策问题、备选方案、选择、理由、影响范围、相关文件。
4. 每完成一个 Phase 或关键改动，立即验证（构建 + 测试 + E2E），不攒积压。
5. 验证结果写入 docs/e2e/verify/，进度更新到 docs/progress.md。
6. 实现前先读取当前 Phase 直接相关的 spec，不要一次性加载所有文档。

上下文读取顺序：
1. CLAUDE.md 或 AGENTS.md
2. docs/progress.md（判断当前进度和中断点）
3. 当前 Phase 相关的 docs/specs/ 文件和 docs/research/ 研究结论
4. 如有原型，对照原型实现前端

完成后输出：修改内容、验证结果、决策记录、未验证项、偏离规格情况。
```
