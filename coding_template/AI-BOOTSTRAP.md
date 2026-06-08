# AI Bootstrap 入口模板

> 目的：让 AI 进入一个新项目后，先判断项目当前状态，再按模板体系补齐缺口，并向人类推荐下一步 prompt。
>
> 使用方式：AI 读取本文件后，按指引执行初始化或阶段判断。本文件通常位于项目 `.template/` 目录。

---

**⚠️ 前置检查：** 如果当前项目没有 `.template/` 目录，AI **必须**先执行以下操作，不要跳过：

1. 将本文件所在的 `coding_template/` 目录整体复制到目标项目的 `.template/`。
2. 检查目标项目的 `.gitignore` 不应忽略 `.template/`。默认建议 `.template/` 随项目入库，确保新环境 clone 后仍能使用 prompt 和 spec 模板；如果团队明确要求模板不入库，必须创建 `docs/decision.md` 后记录模板源路径和重新安装方式。
3. 检查目标项目根目录是否已有 `CLAUDE.md` 或 `AGENTS.md`：
   - **不存在**：从 `.template/` 复制到根目录，然后根据目标项目的代码结构、配置文件和已有文档，替换模板中的 `[变量]`（至少补齐项目定位、技术方向和本地开发环境）。
   - **已存在**：**不要覆盖**。读取已有内容，根据目标项目实际情况补充缺失的章节（如缺少技术方向、开发环境、验证标准等），保留项目原有的约定和规则不变。
4. 创建 `docs/specs/`、`docs/research/` 和 `docs/e2e/verify/` 目录。
5. 从 `.template/templates/decision.md` 创建 `docs/decision.md`，从 `.template/templates/progress.md` 创建 `docs/progress.md`，从 `.template/templates/runtime-prompt.md` 创建或更新 `docs/prompt.md`；已存在则不要覆盖，只补充缺失结构。
   - `docs/prompt.md` 必须根据目标项目自身已有 prompt、`CLAUDE.md` / `AGENTS.md`、`docs/progress.md`、`docs/research/` 和当前阶段相关规格生成。
6. 如存在 `.template/scripts/validate-template.sh`，运行它检查 `.template/`。

完成后再继续阅读下方内容。

---

## 1. 模板体系总览

本模板不是单个 prompt，而是一套从想法到交付的分层上下文系统：

```text
CLAUDE.md / AGENTS.md   ->  全局工程约束和 AI 行为边界（项目根目录）
.template/               ->  模板原件目录（AI-BOOTSTRAP + prompt + spec 模板 + reference，默认入库）
  AI-BOOTSTRAP.md        ->  本文件，AI 首次接手时判断项目阶段和文档缺口
  prompt.md              ->  按阶段驱动 AI 生成规格、计划、实现和验收
  specs/                 ->  规格模板原件，不写项目事实
  templates/             ->  项目运行态文档模板，如 decision / progress / runtime-prompt
  scripts/               ->  模板体系校验脚本
  reference/             ->  方法论参考，默认不进入 AI 工作上下文
docs/prompt.md           ->  项目运行态 prompt，根据目标项目自身 prompt 和当前阶段生成
docs/specs/              ->  项目实际规格，是实现和验证的主要上下文
docs/research/           ->  领域调研、数据发现、证据、假设和后续设计引用
docs/e2e/verify/         ->  真实 E2E 验收报告
docs/decision.md         ->  决策记录，记录重要产品、技术、实现和验证取舍
docs/progress.md         ->  当前阶段、任务进度、验证状态和下一步
```

规格编号和执行阶段不是同一件事：

- `00-03` 是核心必备规格，表示任何产品都应最终具备这些文档。
- `05` 是研究与数据发现规格，用于在 UX 和系统设计前沉淀 `docs/research/05-domain-research.md`。
- `10-50` 是按需设计规格，只有涉及对应复杂度时才使用。
- `90` 是实施计划规格，通常在产品、架构和验收定义之后生成。
- 实际执行顺序由本文件的"项目阶段判断"决定，不由文件编号直接决定。

工程化必备产物：

