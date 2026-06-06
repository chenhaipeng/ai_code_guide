# AI Bootstrap 入口模板

> 目的：让 AI 进入一个新项目后，先判断项目当前状态，再按模板体系补齐缺口，并向人类推荐下一步 prompt。
>
> 使用方式：把本文件复制到项目文档目录，作为 AI 第一次接手项目时的阅读入口。

---

## 1. 模板体系总览

本模板不是单个 prompt，而是一套从想法到交付的分层上下文系统：

```text
AGENTS.md / CLAUDE.md  ->  全局工程约束和 AI 行为边界
ai-bootstrap.md        ->  AI 首次接手时判断项目阶段和文档缺口
prompt.md              ->  按阶段驱动 AI 生成规格、计划、实现和验收
docs/template/specs/   ->  规格模板原件，不写项目事实
docs/specs/            ->  项目实际规格，是实现和验证的主要上下文
docs/e2e/verify/       ->  真实 E2E 验收报告
reference/             ->  方法论参考，默认不进入 AI 工作上下文
```

规格编号和执行阶段不是同一件事：

- `00-03` 是核心必备规格，表示任何产品都应最终具备这些文档。
- `10-50` 是按需设计规格，只有涉及对应复杂度时才使用。
- `90` 是实施计划规格，通常在产品、架构和验收定义之后生成。
- 实际执行顺序由本文件的“项目阶段判断”决定，不由文件编号直接决定。

冲突处理优先级：

1. 人类当前明确指令。
2. `AGENTS.md` / `CLAUDE.md` 中的项目级约束。
3. `docs/specs/` 中已补全的项目实际规格。
4. `prompt.md` 中的阶段驱动要求。
5. `docs/template/specs/` 和 `reference/` 中的模板或方法论参考。

如果上述内容互相冲突，AI 必须指出冲突并请求人类确认，不能自行选择对自己方便的解释。

---

## 2. 启动原则

AI 进入项目后，不要立刻实现功能。必须先完成三件事：

1. 判断项目当前处于哪个阶段。
2. 检查项目是否具备必要文档和验证条件。
3. 向人类说明下一步推荐使用哪个 prompt，并请求确认。

禁止一次性读取所有 spec 文件。只读取判断当前阶段所需的最少文档。

---

## 3. 阶段 0：空项目初始化

当 AI 进入一个全新的空项目目录，或目标项目缺少 `AGENTS.md` / `CLAUDE.md` 且缺少 `docs/template/` 时，先进入阶段 0，不要直接进入 Idea 阶段。

阶段 0 的目标是把模板安装到目标项目，而不是生成产品规格或写代码。

AI 必须先确认模板源目录：

- 如果用户通过 `@coding_template/ai-bootstrap.md` 启动，模板源目录通常是 `coding_template/`。
- 如果当前项目已经有 `docs/template/`，模板源目录是 `docs/template/`。
- 如果两者都不存在，AI 必须询问人类提供模板源路径，不能凭空创建不完整模板。

阶段 0 可自动执行的低风险动作：

1. 从模板源复制 `AGENTS.md` 和 `CLAUDE.md` 到目标项目根目录。
2. 创建 `docs/template/`，并复制 `ai-bootstrap.md`、`prompt.md` 和 `specs/`。
3. 创建 `docs/specs/`，用于保存项目实际规格。
4. 创建 `docs/e2e/verify/`，用于保存真实 E2E 验收报告。
5. 创建 `docs/decision.md` 或等价决策记录文件。

阶段 0 完成后，AI 必须提醒人类先补齐根目录 `AGENTS.md` / `CLAUDE.md` 中的项目定位、技术方向和本地开发环境，再继续阶段判断。

阶段 0 不允许自动决定：

- 产品目标用户。
- MVP 范围。
- 技术栈。
- 外部服务、账号、密钥或生产数据。
- 业务验收标准。

---

## 4. 第一轮必须读取

按顺序读取以下文件；不存在则记录缺口：

1. `AGENTS.md` 或 `CLAUDE.md`
2. `docs/template/prompt.md` 或项目自己的 prompt 模板
3. `docs/specs/00-idea-brief.md` 或等价 idea 文档
4. `docs/specs/01-product-spec.md` 或等价产品规格
5. `docs/specs/02-e2e-acceptance.md` 或等价 E2E 验收规范

路径规则：`docs/template/specs/` 是模板原件目录，不写项目事实；`docs/specs/` 是项目实际规格目录，是实现、验证和交付时读取的主要上下文。

如果项目没有 `docs/specs/`，检查是否有：

- `docs/product/`
- `docs/prototypes/`
- `docs/e2e/`
- `docs/decision.md`
- `docs/README.md`

---

## 5. 项目阶段判断

读取最小上下文后，把项目归入一个阶段：

