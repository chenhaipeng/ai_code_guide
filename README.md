# AI Code Guide — AI 编程工具最佳实践文档集

> 整理时间：2026-04-19
> 最近更新：2026-04-20

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

### OpenCode + omo — `@plan` 与 `/start-work` 配合

```
@plan "任务"      ← 规划入口（Prometheus 采访 → Metis 分析 → Momus 评审）
    ↓
/start-work       ← 执行入口（Atlas 调度专家 agent）
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
| oh-my-claudecode + Codex CLI + Gemini CLI | **无** | 特色功能，跨模型交叉验证 |

---

## 各工具日常开发流程对照

| 流程阶段 | Superpowers | OpenCode + omo | oh-my-claudecode | oh-my-codex |
|---|---|---|---|---|
| **需求澄清** | brainstorming（自动） | `@plan`（手动） | `/deep-interview`（手动） | `/plan`（手动） |
| **规划** | writing-plans（自动） | Prometheus 三剑客（自动） | `/ralplan`（手动） | `/ralplan`（手动） |
| **执行** | executing-plans（自动） | `/start-work` 或 `ulw:`（手动） | `/team` 或 `/autopilot`（手动） | `/ultrawork` 或 `/ralph`（手动） |
| **测试** | TDD（自动，强制） | 无对应 | `tdd` 关键字（手动） | `/tdd`（手动） |
| **验证** | verification（自动） | `review-work` skill（手动） | `/ralph` 循环（自动） | `/ultraqa` 循环（自动） |
| **Review** | requesting-review（自动） | `@oracle`（手动） | `/ask codex`（手动） | `/code-review`（手动） |
| **自动化程度** | **全自动** | 半自动 | 半自动 | 半自动 |

---

## 文档规范

所有文档遵循 [STYLE.md](STYLE.md) 中定义的统一格式。

---

## 数据说明

- Stars、版本号等数据标注了核实日期，可能随时间变化
- 所有引用均基于 GitHub API 实测，不引用未验证的第三方数据
- 如发现过时信息，欢迎指出