- `.template/` 默认随项目入库，不写入 `.gitignore`；如团队要求不入库，必须在 `docs/decision.md` 记录模板源和重装方式。
- `.template/templates/` 必须包含运行态文档模板，至少覆盖 `decision.md`、`progress.md` 和 `runtime-prompt.md`。
- `.template/scripts/` 必须包含模板校验入口，默认使用 `validate-template.sh`。
- `docs/decision.md` 记录长期决策，按 `.template/templates/decision.md` 创建或补齐。
- `docs/progress.md` 记录当前阶段、任务状态、验证结果和下一步，按 `.template/templates/progress.md` 创建或补齐。
- `docs/prompt.md` 记录目标项目当前可执行 prompt，按 `.template/templates/runtime-prompt.md` 创建或补齐，并融合目标项目已有 prompt。
- `docs/research/` 记录领域调研、竞品、数据来源、数据链路、用户闭环、证据和待确认假设；主产物为 `docs/research/05-domain-research.md`。
- 所有 `docs/specs/*.md` 项目实际规格必须维护规格状态：`Draft / AI Extracted / Human Confirmed / Frozen / Deprecated`。
- 模板安装、模板修改或交付前，如存在 `.template/scripts/validate-template.sh`，必须运行 `.template/scripts/validate-template.sh .template`。

冲突处理优先级：

1. 人类当前明确指令。
2. `CLAUDE.md` / `AGENTS.md` 中的项目级约束。
3. `docs/specs/` 中已补全的项目实际规格。
4. `docs/prompt.md` 中的项目运行态 prompt。
5. `.template/prompt.md` 中的阶段驱动要求。
6. `.template/specs/` 和 `.template/reference/` 中的模板或方法论参考。

如果上述内容互相冲突，AI **必须**指出冲突并请求人类确认，不能自行选择对自己方便的解释。

---

## 2. 启动原则

AI 进入项目后，**不要**立刻实现功能。必须先完成三件事：

1. 判断项目当前处于哪个阶段。
2. 检查项目是否具备必要文档和验证条件。
3. 根据目标项目自身 prompt 生成或更新 `docs/prompt.md`，向人类说明下一步推荐使用哪个 prompt，并请求确认。

在 bootstrap 诊断阶段，只读取判断当前阶段所需的最少文档，避免无关 spec 干扰阶段判断。进入实现阶段后，可按需读取当前任务直接相关的 spec，不受此限制。

模板是起点不是目标。AI 应根据项目实际情况调整模板内容和结构，不要机械照搬：

- 已有文档能覆盖的内容，引用而不重写。
- 项目不适用的 spec，跳过并在 `CLAUDE.md` / `AGENTS.md` 中说明。
- 从代码和配置中提取信息反填模板，减少人类手动填写。
- 根据目标项目已有 prompt、当前阶段和已确认文档生成 `docs/prompt.md`，不要把项目事实写回 `.template/prompt.md`。
- 不阻塞当前工作的缺口，记录为待补项而非阻断项。
- 阶段切换、长任务中断、E2E 验收和交付前后，更新 `docs/progress.md`。

---

## 3. 项目初始化

AI 进入项目后，先判断项目是否已有 `.template/` 目录，再选择对应的初始化路径：

### 3A. 模板安装（项目无 .template/ 目录）

当项目缺少 `.template/` 目录时，AI **必须**先将模板安装到项目中，不要直接进入阶段判断。

**安装步骤：**

1. 找到模板源目录。如果用户通过 `@coding_template/AI-BOOTSTRAP.md` 启动，模板源是 `coding_template/`。否则询问人类提供模板源路径。
2. 将整个模板源目录复制到目标项目的 `.template/`。
3. 创建 `docs/specs/`，用于保存项目实际规格。
4. 创建 `docs/research/`，用于保存领域调研、数据发现和证据材料。
5. 创建 `docs/e2e/verify/`，用于保存真实 E2E 验收报告。
6. 从 `.template/templates/decision.md` 创建 `docs/decision.md`，已存在则补充缺失结构，不覆盖已有决策。
7. 从 `.template/templates/progress.md` 创建 `docs/progress.md`，已存在则补充缺失结构，不覆盖已有进度。
8. 从 `.template/templates/runtime-prompt.md` 创建或更新 `docs/prompt.md`，已存在则补充缺失结构，不覆盖已有项目 prompt 约定。
9. 检查 `.gitignore` 不应忽略 `.template/`。如果团队明确要求模板不入库，必须在 `docs/decision.md` 或等价文件中记录模板源路径和重新安装方式。
10. 如存在 `.template/scripts/validate-template.sh`，运行它检查 `.template/`。
11. 检查目标项目根目录的 `CLAUDE.md` 和 `AGENTS.md`：
   - **不存在**：从 `.template/` 复制到根目录，然后根据目标项目的代码结构和配置文件，替换模板中的 `[变量]`。
   - **已存在**：**不要覆盖**。读取已有内容，根据目标项目实际情况补充缺失章节，保留原有约定不变。
