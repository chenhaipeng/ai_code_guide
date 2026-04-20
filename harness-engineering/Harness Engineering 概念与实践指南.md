# Harness Engineering 概念与实践指南

> 整理时间：2026-04-20（v2 修订：补全官方源验证、新增 Martin Fowler 框架、工具现状评估）
>
> 信息来源：实测核验 [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/)、[Anthropic Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps)、[Martin Fowler - Birgitta Böckeler](https://martinfowler.com/articles/harness-engineering.html)、[Stripe Minions](https://stripe.com/blog/minions)、[Mitchell Hashimoto 博客](https://mitchellh.com/writing/my-ai-adoption-journey)、[Can Bölük - The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/)、[LangChain - Anatomy of an Agent Harness](https://blog.langchain.dev/anatomy-of-an-agent-harness/)

---

## 0. 什么是 Harness Engineering

### 0.1 一句话定义

> **Agent = Model + Harness。Harness 是模型之外的一切——系统提示词、工具调用、文件系统、沙箱环境、编排逻辑、约束机制、反馈回路。**

模型是 CPU，Harness 是操作系统。CPU 再强，OS 拉胯也白搭。

> **术语归属**：由 OpenAI 于 2026 年 2 月 11 日在博客 [Harness Engineering: Leveraging Codex in an Agent-First World](https://openai.com/index/harness-engineering/) 中正式提出。

### 0.2 Harness Engineering 解决什么问题

当 AI Agent 拥有了强大的代码生成能力后，如何确保其输出的**可靠性、一致性和长期可维护性**。具体来说：

| 问题 | 表现 |
|---|---|
| 重复犯错 | 同一类错误反复出现 |
| 做到一半放弃 | 长任务中途质量骤降 |
| 越跑越蠢 | 上下文膨胀导致幻觉增多 |
| 架构漂移 | 沿袭坏模式，越跑越偏 |
| 无法验证 | 不知道自己做对了没有 |

**核心论点**：模型决定了系统的上限，Harness 决定了系统的底线。与其纠结选哪个模型，不如先把 Harness 搭好。

### 0.3 实验证据

**实验一：Can Bölük 的编辑工具实验**（来源：[The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/)）

在自研 Harness [oh-my-pi](https://github.com/can1357/oh-my-pi) 上测试 16 个模型、3 种编辑工具（`apply_patch`、`str_replace`、自创的 `hashline`），180 个任务，每个任务跑 3 次。结果：**Grok Code Fast 1 使用 `apply_patch` 时成功率 6.7%，换成 `hashline` 后跳到 68.3%**——同一模型，只换了编辑工具，成功率翻了 10 倍。Gemini 的改进幅度甚至超过了大多数模型升级带来的提升，而且零训练算力，只花了约 $300 的 API 费用。

**实验二：Anthropic 的 Solo vs Full Harness 对比**（来源：[Anthropic 官方博客](https://www.anthropic.com/engineering/harness-design-long-running-apps)）

同一模型（Opus 4.5）、同一 prompt（"Create a 2D retro game maker"），单 Agent vs 三 Agent Harness：

| Harness 类型 | 耗时 | 费用 | 效果 |
|---|---|---|---|
| Solo（单 Agent） | 20 min | $9 | 核心功能坏了，实体无法响应输入 |
| Full Harness（Planner + Generator + Evaluator） | 6 hr | $200 | 可以实际玩游戏，功能完整 |

> **结论**：不是模型不行，是 Harness 决定了模型能发挥出多少。先排查 Harness，再考虑换模型。

---

## 1. Harness 和 Prompt / Context Engineering 的关系

三者是**嵌套关系**，不是并列关系：

| 层级 | 解决的核心问题 | 典型工作 |
|---|---|---|
| **Prompt Engineering** | 表达——怎么写好指令 | 系统提示词设计、Few-shot、思维链引导 |
| **Context Engineering** | 信息——给 Agent 看什么 | 上下文管理、RAG、记忆注入、Token 优化 |
| **Harness Engineering** | 执行——整个系统怎么防崩、怎么量化、怎么持续运转 | 文件系统、沙箱、约束执行、熵管理、反馈回路 |

简单任务 Prompt 最重要；依赖外部知识时 Context 关键；**但在长链路、可执行、低容错的真实场景中，Harness 才是决定成败的东西**。

---

## 2. 六层架构

一个成熟的 Harness 有清晰的层次结构：

| 层级 | 名称 | 解决什么问题 | 关键设计 | 类比 |
|---|---|---|---|---|
| **L1** | **信息边界层** | Agent 该知道什么、不该知道什么 | 角色定义、任务状态结构化 | 岗位说明书 |
| **L2** | **工具系统层** | Agent 怎么跟外部世界交互 | 工具选拔、调用时机、结果提炼 | 办公工具 |
| **L3** | **执行编排层** | 多步骤任务怎么串起来 | 理解→判断→分析→生成→检查的完整轨道 | 标准操作流程 |
| **L4** | **记忆与状态层** | 长任务中间结果怎么管 | 独立管理任务状态、中间产物和长期记忆 | 项目管理系统 |
| **L5** | **评估与观测层** | Agent 怎么知道自己做对了没有 | 独立于生成过程的验证机制 | 质检流程 |
| **L6** | **约束、校验与恢复层** | 出错了怎么办 | 预设规则拦截、失败时提供重试或回滚 | 红线规则和应急预案 |

> **投入建议**：不要一开始就搭齐六层。从 **L1（信息边界）** 和 **L6（约束与恢复）** 入手，这两层投入产出比最高。中间的层次随项目复杂度增长逐步补齐。

---

## 3. 模型做不到的，就是 Harness 要补的

| 模型做不到 | Harness 怎么补 | 核心组件 |
|---|---|---|
| 记住多轮对话历史 | 维护对话历史，每次请求时拼进上下文 | **记忆系统** |
| 执行代码、跑命令 | 提供 Bash + 代码执行环境 | **通用执行环境** |
| 获取实时信息 | Web Search、MCP 工具 | **外部知识获取** |
| 操作文件和环境 | 文件系统抽象 + Git 版本控制 | **文件系统** |
| 知道自己做对了没有 | 沙箱环境 + 测试工具 + 浏览器自动化 | **验证闭环** |
| 在长任务中保持连贯 | 上下文压缩、记忆文件、进度追踪 | **上下文管理** |

---

## 4. 关键经验：上下文膨胀与衰减

### 4.1 Anthropic 官方验证的"上下文焦虑"

Anthropic 在 Harness Design 博客中明确描述了这一现象：

> *"Some models also exhibit 'context anxiety,' in which they begin wrapping up work prematurely as they approach what they believe is their context limit."*

具体表现：Sonnet 4.5 在上下文快填满时变得犹豫，倾向于草草收工。

**Anthropic 的解法**：**Context Resets**——启动全新 Agent，通过结构化交接文档恢复状态。这不同于 compaction（原地压缩），reset 提供干净的上下文窗口，代价是交接文档必须足够完整。

> *"A reset provides a clean slate, at the cost of the handoff artifact having enough state for the next agent to pick up the work cleanly."*

### 4.2 社区观察：上下文的衰减区间

> ⚠️ **以下数据来自社区观察，未经 OpenAI/Anthropic 官方论文验证。**

社区中有工程师观察到：168K token 的上下文窗口，用到约 40% 时，Agent 输出质量开始明显下降：

| 区间 | 占比 | 表现 |
|---|---|---|
| **Smart Zone** | 0 - ~40% | 推理聚焦、工具调用准确、代码质量高 |
| **Dumb Zone** | 超过 ~40% | 幻觉增多、兜圈子、格式混乱、低质量代码 |

**工程建议**：监控上下文利用率。超过阈值时触发上下文压缩或任务交接，而不是继续塞信息。具体阈值因模型和任务而异，建议自行实测确定。

---

## 5. 从零搭建 Harness 的行动清单

### 5.1 P0：立即做（投入产出比最高）

| 行动 | 为什么 | 参考实践 |
|---|---|---|
| 创建 `AGENTS.md` 并持续维护 | Agent 每次启动自动加载，犯错就更新，形成反馈循环 | Hashimoto 每一行对应一个历史失败案例 |
| 构建自定义 Linter + 修复指令 | 错误消息里直接告诉 Agent 怎么改，纠错的同时在"教" | OpenAI 的 Linter 报错自带修复方法 |
| 把团队知识放进仓库 | 写在 Slack/Wiki/Docs 里的知识对 Agent 等于不存在 | OpenAI 以仓库为唯一事实源 |

> **常见误区**：把 `AGENTS.md` 当"超级 System Prompt"写，所有规则塞进一个文件。正确做法是像 OpenAI 一样——`AGENTS.md` 只当目录用（约 100 行），详细规则放子文档按需加载。

### 5.2 P1：P0 做完之后

| 行动 | 为什么 | 参考实践 |
|---|---|---|
| 分层管理上下文 | 渐进式披露，不要把所有东西塞进一个文件 | OpenAI AGENTS.md 当目录用 |
| 建立进度文件和功能列表 | JSON 格式追踪功能状态，Agent 不太会乱改结构化数据 | Anthropic 初始化 Agent + 编码 Agent 两阶段 |
| 给 Agent 端到端验证能力 | 浏览器自动化让 Agent 能像用户一样验证功能 | Anthropic 用 Playwright/Puppeteer MCP |
| 控制上下文利用率 | 监控上下文膨胀，增量执行，适时触发压缩或重置 | Anthropic 的 Context Resets 机制 |

### 5.3 P2：有余力再考虑

| 行动 | 为什么 | 参考实践 |
|---|---|---|
| Agent 专业化分工 | 每个 Agent 携带更少无关信息，留在 Smart Zone | Carlini 的去重/优化/文档 Agent |
| 定期垃圾回收 | 确保清理速度跟得上生成速度 | OpenAI 的后台清理 Agent |
| 可观测性集成 | 把"性能优化"从玄学变成可度量的工作 | OpenAI 接入 Chrome DevTools |

---

## 6. Harness 成熟度评估

| 阶段 | 特征 | 工程师角色 |
|---|---|---|
| **Level 0**：无 Harness | 直接给 Agent prompt，无结构化约束 | 手动写代码 + 偶尔使用 AI |
| **Level 1**：基础约束 | `AGENTS.md` + 基础 Linter + 手动测试 | 主要写代码，AI 辅助 |
| **Level 2**：反馈回路 | CI/CD 集成 + 自动化测试 + 进度追踪 | 规划 + 审查为主 |
| **Level 3**：专业化 Agent | 多 Agent 分工 + 分层上下文 + 持久化记忆 | 环境设计 + 管理为主 |
| **Level 4**：自治循环 | 无人值守并行化 + 自动化熵管理 + 自修复 | 架构师 + 质量把关者 |

---

## 7. 一线团队实战摘要

### 7.1 OpenAI：三人、五月、百万行、零手写代码

| 指标 | 数值 |
|---|---|
| 团队规模 | 3 名工程师（后扩至 7 人） |
| 代码规模 | 约 100 万行 |
| 手写代码 | **0 行** |
| 合并 PR 数 | 约 1,500 个 |
| 人均吞吐 | 3.5 PR/人/天 |

核心方法论：

1. **地图式文档**：`AGENTS.md` 只有约 100 行，当目录用，渐进式披露。详细知识放 `docs/` 目录结构化管理
2. **机械化约束**：自定义 Linter + 结构测试强制执行架构规则，报错自带修复方法。原文：*"If it cannot be enforced mechanically, agents will deviate."*
3. **Agent 可读性优先（Agent Legibility）**：代码优先为 Agent 优化可读性，而非人类。"Any component it can't access in-context while running effectively doesn't exist."
4. **仓库即事实源**：写在 Slack/Google Docs 里的知识对 Agent 来说等于不存在，必须放进仓库并版本化
5. **可观测性接入**：Chrome DevTools Protocol 让 Agent 能自己验证 UI；日志、指标、Traces 全部对 Agent 可读（LogQL/PromQL/TraceQL）
6. **熵管理**：早期每周五花 20% 时间人工清理"AI slop"，后改为后台 Agent 定期扫描不一致和违规，自动提交清理 PR
7. **Ralph Wiggum Loop**：Agent 自己 review → 修改 → 再 review 的循环，配合 Agent 间的交叉审查，人类审查逐步后置

> **重要细节**：OpenAI 团队强调，他们选择了"无聊"的技术栈——因为在训练集中表现好、API 稳定、可组合的技术更容易被 Agent 正确使用。某些情况下，让 Agent 重新实现功能子集比依赖不透明的第三方库更划算。

### 7.2 Anthropic：GAN 式三智能体架构 + Context Resets

三 Agent 各司其职：

| Agent | 职责 | 关键设计 |
|---|---|---|
| **Planner** | 将 1-4 句简单 prompt 扩展为完整产品规格 | 保持高层，不过度指定技术细节，避免错误级联 |
| **Generator** | 按 feature 逐个 Sprint 执行 | 每个 Sprint 结束自我评估，再交 Evaluator |
| **Evaluator** | 用 Playwright 实际运行应用，多维度打分 | 与 Generator 协商 Sprint Contract，定义"完成标准"后再动手 |

**官方实验数据**（来源：Anthropic 博客，同一 prompt "Create a 2D retro game maker"）：

| Harness 类型 | 耗时 | 费用 | 效果 |
|---|---|---|---|
| Solo（单 Agent） | 20 min | $9 | 初始界面看起来正常，但核心游戏功能坏了，实体无法响应输入 |
| Full Harness（三 Agent） | 6 hr | $200 | 可以实际玩游戏，有完整的 sprite 编辑器、AI 辅助功能、可运行的 play mode |

Evaluator 捕获的具体问题示例（来自 Anthropic 博客日志）：

| Sprint 合约条款 | Evaluator 发现 |
|---|---|
| 矩形填充工具允许点击拖拽填充矩形区域 | **FAIL** — 工具只在拖拽起止点放置 tile，没有正确触发 `fillRectangle` |
| 用户可以选中并删除实体生成点 | **FAIL** — Delete 键处理逻辑要求同时设置 `selection` 和 `selectedEntityId`，但点击实体只设置了后者 |
| 用户可以通过 API 重排动画帧 | **FAIL** — 路由定义顺序问题，FastAPI 把 `reorder` 当作 `frame_id` 解析，返回 422 |

三个关键发现：

1. **上下文焦虑**：Agent 上下文快满时草草收工。解法是 **Context Resets**——启动全新 Agent，通过结构化交接文档恢复状态，类似重启进程解决内存泄漏。注意：这不等于 compaction（原地压缩），reset 提供干净上下文窗口
2. **自我评价偏差**：Agent 自信地夸自己做得好，实际质量一般。解法是生成和评估交给两个独立的 Agent
3. **Harness 演化原则**：每次模型升级后，Harness 都应重新审视和简化

> Anthropic 原话：*"Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing."*
>
> Anthropic 在升级到 Opus 4.6 后，成功去掉了 Sprint 分解机制和 Context Resets，因为新模型原生能处理更长的任务。**这验证了 Harness 演化原则：模型在进步，Harness 应随之简化。**

### 7.3 Stripe：Minions 系统，每周 1300+ 无人值守 PR

| 组件 | 作用 |
|---|---|
| **Devbox** | AWS EC2 预装环境，10 秒启动，"牲口不是宠物" |
| **编排状态机** | 混合确定性节点（lint、push）和 Agent 节点（实现、修 CI） |
| **Toolshed MCP** | 集中式 MCP 服务，近 500 个工具 |
| **反馈回路** | Pre-push hook 秒级修 lint；推送后最多 2 轮 CI（300 万+ 测试） |

### 7.4 Mitchell Hashimoto：单 Agent 深度参与模式

坚持一次只跑一个 Agent，保持深度参与。六步进阶：

1. 放弃聊天模式，让 Agent 直接干活
2. 复现自己的工作（做两次）
3. 下班前启动 Agent 做深度调研
4. 外包确定性任务后台跑
5. 工程化 Harness——Agent 每犯一错，就工程化一个方案让它永远不再犯
6. 目标是 10-20% 的工作时间有后台 Agent 在跑

---

## 8. 尚未解决的问题

| 问题 | 现状 |
|---|---|
| **棕地项目怎么改造？** | 公开成功案例以绿地项目为主，但 Martin Fowler 的 Birgitta Böckeler 指出：绿地团队可以从第一天就把 Harnessability 烤进去，而棕地团队面临"最需要 Harness 的地方最难搭建"的困境。她提出了 **Harnessability** 的概念（见第 13 节），以及"按拓扑分类的 Harness 模板"思路，但尚无成熟实践 |
| **怎么验证 Agent 做对了事？** | Martin Fowler 把这称为 **Behaviour Harness**，是三类 Harness 中最难的一类。擅长"约束不做错事"，但"验证做对了"远未解决。用 AI 生成的测试验证 AI 生成的代码 = 用同一双眼睛检查自己的作业。Thoughtworks 团队在尝试 [Approved Fixtures](https://lexler.github.io/augmented-coding-patterns/patterns/approved-fixtures/) 模式，但适用范围有限 |
| **Harness 该做厚还是做薄？** | Anthropic 的实验给出了方向：随着模型能力提升，Harness 应逐步简化（如 Opus 4.6 去掉了 Sprint 分解和 Context Resets）。但简化需要系统化的方法——Anthropic 的做法是逐个移除组件并对比结果。场景决定厚度 |
| **AI 生成代码的长期可维护性？** | OpenAI 承认："What we don't yet know is how architectural coherence evolves over years in a fully agent-generated system." LLM 代码经常重新实现已有功能，长期效果未知 |
| **缺乏统一的可复用框架** | 见第 14 节详细讨论 |

---

## 9. 反模式

### 9.1 一上来就搭齐六层

→ 投入大、见效慢。**从 L1 + L6 开始，逐步扩展**。

### 9.2 把 AGENTS.md 当百科全书

→ 上下文窗口被撑爆，Agent 反而更蠢。**当目录用，约 100 行**。

### 9.3 Agent 表现不好就换模型

→ Can.ac 实验证明同一模型只换工具调用格式就能差 10 倍。**先排查 Harness**。

### 9.4 只靠文档约束，不靠工具强制执行

→ OpenAI 原话：不能机械化强制执行的约束，Agent 就会偏离。**约束 = 工具，不是文档**。

### 9.5 忽视熵管理

→ AI 生成代码的速度远超人类审查速度，没有主动清理机制，技术债会指数级增长。

---

## 10. Martin Fowler 框架：前馈、反馈与三类 Harness

> 来源：[Birgitta Böckeler - Harness Engineering for Coding Agent Users](https://martinfowler.com/articles/harness-engineering.html)（2026-04-02，Martin Fowler 站点）

### 10.1 核心模型：Feedforward + Feedback

Birgitta Böckeler（Thoughtworks Distinguished Engineer）提出了一个面向日常开发者的 Harness 实操模型：

| 方向 | 含义 | 时机 | 示例 |
|---|---|---|---|
| **Feedforward（前馈）** | 预判 Agent 行为，**在行动之前**引导 | Agent 生成代码前 | `AGENTS.md`、Skills、LSP、架构文档、bootstrap 脚本 |
| **Feedback（反馈）** | 观察 Agent 结果，**在行动之后**检查并自我修正 | Agent 生成代码后 | Linter、测试、CI、代码审查、Playwright 自动化测试 |

> 两者缺一不可：只有前馈 = Agent 不知道自己做错了（反复犯同样的错）；只有反馈 = Agent 不知道什么是对的（每次都不同）。

### 10.2 两个执行维度

| 类型 | 本质 | 速度 | 可靠性 | 示例 |
|---|---|---|---|---|
| **Computational（计算型）** | 确定性，CPU 执行 | 毫秒~秒级 | 高 | Linter、类型检查、结构测试、dep-cruiser |
| **Inferential（推理型）** | 语义分析，GPU/NPU 执行 | 秒~分钟级 | 非确定性 | AI 代码审查、LLM as Judge、语义审查 |

**实践建议**：Computational 放 pre-commit hook（每次修改都跑），Inferential 放 CI 阶段（定期跑）。

### 10.3 三类 Harness（按难度排序）

| 类型 | 内容 | 难度 | 现状 |
|---|---|---|---|
| **Maintainability Harness** | 代码风格、重复检测、架构边界、复杂度控制 | 最容易 | 工具成熟（ESLint/Ruff/ArchUnit），立即可用 |
| **Architecture Fitness Harness** | 性能要求、可观测性规范、依赖约束 | 中等 | 需要定制 Fitness Function |
| **Behaviour Harness** | 功能正确性验证 | **最难** | **尚未解决**——AI 生成的测试验证 AI 生成的代码 |

### 10.4 Harness 的分布在开发生命周期中

```
[Feedforward]                              [Feedback]
AGENTS.md ─┐                          ┌─ ESLint / Prettier
LSP ───────┤                          ├─ Type Check (tsc / mypy)
架构文档 ──┤─→ Agent 生成代码 ─→     ├─ 单元测试
Skills ────┤                          ├─ AI Code Review
Bootstrap ─┘                          ├─ 人工 Review
                                      └─ Playwright E2E
                                              ↓
                                        [CI Pipeline]
                                      集成测试 + 覆盖率
                                      Architecture Review
                                      Mutation Testing
```

---

## 11. Harnessability：不是所有项目都一样好驾驭

> 来源：[Martin Fowler - Birgitta Böckeler](https://martinfowler.com/articles/harness-engineering.html)

Martin Fowler 文章引入了 **Harnessability（可驾驭性）** 的概念——项目的结构属性决定了给它加 Harness 有多容易。

| 容易加 Harness | 难加 Harness |
|---|---|
| 强类型语言（TypeScript / Java） | 弱类型语言（Python / JS without TS） |
| 有清晰模块边界 | 意大利面条代码 |
| 现有测试覆盖 | 零测试 |
| 标准化技术栈 | 高度定制化的架构 |
| 绿地项目 | 棕地项目（遗留代码、技术债累积） |

> **Birgitta Böckeler 原话**：*"Greenfield teams can bake harnessability in from day one. Legacy teams, especially with applications that have accrued a lot of technical debt, face the harder problem: the harness is most needed where it is hardest to build."*

**工程建议**：如果你的项目 Harnessability 低，先做提升 Harnessability 的基建（加类型检查、拆分模块、补测试），再加 Harness 约束。

---

## 12. Harness 演化原则

> 来源：[Anthropic Harness Design 博客](https://www.anthropic.com/engineering/harness-design-long-running-apps)

Anthropic 通过实际实验验证了一个关键原则：

> *"Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing."*

**这意味着**：

1. **每次模型升级后，都应审视 Harness**——删掉不再需要的约束
2. **不要过度工程化**——Anthropic 在升级到 Opus 4.6 后，成功去掉了 Sprint 分解机制和 Context Resets
3. **简化方法**：逐个移除组件，对比输出质量，确认哪些组件仍是 load-bearing（承重的）
4. **但简化不代表不做**——即使模型更强了，在模型能力边界附近的任务仍然需要 Evaluator 的检查

---

## 13. 当前工具现状：方法论还是产品？

### 13.1 核心事实

> **截至 2026 年 4 月，Harness Engineering 主要是方法论，不是产品。**
>
> 提出 Harness Engineering 的团队（OpenAI、Anthropic、Stripe），没有一个把完整的 Harness 开源。所有公开的成功案例都依赖大量定制开发。

### 13.2 各家 Harness 的开源状态

| 团队 | 他们的 Harness | 有开源吗 |
|---|---|---|
| OpenAI | 自定义 Linter + 结构测试 + 后台垃圾回收 Agent + Chrome DevTools MCP | ❌ 未开源 |
| Anthropic | 三 Agent 编排（Planner/Generator/Evaluator）+ Playwright MCP | ❌ 仅开源了 [frontend-design skill](https://github.com/anthropics/claude-code/blob/main/plugins/frontend-design/skills/frontend-design/SKILL.md) |
| Stripe | Devbox 环境 + 编排状态机 + Toolshed MCP（500 个工具） | ❌ 未开源 |
| Can Bölük | Hashline 编辑工具（行号哈希替代字符串替换） | ✅ [oh-my-pi](https://github.com/can1357/oh-my-pi) |

### 13.3 已有的可用组件（散落的积木）

| 组件 | 工具 | 状态 | 覆盖 Harness 层 |
|---|---|---|---|
| Feedforward 指令 | `AGENTS.md`（60k+ 项目使用，Linux Foundation 标准） | ✅ 可用 | L1 信息边界 |
| Feedforward 流程 | Superpowers Skills（TDD、brainstorming、debugging 等） | ✅ 可用 | L1 + L3 |
| 机械约束 | ESLint、Ruff、dep-cruiser、ArchUnit | ✅ 可用，需自己写规则 | L6 约束层 |
| 反馈循环 | pre-commit hook + CI | ✅ 可用，需自己串 | L5 + L6 |
| Agent 友好报错 | 需自定义 Linter 规则，报错信息带修复指引 | ⚠️ 需大量定制 | L6 约束层 |
| 多 Agent 编排 | Claude Agent SDK / LangGraph | ⚠️ 框架有，编排逻辑需自研 | L3 编排层 |
| 熵管理 | 无现成工具 | ❌ 空白 | L4 + L5 |
| Context Resets | 无现成工具 | ❌ 空白 | L4 状态层 |
| Behaviour Harness | 无现成工具 | ❌ 空白 | L5 评估层 |

### 13.4 与现有工具的关系

一个常见的困惑：**Claude Code + Superpowers 已经在做 Harness 的事了，为什么还要一个新概念？**

| | Claude Code + Superpowers | Harness Engineering |
|---|---|---|
| **解决什么** | "用什么工具和 Agent 交互" | "怎么让 Agent 在你的项目中可靠工作" |
| **关注点** | 客户端功能、Skills 质量 | 项目级约束、反馈回路、熵管理 |
| **谁在做** | 你个人，每次对话 | 你团队，持续维护 |
| **产出** | 每次对话的结果 | 项目仓库里的 AGENTS.md、Linter、CI、架构文档 |
| **跨客户端** | 绑定 Claude Code | 不管用 Claude Code / OpenCode / Cursor 都适用 |

**一句话**：Superpowers 告诉 Agent **"应该怎么做"**（TDD 流程、debugging 流程），Harness Engineering 告诉你 **"怎么确保 Agent 一定会这么做"**（机械约束、反馈回路、熵管理）。前者是方法，后者是保证方法被执行的系统。

### 13.5 Harness 模板的设想

Martin Fowler 提出了 **Harness Templates** 的概念：大多数企业有几个常见的服务拓扑（CRUD 服务、事件处理器、数据仪表盘），可以为每种拓扑预置一套 Guides + Sensors 的捆绑包，团队按拓扑选用。

> 这一想法目前仍处于设想阶段，尚无成熟实现。

---

## 14. 术语澄清

容易混淆的三个层级：

| 术语 | 含义 | 例子 |
|---|---|---|
| **LLM 模型** | 提供推理和生成能力的语言模型 | Claude、GPT、Gemini |
| **Coding Agent 客户端** | 调用 LLM 的终端/IDE 工具，本身是一个 Harness 实现 | Claude Code、OpenCode、Cursor、Codex CLI、Aider |
| **Harness Engineering** | 围绕 Agent 构建工程基础设施的方法论 | 自定义 Linter、熵管理、反馈回路、上下文管理策略 |
| **AGENTS.md** | Agent 指令文件格式（Linux Foundation 标准） | 60k+ 开源项目使用，跨客户端通用 |

> **注意**：`AGENTS.md` 是 Harness 的一个组件（Feedforward Guide），不是 Harness Engineering 本身。它解决的是"怎么给 Agent 看指令"的问题，不涉及反馈回路、熵管理、多 Agent 编排等核心议题。

---

## 15. 参考链接

### 核心文章
- [OpenAI - Harness Engineering: Leveraging Codex in an Agent-First World](https://openai.com/index/harness-engineering/)（2026-02-11，术语提出方）
- [Anthropic - Harness Design for Long-Running Application Development](https://www.anthropic.com/engineering/harness-design-long-running-apps)（2026-03-24）
- [Anthropic - Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)（前篇）
- [Birgitta Böckeler - Harness Engineering for Coding Agent Users](https://martinfowler.com/articles/harness-engineering.html)（2026-04-02，Martin Fowler 站点，面向日常开发者的实操框架）
- [Stripe - Minions: Stripe's One-Shot, End-to-End Coding Agents](https://stripe.com/blog/minions)
- [Mitchell Hashimoto - My AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey)
- [Can Bölük - The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/)（16 模型编辑工具对比实验）
- [LangChain - The Anatomy of an Agent Harness](https://blog.langchain.dev/anatomy-of-an-agent-harness/)

### 标准与工具
- [AGENTS.md](https://agents.md/) — Linux Foundation 下的开放标准，60k+ 项目使用
- [Can Bölük - oh-my-pi](https://github.com/can1357/oh-my-pi) — 唯一开源的 Harness 优化实验工具

### 本工程相关文档
- [Claude Code 核心概念指引](../claudecode/Claude%20Code%20核心概念指引.md)
- [Claude Code 使用最佳实践指南](../claudecode/Claude%20Code%20使用最佳实践指南.md)
- [OpenCode + omo 使用指南](../opencode/📚%20OpenCode%20+%20Oh%20My%20OpenCode%20使用最佳实践指南.md)

---

## 16. 一句话总结

> **模型决定上限，Harness 决定底线。** Harness Engineering 的核心是承认模型有边界，然后把边界之外的需求一个个工程化地补上。先搭好 L1（信息边界）和 L6（约束恢复），再随项目复杂度逐步扩展。
>
> 但也要清醒认识到：**截至 2026 年 4 月，这主要是一堆方法论和博客文章，不是开箱即用的产品。** 你能做的最实际的事是：写好 `AGENTS.md`、配好 Linter、搭好 pre-commit hook，然后持续迭代。
