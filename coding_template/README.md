# Coding Template

> 面向 AI 协作开发的产品工程模板。

## 信息模型：信息只活在一处

AI 协作开发的瓶颈不是代码生成速度，而是**信息对齐**——人、AI、未来的自己之间，能否在需要时获得准确的、不误导的信息。本模板的核心是让每类信息只活在一个天然源头，文档只做**指向**和**思考脚手架**，而不是重复记录。

| 信息源 | 承载 | 维护方式 | 模板 |
| --- | --- | --- | --- |
| **代码** | 现状（接口 / 数据 / 行为） | 代码即真相，零额外维护（OpenAPI / ORM+迁移 / 测试） | — |
| **decision.md** | 为什么（决策与边界） | append-only 封存，不更新已写决策 | `templates/decision.md` |
| **workflow.yaml** | 当前 spec / plan item 与生命周期 | 状态机维护，`current` 是权威 | `templates/workflow.yaml` |
| **README / CLAUDE.md / AGENTS.md** | 导航与约束（指向上面的源） | 改约束 / 入口时同步 | 顶层 |

> 项目实际 `docs/superpowers/specs/` / `docs/superpowers/plans/` 是"想清楚"和"拆清楚"的**思考脚手架**：写的目的是逼你想清楚（价值在创建时兑现）。经人类确认后供后续阶段消费，完成并确认后先把文件内内容状态改为 `Archived`，再移动到各自 archive，不长期维护。现状类信息回写到代码，不留在 spec 或 plan。详见 `reference/documentation-governance.md`。

## 消费场景：谁何时读什么

文档的存在只为一个目的——让对的信息在对的时间到达对的人 / AI。按下表定位，不要通读所有文档：

| 场景 | 读什么 | 产出归到哪 |
| --- | --- | --- |
| 首次接手（新人 / AI） | `README` → `CLAUDE.md`/`AGENTS.md` → `workflow.yaml` → `prompt.md` | — |
| 做技术 / 产品决策 | `decision.md`（历史）+ 代码（现状） | 新决策追加到 `decision.md` |
| 实现某功能 | 代码（现状）+ 相关 ADR（为什么） | 现状写进代码，决策进 `decision.md` |
| 跨 session 恢复 | `workflow.yaml` + `prompt.md` 执行台账 + 活跃 plan / verify 报告 | 更新对应权威文件 |
| 验收 | `e2e-acceptance`（标准）+ 代码（实现） | 验收报告进 `e2e/` |

## 适用场景

当你准备启动一个新产品、新模块或需要 AI 深度参与的软件项目时，可以让 AI 将本模板复制到目标项目中，作为 AI 和人类共同遵守的工程入口。

本模板适合：

- 从零梳理产品想法、MVP 范围和用户路径。
- 让 AI 按阶段生成产品规格、Domain Research / Data Discovery、架构设计、API / 页面映射和实施计划。
- 约束 AI 不要跳过验证、不要用 mock 数据冒充真实验收。
- 将 E2E 验收、缺陷记录和交付报告沉淀为项目文档。

## 文件职责

