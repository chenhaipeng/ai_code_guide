# AI Bootstrap 入口模板

> 目的：让 AI 进入一个新项目后，先判断当前 workflow item / 执行层位置，再按模板体系补齐缺口，并向人类推荐下一步 prompt。
>
> 使用方式：AI 读取本文件后，按指引执行初始化或阶段判断。本文件通常位于项目 `.template/` 目录。

---

**⚠️ 前置检查：** 如果当前项目没有 `.template/` 目录，AI **必须**先执行以下操作，不要跳过：

1. 将本文件所在的 `coding_template/` 目录整体复制到目标项目的 `.template/`。
2. 检查目标项目的 `.gitignore` 不应忽略 `.template/`。默认建议 `.template/` 随项目入库，确保新环境 clone 后仍能使用 prompt 和 spec 模板；如果团队明确要求模板不入库，必须创建 `docs/decision.md` 后记录模板源路径和重新安装方式。
3. 检查目标项目根目录是否已有 `CLAUDE.md` 或 `AGENTS.md`：
   - **不存在**：从 `.template/` 复制到根目录，然后根据目标项目的代码结构、配置文件和已有文档，替换模板中的 `[变量]`（至少补齐项目定位、技术方向和本地开发环境）。
   - **已存在**：**不要覆盖**。读取已有内容，根据目标项目实际情况补充缺失的章节（如缺少技术方向、开发环境、验证标准等），保留项目原有的约定和规则不变。
4. 创建 `docs/superpowers/specs/`、`docs/superpowers/specs/archive/`、`docs/superpowers/plans/`、`docs/superpowers/plans/archive/`、`docs/research/` 和 `docs/e2e/verify/` 目录。
5. 从 `.template/templates/decision.md` 创建 `docs/decision.md`，从 `.template/templates/runtime-prompt.md` 创建或更新 `docs/prompt.md`，从 `.template/templates/workflow.yaml` 创建或更新 `docs/workflow.yaml`；已存在则不要覆盖，只补充缺失结构。
   - `docs/prompt.md` 必须根据目标项目自身已有 prompt、`CLAUDE.md` / `AGENTS.md`、`docs/workflow.yaml`、`docs/superpowers/specs/`、`docs/superpowers/plans/`、`docs/research/` 和当前 workflow item 相关规格生成。
6. 如存在 `.template/scripts/validate-template.sh`，运行它检查 `.template/`。

完成后再继续阅读下方内容。

---

## 0. 方法论主线（AI 先读，贯穿全程）

> 核心原则与主流程。AI 接手任何项目先按这节理解全局；§1-§11 是诊断和执行细节。

### 主流程闭环

AI 按 `.template/prompt.md` 主线推进，每个 spec / plan 走完整闭环：

```text
workflow: pending → drafting → review → ready → consumed → verified → archived
content : Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived
```

`ready` 是 workflow 状态，`Human Confirmed` 是内容状态；两套状态不得混用。Superpowers 负责每类工作的执行纪律，不负责决定产品主线：构思/规格阶段用 brainstorming，实施计划用 writing-plans，开发按计划使用 TDD、review、debugging 和 verification 相关 skill。当前 spec / plan item、依赖和下一步以 `docs/workflow.yaml.current`、`depends_on` 和 `triggers` 为准；`docs/prompt.md` 只提供运行态 prompt 和 Prompt 执行台账。

### 三条铁律

1. **信息只活在一处**：现状(接口/数据/行为)→代码；决策→`decision.md`；当前 spec / plan item 和生命周期→`workflow.yaml`；prompt 执行状态→`prompt.md` 执行台账；实现任务→active implementation plan；验证证据→`docs/e2e/verify/`。文档只指向，不重复记录。
2. **spec / plan 是想清楚的脚手架**：产出必要(逼思考)，经人类确认后可被后续阶段使用；使命完成后先把文件内容状态改为 `Archived`，再移动到对应 archive，不长期维护；现状不抄进 spec 或 plan。
3. **验证 gate 驱动前进**：每步 verify 通过才进下一步；"应该可以"不算通过。

### 产出归位（每次产出按此自检）

| 产出是... | 归到 | 不归到 |
| --- | --- | --- |
| 接口字段/schema、表字段/索引、业务规则 | **代码**(OpenAPI / ORM / 测试) | spec |
| 为什么选 A 不选 B | `decision.md` | spec |
| 当前 spec / plan item、生命周期、依赖 | `workflow.yaml` | spec / prompt |
| prompt 阶段执行状态、跳过原因、阻塞 | `prompt.md` 执行台账 | workflow |
| 实现任务进度 | active implementation plan task | 独立进度摘要 |
| 验证证据 | `docs/e2e/verify/` | prompt / spec |
| 产品边界 / 体验决策 | spec(设计快照) | — |

