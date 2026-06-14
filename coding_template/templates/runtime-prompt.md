# Project Runtime Prompt

> 目的：保存目标项目当前可执行的 AI prompt。本文档由 AI 根据目标项目已有 prompt、`CLAUDE.md` / `AGENTS.md`、`docs/progress.md`、`docs/workflow.yaml` 和实际规格 / 计划生成或更新。
>
> 规则：`.template/prompt.md` 是阶段 prompt 原件，不写项目事实；`docs/prompt.md` 是项目运行态 prompt，可写入项目名、当前 workflow item / 执行层位置、已确认路径、验证命令和下一步指令。

## 元信息

- 项目名称：[项目名称]
- 当前 workflow item：[`docs/workflow.yaml.current`，如 `01-product-spec`；执行层写 `post-90-implementation`]
- 人类可读阶段：[如 Product Spec / Development / Acceptance；以 `docs/workflow.yaml.current` 为准]
- 最近更新时间：[YYYY-MM-DD HH:mm]
- 生成依据：
  - [目标项目已有 prompt 路径，如无写"无"]
  - `CLAUDE.md` / `AGENTS.md`
  - `docs/progress.md`
  - `docs/workflow.yaml`
  - [当前 workflow item / 执行层相关 docs/superpowers/specs 文件]
  - [当前 workflow item / 执行层相关 docs/superpowers/plans 文件，如无写"无"]
  - [当前 workflow item / 执行层相关 docs/research 文件，如无写"无"]

## Prompt 执行台账

> 目的：记录目标项目已经走过哪些 `.template/prompt.md` 阶段 prompt、哪些被跳过、哪些需要人类确认。AI 每次选择、执行、跳过或完成阶段 prompt 后都必须更新本表。
>
> Prompt 状态枚举：`Not Started / In Progress / Needs Review / Done / Skipped / Blocked`
>
> Workflow 生命周期一律以 `docs/workflow.yaml` 为准；Content 状态只写在对应 spec / plan 文件和 `workflow.content_status`。本台账可以展示它们，但不得发明第三套生命周期，也不得把 `Human Confirmed` 当作 Prompt 状态。

