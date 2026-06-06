# AI Bootstrap 入口模板

> 目的：让 AI 进入一个新项目后，先判断项目当前状态，再按模板体系补齐缺口，并向人类推荐下一步 prompt。
>
> 使用方式：AI 读取本文件后，按指引执行初始化或阶段判断。本文件通常位于项目 `.template/` 目录。

---

## 1. 模板体系总览

本模板不是单个 prompt，而是一套从想法到交付的分层上下文系统：

```text
CLAUDE.md / AGENTS.md   ->  全局工程约束和 AI 行为边界（项目根目录）
.template/               ->  模板原件目录（AI-BOOTSTRAP + prompt + spec 模板 + reference）
  AI-BOOTSTRAP.md        ->  本文件，AI 首次接手时判断项目阶段和文档缺口
  prompt.md              ->  按阶段驱动 AI 生成规格、计划、实现和验收
  specs/                 ->  规格模板原件，不写项目事实
  reference/             ->  方法论参考，默认不进入 AI 工作上下文
docs/specs/              ->  项目实际规格，是实现和验证的主要上下文
docs/e2e/verify/         ->  真实 E2E 验收报告
```

规格编号和执行阶段不是同一件事：

- `00-03` 是核心必备规格，表示任何产品都应最终具备这些文档。
- `10-50` 是按需设计规格，只有涉及对应复杂度时才使用。
- `90` 是实施计划规格，通常在产品、架构和验收定义之后生成。
- 实际执行顺序由本文件的"项目阶段判断"决定，不由文件编号直接决定。

冲突处理优先级：

1. 人类当前明确指令。
2. `CLAUDE.md` / `AGENTS.md` 中的项目级约束。
3. `docs/specs/` 中已补全的项目实际规格。
4. `.template/prompt.md` 中的阶段驱动要求。
5. `.template/specs/` 和 `.template/reference/` 中的模板或方法论参考。

如果上述内容互相冲突，AI **必须**指出冲突并请求人类确认，不能自行选择对自己方便的解释。

---

## 2. 启动原则

AI 进入项目后，**不要**立刻实现功能。必须先完成三件事：

1. 判断项目当前处于哪个阶段。
2. 检查项目是否具备必要文档和验证条件。
3. 向人类说明下一步推荐使用哪个 prompt，并请求确认。

在 bootstrap 诊断阶段，只读取判断当前阶段所需的最少文档，避免无关 spec 干扰阶段判断。进入实现阶段后，可按需读取当前任务直接相关的 spec，不受此限制。

模板是起点不是目标。AI 应根据项目实际情况调整模板内容和结构，不要机械照搬：

- 已有文档能覆盖的内容，引用而不重写。
- 项目不适用的 spec，跳过并在 `CLAUDE.md` / `AGENTS.md` 中说明。
- 从代码和配置中提取信息反填模板，减少人类手动填写。
- 不阻塞当前工作的缺口，记录为待补项而非阻断项。

---

## 3. 项目初始化

AI 进入项目后，先判断项目是否已有 `.template/` 目录，再选择对应的初始化路径：

### 3A. 模板安装（项目无 .template/ 目录）

当项目缺少 `.template/` 目录时，AI **必须**先将模板安装到项目中，不要直接进入阶段判断。

**安装步骤：**

1. 找到模板源目录。如果用户通过 `@coding_template/AI-BOOTSTRAP.md` 启动，模板源是 `coding_template/`。否则询问人类提供模板源路径。
2. 将整个模板源目录复制到目标项目的 `.template/`。
3. 从 `.template/` 复制 `CLAUDE.md` 和 `AGENTS.md` 到项目根目录。
4. 创建 `docs/specs/`，用于保存项目实际规格。
5. 创建 `docs/e2e/verify/`，用于保存真实 E2E 验收报告。
6. 创建 `docs/decision.md` 或等价决策记录文件。

安装完成后，AI **必须**提醒人类先补齐根目录 `CLAUDE.md` / `AGENTS.md` 中的项目定位、技术方向和本地开发环境，再继续阶段判断。

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

**从已有信息反填模板：**

- 技术栈、启动命令、数据库信息 → 反填 `CLAUDE.md` / `AGENTS.md` 的 §2-§3。
- 已有 API 路由和数据模型 → 生成 `40-api-and-pages.md` 和 `30-data-design.md` 的初稿供人类确认。
- 已有页面和组件 → 补充 `01-product-spec.md` 的页面列表。
- 已有的任何文档，**先引用再补齐**，不要用模板覆盖已有内容。

**模板适配规则：**

- 项目不适用的 spec（如纯后端无 UI → 跳过 `10-ux-prototype.md`），**必须**在 `CLAUDE.md` / `AGENTS.md` 中说明跳过原因。
- 已有项目约定（`.editorconfig`、lint 规则、命名规范）**必须**尊重，不覆盖。
- 如果项目已有 `CLAUDE.md` 或 `AGENTS.md`，**必须**在其基础上补充，不替换。
- 当前工作不依赖的缺口，记录为待补项，**不要**阻断工作启动。

---

## 4. 第一轮必须读取

模板安装完成后，按顺序读取以下文件；不存在则记录缺口：

1. `CLAUDE.md` 或 `AGENTS.md`（项目根目录）
2. `.template/prompt.md`
3. `docs/specs/00-idea-brief.md` 或等价 idea 文档
4. `docs/specs/01-product-spec.md` 或等价产品规格
5. `docs/specs/02-e2e-acceptance.md` 或等价 E2E 验收规范