这里的"归位"只表示不要把长期事实留在活跃 spec 或 plan 里：接口/数据/行为进入代码或代码生成物，重要取舍进入 `docs/decision.md`，当前 spec / plan item 进入 `docs/workflow.yaml`，prompt 执行状态进入 `docs/prompt.md` 执行台账，验证证据进入 `docs/e2e/verify/`。归档动作本身必须明确执行：完成并经人类确认后，先把文件内内容状态改为 `Archived`，再移动到对应 archive。`Human Confirmed` 只表示该 spec 或 plan 内容经人类确认、可被后续阶段消费，不等于可以立即归档。

归档目录规则：

- 阶段 spec：`docs/superpowers/specs/` → `docs/superpowers/specs/archive/`
- Implementation plan：`docs/superpowers/plans/` → `docs/superpowers/plans/archive/`
- 研究证据如需归档：`docs/research/` → `docs/research/archive/`，但仍被当前设计引用的研究材料不要提前归档。

### 主流程状态机（`docs/workflow.yaml`）

跟踪主线各 spec / plan 的状态、依赖、文件路径和触发。**AI 完成一个 spec 或 plan 必须更新本文件**——状态机转移不能只在上下文里(跨 session 会丢)，必须写回 `workflow.yaml`。

`docs/workflow.yaml.current` 为权威当前 item；`docs/prompt.md` 执行台账和 §5 阶段判断只能解释现状或辅助纠偏，不能覆盖 `current`。

`docs/workflow.yaml` 跟踪 spec / plan 脚手架生命周期，默认到 `90-implementation-plan` 为止；进入代码实现后，进度由 `90-implementation-plan` 内 task、`docs/prompt.md` 执行台账、验证命令和 `docs/e2e/verify/` 报告跟踪。`03-delivery-report` 是一次性交付总结，不进入 workflow 状态机。

**workflow 状态**：`pending` → `drafting` → `review` → `ready` → `consumed` → `verified` → `archived`；按需阶段不适用时可标记为 `skipped`，但必须写明跳过原因。

**spec / plan 内容状态**：`Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived`。两套状态不要混用：`Human Confirmed` 是内容确认，`archived` 是流程生命周期结束。

**workflow item 必填字段**：`id`、`type`（`spec` 或 `plan`）、`artifact_path`、`archive_path`、`status`、`content_status`、`depends_on`、`triggers`。AI 不得只靠文件名推断归档目录。

**转移规则**（完成一个 spec 或 plan 时强制执行）：

1. AI 产出 spec 并完成自检 → `review`，请求人类 review。
2. 人类确认后，spec 内容状态标记为 `Human Confirmed`，workflow 状态转为 `ready`。
3. 后续阶段或实现开始使用该 spec 后 → `consumed`；依赖判断以 `ready` 或 `consumed` 为可用状态，不必等 `archived`。
4. 对应代码、验收或下游产物验证通过 → `verified`。
5. 完成并经人类确认后，先把文件内内容状态改为 `Archived`，再移动到对应 archive：spec 到 `docs/superpowers/specs/archive/`，plan 到 `docs/superpowers/plans/archive/`。
6. 扫描该 spec / plan 的 `triggers`，把其中"所有 `depends_on` 都达到 `ready` 或更后状态，或已明确 `skipped`"的 `pending` item → `drafting`。
7. `current` = 新激活的 item；写回 `workflow.yaml`。

人类 review 的强制点：spec 从 `review` 到 `ready`、实施计划从 `review` 到 `ready`、验证完成后从 `verified` 到 `archived`。按需阶段跳过时必须在 `docs/prompt.md` 执行台账写明原因；例如 UX 不适用时，先把 `10-ux-prototype` 标记为 `skipped`，`20-architecture` 才能继续。其余小步状态更新由 AI 写入对应权威文件：workflow 状态写 `docs/workflow.yaml`，prompt 执行状态写 `docs/prompt.md`，实现任务写 active plan task，验证证据写 `docs/e2e/verify/`。归档时必须同步更新 `docs/workflow.yaml` 和 `docs/prompt.md` 的执行台账。

### 持续优化 Loop 主线

当项目目标是已有代码库上的增量改造、重构、工具层重做或长期持续优化时，默认优先选择持续优化 Loop，而不是从 `00-idea-brief` 开始的产品交付主线。

持续优化 Loop 的权威入口是：

- `docs/superpowers/specs/YYYY-MM-DD-Phase00-[topic]-main.md`
- `docs/superpowers/specs/YYYY-MM-DD-PhaseNN-[topic].md`
- `docs/superpowers/plans/YYYY-MM-DD-PhaseNN-[topic]-plan.md`
- `docs/e2e/verify/YYYY-MM-DD-PhaseNN-[topic]-verify.md`

Loop 停止条件只有两种：

1. 达到 `Phase00-main` 中定义的最终验收标准
2. 连续三轮自救失败并进入 `blocked`

AI 不得以“主要功能差不多了”或“测试大部分通过”作为停止理由。Loop 默认仍由 Superpowers 执行具体工作：先用 brainstorming 产出总控或关键 Phase 设计，再用 writing-plans 产出对应 Phase plan，执行阶段继续使用 TDD、debugging、verification 和 review 相关 skill。