12. 根据目标项目自身 prompt 来源、根目录 `CLAUDE.md` / `AGENTS.md`、`docs/progress.md`、`docs/research/` 和当前阶段，把 `.template/prompt.md` 中对应阶段改写为 `docs/prompt.md` 的"当前推荐 Prompt"。

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
- 已有 API 路由和数据模型 → 生成 `40-api-and-pages.md` 和 `30-data-design.md` 的初稿供人类确认。
- 已有页面和组件 → 补充 `01-product-spec.md` 的页面列表。
- 已有 prompt 和当前阶段 → 生成或更新 `docs/prompt.md`，把 `.template/prompt.md` 的阶段模板改写为目标项目可直接执行的 prompt。
- 已有的任何文档，**先引用再补齐**，不要用模板覆盖已有内容。

**模板适配规则：**

- 项目不适用的 spec（如纯后端无 UI → 跳过 `10-ux-prototype.md`），**必须**在 `CLAUDE.md` / `AGENTS.md` 中说明跳过原因。
- 已有项目约定（`.editorconfig`、lint 规则、命名规范）**必须**尊重，不覆盖。
- 如果项目已有 `CLAUDE.md` 或 `AGENTS.md`，**必须**在其基础上补充，不替换。
- 当前工作不依赖的缺口，记录为待补项，**不要**阻断工作启动。

### 3C. 运行态 prompt 生成规则

`.template/prompt.md` 是模板原件，永远不写目标项目事实。AI 必须在目标项目中维护 `docs/prompt.md` 作为运行态 prompt。

生成或更新 `docs/prompt.md` 时，按以下顺序读取和融合：

1. 目标项目已有 prompt：`docs/prompt.md`、根目录 `prompt.md` / `PROMPT.md`、`docs/*prompt*.md` 或工具专属 prompt 文件；不存在则记录"无"。
2. 根目录 `CLAUDE.md` / `AGENTS.md` 的项目级约束。
3. `docs/progress.md` 的当前阶段、阻塞、验证状态和下一步。
4. 当前阶段直接相关的 `docs/specs/` 文件和 `docs/research/` 研究结论；项目规格不存在时，只读取 `.template/specs/` 了解结构。
5. `.template/prompt.md` 中被阶段判断选中的阶段 prompt 或通用 prompt。

更新规则：

- 已有 `docs/prompt.md` 时，只补充缺失结构和更新"当前推荐 Prompt"，不得覆盖目标项目原有 prompt 约定。
- `docs/prompt.md` 必须包含"Prompt 执行台账"，记录每个阶段 prompt 的状态、输入依据、输出产物、验证结果和备注。
- 每次选择、执行、跳过或完成阶段 prompt 后，AI 必须更新"Prompt 执行台账"；标记为 `Skipped` 必须写原因，标记为 `Done` 必须有输出产物，标记为 `Blocked` 必须写阻塞条件。
- "当前推荐 Prompt" 必须是可直接发送给 AI 的目标项目版本，替换项目名称、输入文件路径、输出文件路径、验证命令、前后端地址、测试账号占位说明和当前阶段约束。
- 如果缺少目标用户、MVP 范围、业务验收标准、真实账号、密钥或生产数据，`docs/prompt.md` 必须把缺口写成待确认项，不能自行发明。
- `docs/prompt.md` 不能替代长期事实；页面、接口、数据、验收、技术约束等长期事实必须写入对应 `docs/specs/`。研究证据、数据来源、竞品材料和待确认假设写入 `docs/research/`，确认后的长期事实再回写 specs。

---

## 4. 第一轮必须读取

模板安装完成后，按顺序读取以下文件；不存在则记录缺口：

1. `CLAUDE.md` 或 `AGENTS.md`（项目根目录）
2. `docs/prompt.md`（如不存在，读取 `.template/templates/runtime-prompt.md` 了解结构）
3. `.template/prompt.md`
4. `docs/specs/00-idea-brief.md`（如不存在，读取 `.template/specs/00-idea-brief.md` 了解模板结构）
5. `docs/specs/01-product-spec.md`（如不存在，读取 `.template/specs/01-product-spec.md` 了解模板结构）
6. `docs/research/05-domain-research.md`（如不存在，读取 `.template/specs/05-domain-research.md` 了解模板结构）
7. `docs/specs/02-e2e-acceptance.md`（如不存在，读取 `.template/specs/02-e2e-acceptance.md` 了解模板结构）
8. `docs/progress.md`（如不存在，读取 `.template/templates/progress.md` 了解模板结构）