| 文件 / 目录 | 给谁用 | 职责 |
| --- | --- | --- |
| `README.md` | 人类 | 说明这套模板怎么用。 |
| `AGENTS.md` | AI 工具 | 项目级工程约束入口，适配支持 `AGENTS.md` 的工具。 |
| `CLAUDE.md` | Claude Code | 项目级工程约束入口，适配 Claude Code。 |
| `AI-BOOTSTRAP.md` | AI | AI 首次接手项目时的启动流程：判断阶段、检查缺口、推荐下一步。 |
| `prompt.md` | 人类 / AI | 分阶段 prompt 模板原件，从 idea 到交付，不写项目事实。 |
| `templates/` | AI | 项目运行态文档模板，如决策记录、workflow 状态机和运行态 prompt。 |
| `scripts/` | AI / 人类 | 模板体系校验脚本和校验器负向测试。 |
| `reference/` | 人类 | 方法论参考（含 `documentation-governance.md` 文档治理），不是 AI 每次必须读取的执行上下文。 |

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
│   ├── templates/
│   ├── scripts/
│   └── reference/
├── docs/
│   ├── prompt.md           ← 目标项目运行态 prompt（根据项目自身 prompt 和当前 workflow item 生成）
│   ├── superpowers/
│   │   ├── specs/          ← 项目实际规格（Superpowers 默认 spec 目录）
│   │   │   └── archive/    ← 内容状态已改为 Archived 的历史规格
│   │   └── plans/          ← 项目实际实施计划（Superpowers 默认 plan 目录）
│   │       └── archive/    ← 内容状态已改为 Archived 的历史计划
│   ├── research/           ← 领域调研、竞品、数据来源、数据链路、证据和假设
│   │   ├── competitors/
│   │   ├── data-sources/
│   │   ├── data-lineage/
│   │   ├── user-flows/
│   │   ├── evidence/
│   │   └── assumptions.md
│   ├── e2e/verify/         ← 真实 E2E 验收报告
│   ├── decision.md         ← 决策记录，记录技术、产品和实现取舍
│   └── workflow.yaml       ← 主流程状态机（spec/plan 状态/路径/依赖/触发），见 AI-BOOTSTRAP §0
```

其中：

- `.template/` 保存模板原件，不写项目事实。AI 读取 `.template/AI-BOOTSTRAP.md` 启动诊断。默认建议随项目入库，确保新环境 clone 后仍能使用模板。
- `docs/prompt.md` 保存目标项目运行态 prompt，由 AI 根据目标项目已有 prompt、项目约束、`docs/workflow.yaml.current` 和当前相关 specs / plans / research 生成；已有则补充更新，不覆盖项目原有约定。
- `docs/superpowers/specs/` 保存目标项目补全后的规格。**这些是脚手架（过程产物），经人类确认后供后续阶段消费，完成并确认后先改内容状态为 `Archived`，再移动到 `docs/superpowers/specs/archive/`**（详见 `reference/documentation-governance.md`）；接口 / 数据真相以代码为准（OpenAPI / ORM），不手写。
- `docs/superpowers/plans/` 保存目标项目补全后的实施计划，完成并确认后先改内容状态为 `Archived`，再移动到 `docs/superpowers/plans/archive/`。
- `docs/research/` 保存目标项目的领域调研、竞品、数据来源、数据链路、用户闭环、证据和待确认假设；主产物为 `docs/superpowers/specs/05-domain-research.md`。
- `CLAUDE.md` / `AGENTS.md` 放在项目根目录，供 AI 工具自动发现。

## 最小使用流程

1. 在 AI 工具中发送启动 Prompt（见下方），AI 会将 `coding_template/` 复制到目标项目的 `.template/` 目录。
2. AI 检查 `.gitignore` 不应忽略 `.template/`；如果团队明确要求模板原件不入库，必须在 `docs/decision.md` 记录模板源路径和重新安装方式。
3. AI 检查根目录 `CLAUDE.md` / `AGENTS.md`：不存在则根据项目代码创建，已存在则补充缺失章节。
4. AI 从 `.template/templates/` 创建 `docs/decision.md`、`docs/prompt.md` 和 `docs/workflow.yaml`，并创建 `docs/superpowers/specs/`、`docs/superpowers/plans/`、`docs/research/`；`docs/prompt.md` 必须融合目标项目自身已有 prompt。
5. AI 运行 `.template/scripts/validate-template.sh .template` 检查模板体系。
6. AI 根据 `AI-BOOTSTRAP.md` 输出项目阶段、文档缺口、验证条件，并把 `.template/prompt.md` 中对应阶段改写进 `docs/prompt.md`。
7. 你确认后，按 `docs/prompt.md` 中的当前推荐 prompt 生成或补齐规格。
8. 每个 spec / plan 阶段完成后写入对应规格或计划，并更新 `docs/workflow.yaml` 和 `docs/prompt.md` 执行台账；进入执行层后更新 implementation plan task、验证报告、交付报告和 `docs/prompt.md` 执行台账。

## 标准闭环流程

目标项目启动后，AI 和人类按同一条主线推进：

1. `docs/workflow.yaml.current` 决定当前 spec / plan item、依赖、产物路径和归档路径。
2. `docs/prompt.md` 给出当前可执行 prompt，输入必须来自项目约束、`docs/workflow.yaml`、当前相关 specs / plans / research。
3. AI 使用 Superpowers 对应 skill 产出当前 spec 或 plan，并写入 `docs/superpowers/specs/` 或 `docs/superpowers/plans/`。
4. 产出完成后 workflow 进入 `review`，人类确认后进入 `ready`，文件内容状态可标记为 `Human Confirmed`。
5. 后续阶段开始使用该产物后进入 `consumed`；对应实现、验收或下游产物验证通过后进入 `verified`。
6. 完成并经人类确认后，先把文件内内容状态改为 `Archived`，再移动到 `artifact_path` 对应的 `archive_path`。
7. 每次状态变化都必须同步更新 `docs/workflow.yaml` 和 `docs/prompt.md` 的执行台账。

`docs/workflow.yaml` 默认只跟踪到 `90-implementation-plan`。阶段 8-11 属于执行层，按 implementation plan task、`docs/prompt.md` 执行台账、`docs/e2e/verify/` 和交付报告跟踪；`03-delivery-report` 是一次性交付总结，不进入 workflow，完成并确认后仍按 spec 归档到 `docs/superpowers/specs/archive/`。

按需阶段不能静默跳过。以 UX / Prototype 为例：如果产品不涉及 C 端体验、复杂页面、视觉设计或可交互原型，必须把 `10-ux-prototype` 标记为 `skipped` 并写明原因；否则 `20-architecture` 不能继续。

## 持续优化 Loop（已有项目优先）

对于已有代码库上的增量改造、重构、工具层重做和长期持续优化，模板默认优先使用持续优化 Loop：

1. 先写 `Phase00-main` 总控 spec，定义最终目标和最终验收标准
2. 再拆 `Phase01+` spec，明确依赖关系和编号
3. 每个 Phase 单独写 plan
4. 每个 Phase 完成后写 verify 报告
5. 任务状态变化后同步更新对应 spec / plan、`docs/workflow.yaml` 和 `docs/prompt.md`
6. 未达到最终验收标准前不得停止，除非连续三轮自救失败并进入 `blocked`

命名规则：

- `docs/superpowers/specs/YYYY-MM-DD-Phase00-[topic]-main.md`
- `docs/superpowers/specs/YYYY-MM-DD-PhaseNN-[topic].md`
- `docs/superpowers/plans/YYYY-MM-DD-PhaseNN-[topic]-plan.md`
- `docs/e2e/verify/YYYY-MM-DD-PhaseNN-[topic]-verify.md`

## AI 启动 Prompt

```text
请先读取 `@coding_template/AI-BOOTSTRAP.md` 或项目中的 `.template/AI-BOOTSTRAP.md`，不要直接实现。

