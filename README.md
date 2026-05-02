# AI Code Guide — AI 编程工具最佳实践文档集

> 整理时间：2026-04-19
> 最近更新：2026-05-03

一套实测核验的 AI 编程工具最佳实践文档。每份文档基于实际 GitHub 仓库验证，不引用未核实数据。

---

## 文档导航

### Claude Code 系列

| 文档 | 定位 | 适合 |
|---|---|---|
| [Claude Code 核心概念指引](claudecode/Claude%20Code%20核心概念指引.md) | 7 大核心概念精炼参考 | 想理解 CLAUDE.md / Skills / Agents / Hooks / MCP 的机制 |
| [Claude Code 使用最佳实践指南](claudecode/Claude%20Code%20使用最佳实践指南.md) | 索引 + 实践要点 | 日常使用参考，"我应该装什么"的快速答案 |
| [Claude Code Plugin Marketplace 完全指南](claudecode/Claude%20Code%20Plugin%20Marketplace%20完全指南.md) | 插件市场全景 + 安装指南 | 想了解有哪些市场/插件可装 |
| [claude-mem 使用指南](claudecode/claude-mem%20使用指南与最佳实践.md) | 跨会话记忆插件专题 | 痛点：跨会话上下文丢失 |

### 跨工具系列

| 文档 | 定位 | 适合 |
|---|---|---|
| [Harness Engineering 概念与实践指南](harness-engineering/Harness%20Engineering%20概念与实践指南.md) | Harness 工程方法论 + 实战案例 | "怎么给 Agent 搭好基础设施" |
| [OpenCode + omo 使用指南](opencode/📚%20OpenCode%20+%20Oh%20My%20OpenCode%20使用最佳实践指南.md) | OpenCode + Oh My OpenAgent 专题 | 跨模型/省钱型用户 |

### 插件专题

| 文档 | 定位 | 适合 |
|---|---|---|
| [Superpowers 使用最佳实践指南](superpower/Superpowers%20使用最佳实践指南.md) | 流程纪律插件（14 skill） | 痛点：AI 不守纪律、偷懒、跳验证 |
| [everything-claude-code 深度使用指南](claudecode/everything-claude-code%20深度使用指南.md) | 大型 skill 包挑选指南 | 想从 ECC 中按需挑选 skill |
| [oh-my-claudecode 使用最佳实践指南](oh-my-claudecode/oh-my-claudecode%20使用最佳实践指南.md) | 多 agent 编排插件 for Claude Code | 想给 Claude Code 加 Team/并行执行 |
| [oh-my-codex 使用最佳实践指南](oh-my-codex/oh-my-codex%20使用最佳实践指南.md) | 多 agent 编排插件 for Codex CLI | 想给 Codex CLI 加编排 + LSP/AST |

### Spec-Driven Development 系列

| 文档 | 定位 | 适合 |
|---|---|---|
| [SpecKit + OpenSpec 使用最佳实践指南](speckit/SpecKit%20+%20OpenSpec%20使用最佳实践指南.md) | SDD 工具对比 + 选型 + 工作流 | 想让 AI 按规格驱动开发，不确定选 Spec Kit 还是 OpenSpec |

### AI Agent SOP 框架

| 文档 | 定位 | 适合 |
|---|---|---|
| [Vibe Coding Agent 最佳实践指南](vibe-coding-agent/Vibe%20Coding%20Agent%20最佳实践指南.md) | 银行级 AI 编码 SOP 流水线（7 agent + 2 pipeline + 3 human gate） | 受监管行业 / 跨团队协作 / 需要审计 trace / 想学多 agent 编排设计模式 |

### 跨工具协作

| 文档 | 定位 | 适合 |
|---|---|---|
| [跨工具协作指南](collaboration/跨工具协作指南.md) | 插件搭配 + 组合推荐 | 不确定哪些工具可以同时用 |

---

## 各文档核心亮点

### Superpowers — 14 个 Skill 触发方式

14 个 skill 中 **13 个自动触发，1 个手动**。提出需求后 AI 自动走 brainstorm → plan → TDD → review → ship 流程。