路径规则：`.template/specs/` 是模板原件目录，不写项目事实；`docs/specs/` 是项目实际规格目录，是实现、验证和交付时读取的主要上下文。优先读取 `docs/specs/`，仅在项目规格尚未生成时回退到 `.template/specs/`。

如果项目没有 `docs/specs/`，检查是否有：

- `docs/product/`
- `docs/prototypes/`
- `docs/research/`
- `docs/e2e/`
- `docs/decision.md`
- `docs/README.md`

---

## 5. 项目阶段判断

读取最小上下文后，把项目归入一个阶段：

| 阶段 | 判断标准 | 推荐下一步 | 主要产物 |
| --- | --- | --- | --- |
| 阶段 0A：模板安装 | 项目无 `.template/` 目录 | 执行本文件 §3A | `.template/` + 根目录 CLAUDE.md / AGENTS.md + `docs/decision.md` + `docs/progress.md` + `docs/prompt.md` + 模板校验结果 |
| 阶段 0B：已有项目适配 | 有代码或文档，但未使用模板体系 | 执行本文件 §3B，从项目提取信息反填模板 | 适配后的 CLAUDE.md + `docs/prompt.md` + 按需 spec 初稿 |
| Idea 阶段 | 只有想法，没有产品规格 | 使用 `.template/prompt.md` 阶段 1 | `docs/specs/00-idea-brief.md` |
| 产品规格阶段 | 有 idea，但页面/用户路径不清 | 使用 `.template/prompt.md` 阶段 2 | `docs/specs/01-product-spec.md` |
| 领域研究 / 数据发现阶段（Domain Research / Data Discovery） | 有产品规格，但缺竞品、数据来源、数据链路或用户闭环研究 | 使用 `.template/prompt.md` 阶段 3 | `docs/research/05-domain-research.md` |
| 原型阶段 | 有产品规格和研究结论，但没有原型或 UX 规范 | 视项目类型使用 `.template/prompt.md` 阶段 4 | `docs/specs/10-ux-prototype.md` |
| 系统设计阶段 | 有产品/研究/原型，但缺架构、数据、API 设计 | 使用 `.template/prompt.md` 阶段 5 | `20/30/40/50` 相关 specs |
| 验收定义阶段 | 有设计，但缺 E2E 验收规范 | 使用 `.template/prompt.md` 阶段 6 | `docs/specs/02-e2e-acceptance.md` |
| 计划阶段 | 有验收规范，但缺实施计划 | 使用 `.template/prompt.md` 阶段 7 | `docs/specs/90-implementation-plan.md` |
| 实现阶段 | 有计划，正在开发 | 使用 `.template/prompt.md` 阶段 8 | 代码变更和阶段验证 |
| 对齐阶段 | 已实现 UI，但未和原型对齐 | 使用 `.template/prompt.md` 阶段 9 | 原型对齐结果和修复项 |
| 验收阶段 | 已实现，未完成全量 E2E | 使用 `.template/prompt.md` 阶段 10 | `docs/e2e/verify/*-verify.md` |
| 交付阶段 | E2E 通过，缺交付报告 | 使用 `.template/prompt.md` 阶段 11 | `docs/specs/03-delivery-report.md` |
| 迭代阶段 | 已交付后新增/修改需求 | 使用 `.template/prompt.md` 通用：已交付产品增量迭代 | Delta Spec 和回归范围 |

阶段表决定实际执行顺序。规格文件编号只表示核心程度和归类，不代表必须按编号从小到大执行。

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
| docs/progress.md | 是/否 | 是/否 | [说明] | [建议] |
| docs/prompt.md | 是/否 | 是/否 | [说明] | [建议] |

判断"足够"的标准：

- 文件不是空模板，关键 `[变量]` 已被项目内容替换。
- spec 有明确规格状态，且 AI 反填内容标记为 `AI Extracted` 或 `Draft`，不能冒充 `Human Confirmed`。
- 有明确验收标准，不只是描述愿景。
- 涉及实现的内容能追溯到页面、接口、数据、研究结论或 E2E 用例。
- 进入系统设计前，`docs/research/05-domain-research.md` 已覆盖竞品 / 数据来源 / 数据链路 / 用户闭环，或明确记录跳过原因。
- `docs/prompt.md` 的当前推荐 prompt 已根据目标项目自身 prompt 和当前阶段替换路径、输入、输出、验证命令，不只是复制 `.template/prompt.md`。
- `docs/prompt.md` 包含 Prompt 执行台账，且已根据项目阶段把已完成、跳过、阻塞和待确认的阶段 prompt 标清楚。
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

