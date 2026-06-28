# CLAUDE.md

> 项目工程约束模板。由 `.template/AI-BOOTSTRAP.md` 自动安装；或手动复制到根目录并替换 `[变量]`。
> 行为规则（Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution）由 Superpowers 插件覆盖，此处不重复。
> 本文件与 `AGENTS.md` 默认保持相同内容，仅用于适配不同 AI 工具的自动发现入口。修改本文件时必须同步 `AGENTS.md`，除非项目明确记录只维护其中一个入口。

## 1. 项目定位

> 详细 Idea 分析（目标用户拆分、痛点论证、竞品对标、MVP 范围、成功标准）见 `docs/superpowers/specs/00-idea-brief.md`。领域研究 spec 见 `docs/superpowers/specs/05-domain-research.md`，原始证据和专项材料见 `docs/research/`。

[产品名称] 是 [一句话描述产品边界]。

目标用户：[描述用户群体]
核心场景：[用户在什么场景下使用，解决什么问题]
核心价值：[用户用完之后得到什么]

核心原则：

- [原则 1]
- [原则 2]
- [原则 3]
- [原则 4]
- [原则 5]

**不是什么：** [明确边界，说明这个产品不做哪些事]

## 2. 技术方向

目标技术栈：

- 前端：[框架 + 版本]。示例：Vue 3 + TypeScript + Vite。
- 后端：[框架 + 版本]。示例：Python FastAPI + Pydantic。
- 数据库：[数据库 + ORM]。示例：PostgreSQL + SQLAlchemy + Alembic。
- 缓存 / 队列：[技术]。示例：Redis。
- 后台任务：[技术]。示例：Python worker + Celery / RQ / Arq。
- AI / 数据处理：[技术]。示例：统一 Python 生态。

原型参考：[原型文件路径]
Mock / Contract 参考：[mock 文件路径]
废弃方向：[如果有旧技术栈被废弃，在此说明]

## 3. 本地开发环境

### 中间件

| 服务 | 容器名/进程名 | 地址:端口 | 凭据 |
| --- | --- | --- | --- |
| [数据库] | [容器名] | [地址:端口] | [用户名/密码] |
| [缓存] | [容器名] | [地址:端口] | [密码或无] |

数据库名：[数据库名]（字符集 [编码]）。

### 后端

- 构建命令：`[构建命令]`（在 `[目录]` 下执行）
- 启动命令：`[启动命令]`
- 端口：`http://localhost:[端口]`
- 配置文件：`[配置文件路径]`
- 数据库迁移：`[迁移命令]`
- 数据库初始化脚本：`[脚本路径]`

### 前端

- 安装依赖：`[安装命令]`（在 `[目录]` 下执行）
- 启动命令：`[启动命令]`
- 端口：`http://localhost:[端口]`

### 登录信息

- 测试用户：[账号] / [密码]
- 管理员：[账号] / [密码]

## 4. 开发流程（强制 Superpowers 工作流）

默认项目使用 Superpowers 工作流。开发、调试、规划、验证、Git 和代码审查相关任务必须优先使用对应 skill；如果当前环境没有可用 skill，必须在回复中说明降级执行方式和缺失能力。

### Superpowers 与主线 prompt 的边界

- `.template/prompt.md` 是阶段 prompt 模板原件，不写项目事实；`docs/prompt.md` 是项目运行态 prompt 和 Prompt 执行台账；`docs/workflow.yaml` 是 spec / plan 生命周期状态机。
- `docs/workflow.yaml.current` 是当前 spec / plan item 的权威；`docs/prompt.md` 只能解释、展示或辅助纠偏，不另立当前 item 真相。
- `docs/workflow.yaml` 默认跟踪到 `90-implementation-plan`；阶段 8-11 属于执行层，按 implementation plan task、`docs/prompt.md` 执行台账、`docs/e2e/verify/` 和交付报告跟踪。
- `03-delivery-report` 是一次性交付总结，不进入 workflow；完成并确认后仍按 spec 归档到 `docs/superpowers/specs/archive/`。
- Superpowers 决定每类工作怎么执行：构思/规格优先用 brainstorming，实施计划用 writing-plans，开发按计划使用 TDD、review、debugging 和 verification 相关 skill。
- 本项目遵循 Superpowers 的默认文档根路径：阶段 spec 写入 `docs/superpowers/specs/`，implementation plan 写入 `docs/superpowers/plans/`。
- 人类 review 是阶段 gate：spec 从 `review` 到 `ready`、实施计划从 `review` 到 `ready`、验证完成后从 `verified` 到 `archived` 必须经人类确认。
- `Human Confirmed` 是内容状态，只表示 spec 或 plan 经人类确认、可被后续阶段消费；`archived` 是 workflow 状态，只表示生命周期结束。完成并经人类确认后，必须先把文件内内容状态改为 `Archived`，再移动到对应 archive。
- 按需阶段不能静默绕过；如 UX / Prototype 不适用，必须在 `docs/workflow.yaml` 标记为 `skipped`，并在 `docs/prompt.md` 执行台账写明原因。