详见 [Superpowers 使用最佳实践指南](superpower/Superpowers%20使用最佳实践指南.md) 第 4 节 "全部 Skill 触发方式一览"。

### oh-my-claudecode — 四种 Workflow 模式

| 模式 | 命令序列 | 适用 |
|---|---|---|
| Full-Auto from PRD | `ralplan` → `team` → `ralph` | 大型功能 |
| No-Brainer | `autopilot` → `ultrawork` → `ralph` | 目标明确 |
| Fix / Debugging | `plan` → `ralph` | Bug 修复 |
| Parallel Issue | `team (architect)` → `ralplan` → `ralph` | 多 Issue 并行 |

详见 [oh-my-claudecode 使用最佳实践指南](oh-my-claudecode/oh-my-claudecode%20使用最佳实践指南.md) 第 8 节。

### OpenCode + omo — Prometheus 采访式规划

```
Tab 切到 Prometheus（plan模式） → 描述任务   ← 规划入口（Prometheus 采访 → Metis 分析 → Momus 评审）
    ↓
/start-work                       ← 执行入口（Atlas 调度专家 agent）
```

详见 [OpenCode + omo 使用指南](opencode/📚%20OpenCode%20+%20Oh%20My%20OpenCode%20使用最佳实践指南.md) 第 8 节。

### oh-my-codex — 8 种执行模式

| 模式 | 适用 |
|---|---|
| `autopilot` | 自主执行 |
| `ultrawork` | 最大并行 |
| `ralph` | 持久循环直到完成 |
| `team` | 多 agent 流水线 |
| `ralplan` | 迭代规划共识 |
| `ecomode` | 成本敏感 |
| `ultraqa` | QA 循环验证 |
| `tdd` | TDD 强制 |

详见 [oh-my-codex 使用最佳实践指南](oh-my-codex/oh-my-codex%20使用最佳实践指南.md) 第 6 节。

### Vibe Coding Agent — 银行级 7-agent SOP 流水线

```
/vibe-req <原始需求>                          /vibe-coding <tech_spec>
  ↓                                             ↓
PO → PRD → SA → tech_spec  ──── Gate 1 ────→  Maker → Tester → Checker → Insight
              ↑ bounce loop                      ↺ FAIL retry ×3         ↓
                                                            Gate 2 → 代码 PR
```

**关键设计**：3 个不可跳过的人类 Gate + HARD-GATE 硬约束 + 跨 LLM 族对抗审稿 + 全链路审计 trace。

详见 [Vibe Coding Agent 最佳实践指南](vibe-coding-agent/Vibe%20Coding%20Agent%20最佳实践指南.md)。

---

## 快速选型

```
你的情况？
│
├─ 主要用 Claude，希望最稳定
│   └─ Claude Code → 核心概念 → 最佳实践
│
├─ 跨多家模型 / 省钱
│   └─ OpenCode + omo → 对应指南
│
├─ AI 偷懒不守纪律
│   └─ Superpowers → 对应指南（14 skill 全自动触发）
│
├─ 想让 AI 按规格驱动开发
│   ├─ 绿地项目 / 团队协作 → Spec Kit（Constitution + 完整 spec）
│   ├─ 棕地项目 / 快速迭代 → OpenSpec（Delta spec 只写变更）
│   └─ 详见 SpecKit + OpenSpec 使用最佳实践指南
│
├─ 跨会话老忘事
│   └─ claude-mem → 对应指南
│
├─ 想挑几个特定 skill
│   └─ everything-claude-code → 深度指南里的分类推荐
│
├─ 想给 Claude Code 加多 agent 编排
│   └─ oh-my-claudecode → Team / Ralph / Autopilot
│
├─ 想给 Codex CLI 加编排 + LSP/AST
│   └─ oh-my-codex → 8 种执行模式
│
├─ 受监管行业 / 需要审计 trace / 多 agent 流水线
│   └─ Vibe Coding Agent → 最佳实践指南（7 agent + 2 pipeline + 3 human gate）
│
└─ 不确定选什么
    └─ 先看 Harness Engineering 概念与实践指南
```