### 长期只维护

`README` + `decision.md` + `workflow.yaml` + `prompt.md` 执行台账（+ `CLAUDE.md`/`AGENTS.md`）。其余(spec / research / plan / verify)是过程产物或验证证据，确认、消费并验证后先改内容状态再归档。

> 阶段诊断见 §5；执行某 spec 时用对应 superpowers 技能，产出按归位规则，状态转移按上面的状态机。

---

## 1. 模板体系总览

本模板不是单个 prompt，而是一套从想法到交付的分层上下文系统：

```text
CLAUDE.md / AGENTS.md   ->  全局工程约束和 AI 行为边界（项目根目录）
.template/               ->  模板原件目录（AI-BOOTSTRAP + prompt + spec 模板 + reference，默认入库）
  AI-BOOTSTRAP.md        ->  本文件，AI 首次接手时判断项目阶段和文档缺口
  prompt.md              ->  按阶段驱动 AI 生成规格、计划、实现和验收
  templates/             ->  项目运行态文档模板，如 decision / runtime-prompt / workflow
  scripts/               ->  模板体系校验脚本
  reference/             ->  方法论参考，默认不进入 AI 工作上下文
docs/prompt.md           ->  项目运行态 prompt，根据目标项目自身 prompt 和当前 workflow item 生成
docs/superpowers/specs/              ->  规格脚手架(过程产物)，完成后归档到 docs/superpowers/specs/archive/；现状真相以代码为准
docs/superpowers/plans/              ->  实施计划脚手架(过程产物)，完成后归档到 docs/superpowers/plans/archive/
docs/research/           ->  领域调研、数据发现、证据、假设和后续设计引用
docs/e2e/verify/         ->  真实 E2E 验收报告
docs/decision.md         ->  决策记录，记录重要产品、技术、实现和验证取舍
docs/workflow.yaml       ->  当前 spec / plan item、生命周期、依赖和归档路径
```

规格编号和执行阶段不是同一件事：

- `00-03` 是核心必备规格，表示任何产品都应最终具备这些文档。
- `05` 是研究与数据发现规格，用于在 UX 和系统设计前沉淀 `docs/superpowers/specs/05-domain-research.md`；支撑证据写入 `docs/research/`。
- `10-50` 是按需设计规格，只有涉及对应复杂度时才使用。
- `90` 是实施计划规格，通常在产品、架构和验收定义之后生成。
- 实际执行顺序由 `docs/workflow.yaml.current`、`depends_on` 和 `triggers` 决定；§5 只用于阶段解释、初始化和纠偏。

工程化必备产物：

- `.template/` 默认随项目入库，不写入 `.gitignore`；如团队要求不入库，必须在 `docs/decision.md` 记录模板源和重装方式。
- `.template/templates/` 必须包含运行态文档模板，至少覆盖 `decision.md`、`runtime-prompt.md` 和 `workflow.yaml`。
- `.template/scripts/` 必须包含模板校验入口，默认使用 `validate-template.sh`。
- `docs/decision.md` 记录长期决策，按 `.template/templates/decision.md` 创建或补齐。
- `docs/prompt.md` 记录目标项目当前可执行 prompt，按 `.template/templates/runtime-prompt.md` 创建或补齐，并融合目标项目已有 prompt。
- `docs/workflow.yaml` 记录主流程状态机，按 `.template/templates/workflow.yaml` 创建或补齐。
- `docs/research/` 记录领域调研、竞品、数据来源、数据链路、用户闭环、证据和待确认假设；Domain Research spec 主产物为 `docs/superpowers/specs/05-domain-research.md`。
- 所有 `docs/superpowers/specs/*.md` 项目实际规格和 `docs/superpowers/plans/*.md` 项目实际计划必须维护内容状态：`Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived`。
- 模板安装、模板修改或交付前，如存在 `.template/scripts/validate-template.sh`，必须运行 `.template/scripts/validate-template.sh .template`。

冲突处理优先级：

1. 人类当前明确指令。
2. `CLAUDE.md` / `AGENTS.md` 中的项目级约束。
3. `docs/superpowers/specs/` 中已补全的项目实际规格和 `docs/superpowers/plans/` 中已补全的项目实际计划。
4. `docs/prompt.md` 中的项目运行态 prompt。
5. `.template/prompt.md` 中的阶段驱动要求。
6. `.template/reference/` 中的方法论参考。

如果上述内容互相冲突，AI **必须**指出冲突并请求人类确认，不能自行选择对自己方便的解释。

---

## 2. 启动原则

AI 进入项目后，**不要**立刻实现功能。必须先完成三件事：

1. 判断 `docs/workflow.yaml.current` 指向哪个 spec / plan item；若已进入阶段 8-11，则判断执行层位置。
2. 检查项目是否具备必要文档和验证条件。
3. 根据目标项目自身 prompt 生成或更新 `docs/prompt.md`，向人类说明下一步推荐使用哪个 prompt，并请求确认。