如果项目中没有 `.template/` 目录，请先将 `coding_template/` 整体复制到项目的 `.template/` 目录，
检查 `.gitignore` 不应忽略 `.template/`。如果团队要求模板不入库，必须记录模板源和重装方式。

然后检查根目录的 CLAUDE.md 和 AGENTS.md：
- 如果不存在，从 `.template/` 复制到根目录，并根据项目代码替换 [变量]。
- 如果已存在，不要覆盖，只补充缺失章节。

然后从 `.template/templates/` 创建 docs/decision.md、docs/prompt.md 和 docs/workflow.yaml（已存在则不要覆盖，只补充缺失结构），并创建 docs/superpowers/specs/、docs/superpowers/specs/archive/、docs/superpowers/plans/、docs/superpowers/plans/archive/ 和 docs/research/。
docs/prompt.md 必须根据目标项目自身已有 prompt、CLAUDE.md / AGENTS.md、docs/workflow.yaml、docs/superpowers/specs/、docs/superpowers/plans/、docs/research/ 和当前 workflow item 相关规格生成。

按 AI-BOOTSTRAP.md 要求判断当前项目阶段，检查必要文档和验证条件，列出缺口，
并推荐下一步应该使用 `.template/prompt.md` 中的哪个阶段 prompt，同时写入或更新 docs/prompt.md 的当前推荐 prompt。安装或反填完成后先暂停，等待我确认后再进入下一阶段。

如果是已有项目（有代码或文档），按 §3B 从项目现有信息中提取内容反填模板。

只读取判断阶段所需的最少文档，进入实现阶段后再按需读取相关 spec。

