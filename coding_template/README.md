# Coding Template

> 面向 AI 协作开发的产品工程模板。用于从 idea 到规格、架构、实施计划、真实 E2E 验收和交付报告，逐步沉淀可执行上下文。

## 适用场景

当你准备启动一个新产品、新模块或需要 AI 深度参与的软件项目时，可以让 AI 将本模板复制到目标项目中，作为 AI 和人类共同遵守的工程入口。

本模板适合：

- 从零梳理产品想法、MVP 范围和用户路径。
- 让 AI 按阶段生成产品规格、架构设计、API / 页面映射和实施计划。
- 约束 AI 不要跳过验证、不要用 mock 数据冒充真实验收。
- 将 E2E 验收、缺陷记录和交付报告沉淀为项目文档。

## 文件职责

| 文件 / 目录 | 给谁用 | 职责 |
| --- | --- | --- |
| `README.md` | 人类 | 说明这套模板怎么用。 |
| `AGENTS.md` | AI 工具 | 项目级工程约束入口，适配支持 `AGENTS.md` 的工具。 |
| `CLAUDE.md` | Claude Code | 项目级工程约束入口，适配 Claude Code。 |
| `AI-BOOTSTRAP.md` | AI | AI 首次接手项目时的启动流程：判断阶段、检查缺口、推荐下一步。 |
| `prompt.md` | 人类 / AI | 分阶段 prompt 驱动器，从 idea 到交付。 |
| `specs/` | 人类 / AI | 各阶段规格模板，按需复制和补全。 |
| `templates/` | AI | 项目运行态文档模板，如决策记录和进度记录。 |
| `scripts/` | AI / 人类 | 模板体系校验脚本。 |
| `reference/` | 人类 | 方法论参考，不是 AI 每次必须读取的执行上下文。 |

`CLAUDE.md` 和 `AGENTS.md` 内容默认保持一致，只是适配不同 AI 工具的自动发现入口。修改其中一个时，必须同步另一个；如果项目只使用其中一种工具，也应在另一个文件顶部说明它由谁同步或不再使用。

## 目标项目结构

AI 将本模板复制到目标项目后，形成以下结构：

```text
your-project/
├── CLAUDE.md               ← 从 .template/ 复制到根目录（AI 工具自动发现）
├── AGENTS.md               ← 从 .template/ 复制到根目录（AI 工具自动发现）
├── .template/              ← 整个 coding_template/ 的副本
│   ├── AI-BOOTSTRAP.md
│   ├── CLAUDE.md
│   ├── AGENTS.md
│   ├── prompt.md
│   ├── specs/
│   ├── templates/
│   ├── scripts/
│   └── reference/
├── docs/
│   ├── specs/              ← 项目实际规格（从模板补全后存入）
│   ├── e2e/verify/         ← 真实 E2E 验收报告
│   ├── decision.md         ← 决策记录，记录技术、产品和实现取舍
│   └── progress.md         ← 当前阶段、任务进度、验证状态和下一步
```

其中：

- `.template/` 保存模板原件，不写项目事实。AI 读取 `.template/AI-BOOTSTRAP.md` 启动诊断。默认建议随项目入库，确保新环境 clone 后仍能使用模板。
- `docs/specs/` 保存目标项目实际补全后的规格，是开发和验收时读取的主要上下文。
- `docs/progress.md` 保存跨 session 的当前状态，长任务中断、阶段切换和交付前后必须更新。
- `CLAUDE.md` / `AGENTS.md` 放在项目根目录，供 AI 工具自动发现。

## 最小使用流程

1. 在 AI 工具中发送启动 Prompt（见下方），AI 会将 `coding_template/` 复制到目标项目的 `.template/` 目录。
2. AI 检查 `.gitignore` 不应忽略 `.template/`；如果团队明确要求模板原件不入库，必须在 `docs/decision.md` 记录模板源路径和重新安装方式。
3. AI 检查根目录 `CLAUDE.md` / `AGENTS.md`：不存在则根据项目代码创建，已存在则补充缺失章节。
4. AI 从 `.template/templates/` 创建 `docs/decision.md` 和 `docs/progress.md`。
5. AI 运行 `.template/scripts/validate-template.sh .template` 检查模板体系。
6. AI 根据 `AI-BOOTSTRAP.md` 输出项目阶段、文档缺口、验证条件和推荐 prompt，并暂停等待你确认。
7. 你确认后，按 `.template/prompt.md` 中对应阶段的 prompt 生成或补齐规格。
8. 每个阶段完成后写入对应规格、验证报告或交付报告，并更新 `docs/progress.md`。