- 创建缺失的 `docs/specs/` 和 `docs/research/` 目录。
- 将 `coding_template/` 整体复制到 `.template/`。
- 检查 `.gitignore` 不应忽略 `.template/`；如团队要求不入库，记录模板源路径和重新安装方式。
- 如果根目录没有 `CLAUDE.md` / `AGENTS.md`，从 `.template/` 复制并根据项目代码结构和配置替换 `[变量]`。
- 如果根目录已有 `CLAUDE.md` / `AGENTS.md`，补充缺失章节，不覆盖已有内容。
- 创建 `docs/e2e/verify/` 目录。
- 从 `.template/templates/decision.md` 创建或补齐 `docs/decision.md`。
- 从 `.template/templates/progress.md` 创建或补齐 `docs/progress.md`。
- 从 `.template/templates/runtime-prompt.md` 创建或补齐 `docs/prompt.md`，并根据目标项目自身 prompt 和当前阶段生成"当前推荐 Prompt"。
- 运行 `.template/scripts/validate-template.sh .template` 检查模板体系（如脚本存在）。

### 已有项目：从代码和配置反填

AI **可以**从项目现有信息中自动提取并填入以下内容：

- 从 `package.json` / `pyproject.toml` / `build.gradle` 等提取技术栈 → 填入 `CLAUDE.md` §2。
- 从 `docker-compose.yml` / `.env.example` 提取中间件和端口 → 填入 `CLAUDE.md` §3。
- 从 `Makefile` / `scripts/` / CI 配置提取构建和启动命令 → 填入 `CLAUDE.md` §3。
- 从数据库模型文件提取表结构 → 生成 `30-data-design.md` 初稿。
- 从路由定义提取 API 列表 → 生成 `40-api-and-pages.md` 初稿。
- 从 `README.md` 提取产品描述 → 填入 `CLAUDE.md` §1 和 `00-idea-brief.md`。
- 从目标项目已有 prompt 和当前阶段 → 生成或更新 `docs/prompt.md`。

反填生成的内容**必须**标记为"AI 从代码提取，待人类确认"，不能直接视为已确认的项目规格。
对应 spec 的规格状态必须设置为 `AI Extracted`，确认人留空或标记为待确认。

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
- 领域术语、竞品结论、数据来源、数据链路、用户闭环、研究证据或待确认假设变化 → `docs/research/05-domain-research.md`
- E2E 路径、断言、缺陷分级、验收报告要求变化 → `02-e2e-acceptance.md`
- 架构边界、数据模型、API 契约、实现约束变化 → `20/30/40/50` 对应 spec
- Phase 范围、验证命令、E2E 路径变化 → `90-implementation-plan.md`

只影响一次性交付说明、临时验证结果或短期风险的内容，保留在 Delta Spec、verify 报告或 delivery report 中即可。

每次完成上述回写后，必须更新 `docs/progress.md` 的当前阶段、已完成、进行中、未完成、最新验证和下一步建议。

---

## 11. 最小启动 Prompt

```text
请先读取 `@coding_template/AI-BOOTSTRAP.md` 或项目中的 `.template/AI-BOOTSTRAP.md`，不要直接实现。

如果项目中没有 `.template/` 目录，请先将 `coding_template/` 整体复制到项目的 `.template/` 目录，
检查 `.gitignore` 不应忽略 `.template/`，然后从 `.template/` 复制 CLAUDE.md 和 AGENTS.md 到项目根目录。
从 `.template/templates/` 创建 docs/decision.md、docs/progress.md 和 docs/prompt.md，并创建 docs/research/，已存在则补齐缺失结构但不要覆盖已有内容。
docs/prompt.md 必须根据目标项目自身已有 prompt、CLAUDE.md / AGENTS.md、docs/progress.md、docs/research/ 和当前阶段相关规格生成。
如果存在 `.template/scripts/validate-template.sh`，运行 `.template/scripts/validate-template.sh .template`。

按 AI-BOOTSTRAP.md 要求判断当前项目阶段，检查必要文档和验证条件，列出缺口，
并推荐下一步应该使用 `.template/prompt.md` 中的哪个阶段 prompt，同时写入或更新 docs/prompt.md 的当前推荐 prompt。安装或反填完成后先暂停，等待人类确认后再进入下一阶段。

如果是已有项目（有代码或文档），按 §3B 从项目现有信息中提取内容反填模板。

只读取判断阶段所需的最少文档，进入实现阶段后再按需读取相关 spec。
```