### 持续优化 Loop（已有项目优先）

当任务是已有代码库上的增量改造、重构、工具层重做或长期持续优化时，默认优先使用持续优化 Loop：

1. 先创建 `Phase00-main` 总控 spec
2. 再拆分 `Phase01+` spec，并显式写明依赖顺序和编号
3. 每个 `Phase` 单独生成 plan
4. 每个 `Phase` 完成后写 verify 报告
5. 每次关键改动后立即执行构建、测试和必要 E2E
6. 未达到最终验收标准前不得停止，除非连续三轮自救失败并进入 `blocked`

命名规则：

- `docs/superpowers/specs/YYYY-MM-DD-Phase00-[topic]-main.md`
- `docs/superpowers/specs/YYYY-MM-DD-PhaseNN-[topic].md`
- `docs/superpowers/plans/YYYY-MM-DD-PhaseNN-[topic]-plan.md`
- `docs/e2e/verify/YYYY-MM-DD-PhaseNN-[topic]-verify.md`

### Superpowers 产物归档

- Superpowers 产出的阶段 spec 写入 `docs/superpowers/specs/`；workflow 内的 spec 完成后归档到 `docs/superpowers/specs/archive/`。
- Superpowers 产出的 implementation plan 写入 `docs/superpowers/plans/`，完成后归档到 `docs/superpowers/plans/archive/`。
- 归档前必须更新文件内的内容状态：`Human Confirmed` 表示内容经人类确认、可被消费；`Archived` 表示该 spec 或 plan 已完成并移出活跃上下文。
- workflow item 移动到 archive 后，必须同步更新 `docs/workflow.yaml` 和 `docs/prompt.md` 的执行台账。
- `03-delivery-report` 不进入 workflow，生成、确认和归档只更新 `docs/prompt.md` 执行台账。
- 归档不是删除事实：接口、数据、行为以代码为准；决策写入 `docs/decision.md`；执行进度以 `docs/workflow.yaml`、active plan task、`docs/prompt.md` 执行台账和 `docs/e2e/verify/` 为准。

### TDD 灵活度

根据任务复杂度决定是否严格 TDD：

- **简单任务**（配置修改、单文件小改动、参数调整）：直接实现 + 现有测试验证即可，不必写专门的 failing test 先行。
- **中等任务**（新增函数、小模块）：先写关键路径的测试，不需要每个边界条件都 TDD。
- **复杂任务**（新模块、多文件重构、核心逻辑）：严格 TDD，先写 failing test 再实现。

判断标准：如果任务的正确行为显而易见、改动范围小、出错概率低，可以跳过严格的 TDD 流程。

### E2E 验证（强制）

功能完成后，必须对受影响的关联功能执行 E2E 验证。

涉及前端页面、路由、菜单、权限、接口调用、表单、按钮、交互状态或展示逻辑的修改，完成后必须启动真实前后端并使用浏览器做 E2E 验证，不能只依赖编译、单元测试、静态检查或代码审查。

如果后端接口返回结构、权限注解、菜单配置、路由组件路径、前端 API 封装或按钮权限标识发生变化，也视为影响前端行为，必须通过浏览器进行真实前后端调用验证。

**E2E 前置检查：**

- [ ] 中间件状态：确认数据库和缓存正常运行。
- [ ] 后端端口：确认服务真实启动且无启动异常。
- [ ] 前端端口：确认 dev server 真实启动。
- [ ] 如果端口被占用、服务启动失败、数据库连接失败或依赖缺失，必须停止声称 E2E 通过，并在最终回复中说明阻塞原因。

**E2E 最低要求：**

- 后端真实启动在 `[后端地址]`。
- 前端真实启动在 `[前端地址]`。
- 使用测试账号登录。
- 进入受影响页面，执行本次修改涉及的主要用户路径。
- 通过 DevTools Network 确认页面发起真实后端请求，并检查响应状态与业务数据；不得用 mock 数据替代。
- 检查 Console 和 Network 中是否存在新增的 JavaScript 错误、401/403/404/500、接口路径错误或权限错误。
- 对权限或菜单变更，必须验证菜单可见性、按钮显隐以及点击后的后端权限校验结果。
- 不能用"应该可以"代替验证。