如果当前任务是已有项目的增量改造，先判断是否应创建 `Phase00-main`，而不是直接进入实现阶段；只有在总控目标、最终验收标准和 Phase 依赖关系已经明确存在时，才允许跳过这一步。

在 bootstrap 诊断阶段，只读取判断当前 workflow item / 执行层位置所需的最少文档，避免无关 spec 干扰阶段判断。进入实现阶段后，可按需读取当前 task 直接相关的 spec / plan / research，不受此限制。

模板是起点不是目标。AI 应根据项目实际情况调整模板内容和结构，不要机械照搬：

- 已有文档能覆盖的内容，引用而不重写。
- 项目不适用的 spec，跳过并在 `CLAUDE.md` / `AGENTS.md` 中说明。
- 从代码和配置中提取信息反填模板，减少人类手动填写。
- 根据目标项目已有 prompt、`docs/workflow.yaml.current` 和已确认文档生成 `docs/prompt.md`，不要把项目事实写回 `.template/prompt.md`。
- 不阻塞当前工作的缺口，记录为待补项而非阻断项。
- 阶段切换、长任务中断、E2E 验收和交付前后，更新 `docs/prompt.md` 执行台账；实现任务状态写 active implementation plan，验证证据写 `docs/e2e/verify/`。

---

## 3. 项目初始化

AI 进入项目后，先判断项目是否已有 `.template/` 目录，再选择对应的初始化路径：

### 3A. 模板安装（项目无 .template/ 目录）

当项目缺少 `.template/` 目录时，AI **必须**先将模板安装到项目中，不要直接进入阶段判断。

**安装步骤：**

1. 找到模板源目录。如果用户通过 `@coding_template/AI-BOOTSTRAP.md` 启动，模板源是 `coding_template/`。否则询问人类提供模板源路径。
2. 将整个模板源目录复制到目标项目的 `.template/`。
3. 创建 `docs/superpowers/specs/` 和 `docs/superpowers/specs/archive/`，用于保存项目实际规格和已完成规格。
4. 创建 `docs/superpowers/plans/` 和 `docs/superpowers/plans/archive/`，用于保存项目实际实施计划和已完成计划。
5. 创建 `docs/research/`，用于保存领域调研、数据发现和证据材料。
6. 创建 `docs/e2e/verify/`，用于保存真实 E2E 验收报告。
7. 从 `.template/templates/decision.md` 创建 `docs/decision.md`，已存在则补充缺失结构，不覆盖已有决策。
8. 从 `.template/templates/runtime-prompt.md` 创建或更新 `docs/prompt.md`，已存在则补充缺失结构，不覆盖已有项目 prompt 约定。
9. 从 `.template/templates/workflow.yaml` 创建或更新 `docs/workflow.yaml`，已存在则补充缺失结构，不覆盖已有状态。
10. 检查 `.gitignore` 不应忽略 `.template/`。如果团队明确要求模板不入库，必须在 `docs/decision.md` 或等价文件中记录模板源路径和重新安装方式。
11. 如存在 `.template/scripts/validate-template.sh`，运行它检查 `.template/`。
12. 检查目标项目根目录的 `CLAUDE.md` 和 `AGENTS.md`：
   - **不存在**：从 `.template/` 复制到根目录，然后根据目标项目的代码结构和配置文件，替换模板中的 `[变量]`。
   - **已存在**：**不要覆盖**。读取已有内容，根据目标项目实际情况补充缺失章节，保留原有约定不变。
13. 根据目标项目自身 prompt 来源、根目录 `CLAUDE.md` / `AGENTS.md`、`docs/workflow.yaml`、当前 workflow item 相关 `docs/superpowers/specs/`、`docs/superpowers/plans/`、`docs/research/`，把 `.template/prompt.md` 中对应阶段改写为 `docs/prompt.md` 的"当前推荐 Prompt"。

安装完成后，AI **必须暂停**，提醒人类确认根目录 `CLAUDE.md` / `AGENTS.md` 中的项目定位、技术方向、本地开发环境，以及 `docs/prompt.md` 的当前推荐 prompt 是否正确。未经人类确认，不进入下一阶段判断。

安装过程**不允许**自动决定：

- 产品目标用户。
- MVP 范围。
- 技术栈。
- 外部服务、账号、密钥或生产数据。
- 业务验收标准。

### 3B. 已有项目适配（项目有代码但未使用模板体系）

当项目已有代码或文档，但尚未使用本模板体系时，**不要要求人类从零填写所有模板**。AI 必须先从项目现有信息中提取关键内容，再按需补齐缺口。

**AI 必须先扫描以下项目信息：**

