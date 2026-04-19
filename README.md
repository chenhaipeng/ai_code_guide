# AI Code Guide — AI 编程工具最佳实践文档集

> 整理时间：2026-04-19

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
| [everything-claude-code 深度使用指南](oh-my-claudecode/everything-claude-code%20深度使用指南.md) | 大型 skill 包挑选指南 | 想从 ECC 中按需挑选 skill |
| [oh-my-claudecode 使用最佳实践指南](oh-my-claudecode/oh-my-claudecode%20使用最佳实践指南.md) | 多 agent 编排插件 for Claude Code | 想给 Claude Code 加 Team/并行执行 |
| [oh-my-codex 使用最佳实践指南](oh-my-codex/oh-my-codex%20使用最佳实践指南.md) | 多 agent 编排插件 for Codex CLI | 想给 Codex CLI 加编排 + LSP/AST |

### 跨工具协作

| 文档 | 定位 | 适合 |
|---|---|---|
| [跨工具协作指南](collaboration/跨工具协作指南.md) | 插件搭配 + 组合推荐 | 不确定哪些工具可以同时用 |

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
│   └─ Superpowers → 对应指南
│
├─ 跨会话老忘事
│   └─ claude-mem → 对应指南
│
├─ 想挑几个特定 skill
│   └─ everything-claude-code → 深度指南里的分类推荐
│
└─ 不确定选什么
    └─ 先看 Harness Engineering 概念与实践指南
```

---

## 文档规范

所有文档遵循 [STYLE.md](STYLE.md) 中定义的统一格式。

---

## 数据说明

- Stars、版本号等数据标注了核实日期，可能随时间变化
- 所有引用均基于 GitHub API 实测，不引用未验证的第三方数据
- 如发现过时信息，欢迎指出