如果存在 `.template/scripts/validate-template.sh`，请运行它检查模板体系。
```

## 使用原则

- `CLAUDE.md` / `AGENTS.md` 只放全局约束和索引，不内联复杂规格。
- 具体产品、页面、架构和验收标准写入 `docs/superpowers/specs/`（脚手架，经确认后消费，完成并确认后改为 `Archived` 再归档）；实施计划写入 `docs/superpowers/plans/`，完成并确认后归档到 `docs/superpowers/plans/archive/`。**接口与数据真相以代码为准**（OpenAPI / ORM），不手写逐字段 / 逐接口 schema。
- 领域调研、竞品、数据来源、数据链路、用户闭环、证据和待确认假设写入 `docs/research/`；确认后的长期事实再回写到对应 spec。
- `AI-BOOTSTRAP.md` 用于判断"现在该做什么"，不是替代 `prompt.md`。
- `.template/prompt.md` 用于驱动阶段产出，不保存项目事实。
- `docs/prompt.md` 是目标项目运行态 prompt，必须根据目标项目自身 prompt 和当前 workflow item 生成；它不能替代长期规格。
- `.template/reference/` 只在需要理解方法论时阅读，默认不进入 AI 工作上下文。
- E2E 验收报告统一写入 `docs/e2e/verify/`。
- `docs/decision.md` 用于记录产品、技术、实现和验证中的重要取舍。
- `.template/scripts/validate-template.sh` 用于检查模板体系本身是否完整。
- `.template/scripts/test-validate-template.sh` 用于验证校验器能拦住 workflow 断环、错误归档路径和非法状态。

## 主线产物顺序

核心必备：

1. `docs/superpowers/specs/00-idea-brief.md`
2. `docs/superpowers/specs/01-product-spec.md`
3. `docs/superpowers/specs/02-e2e-acceptance.md`
4. `docs/superpowers/specs/03-delivery-report.md`

研究 / 数据发现：

- `docs/superpowers/specs/05-domain-research.md`

按需使用：

- `docs/superpowers/specs/10-ux-prototype.md`
- `docs/superpowers/specs/20-architecture.md`
- `docs/superpowers/specs/30-data-design.md`
- `docs/superpowers/specs/40-api-and-pages.md`
- `docs/superpowers/specs/50-implementation-constraints.md`
- `docs/superpowers/plans/90-implementation-plan.md`

是否"按需"由项目复杂度决定，不由 AI 为了加快实现自行跳过。凡涉及数据库、外部服务、权限、支付、额度、异步任务、复杂前后端接口、多角色流程或生产数据链路，进入 UX / Architecture 前必须先完成或明确跳过 `05-domain-research.md`，进入实施计划前必须至少补齐 `20/30/40/50` 中对应的设计规格。

## 注意事项

- 不要让 AI 直接从 idea 跳到实现。
- 不要让 AI 在没有 `docs/superpowers/specs/05-domain-research.md` 或明确跳过理由的情况下直接进入 Architecture / System Design。
- 不要用 mock / 静态数据作为最终 E2E 通过依据。
- 不要把项目专属的大段业务规则写回模板入口文件。
- 不要把目标项目事实写入 `.template/prompt.md`；项目化 prompt 写入 `docs/prompt.md`。
- 模板复制到项目后，应把 `[变量]` 替换成真实项目内容。
- 已有项目可以让 AI 从代码和配置中提取信息反填模板，不必全部手动填写。
- 增量迭代先写 Delta Spec；如果变化影响长期事实（页面、接口、数据模型、验收标准、技术约束），必须同步回写对应全量 spec。
- 每个 spec 和 plan 必须维护内容状态：`Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived`。`Human Confirmed` 只表示内容经人类确认、可被后续阶段消费，不等于可以立即归档；归档前必须先把文件内内容状态改为 `Archived`，再移动到对应 archive。workflow 状态由 `docs/workflow.yaml` 维护：`pending / drafting / review / ready / consumed / verified / archived / skipped`。按需阶段如 UX / Prototype 不适用，必须标记为 `skipped` 并写明原因，不能让后续阶段静默绕过。
- 阶段切换、长任务中断、E2E 验收和交付前后必须更新 `docs/prompt.md` 执行台账；实现任务进度写入 active implementation plan，验证证据写入 `docs/e2e/verify/`。