| 阶段 | 判断标准 | 推荐下一步 | 主要产物 |
| --- | --- | --- | --- |
| 阶段 0：空项目初始化 | 缺少入口文件或模板目录 | 执行本文件阶段 0 | 项目模板骨架 |
| Idea 阶段 | 只有想法，没有产品规格 | 使用 prompt.md 阶段 1 | `docs/specs/00-idea-brief.md` |
| 产品规格阶段 | 有 idea，但页面/用户路径不清 | 使用 prompt.md 阶段 2 | `docs/specs/01-product-spec.md` |
| 原型阶段 | 有产品规格，但没有原型或 UX 规范 | 视项目类型使用 prompt.md 阶段 3 | `docs/specs/10-ux-prototype.md` |
| 系统设计阶段 | 有产品/原型，但缺架构、数据、API 设计 | 使用 prompt.md 阶段 4 | `20/30/40/50` 相关 specs |
| 验收定义阶段 | 有设计，但缺 E2E 验收规范 | 使用 prompt.md 阶段 5 | `docs/specs/02-e2e-acceptance.md` |
| 计划阶段 | 有验收规范，但缺实施计划 | 使用 prompt.md 阶段 6 | `docs/specs/90-implementation-plan.md` |
| 实现阶段 | 有计划，正在开发 | 使用 prompt.md 阶段 7 | 代码变更和阶段验证 |
| 对齐阶段 | 已实现 UI，但未和原型对齐 | 使用 prompt.md 阶段 8 | 原型对齐结果和修复项 |
| 验收阶段 | 已实现，未完成全量 E2E | 使用 prompt.md 阶段 9 | `docs/e2e/verify/*-verify.md` |
| 交付阶段 | E2E 通过，缺交付报告 | 使用 prompt.md 阶段 10 | `docs/specs/03-delivery-report.md` |
| 迭代阶段 | 已交付后新增/修改需求 | 使用 prompt.md 通用：已交付产品增量迭代 | Delta Spec 和回归范围 |

阶段表决定实际执行顺序。规格文件编号只表示核心程度和归类，不代表必须按编号从小到大执行。

---

## 6. 必要文档自检

AI 必须输出一份文档状态表：

| 文档 | 是否存在 | 是否足够 | 缺口 | 下一步 |
| --- | --- | --- | --- | --- |
| AGENTS.md / CLAUDE.md | 是/否 | 是/否 | [说明] | [建议] |
| 00-idea-brief.md | 是/否 | 是/否 | [说明] | [建议] |
| 01-product-spec.md | 是/否 | 是/否 | [说明] | [建议] |
| 02-e2e-acceptance.md | 是/否 | 是/否 | [说明] | [建议] |
| 03-delivery-report.md | 是/否 | 是/否 | [说明] | [建议] |
| 按需 specs | 是/否 | 是/否 | [说明] | [建议] |

判断“足够”的标准：

- 文件不是空模板，关键 `[变量]` 已被项目内容替换。
- 有明确验收标准，不只是描述愿景。
- 涉及实现的内容能追溯到页面、接口、数据或 E2E 用例。
- 如果缺失，AI 应说明应补哪个文件，而不是直接开始实现。

---

## 7. 环境与验证自检

AI 必须检查或询问：

- 后端启动命令是否明确。
- 前端启动命令是否明确。
- 数据库 / 缓存 / 中间件是否明确。
- 测试账号是否明确。
- 构建命令是否明确。
- E2E 验收报告目录是否明确，默认应为 `docs/e2e/verify/`。

如果环境信息缺失，AI 应先建议补充 `AGENTS.md / CLAUDE.md` 的本地开发环境章节。

---

## 8. 向人类确认的输出格式

完成自检后，AI 必须用以下格式回复人类：

```text
我判断当前项目处于：[阶段]

已具备：
- [文档/能力]

缺失或不足：
- [缺口]

我建议下一步使用：
- [prompt.md 的阶段或通用 prompt]

原因：
- [简短说明]

我将只读取以下相关文档：
- [文件列表]

是否按这个方向继续？
```

如果用户已经明确要求实现，并且缺口不阻塞实现，AI 可以继续执行；但最终回复必须说明哪些文档缺口是后续风险。

---

## 9. 自动补齐规则

AI 可以自行补齐以下低风险缺口：

- 创建缺失的 `docs/specs/` 目录。
- 从模板源复制必要模板：如果目标项目已有 `docs/template/specs/`，从该目录复制；如果是外部模板库启动，则从 `coding_template/specs/` 复制到目标项目的 `docs/template/specs/`，再复制到 `docs/specs/` 生成项目实际规格。
- 创建 `docs/e2e/verify/` 目录。
- 创建空的 `docs/decision.md` 或等价决策记录文件。

AI 不应自行补齐以下内容，必须询问人类：

- 产品目标用户不明确。
- MVP 范围不明确。
- 技术栈选择不明确。
- 需要真实账号、密钥、外部服务或生产数据。
- E2E 通过标准存在业务歧义。

---

## 10. 最小启动 Prompt

把下面这段发给 AI，即可启动项目接管流程：

```text
请先读取 `@coding_template/ai-bootstrap.md` 或项目中的 `docs/template/ai-bootstrap.md`，不要直接实现。

先判断当前读取的是模板源目录，还是已经复制到目标项目中的模板。

如果是模板源目录，请以 `coding_template/` 为模板根目录，检查其中的 `AGENTS.md`、`CLAUDE.md`、`prompt.md` 和 `specs/`。

如果是目标项目，请检查项目根目录下的 `AGENTS.md` / `CLAUDE.md`、`docs/specs/`、`docs/e2e/verify/` 和项目自己的 prompt 模板。

按 `ai-bootstrap.md` 要求判断项目阶段，检查必要文档和验证条件，列出缺口，并推荐下一步应该使用 `prompt.md` 中的哪个阶段 prompt。

只读取判断阶段所需的最少文档，禁止一次性读取所有 spec。
```