### 数据库脚本验证

修改数据库迁移脚本、菜单、权限、字典、表结构或初始化数据后，必须明确说明数据库验证状态：

- 如已执行迁移，说明执行的脚本、目标库、执行结果，以及关键表/菜单/权限查询结果。
- 如未执行迁移，不能声称数据库结构或数据已在本地生效。

### 验证报告格式

涉及代码或配置修改的最终回复必须包含验证摘要，至少覆盖：

- **构建结果**：后端编译 / 前端 build 是否通过。
- **测试结果**：相关测试是否通过（区分 pre-existing failure 和新引入的 failure）。
- **E2E 页面/路径**：实际访问了哪些页面或 URL。
- **关键接口**：DevTools Network 中确认的真实请求路径、状态码和返回数据。
- **Console / Network**：是否存在新增 JS 错误、401/403/404/500 或接口路径错误。
- **数据库变更**：是否执行迁移，执行了哪些脚本，若未执行必须明确说明。
- **未验证项**：无法验证的内容和原因，不能省略。
- **过程记录**：是否更新 `docs/workflow.yaml`、active plan task、`docs/prompt.md` 执行台账或 `docs/e2e/verify/`；如未更新，说明原因。

### 语言约定

- 代码注释和 commit message 用 [语言 1]
- 设计文档和沟通用 [语言 2]

## 5. 原型与 Mock 使用边界

允许：

- 使用原型理解产品体验、页面结构、交互流程、视觉层级和字段展示。
- 使用 mock 接口理解 API 路由、请求/响应结构、状态流转和 contract 测试。
- 后端实现时参考 mock 接口结构，尽量保持兼容。
- 前端实现时参考原型进行工程化改造。

禁止：

- E2E 验证时使用 mock 数据作为通过依据。
- 在前端写死展示数据（空状态 UI 除外）。
- 真实用户流程依赖离线 fallback、静态假数据、硬编码结果。
- 只看 HTTP 状态码就宣称通过。必须核对接口数据、页面展示和完整数据链路。
- 新增与用户意图无关的功能、视觉风格或后端接口。
- 顺手重构无关代码、静默吞异常、混入无关格式化或风格调整。

## 6. 规格模板索引

详细规格不写在本入口文件中。项目实际规格写入 `docs/superpowers/specs/`；项目实际计划写入 `docs/superpowers/plans/`；研究证据和数据发现写入 `docs/research/`。

`docs/superpowers/specs/` 保存项目实际规格（思考脚手架，经人类确认后供后续阶段消费，完成并确认后按规则归档）；`docs/superpowers/plans/` 保存项目实际实施计划，完成并确认后归档到 `docs/superpowers/plans/archive/`；现状（接口 / 数据 / 行为）以代码、测试、OpenAPI 和 ORM / migration 为准。`docs/research/` 保存领域调研、竞品、数据来源、数据链路、用户闭环、证据和待确认假设；Domain Research spec 主产物为 `docs/superpowers/specs/05-domain-research.md`。默认建议 `.template/` 随项目入库；如果团队选择不入库，必须在 `docs/decision.md` 记录模板源路径和重新安装方式。

`.template/prompt.md` 是阶段 prompt 模板原件，不写项目事实；`docs/prompt.md` 是目标项目运行态 prompt，必须根据目标项目自身已有 prompt、`CLAUDE.md` / `AGENTS.md`、`docs/workflow.yaml`、当前 workflow item 相关 `docs/superpowers/specs/`、`docs/superpowers/plans/` 和 `docs/research/` 生成或更新。阶段切换后必须更新 `docs/prompt.md` 的当前推荐 prompt 和 Prompt 执行台账。

`docs/decision.md` 记录长期决策；当前 spec / plan item 以 `docs/workflow.yaml.current` 为准。研究发现如果影响长期事实，必须从 `docs/research/` 回写到对应 `docs/superpowers/specs/` 或 decision。spec / plan 阶段切换必须更新 `docs/workflow.yaml` 和 `docs/prompt.md`；进入阶段 8-11 执行层后，按 implementation plan task、`docs/prompt.md` 执行台账、`docs/e2e/verify/` 和交付报告跟踪，不新增默认 workflow item。