1. **代码结构**：目录布局、入口文件、路由定义、数据库模型——推断技术栈和架构。
2. **配置文件**：`package.json`、`pyproject.toml`、`docker-compose.yml`、`.env.example` 等——推断依赖、启动命令和中间件。
3. **已有文档**：`README.md`、`docs/` 下任何文档、`CHANGELOG.md`、`CONTRIBUTING.md`——能引用则引用，不重写。
4. **测试和构建**：测试目录、CI 配置、构建脚本——推断验证流程。
5. **已有 prompt**：根目录 `prompt.md` / `PROMPT.md`、`docs/*prompt*.md`、工具专属说明文件或其他团队已有 AI prompt——作为 `docs/prompt.md` 的优先输入，不能被模板覆盖。

**从已有信息反填模板：**

- 技术栈、启动命令、数据库信息 → 反填 `CLAUDE.md` / `AGENTS.md` 的 §2-§3。
- 已有 API 路由和数据模型 → **代码即真相，不反填到手写 spec**；只在需要记录设计决策（鉴权、幂等、快照规则等）时才写 `30/40`，现状字段 / schema 不手写（详见 `reference/documentation-governance.md`）。
- 已有页面和组件 → 补充 `01-product-spec.md` 的页面列表。
- 已有 prompt 和 `docs/workflow.yaml.current` → 生成或更新 `docs/prompt.md`，把 `.template/prompt.md` 的阶段模板改写为目标项目可直接执行的 prompt。
- 已有的任何文档，**先引用再补齐**，不要用模板覆盖已有内容。

**模板适配规则：**

- 项目不适用的 spec（如纯后端无 UI → 跳过 `10-ux-prototype.md`），**必须**在 `docs/workflow.yaml` 标记为 `skipped`，并在 `docs/prompt.md` 执行台账、`CLAUDE.md` / `AGENTS.md` 中说明跳过原因。
- 已有项目约定（`.editorconfig`、lint 规则、命名规范）**必须**尊重，不覆盖。
- 如果项目已有 `CLAUDE.md` 或 `AGENTS.md`，**必须**在其基础上补充，不替换。
- 当前工作不依赖的缺口，记录为待补项，**不要**阻断工作启动。

### 3C. 运行态 prompt 生成规则

`.template/prompt.md` 是模板原件，永远不写目标项目事实。AI 必须在目标项目中维护 `docs/prompt.md` 作为运行态 prompt。

生成或更新 `docs/prompt.md` 时，按以下顺序读取和融合：

1. 目标项目已有 prompt：`docs/prompt.md`、根目录 `prompt.md` / `PROMPT.md`、`docs/*prompt*.md` 或工具专属 prompt 文件；不存在则记录"无"。
2. 根目录 `CLAUDE.md` / `AGENTS.md` 的项目级约束。
3. `docs/workflow.yaml` 的当前 item、依赖、状态、artifact_path 和 archive_path。
4. 当前 workflow item 直接相关的 `docs/superpowers/specs/`、`docs/superpowers/plans/` 文件和 `docs/research/` 研究结论；项目规格不存在时，以 `.template/prompt.md` 当前阶段要求和 Superpowers skill 输出为准。
5. `.template/prompt.md` 中被阶段判断选中的阶段 prompt 或通用 prompt。

更新规则：

- 已有 `docs/prompt.md` 时，只补充缺失结构和更新"当前推荐 Prompt"，不得覆盖目标项目原有 prompt 约定。
- `docs/prompt.md` 必须包含"Prompt 执行台账"，记录每个阶段 prompt 的状态、输入依据、输出产物、验证结果和备注。
- 每次选择、执行、跳过或完成阶段 prompt 后，AI 必须更新"Prompt 执行台账"；标记为 `Skipped` 必须写原因，标记为 `Done` 必须有输出产物，标记为 `Blocked` 必须写阻塞条件。
- "当前推荐 Prompt" 必须是可直接发送给 AI 的目标项目版本，替换项目名称、输入文件路径、输出文件路径、验证命令、前后端地址、测试账号占位说明和当前 workflow item / 执行层约束。
- 如果缺少目标用户、MVP 范围、业务验收标准、真实账号、密钥或生产数据，`docs/prompt.md` 必须把缺口写成待确认项，不能自行发明。
- `docs/prompt.md` 不能替代长期事实；页面、接口、数据、验收、技术约束等长期事实必须写入对应 `docs/superpowers/specs/`。研究证据、数据来源、竞品材料和待确认假设写入 `docs/research/`，确认后的长期事实再回写 specs。

---

## 4. 第一轮必须读取

模板安装完成后，按顺序读取以下文件；不存在则记录缺口：