## AI 启动 Prompt

```text
请先读取 `@coding_template/AI-BOOTSTRAP.md` 或项目中的 `.template/AI-BOOTSTRAP.md`，不要直接实现。

如果项目中没有 `.template/` 目录，请先将 `coding_template/` 整体复制到项目的 `.template/` 目录，
检查 `.gitignore` 不应忽略 `.template/`。如果团队要求模板不入库，必须记录模板源和重装方式。

然后从 `.template/templates/` 创建 docs/decision.md 和 docs/progress.md（已存在则不要覆盖，只补充缺失结构）。

然后检查根目录的 CLAUDE.md 和 AGENTS.md：
- 如果不存在，从 `.template/` 复制到根目录，并根据项目代码替换 [变量]。
- 如果已存在，不要覆盖，只补充缺失章节。

按 AI-BOOTSTRAP.md 要求判断当前项目阶段，检查必要文档和验证条件，列出缺口，
并推荐下一步应该使用 `.template/prompt.md` 中的哪个阶段 prompt。安装或反填完成后先暂停，等待我确认后再进入下一阶段。

如果是已有项目（有代码或文档），按 §3B 从项目现有信息中提取内容反填模板。

只读取判断阶段所需的最少文档，进入实现阶段后再按需读取相关 spec。

如果存在 `.template/scripts/validate-template.sh`，请运行它检查模板体系。
```

## 使用原则

- `CLAUDE.md` / `AGENTS.md` 只放全局约束和索引，不内联复杂规格。
- 具体产品、页面、接口、数据、架构和验收标准写入 `docs/specs/`。
- `AI-BOOTSTRAP.md` 用于判断"现在该做什么"，不是替代 `prompt.md`。
- `prompt.md` 用于驱动阶段产出，不保存项目事实。
- `.template/reference/` 只在需要理解方法论时阅读，默认不进入 AI 工作上下文。
- E2E 验收报告统一写入 `docs/e2e/verify/`。
- `docs/decision.md` 用于记录产品、技术、实现和验证中的重要取舍。
- `docs/progress.md` 用于记录当前阶段、已完成、进行中、未完成、阻塞、验证和下一步。
- `.template/scripts/validate-template.sh` 用于检查模板体系本身是否完整。

## 规格模板顺序

核心必备：

1. `00-idea-brief.md`
2. `01-product-spec.md`
3. `02-e2e-acceptance.md`
4. `03-delivery-report.md`

按需使用：

- `10-ux-prototype.md`
- `20-architecture.md`
- `30-data-design.md`
- `40-api-and-pages.md`
- `50-implementation-constraints.md`
- `90-implementation-plan.md`

是否"按需"由项目复杂度决定，不由 AI 为了加快实现自行跳过。凡涉及数据库、外部服务、权限、支付、额度、异步任务、复杂前后端接口或多角色流程，进入实施计划前必须至少补齐 `20/30/40/50` 中对应的设计规格。

## 注意事项

- 不要让 AI 直接从 idea 跳到实现。
- 不要用 mock / 静态数据作为最终 E2E 通过依据。
- 不要把项目专属的大段业务规则写回模板入口文件。
- 模板复制到项目后，应把 `[变量]` 替换成真实项目内容。
- 已有项目可以让 AI 从代码和配置中提取信息反填模板，不必全部手动填写。
- 增量迭代先写 Delta Spec；如果变化影响长期事实（页面、接口、数据模型、验收标准、技术约束），必须同步回写对应全量 spec。
- 每个 spec 必须维护规格状态：`Draft / AI Extracted / Human Confirmed / Frozen / Deprecated`。
- 阶段切换、长任务中断、E2E 验收和交付前后必须更新 `docs/progress.md`。