| 阶段 Prompt | Prompt 状态 | Workflow item | Workflow 状态 | Content 状态 | 执行时间 | 输入依据 | 输出产物 | 验证结果 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 阶段 1：Idea Brief | Not Started | `00-idea-brief` | [pending / drafting / review / ready / consumed / verified / archived / skipped] | [Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/specs/00-idea-brief.md` | [通过 / 未验证 / 不适用] | [说明] |
| 阶段 2：Product Spec | Not Started | `01-product-spec` | [pending / drafting / review / ready / consumed / verified / archived / skipped] | [Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/specs/01-product-spec.md` | [通过 / 未验证 / 不适用] | [说明] |
| 阶段 3：Domain Research / Data Discovery | Not Started | `05-domain-research` | [pending / drafting / review / ready / consumed / verified / archived / skipped] | [Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/specs/05-domain-research.md` | [通过 / 未验证 / 不适用] | 进入 UX / Architecture 前必须完成或记录跳过原因 |
| 阶段 4：UX / Prototype | Not Started | `10-ux-prototype` | [pending / drafting / review / ready / consumed / verified / archived / skipped] | [Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/specs/10-ux-prototype.md` | [通过 / 未验证 / 不适用] | 按需；跳过必须写原因 |
| 阶段 5：Architecture / System Design | Not Started | `20/30/40/50` | [pending / drafting / review / ready / consumed / verified / archived / skipped] | [Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/specs/20-architecture.md` / `30-data-design.md` / `40-api-and-pages.md` / `50-implementation-constraints.md` | [通过 / 未验证 / 不适用] | 必须引用 research 结论或说明不适用 |
| 阶段 6：E2E Acceptance Spec | Not Started | `02-e2e-acceptance` | [pending / drafting / review / ready / consumed / verified / archived / skipped] | [Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/specs/02-e2e-acceptance.md` | [通过 / 未验证 / 不适用] | [说明] |
| 阶段 7：Implementation Plan | Not Started | `90-implementation-plan` | [pending / drafting / review / ready / consumed / verified / archived / skipped] | [Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/plans/90-implementation-plan.md` | [通过 / 未验证 / 不适用] | 完成后改为 `Archived` 并移动到 `docs/superpowers/plans/archive/` |
| 阶段 8：分阶段开发 | Not Started | 不适用（执行层） | 不适用 | 不适用 | [YYYY-MM-DD HH:mm] | [路径或无] | [代码变更 / 进度记录] | [通过 / 未验证 / 不适用] | [Phase 编号] |
| 阶段 9：前端原型对齐 | Not Started | 不适用（执行层） | 不适用 | 不适用 | [YYYY-MM-DD HH:mm] | [路径或无] | [对齐结果 / 修复项 / 截图证据] | [通过 / 未验证 / 不适用] | 按需；跳过必须写原因 |
| 阶段 10：全量 E2E 验收 | Not Started | 不适用（执行层） | 不适用 | 不适用 | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/e2e/verify/*-verify.md` | [通过 / 有条件通过 / 不通过 / 未验证] | [说明] |
| 阶段 11：Delivery Report | Not Started | `03-delivery-report`（不进 workflow） | 不适用 | [Draft / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | `docs/superpowers/specs/03-delivery-report.md` | [通过 / 未验证 / 不适用] | 一次性交付总结，不作为 workflow item |
| 通用：已交付产品增量迭代 | Not Started | 按需 Delta Spec（不进默认 workflow） | 不适用 | [Draft / Archived] | [YYYY-MM-DD HH:mm] | [路径或无] | [Delta Spec / 回归范围] | [通过 / 未验证 / 不适用] | 按需追加任务编号 |

## 当前推荐 Prompt

```text
[把 `.template/prompt.md` 中当前 workflow item / 执行层对应 prompt 或通用 prompt 改写为目标项目可直接发送的版本。必须替换项目名称、输入文件路径、验证命令、前后端地址、测试账号占位说明和当前 workflow item / 执行层约束。]
```

## 相关上下文

- 必读文件：
  - [文件路径]
- 禁止读取或默认不读取：
  - `.template/reference/`（除非需要方法论参考）
- 当前 workflow item / 执行层输出：
  - [目标输出文件或报告路径]

## 验证与门禁

- 本阶段验证命令：
  - `[命令]`
- E2E 报告路径：
  - `docs/e2e/verify/[报告名].md`
- 不得通过的条件：
  - [缺少真实验证 / 缺少人类确认 / 仍有阻塞项等]

## 更新规则

- 阶段切换后必须更新本文件的"当前推荐 Prompt"。
- 每次选择、执行、跳过或完成阶段 prompt 后，必须更新"Prompt 执行台账"。
- Prompt 状态只记录执行层：标记为 `Needs Review` 必须写明需要人类确认的问题；标记为 `Done` 必须有输出产物；标记为 `Skipped` 必须写明跳过原因；标记为 `Blocked` 必须写明阻塞条件和需要谁确认。
- Workflow 状态必须从 `docs/workflow.yaml` 同步，不得在本表单独推进；Content 状态必须从对应 spec / plan 文件和 `workflow.content_status` 同步，不得把 `Human Confirmed`、`Archived` 写成 Prompt 状态。
- 归档时必须说明文件内状态已改为 `Archived` 且已移动到对应 archive；spec 到 `docs/superpowers/specs/archive/`，plan 到 `docs/superpowers/plans/archive/`。
- 目标项目已有 prompt 变化后，必须重新融合到本文件，不覆盖原有项目约定。
- 长期事实不得只写在本文件；必须同步回写到对应 `docs/superpowers/specs/`、`docs/research/`、`docs/decision.md` 或 `docs/progress.md`。
