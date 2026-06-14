# 文档治理：角色、生命周期与最小维护集

> 目的：回答"一个 AI 协作的项目，到底需要长期维护哪些文档，其余怎么处理"。
> 这是 `ai-product-engineering-workflow.md` 的补充，专门针对文档本身的治理，避免文档堆积成负债。

## 核心问题

很多 AI 驱动的项目会产出大量规格（specs）、设计文档、调研报告，但其中大部分在项目推进中迅速过时，变成**游离文档**——既不是真相（代码才是），又没人维护，反而误导后来者。

本文件给出一套判定与处理规则。

## 三类文档（按"回答什么问题"分，不按"种类"分）

| 类型 | 回答 | 例子 | 维护方式 |
| --- | --- | --- | --- |
| **决策记录（Why）** | 为什么选 A 不选 B？边界是什么？ | `decision.md` (ADR)、技术选型理由、产品边界 | **封存**：append-only，不更新已写决策 |
| **现状真相（What）** | 现在系统有哪些接口？表长什么样？行为如何？ | API、数据模型、业务规则 | **代码即真相**：不手写，由 OpenAPI / ORM+迁移 / 测试承担 |
| **导航与状态（Where/Now）** | 东西在哪？现在到哪了？ | `README`、`progress.md`、`CLAUDE.md`/`AGENTS.md` | **轻量维护**：必须短，长了就不更新了 |

> **游离文档 = 一份被当成"活真相"在用、却没人维护的文档。** 根治办法是让每份文档只承担一个它扛得住的角色。

## specs 的正确定位：脚手架，不是长期资产

本模板里的 `specs/` 和 `plans/`，**是"想清楚"和"拆清楚"的过程产物，不是需要长期维护的资产**。

- 写 spec 的真正价值在"写"这个动作——逼你把模糊想法、设计决策、验收标准想清楚。这个价值在创建时就兑现了。
- 因此 specs 和 plans 在**经人类确认、被后续阶段消费、对应实现/验收验证通过**后，先把文件内状态改为 `Archived`，再移动到各自 archive（git 历史保留），不要试图长期维护它们与代码一致——那是徒劳。
- 特别是 `30-data-design`、`40-api-and-pages` 这类描述"现状"的 spec：现状的真相在代码（ORM / OpenAPI），手写必过时。

## 主流程状态机

`docs/workflow.yaml.current` 是当前 spec / plan item 的权威来源；阶段诊断表、`docs/progress.md` 和 `docs/prompt.md` 只能解释、展示或辅助纠偏，不能各自形成另一套当前阶段真相。

workflow 状态维护过程生命周期：`pending / drafting / review / ready / consumed / verified / archived / skipped`。内容状态维护文件自身可信度：`Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived`。两套状态不能混用：`Human Confirmed` 表示内容经人类确认、可被消费；`archived` 表示该 item 的生命周期结束。

人类 review 是强制 gate：`review → ready`、implementation plan `review → ready`、`verified → archived` 必须经人类确认。归档前必须先把文件内内容状态改为 `Archived`，再按 `docs/workflow.yaml` 的 `archive_path` 移动文件，并同步更新 `docs/workflow.yaml`、`docs/progress.md` 和 `docs/prompt.md` 执行台账。

`docs/workflow.yaml` 跟踪 spec / plan 脚手架到 `90-implementation-plan` 为止。进入代码实现后，进度由 implementation plan 内 task、`docs/progress.md`、验证命令和 `docs/e2e/verify/` 报告跟踪；交付总结由 `03-delivery-report.md` 记录。

## 最小长期维护集

一个项目真正需要长期维护的文档只有：

1. **README** — 项目是什么、怎么跑、入口在哪
2. **decision.md (ADR)** — 为什么这么选（append-only）
3. **progress.md** — 现在到哪、下一步（协作必需，单人短期可省）

加上 **CLAUDE.md / AGENTS.md**（AI 行为约束）。其余要么是代码（接口/数据/行为），要么是写完即弃的脚手架（specs / research）。

## 五条铁律

1. **"现状"类一旦手写，就注定游离。** 接口/数据/行为文档，真相只能是代码或代码生成物（OpenAPI / ORM+迁移 / 测试）。
2. **"决策"类写完即封存。** ADR 是 append-only 历史账本，不更新。
3. **唯一需要手动维护的是导航状态，且必须轻。** 长了就不更新了（progress 验证表堆积就是信号）。
4. **写文档的价值在"写"的动作，不在维护产物。** 早期 spec/设计/计划有必要写，但不要在刚写完时归档；确认、消费、验证后先改状态为 `Archived`，再移动到对应 archive。
5. **文档应被"生成"或"封存"，不应被"更新"。** 只有导航状态例外。

## 判定一份文档去留的三问

1. 删掉它，谁会真正受影响？没人 → 归档或删。
2. 它描述"会变的现状"还是"不变的决策/设计"？会变 → 交给代码。
3. 它被谁、在什么时刻需要？说不出来 → 游离，归档。

## 反模式

- ❌ 把 specs 当长期资产持续维护（它们是脚手架）
- ❌ 手写接口/数据文档并要求"和代码同步"（现状交代码）
- ❌ 用一份手写文档同时承担"决策"+"现状"两个角色
- ❌ README / progress 堆砌全部历史，压垮维护意愿
- ❌ 归档文档留在主索引，误导新人
- ❌ 规格状态机（Draft / Confirmed）没有强制 gate，永远停在"AI Extracted"

## 新项目怎么套用

1. 从模板建 `CLAUDE.md` / `AGENTS.md`（约束）、`decision.md`（空 ADR）、`progress.md`（状态）、`README.md`（导航）。
2. 接口/数据从一开始就用代码当真相（如 FastAPI `/openapi.json` + SQLAlchemy + Alembic），**不要**先写手写接口/数据 spec 再实现。
3. 按模板 prompt 走阶段时，specs 是"想清楚"的工具，plans 是"拆清楚"的工具，确认后供后续阶段消费——别把它们列为"必须长期维护的规格"。
4. 每完成一个阶段/任务，对应 spec 先改状态为 `Archived` 再进 `docs/superpowers/specs/archive/`；对应 plan 先改状态为 `Archived` 再进 `docs/superpowers/plans/archive/`（git 历史是最终 archive）。
5. 每次纠结"这文档要不要更新"，回到上面的三问。