1. `CLAUDE.md` 或 `AGENTS.md`（项目根目录）
2. `docs/prompt.md`（如不存在，读取 `.template/templates/runtime-prompt.md` 了解结构）
3. `.template/prompt.md`
4. 当前 workflow item 对应的 `docs/superpowers/specs/*.md` 或 `docs/superpowers/plans/*.md`（如不存在，读取 `.template/prompt.md` 当前阶段要求）
5. 当前 workflow item 相关的 `docs/research/` 研究结论（如无写"无"）
6. 当前阶段需要的验证报告目录：`docs/e2e/verify/`
路径规则：`.template/prompt.md` 定义主线阶段、输入、输出和门禁，不写项目事实；`docs/superpowers/specs/` 是规格脚手架（过程产物），完成并确认后先改内容状态为 `Archived`，再移动到 `docs/superpowers/specs/archive/`；`docs/superpowers/plans/` 是计划脚手架，完成并确认后先改内容状态为 `Archived`，再移动到 `docs/superpowers/plans/archive/`。**现状（接口 / 数据 / 行为）以代码为准**（OpenAPI / ORM / 测试），不要优先读 spec 查现状。

如果项目没有 `docs/superpowers/specs/`，检查是否有：

- `docs/product/`
- `docs/prototypes/`
- `docs/research/`
- `docs/e2e/`
- `docs/decision.md`
- `docs/README.md`

---

## 5. 项目阶段判断

当前 spec / plan item 以 `docs/workflow.yaml.current` 为权威；本表用于理解该 item 属于哪类工作、该做什么、缺什么。若本表诊断结果与 `docs/workflow.yaml.current` 不一致，AI 必须报告差异，等待人类确认后再同步更新 `docs/workflow.yaml` 和 `docs/prompt.md`。

`docs/workflow.yaml` 只跟踪 spec / plan 脚手架到 `90-implementation-plan` 为止；实现阶段、原型对齐、E2E 验收和交付阶段属于执行层，分别由 `90-implementation-plan` 内 task、`docs/prompt.md` 执行台账、验证命令、`docs/e2e/verify/` 报告和 `03-delivery-report.md` 跟踪。

`03-delivery-report` 是一次性交付总结，不进入 workflow；生成、确认和归档由交付阶段在 `docs/prompt.md` 执行台账记录，最终文件仍按 spec 归档目录移动到 `docs/superpowers/specs/archive/`。

读取最小上下文后，把项目归入一个阶段：

| 阶段 | 判断标准 | 推荐下一步 | 主要产物 |
| --- | --- | --- | --- |
| 阶段 0A：模板安装 | 项目无 `.template/` 目录 | 执行本文件 §3A | `.template/` + 根目录 CLAUDE.md / AGENTS.md + `docs/decision.md` + `docs/prompt.md` + `docs/workflow.yaml` + 模板校验结果 |
| 阶段 0B：已有项目适配 | 有代码或文档，但未使用模板体系 | 执行本文件 §3B，从项目提取信息反填模板 | 适配后的 CLAUDE.md + `docs/prompt.md` + 按需 spec 初稿 |
| Idea 阶段 | 只有想法，没有产品规格 | 使用 `.template/prompt.md` 阶段 1 | `docs/superpowers/specs/00-idea-brief.md` |
| 产品规格阶段 | 有 idea，但页面/用户路径不清 | 使用 `.template/prompt.md` 阶段 2 | `docs/superpowers/specs/01-product-spec.md` |
| 领域研究 / 数据发现阶段（Domain Research / Data Discovery） | 有产品规格，但缺竞品、数据来源、数据链路或用户闭环研究 | 使用 `.template/prompt.md` 阶段 3 | `docs/superpowers/specs/05-domain-research.md` + `docs/research/` 证据 |
| 原型阶段 | 有产品规格和研究结论，但没有原型或 UX 规范 | 视项目类型使用 `.template/prompt.md` 阶段 4 | `docs/superpowers/specs/10-ux-prototype.md` |
| 系统设计阶段 | 有产品/研究/原型，但缺架构、数据、API 设计 | 使用 `.template/prompt.md` 阶段 5 | `20/30/40/50` 相关 specs |
| 验收定义阶段 | 有设计，但缺 E2E 验收规范 | 使用 `.template/prompt.md` 阶段 6 | `docs/superpowers/specs/02-e2e-acceptance.md` |
| 计划阶段 | 有验收规范，但缺实施计划 | 使用 `.template/prompt.md` 阶段 7 | `docs/superpowers/plans/90-implementation-plan.md` |
| 实现阶段 | 有计划，正在开发 | 使用 `.template/prompt.md` 阶段 8 | 代码变更和阶段验证 |
| 对齐阶段 | 已实现 UI，但未和原型对齐 | 使用 `.template/prompt.md` 阶段 9 | 原型对齐结果和修复项 |
| 验收阶段 | 已实现，未完成全量 E2E | 使用 `.template/prompt.md` 阶段 10 | `docs/e2e/verify/*-verify.md` |
| 交付阶段 | E2E 通过，缺交付报告 | 使用 `.template/prompt.md` 阶段 11 | `docs/superpowers/specs/03-delivery-report.md` |
| 迭代阶段 | 已交付后新增/修改需求 | 使用 `.template/prompt.md` 通用：已交付产品增量迭代 | Delta Spec 和回归范围 |

实际执行顺序由 `docs/workflow.yaml.current`、`depends_on` 和 `triggers` 决定；本表用于阶段解释、初始化和纠偏。规格文件编号只表示核心程度和归类，不代表必须按编号从小到大执行。