### 插件冲突警告

| 组合 | 冲突风险 | 建议 |
|---|---|---|
| Superpowers + oh-my-claudecode | **高** | 择一，两者都管工作流编排 |
| Superpowers + everything-claude-code | **高** | 择一，skill 重名会互相覆盖 |
| oh-my-claudecode + everything-claude-code | **高** | 55+ skill 同时加载，context 爆炸 |
| Superpowers + claude-mem | **无** | 流程 vs 记忆，互补 |
| Superpowers + anthropics/skills | **无** | 流程 vs 领域，互补 |
| Superpowers + OpenSpec | **无** | 纪律 vs 变更管理，互补 |
| Superpowers + Spec Kit | **高** | planning 功能重叠，择一 |
| Spec Kit + OpenSpec | **中** | 同为 SDD 工具，择一 |
| oh-my-claudecode + Codex CLI + Gemini CLI | **无** | 特色功能，跨模型交叉验证 |
| Vibe Coding Agent + Superpowers | **无** | 多 agent 流水线 vs 单 agent 纪律，互补 |
| Vibe Coding Agent + Spec Kit | **中** | 规划阶段可能重叠，择一或先用 Spec Kit 再用 Vibe |
| Vibe Coding Agent + oh-my-claudecode | **高** | 同为多 agent 编排，架构冲突 |

---

## 各工具日常开发流程对照

| 流程阶段 | Superpowers | Spec Kit | OpenSpec | OpenCode + omo | oh-my-claudecode | oh-my-codex | Vibe Coding Agent |
|---|---|---|---|---|---|---|---|
| **需求澄清** | brainstorming（自动） | `/speckit.clarify`（手动） | 内嵌在 `/opsx:propose` | Tab 切 Prometheus（手动） | `/deep-interview`（手动） | `/plan`（手动） | `/vibe-req`（PO agent 自动结构化） |
| **规划** | writing-plans（自动） | `/speckit.plan`（手动） | `/opsx:propose`（手动） | Prometheus 三剑客（自动） | `/ralplan`（手动） | `/ralplan`（手动） | SA agent（自动 tech_spec） |
| **执行** | executing-plans（自动） | `/speckit.implement`（手动） | `/opsx:apply`（手动） | `/start-work` 或 `ulw:`（手动） | `/team` 或 `/autopilot`（手动） | `/ultrawork` 或 `/ralph`（手动） | `/vibe-coding`（Maker agent 自动实现） |
| **测试** | TDD（自动，强制） | Constitution 约束（plan 阶段） | 无对应 | 无对应 | `tdd` 关键字（手动） | `/tdd`（手动） | Tester agent（自动 PASS/FAIL + retry） |
| **验证** | verification（自动） | `/speckit.analyze`（手动） | `/opsx:verify`（手动） | `review-work` skill（手动） | `/ralph` 循环（自动） | `/ultraqa` 循环（自动） | Checker agent（5 类静态审查自动） |
| **Review** | requesting-review（自动） | `/speckit.checklist`（手动） | `/opsx:archive`（手动） | `@oracle`（手动） | `/ask codex`（手动） | `/code-review`（手动） | Insight agent + Gate 2（自动 briefing + 人类拍板） |
| **人类介入** | brainstorm 环节 | 全程手动 | 全程手动 | `/start-work` 手动 | 手动触发 | 手动触发 | **3 个硬性 Gate（不可跳过）** |
| **自动化程度** | **全自动** | 全手动 | 全手动 | 半自动 | 半自动 | 半自动 | **半自动（AI 执行 + 人类决策）** |

---

## 文档规范

所有文档遵循 [STYLE.md](STYLE.md) 中定义的统一格式。

---

## 数据说明

- Stars、版本号等数据标注了核实日期，可能随时间变化
- 所有引用均基于 GitHub API 实测，不引用未验证的第三方数据
- 如发现过时信息，欢迎指出