路径规则：`.template/specs/` 是模板原件目录，不写项目事实；`docs/specs/` 是项目实际规格目录，是实现、验证和交付时读取的主要上下文。

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
| 阶段 0A：模板安装 | 项目无 `.template/` 目录 | 执行本文件 §3A | `.template/` + 根目录 CLAUDE.md |
| 阶段 0B：已有项目适配 | 有代码或文档，但未使用模板体系 | 执行本文件 §3B，从项目提取信息反填模板 | 适配后的 CLAUDE.md + 按需 spec 初稿 |
| Idea 阶段 | 只有想法，没有产品规格 | 使用 `.template/prompt.md` 阶段 1 | `docs/specs/00-idea-brief.md` |
| 产品规格阶段 | 有 idea，但页面/用户路径不清 | 使用 `.template/prompt.md` 阶段 2 | `docs/specs/01-product-spec.md` |
| 原型阶段 | 有产品规格，但没有原型或 UX 规范 | 视项目类型使用 `.template/prompt.md` 阶段 3 | `docs/specs/10-ux-prototype.md` |
| 系统设计阶段 | 有产品/原型，但缺架构、数据、API 设计 | 使用 `.template/prompt.md` 阶段 4 | `20/30/40/50` 相关 specs |
| 验收定义阶段 | 有设计，但缺 E2E 验收规范 | 使用 `.template/prompt.md` 阶段 5 | `docs/specs/02-e2e-acceptance.md` |
| 计划阶段 | 有验收规范，但缺实施计划 | 使用 `.template/prompt.md` 阶段 6 | `docs/specs/90-implementation-plan.md` |
| 实现阶段 | 有计划，正在开发 | 使用 `.template/prompt.md` 阶段 7 | 代码变更和阶段验证 |
| 对齐阶段 | 已实现 UI，但未和原型对齐 | 使用 `.template/prompt.md` 阶段 8 | 原型对齐结果和修复项 |
| 验收阶段 | 已实现，未完成全量 E2E | 使用 `.template/prompt.md` 阶段 9 | `docs/e2e/verify/*-verify.md` |
| 交付阶段 | E2E 通过，缺交付报告 | 使用 `.template/prompt.md` 阶段 10 | `docs/specs/03-delivery-report.md` |
| 迭代阶段 | 已交付后新增/修改需求 | 使用 `.template/prompt.md` 通用：已交付产品增量迭代 | Delta Spec 和回归范围 |

阶段表决定实际执行顺序。规格文件编号只表示核心程度和归类，不代表必须按编号从小到大执行。

---

## 6. 必要文档自检

AI **必须**输出一份文档状态表：

| 文档 | 是否存在 | 是否足够 | 缺口 | 下一步 |
| --- | --- | --- | --- | --- |
| CLAUDE.md / AGENTS.md | 是/否 | 是/否 | [说明] | [建议] |
| 00-idea-brief.md | 是/否 | 是/否 | [说明] | [建议] |
| 01-product-spec.md | 是/否 | 是/否 | [说明] | [建议] |
| 02-e2e-acceptance.md | 是/否 | 是/否 | [说明] | [建议] |
| 03-delivery-report.md | 是/否 | 是/否 | [说明] | [建议] |
| 按需 specs | 是/否 | 是/否 | [说明] | [建议] |

判断"足够"的标准：

- 文件不是空模板，关键 `[变量]` 已被项目内容替换。
- 有明确验收标准，不只是描述愿景。
- 涉及实现的内容能追溯到页面、接口、数据或 E2E 用例。
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

- 创建缺失的 `docs/specs/` 目录。
- 将 `coding_template/` 整体复制到 `.template/`。
- 从 `.template/` 复制 `CLAUDE.md` 和 `AGENTS.md` 到项目根目录。
- 创建 `docs/e2e/verify/` 目录。
- 创建空的 `docs/decision.md` 或等价决策记录文件。

### 已有项目：从代码和配置反填

AI **可以**从项目现有信息中自动提取并填入以下内容：

- 从 `package.json` / `pyproject.toml` / `build.gradle` 等提取技术栈 → 填入 `CLAUDE.md` §2。
- 从 `docker-compose.yml` / `.env.example` 提取中间件和端口 → 填入 `CLAUDE.md` §3。
- 从 `Makefile` / `scripts/` / CI 配置提取构建和启动命令 → 填入 `CLAUDE.md` §3。
- 从数据库模型文件提取表结构 → 生成 `30-data-design.md` 初稿。
- 从路由定义提取 API 列表 → 生成 `40-api-and-pages.md` 初稿。
- 从 `README.md` 提取产品描述 → 填入 `CLAUDE.md` §1 和 `00-idea-brief.md`。

反填生成的内容**必须**标记为"AI 从代码提取，待人类确认"，不能直接视为已确认的项目规格。

### 禁止自动决定

AI **不得**自行补齐以下内容，必须询问人类：

- 产品目标用户不明确。
- MVP 范围不明确。
- 技术栈选择不明确。
- 需要真实账号、密钥、外部服务或生产数据。
- E2E 通过标准存在业务歧义。

---

## 10. 最小启动 Prompt

```text
请先读取 `@coding_template/AI-BOOTSTRAP.md` 或项目中的 `.template/AI-BOOTSTRAP.md`，不要直接实现。

如果项目中没有 `.template/` 目录，请先将 `coding_template/` 整体复制到项目的 `.template/` 目录，
然后从 `.template/` 复制 CLAUDE.md 和 AGENTS.md 到项目根目录。

按 AI-BOOTSTRAP.md 要求判断当前项目阶段，检查必要文档和验证条件，列出缺口，
并推荐下一步应该使用 `.template/prompt.md` 中的哪个阶段 prompt。

如果是已有项目（有代码或文档），按 §3B 从项目现有信息中提取内容反填模板。

只读取判断阶段所需的最少文档，进入实现阶段后再按需读取相关 spec。
```