`20/30/40/50` 虽为按需规格，但不能由 AI 为了加快实现自行跳过。凡涉及数据库、外部服务、权限、支付、额度、异步任务、复杂前后端接口、多角色流程或生产数据链路，进入实施计划前必须补齐对应设计规格。

---

## 6. 必要文档自检

AI **必须**输出一份文档状态表：

| 文档 | 是否存在 | 是否足够 | 缺口 | 下一步 |
| --- | --- | --- | --- | --- |
| CLAUDE.md / AGENTS.md | 是/否 | 是/否 | [说明] | [建议] |
| 00-idea-brief.md | 是/否 | 是/否 | [说明] | [建议] |
| 01-product-spec.md | 是/否 | 是/否 | [说明] | [建议] |
| 05-domain-research.md / docs/research | 是/否 | 是/否 | [说明] | [建议] |
| 02-e2e-acceptance.md | 是/否 | 是/否 | [说明] | [建议] |
| 03-delivery-report.md | 是/否 | 是/否 | [说明] | [建议] |
| 按需 specs | 是/否 | 是/否 | [说明] | [建议] |
| docs/decision.md | 是/否 | 是/否 | [说明] | [建议] |
| docs/prompt.md | 是/否 | 是/否 | [说明] | [建议] |
| `docs/workflow.yaml` | 是/否 | 是/否 | current 是否存在、是否与 §5 诊断一致、状态转移有无断裂 | [建议] |

判断"足够"的标准：

- 文件不是空模板，关键 `[变量]` 已被项目内容替换。
- spec / plan 有明确内容状态，且 AI 反填内容标记为 `AI Extracted` 或 `Draft`，不能冒充 `Human Confirmed`。
- 有明确验收标准，不只是描述愿景。
- 涉及实现的内容能追溯到页面、接口、数据、研究结论或 E2E 用例。
- 进入系统设计前，`docs/superpowers/specs/05-domain-research.md` 已覆盖竞品 / 数据来源 / 数据链路 / 用户闭环，且支撑证据已写入 `docs/research/`，或明确记录跳过原因。
- `docs/prompt.md` 的当前推荐 prompt 已根据目标项目自身 prompt 和当前 workflow item / 执行层位置替换路径、输入、输出、验证命令，不只是复制 `.template/prompt.md`。
- `docs/prompt.md` 包含 Prompt 执行台账，且已根据 workflow item / 执行层位置把已完成、跳过、阻塞和待确认的阶段 prompt 标清楚。
- `docs/workflow.yaml.current` 必须存在或明确为空；当前 item、依赖和状态必须与 §5 诊断一致。若不一致，AI 必须报告差异并等待人类确认后再同步。
- 如果缺失，AI 应说明应补哪个文件，而不是直接开始实现。

---

## 7. 环境与验证自检

AI **必须**检查或询问：

- 后端启动命令是否明确。
- 前端启动命令是否明确。
- 数据库 / 缓存 / 中间件是否明确。
- 测试账号是否明确。
- 构建命令是否明确。
- E2E 验收报告目录是否明确，默认应为 `docs/e2e/verify/`。
- 是否能运行 `.template/scripts/validate-template.sh .template`（如脚本存在）。

如果环境信息缺失，AI 应先建议补充 `CLAUDE.md` / `AGENTS.md` 的本地开发环境章节。

---

## 8. 向人类确认的输出格式

完成自检后，AI **必须**用以下格式回复人类：

```text
我判断当前项目处于：[阶段]

已具备：
- [文档/能力]

缺失或不足：
- [缺口]

我建议下一步使用：
- [.template/prompt.md 的阶段或通用 prompt]

已生成或更新运行态 prompt：
- docs/prompt.md：[是/否，说明是否融合目标项目自身 prompt]

原因：
- [简短说明]

我将只读取以下相关文档：
- [文件列表]

是否按这个方向继续？
```

如果用户已经明确要求实现，并且缺口不阻塞实现，AI 可以继续执行；但最终回复**必须**说明哪些文档缺口是后续风险。

---

## 9. 自动补齐与反填规则

### 模板安装

AI 可以自行补齐以下低风险缺口：

- 创建缺失的 `docs/superpowers/specs/`、`docs/superpowers/specs/archive/`、`docs/superpowers/plans/`、`docs/superpowers/plans/archive/` 和 `docs/research/` 目录。
- 将 `coding_template/` 整体复制到 `.template/`。
- 检查 `.gitignore` 不应忽略 `.template/`；如团队要求不入库，记录模板源路径和重新安装方式。
- 如果根目录没有 `CLAUDE.md` / `AGENTS.md`，从 `.template/` 复制并根据项目代码结构和配置替换 `[变量]`。
- 如果根目录已有 `CLAUDE.md` / `AGENTS.md`，补充缺失章节，不覆盖已有内容。
- 创建 `docs/e2e/verify/` 目录。
- 从 `.template/templates/decision.md` 创建或补齐 `docs/decision.md`。
- 从 `.template/templates/runtime-prompt.md` 创建或补齐 `docs/prompt.md`，并根据目标项目自身 prompt 和当前 workflow item / 执行层位置生成"当前推荐 Prompt"。
- 运行 `.template/scripts/validate-template.sh .template` 检查模板体系（如脚本存在）。

