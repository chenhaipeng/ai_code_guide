# Harness Engineering 概念与实践指南

> 整理时间：2026-04-19
>
> 信息来源：实测核验 [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/)、[Anthropic Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps)、[Stripe Minions](https://stripe.com/blog/minions)、[Mitchell Hashimoto 博客](https://mitchellh.com/writing/my-ai-adoption-journey)、[Martin Fowler - Birgitta Böckeler](https://martinfowler.com/articles/harness-engineering.html)、[Can.ac - The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/)、[LangChain - Anatomy of an Agent Harness](https://blog.langchain.dev/anatomy-of-an-agent-harness/)

---

## 0. 什么是 Harness Engineering

### 0.1 一句话定义

> **Agent = Model + Harness。Harness 是模型之外的一切——系统提示词、工具调用、文件系统、沙箱环境、编排逻辑、约束机制、反馈回路。**

模型是 CPU，Harness 是操作系统。CPU 再强，OS 拉胯也白搭。

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

### 0.3 一个实验说明一切

Can.ac 做了一个实验：**同一个模型，只换了文件编辑接口的调用方式**，编码基准分数从 **6.7% 直接跳到 68.3%**。模型没变，变的是 Harness。

LangChain 也印证了这一点：优化 Agent 运行环境后，在 Terminal Bench 2.0 上从全球第 30 名升到第 5 名。模型没换，Harness 换了。

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

## 4. 关键经验：上下文的 40% 阈值

Dex Horthy 观察到一个关键现象：168K token 的上下文窗口，用到大约 40% 时，Agent 输出质量开始明显下降。

| 区间 | 占比 | 表现 |
|---|---|---|
| **Smart Zone** | 0 - ~40% | 推理聚焦、工具调用准确、代码质量高 |
| **Dumb Zone** | 超过 ~40% | 幻觉增多、兜圈子、格式混乱、低质量代码 |

Anthropic 也发现了类似的"上下文焦虑"现象：Sonnet 4.5 在上下文快填满时变得犹豫，倾向于提前收工。

**工程建议**：设置 40% 阈值告警。超过时触发上下文压缩或任务交接，而不是继续塞信息。

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
| 控制上下文利用率 | 尽量不超过 40%，增量执行 | Dex Horthy 的 Smart Zone / Dumb Zone |

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

五大方法论：

1. **地图式文档**：`AGENTS.md` 只有约 100 行，当目录用，渐进式披露
2. **机械化约束**：自定义 Linter + 结构测试强制执行架构规则，报错自带修复方法
3. **可观测性接入**：Chrome DevTools、日志、指标全部对 Agent 可读
4. **熵管理**：后台 Agent 定期扫描不一致和违规，自动提交清理 PR
5. **仓库即事实源**：写在 Slack/Google Docs 里的知识对 Agent 来说等于不存在

> OpenAI 原话：*"If it cannot be enforced mechanically, agents will deviate."*

### 7.2 Anthropic：GAN 式三智能体架构 + Context Resets

| 组件 | 职责 |
|---|---|
| **Planner** | 拿到简短产品描述，扩展成完整产品规格 |
| **Generator** | 按功能逐个 Sprint 执行 |
| **Evaluator** | 用 Playwright 实际运行应用，多维度打分 |

两个关键发现：

- **上下文焦虑**：Agent 上下文快满时草草收工。解法是 **context resets**——启动全新 Agent，通过结构化交接文档恢复状态，类似重启进程解决内存泄漏
- **自我评价偏差**：Agent 自信地夸自己做得好，实际质量一般。解法是生成和评估交给两个独立的 Agent

> Anthropic 原话：*"Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing."*

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
| **棕地项目怎么改造？** | 所有公开成功案例全是绿地项目（从零开始），零方法论。已有代码库引入 Harness 是更大挑战 |
| **怎么验证 Agent 做对了事？** | 擅长"约束不做错事"，但"验证做对了"远未解决。用 AI 生成的测试验证 AI 生成的代码 = 用同一双眼睛检查自己的作业 |
| **Harness 该做厚还是做薄？** | Manus 越做越简单 vs OpenAI 越做越复杂。场景决定。随着模型变强，已有 Harness 应定期简化 |
| **AI 生成代码的长期可维护性？** | LLM 代码经常重新实现已有功能，长期效果未知 |

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

## 10. 术语澄清：Harness Engineering vs Coding Agent 客户端

容易混淆的概念：

| 术语 | 含义 | 例子 |
|---|---|---|
| **Harness Engineering** | 围绕 Agent 构建工程基础设施的**方法论** | 自定义 Linter、熵管理、反馈回路、上下文管理策略 |
| **Coding Agent 客户端** | 调用 LLM 的**终端/IDE 工具** | Claude Code、OpenCode、Cursor、Codex CLI、Aider |

两者关系：**Coding Agent 客户端本身也是一个 Harness 的实现**，但 Harness Engineering 讨论的是比"选哪个客户端"更底层的问题——不管你用哪个客户端，都需要考虑约束、验证、熵管理和反馈回路。

---

## 11. 参考链接

### 核心文章
- [OpenAI - Harness Engineering: Leveraging Codex in an Agent-First World](https://openai.com/index/harness-engineering/)
- [Anthropic - Harness Design for Long-Running Application Development](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- [Stripe - Minions: Stripe's One-Shot, End-to-End Coding Agents](https://stripe.com/blog/minions)
- [Mitchell Hashimoto - My AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey)
- [Birgitta Böckeler - Harness Engineering (Martin Fowler)](https://martinfowler.com/articles/harness-engineering.html)
- [LangChain - The Anatomy of an Agent Harness](https://blog.langchain.dev/anatomy-of-an-agent-harness/)
- [Can Bölük - The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/)

### 本工程相关文档
- [Claude Code 核心概念指引](../claudecode/Claude%20Code%20核心概念指引.md)
- [Claude Code 使用最佳实践指南](../claudecode/Claude%20Code%20使用最佳实践指南.md)
- [OpenCode + omo 使用指南](../opencode/📚%20OpenCode%20+%20Oh%20My%20OpenCode%20使用最佳实践指南.md)

---

## 12. 一句话总结

> **模型决定上限，Harness 决定底线。** Harness Engineering 的核心是承认模型有边界，然后把边界之外的需求一个个工程化地补上。先搭好 L1（信息边界）和 L6（约束恢复），再随项目复杂度逐步扩展。