AI 首次接手项目时，优先阅读：`.template/AI-BOOTSTRAP.md`，用于判断项目阶段、检查文档缺口并向人类推荐下一步 prompt。

### 核心必备

任何产品都需要回答这 4 类问题：

1. Idea Brief：`docs/superpowers/specs/00-idea-brief.md`
2. Product Spec：`docs/superpowers/specs/01-product-spec.md`
3. E2E Acceptance Spec：`docs/superpowers/specs/02-e2e-acceptance.md`
4. Delivery Report：`docs/superpowers/specs/03-delivery-report.md`（一次性交付总结，不进入 workflow）

### 研究 / 数据发现

- Domain Research / Data Discovery：`docs/superpowers/specs/05-domain-research.md`；支撑证据写入 `docs/research/`

### 按需使用

- UI / 原型 / C 端体验：`docs/superpowers/specs/10-ux-prototype.md`
- 架构 / 模块边界 / 技术选型：`docs/superpowers/specs/20-architecture.md`
- 数据模型 / 数据链路：`docs/superpowers/specs/30-data-design.md`
- API 契约 / 页面接口映射：`docs/superpowers/specs/40-api-and-pages.md`
- 前后端实现约束：`docs/superpowers/specs/50-implementation-constraints.md`
- 分阶段实施计划：`docs/superpowers/plans/90-implementation-plan.md`

`05-domain-research.md` 用于在 UX / Architecture 前沉淀竞品、数据来源、数据模型映射、数据流闭环、用户使用闭环和待确认假设。`20/30/40/50` 虽为按需规格，但涉及数据库、外部服务、权限、支付、额度、异步任务、复杂前后端接口、多角色流程或生产数据链路时，进入实施计划前必须补齐对应设计规格。

### 使用规则

- 入口文件只保留全局约束、权威来源和文档索引；不要在本文件维护页面、接口、字段或当前 workflow item / 执行层事实。
- 具体页面、接口、数据、架构、前后端规范按需写入 `docs/superpowers/specs/` 下对应 spec 文件。
- 竞品、领域术语、数据来源、数据链路、用户闭环、证据和待确认假设写入 `docs/research/`；确认后的长期事实必须同步回写对应 spec。
- 具体可执行的下一步 prompt 写入 `docs/prompt.md`；Prompt 执行台账只记录 prompt 执行状态，不得把 `Human Confirmed`、`archived` 等 workflow/content 状态写成 Prompt 状态。长期事实不得只写在 `docs/prompt.md`，必须同步回写对应 spec 或 decision。
- 如果某个规格填充后超过 20 行，保留在独立 spec 文件中，不要内联回本文件。
- 实现前**必须**读取当前 task 直接相关的 spec / plan / research，避免一次性加载无关历史脚手架。
- 每个 spec 和 plan 必须维护内容状态：`Draft / AI Extracted / Human Confirmed / Frozen / Deprecated / Archived`。AI 从代码或文档反填的内容只能标记为 `AI Extracted`，不能冒充人类确认。归档前必须先把文件内内容状态改为 `Archived`，再移动到对应 archive。`docs/workflow.yaml` 另行维护 workflow 状态：`pending / drafting / review / ready / consumed / verified / archived / skipped`；两套状态不得混用。
- 如果存在 `.template/scripts/validate-template.sh`，模板安装、模板修改或交付前应运行 `.template/scripts/validate-template.sh .template`。

## 7. 文档治理

> 详见 `.template/reference/documentation-governance.md`。核心:

- **信息只活在一处**:现状(接口 / 数据 / 行为)→ **代码即真相**(OpenAPI / ORM+迁移 / 测试),不手写;决策(为什么)→ `docs/decision.md`(append-only 封存);当前 spec / plan item → `docs/workflow.yaml.current`;prompt 执行状态 → `docs/prompt.md` 执行台账;实现任务 → active implementation plan;验证证据 → `docs/e2e/verify/`;导航 / 约束 → `README` + 本文件(指向上面的源)。
- **specs / plans 是思考脚手架**:确认、消费、验证完成后先改内容状态为 `Archived`，再移动到各自 archive,不长期维护;现状不抄进 spec 或 plan。
- **长期只维护** `README` + `docs/decision.md` + `docs/workflow.yaml` + `docs/prompt.md` 执行台账(+ 本文件)。其余要么是代码,要么是用完即弃的脚手架或验证证据。

判定一份文档去留:删掉它谁会受影响?它描述会变的现状、还是不变的决策?谁在何时需要它?