### 已有项目：从代码和配置反填

AI **可以**从项目现有信息中自动提取并填入以下内容：

- 从 `package.json` / `pyproject.toml` / `build.gradle` 等提取技术栈 → 填入 `CLAUDE.md` §2。
- 从 `docker-compose.yml` / `.env.example` 提取中间件和端口 → 填入 `CLAUDE.md` §3。
- 从 `Makefile` / `scripts/` / CI 配置提取构建和启动命令 → 填入 `CLAUDE.md` §3。
- 从数据库模型文件和路由定义提取**设计决策**（不可变快照、账本规则、鉴权、幂等）→ 只在需要时写入 `30/40` 的"设计决策"节；**逐字段表 / 逐接口 schema 不反填**，真相在代码（ORM / OpenAPI）。
- 从 `README.md` 提取产品描述 → 填入 `CLAUDE.md` §1 和 `00-idea-brief.md`。
- 从目标项目已有 prompt 和 `docs/workflow.yaml.current` → 生成或更新 `docs/prompt.md`。

反填生成的内容**必须**标记为"AI 从代码提取，待人类确认"，不能直接视为已确认的项目规格。
对应 spec 的内容状态必须设置为 `AI Extracted`，确认人留空或标记为待确认。

### 禁止自动决定

AI **不得**自行补齐以下内容，必须询问人类：

- 产品目标用户不明确。
- MVP 范围不明确。
- 技术栈选择不明确。
- 需要真实账号、密钥、外部服务或生产数据。
- E2E 通过标准存在业务歧义。

---

## 10. 规格更新规则

增量迭代时，AI 应先写 Delta Spec，描述本次变化、影响范围和回归验收范围。Delta Spec 不是长期事实的替代品。

以下变化必须同步回写对应全量 spec：

- 目标用户、MVP 范围、明确不做项变化 → `00-idea-brief.md`
- 页面、用户路径、字段、状态、验收标准变化 → `01-product-spec.md`
- 领域术语、竞品结论、数据来源、数据链路、用户闭环、研究证据或待确认假设变化 → `docs/superpowers/specs/05-domain-research.md`
- E2E 路径、断言、缺陷分级、验收报告要求变化 → `02-e2e-acceptance.md`
- 架构边界、数据模型、API 契约、实现约束变化 → `20/30/40/50` 对应 spec
- Phase 范围、验证命令、E2E 路径变化 → `90-implementation-plan.md`

只影响一次性交付说明、临时验证结果或短期风险的内容，保留在 Delta Spec、verify 报告或 delivery report 中即可。

每次完成上述回写后，必须更新对应权威记录：如影响当前 spec / plan item，更新 `docs/workflow.yaml`；如影响 prompt 执行状态、跳过、阻塞或下一步，更新 `docs/prompt.md` 执行台账；如产生验证证据，写入 `docs/e2e/verify/`。

---

## 11. 最小启动 Prompt

```text
请先读取 `@coding_template/AI-BOOTSTRAP.md` 或项目中的 `.template/AI-BOOTSTRAP.md`，不要直接实现。

如果项目中没有 `.template/` 目录，请先将 `coding_template/` 整体复制到项目的 `.template/` 目录，
检查 `.gitignore` 不应忽略 `.template/`，然后从 `.template/` 复制 CLAUDE.md 和 AGENTS.md 到项目根目录。
从 `.template/templates/` 创建 docs/decision.md、docs/prompt.md 和 docs/workflow.yaml，并创建 docs/superpowers/specs/、docs/superpowers/specs/archive/、docs/superpowers/plans/、docs/superpowers/plans/archive/ 和 docs/research/，已存在则补齐缺失结构但不要覆盖已有内容。
docs/prompt.md 必须根据目标项目自身已有 prompt、CLAUDE.md / AGENTS.md、docs/workflow.yaml、docs/superpowers/specs/、docs/superpowers/plans/、docs/research/ 和当前 workflow item 相关规格生成。
如果存在 `.template/scripts/validate-template.sh`，运行 `.template/scripts/validate-template.sh .template`。

按 AI-BOOTSTRAP.md 要求判断当前项目阶段，检查必要文档和验证条件，列出缺口，
并推荐下一步应该使用 `.template/prompt.md` 中的哪个阶段 prompt，同时写入或更新 docs/prompt.md 的当前推荐 prompt。安装或反填完成后先暂停，等待人类确认后再进入下一阶段。

如果是已有项目（有代码或文档），按 §3B 从项目现有信息中提取内容反填模板。

只读取判断阶段所需的最少文档，进入实现阶段后再按需读取相关 spec。
```
