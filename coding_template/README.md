# Coding Template

> 面向 AI 协作开发的产品工程模板。用于从 idea 到规格、架构、实施计划、真实 E2E 验收和交付报告，逐步沉淀可执行上下文。

## 适用场景

当你准备启动一个新产品、新模块或需要 AI 深度参与的软件项目时，可以复制本模板到目标项目中，作为 AI 和人类共同遵守的工程入口。

本模板适合：

- 从零梳理产品想法、MVP 范围和用户路径。
- 让 AI 按阶段生成产品规格、架构设计、API / 页面映射和实施计划。
- 约束 AI 不要跳过验证、不要一次性读取全部上下文、不要用 mock 数据冒充真实验收。
- 将 E2E 验收、缺陷记录和交付报告沉淀为项目文档。

## 文件职责

| 文件 / 目录 | 给谁用 | 职责 |
| --- | --- | --- |
| `README.md` | 人类 | 说明这套模板怎么用。 |
| `AGENTS.md` | AI 工具 | 项目级工程约束入口，适配支持 `AGENTS.md` 的工具。 |
| `CLAUDE.md` | Claude Code | 项目级工程约束入口，适配 Claude Code。 |
| `ai-bootstrap.md` | AI | AI 首次接手项目时的启动流程：判断阶段、检查缺口、推荐下一步。 |
| `prompt.md` | 人类 / AI | 分阶段 prompt 驱动器，从 idea 到交付。 |
| `specs/` | 人类 / AI | 各阶段规格模板，按需复制和补全。 |
| `reference/` | 人类 | 方法论参考，不是 AI 每次必须读取的执行上下文。 |

## 推荐目录结构

复制到新项目后，建议形成以下结构：

```text
your-project/
├── AGENTS.md
├── CLAUDE.md
├── docs/
│   ├── template/
│   │   ├── ai-bootstrap.md
│   │   ├── prompt.md
│   │   └── specs/
│   ├── specs/
│   └── e2e/
│       └── verify/
```

如果只是作为外部模板库引用，也可以保留在 `coding_template/` 中，通过 `@coding_template/ai-bootstrap.md` 让 AI 启动。

其中：

- `docs/template/specs/` 保存模板原件，不写项目事实。
- `docs/specs/` 保存目标项目实际补全后的规格，是开发和验收时读取的主要上下文。
- 如果项目规模较小，也可以只保留 `docs/specs/`，但必须在 `AGENTS.md` / `CLAUDE.md` 中说明模板位置和实际规格位置。

## 最小使用流程

1. 把 `AGENTS.md` 和 `CLAUDE.md` 复制到目标项目根目录。
2. 把 `ai-bootstrap.md`、`prompt.md` 和 `specs/` 复制到目标项目的 `docs/template/`。
3. 先把根目录 `AGENTS.md` / `CLAUDE.md` 中的 `[变量]` 替换成真实项目内容，至少补齐项目定位、技术方向和本地开发环境。
4. 让 AI 先读取 `docs/template/ai-bootstrap.md`，不要直接实现。
5. AI 根据 bootstrap 输出项目阶段、文档缺口、验证条件和推荐 prompt。
6. 人类确认后，再使用 `prompt.md` 中对应阶段的 prompt 生成或补齐规格。
7. 实现前只读取当前阶段相关 spec，禁止一次性读取所有 spec。
8. 每个阶段完成后写入对应规格、验证报告或交付报告。

## AI 启动 Prompt

可以直接发送：

```text
请先读取 `@coding_template/ai-bootstrap.md` 或项目中的 `docs/template/ai-bootstrap.md`，不要直接实现。

先判断当前读取的是模板源目录，还是已经复制到目标项目中的模板。

如果是模板源目录，请以 `coding_template/` 为模板根目录，检查其中的 `AGENTS.md`、`CLAUDE.md`、`prompt.md` 和 `specs/`。

如果是目标项目，请检查项目根目录下的 `AGENTS.md` / `CLAUDE.md`、`docs/specs/`、`docs/e2e/verify/` 和项目自己的 prompt 模板。

按该文件要求判断当前项目阶段，检查必要文档和验证条件，列出缺口，并推荐下一步应该使用 `prompt.md` 中的哪个阶段 prompt。

只读取判断阶段所需的最少文档，禁止一次性读取所有 spec。
```

## 使用原则

- `AGENTS.md` / `CLAUDE.md` 只放全局约束和索引，不内联复杂规格。
- 具体产品、页面、接口、数据、架构和验收标准写入 `specs/`。
- `ai-bootstrap.md` 用于判断“现在该做什么”，不是替代 `prompt.md`。
- `prompt.md` 用于驱动阶段产出，不保存项目事实。
- `reference/` 只在需要理解方法论时阅读，默认不进入 AI 工作上下文。
- E2E 验收报告统一写入 `docs/e2e/verify/`。

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

## 注意事项

- 不要让 AI 直接从 idea 跳到实现。
- 不要让 AI 一次性读取所有 spec。
- 不要用 mock / 静态数据作为最终 E2E 通过依据。
- 不要把项目专属的大段业务规则写回模板入口文件。
- 模板复制到项目后，应把 `[变量]` 替换成真实项目内容。
