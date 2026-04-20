# oh-my-claudecode 使用最佳实践指南

> 整理时间：2026-04-19
> 信息来源：实测核验 [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) README、REFERENCE.md

---

## 0. 项目核心信息

| 属性 | 值 |
|---|---|
| 仓库 | [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) |
| 作者 | Yeachan Heo |
| License | **MIT** |
| 定位 | Teams-first 多 agent 编排插件 for Claude Code |
| npm 包名 | `oh-my-claude-sisyphus`（与仓库名不同） |
| 核心组件 | 19 个专业化 Agent、36 个 Skill、CLI 工具 `omc` |

> ⚠️ **命名注意**：项目品牌名为 oh-my-claudecode，但 npm 包发布为 `oh-my-claude-sisyphus`。安装 CLI 时用后者。

---

## 1. 它是什么 / 不是什么

### 1.1 一句话定位

> **oh-my-claudecode（OMC）是一个为 Claude Code 添加多 agent 编排、Team 协作和持久执行的插件**，让单一 Claude Code 会话变成一个有多角色协作的开发团队。

### 1.2 它不是什么

- **不是独立的 coding agent**（装在 Claude Code 内部运行）
- **不是 Superpowers 的同类**（Superpowers 是流程纪律，OMC 是多 agent 编排 + 执行策略）
- **不是 omo 的同类**（omo 是给 OpenCode 加多模型编排，OMC 是给 Claude Code 加多 agent 编排）

---

## 2. 装不装的判断

| 你的情况 | 建议 |
|---|---|
| 日常小任务 / 单文件改动 | **不装**。Claude Code 裸机足够 |
| 长期项目，需要并行执行多个子任务 | **推荐**。Team / Ultrawork 模式是核心价值 |
| 需要跨模型交叉验证（Codex / Gemini） | **推荐**。内置 Provider Advisor + tmux CLI Workers |
| 已装 Superpowers | ⚠️ **可能冲突**。两者都管"怎么工作"，择一或仔细配置 |
| 想要"不放弃就一定做完"的执行 | **推荐**。Ralph 模式的 verify/fix 循环 |

---

## 3. 安装

### 3.1 插件方式（推荐）

在 Claude Code 中逐行执行：

```bash
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode
```

### 3.2 npm CLI 方式

```bash
npm i -g oh-my-claude-sisyphus@latest
```

### 3.3 初始化

在 Claude Code 会话内：

```bash
/setup
```

或从终端：

```bash
omc setup
```

### 3.4 启用 Team 模式（推荐）

在 `~/.claude/settings.json` 中添加：

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 3.5 系统要求

- **Claude Code CLI** + Claude Max/Pro 订阅或 API key
- **tmux**（Team 模式和 rate-limit 恢复需要）：`brew install tmux`（macOS）
- **可选**：Gemini CLI（设计审查）、Codex CLI（架构验证）

---

## 4. 核心编排模式

### 4.1 Team 模式（推荐，v4.1.7+）

**这是 OMC 的主推模式**，取代了旧的 swarm。

```bash
# 会话内
/team 3:executor "fix all TypeScript errors"

# 终端 CLI（tmux workers）
omc team 2:codex "review auth module for security issues"
omc team 2:gemini "redesign UI components for accessibility"
omc team 1:claude "implement the payment flow"
```

流水线阶段：`team-plan → team-prd → team-exec → team-verify → team-fix（循环）`

| Surface | Workers | 适合 |
|---|---|---|
| `omc team N:codex "..."` | N 个 Codex CLI pane | 代码审查、安全分析、架构 |
| `omc team N:gemini "..."` | N 个 Gemini CLI pane | UI/UX 设计、文档、大上下文任务 |
| `omc team N:claude "..."` | N 个 Claude CLI pane | 通用任务 |
| `/ccg` | ask codex + ask gemini | 三模型综合分析 |

Workers 按需启动，任务完成自动销毁。

### 4.2 Autopilot 模式

单 agent 自主执行，最少交互：

```bash
/autopilot "build a REST API for managing tasks"
```

### 4.3 Ultrawork 模式

最大并行度（非 Team），用于快速修复/重构：

```bash
/ultrawork "fix all lint errors"
ulw: fix all lint errors
```

### 4.4 Ralph 模式

持久执行 + 验证/修复循环，**不到完成不停止**：

```bash
/ralph "refactor auth module"
```

Ralph 自动包含 Ultrawork 的并行能力。

### 4.5 Deep Interview 模式

苏格拉底式需求澄清，在写代码前把模糊想法变清晰：

```bash
/deep-interview "I want to build a task management app"
```

### 4.6 其他模式

| 模式 | 用途 |
|---|---|
| Pipeline | 顺序阶段处理，严格顺序 |
| Ultrapilot | 已弃用（autopilot pipeline 别名） |
| deepsearch | 代码库聚焦搜索 |
| ultrathink | 深度推理模式 |

---

## 5. 19 个专业化 Agent

OMC 提供 19 个角色化 agent，支持 tier 路由（-low / 默认 / -high）：

| 类型 | 用途 |
|---|---|
| 架构类 | 架构设计、技术决策 |
| 执行类 | 具体实现、bug 修复 |
| 审查类 | 代码审查、安全审查 |
| QA 类 | 测试执行、验证 |
| 研究类 | 文档查找、代码搜索 |
| 数据类 | 数据分析、科学计算 |

**Tier 路由策略**：

| Tier | 适合 | 成本 |
|---|---|---|
| `-low` | 简单快速任务（Haiku 级别） | 低 |
| 默认 | 平衡复杂度 | 中 |
| `-high` | 深度推理、关键审查 | 高 |

**推荐流程**：plan 用 high → execute 用默认 → verify 用 critic/reviewer → finalize 用 QA

---

## 6. 自定义 Skill 系统

### 6.1 Skill 学习

OMC 能从你的会话中自动提取可复用模式：

```bash
/learner
```

自动提取调试知识到可移植的 skill 文件。

### 6.2 Skill 路径

| 范围 | 路径 | 共享 |
|---|---|---|
| 项目级 | `.omc/skills/` | 团队（版本控制） |
| 用户级 | `~/.omc/skills/` | 所有项目 |

### 6.3 Skill 管理

```bash
/skill list     # 列出所有 skill
/skill add      # 添加 skill
/skill remove   # 移除
/skill edit     # 编辑
/skill search   # 搜索
```

### 6.4 Skill 示例

```markdown
---
name: Fix Proxy Crash
description: aiohttp proxy crashes on ClientDisconnectedError
triggers: ["proxy", "aiohttp", "disconnected"]
source: extracted
---

Wrap handler at server.py:42 in try/except ClientDisconnectedError...
```

---

## 7. 实用工具

### 7.1 Provider Advisor（`/ask`）

调用外部 AI 做交叉验证，结果保存到 `.omc/artifacts/ask/`：

```bash
# 会话内
/ask codex "review this migration plan"
/ask gemini "propose UI polish ideas"

# 终端
omc ask claude "review this migration plan"
omc ask codex --prompt "identify architecture risks"
```

### 7.2 Rate Limit 恢复

```bash
omc wait          # 查看状态
omc wait --start  # 启用自动恢复守护
omc wait --stop   # 停止
```

### 7.3 HUD Statusline

实时展示编排指标：

```bash
omc hud
```

### 7.4 通知集成

支持 session 完成时发送通知：

```bash
# Telegram
omc config-stop-callback telegram --enable --token <bot_token> --chat <chat_id>

# Discord
omc config-stop-callback discord --enable --webhook <url>

# Slack
omc config-stop-callback slack --enable --webhook <url>
```

### 7.5 Autoresearch

自动化研究运行时：

```bash
omc autoresearch --mission "improve startup performance" --eval "npm test"
```

---

## 8. 日常开发工作流（按场景）

### 8.0 模式选择速查

**先选模式，再开干：**

| 场景 | 推荐模式 | 关键字触发 |
|---|---|---|
| 需求不明确 | Deep Interview | `/deep-interview` 或 `deep interview` / `ouroboros` |
| 新功能（大型） | Team | `/team N:role "..."` |
| 新功能（中小型） | Autopilot | `/autopilot` 或 `autopilot:` / `build me` / `I want a` |
| Bug 修复（简单） | Autopilot | `/autopilot "fix ..."` |
| Bug 修复（复杂/多个） | Ralph | `/ralph` 或 `ralph:` / `don't stop` / `must complete` |
| 批量修改 / Lint 修复 | Ultrawork | `/ultrawork` 或 `ulw:` / `uw` |
| 重构 | Team（executor-high） | `/team 1:executor-high "refactor ..."` |
| 架构设计 | Deep Interview + Ralplan | `/deep-interview` → `/ralplan` |
| Code Review | Team（code-reviewer） | `/team 1:code-reviewer "review ..."` |

### 8.1 四种推荐 Workflow 模式

官方推荐了 4 种命名的 Workflow 模式：

**Full-Auto from PRD（大型功能，需要规划）：**

```
deep-interview / ralplan → team → ralph
```

1. `/deep-interview` 或 `/ralplan` 收集需求，planner + architect + critic 达成共识
2. `/team` 启动并行 workers 构建实现
3. `/ralph` 持久运行直到所有内容验证通过

**No-Brainer（目标明确，直接干）：**

```
autopilot → ultrawork → ralph
```

1. `/autopilot` 自主执行
2. `/ultrawork` 并行化子任务
3. `/ralph` 持久运行直到验证完成

**Fix / Debugging（Bug 和错误修复）：**

```
plan / autopilot → ralph
```

1. `/autopilot` 或直接描述调查根因
2. `/ralph` 实现修复直到完成（自动包含 ultrawork 并行能力）

**Parallel Issue Handling（多个 Issue / Ticket 并行处理）：**

```
omc team (architect) → omc team (workers) → ralplan → ralph + ultrawork
```

1. 启动 architect workers 分析所有 issue，草拟完整 plan
2. workers 在独立 worktree 并行工作，各提交 PR
3. 审查合并 PR，然后 `/ralplan` 解决冲突
4. `/ralph` + `/ultrawork` 直到全部测试通过

### 8.2 新功能开发（大型）—— Team 模式

```
/deep-interview "我想做一个用户通知系统"     ← 需求澄清（如果需求模糊）
    ↓
/ralplan "按 interview 结果拆任务"            ← 迭代规划共识
    ↓
/team 3:executor "按 plan 执行实现"           ← Team 流水线
    ↓                                             team-plan → team-prd → team-exec
    ↓                                             → team-verify → team-fix（循环）
/ask codex "review 架构设计"                   ← Codex 交叉验证
    ↓
/ask gemini "review UI/UX 设计"               ← Gemini 交叉验证
    ↓
手动 merge / PR
```

**Team 流水线各阶段 Agent 路由：**

| 阶段 | Agent 路由 |
|---|---|
| `team-plan` | planner（opus），可选 architect/analyst |
| `team-prd` | analyst（opus），可选 critic |
| `team-exec` | executor（sonnet）+ 任务相关专家（designer, debugger, test-engineer 等） |
| `team-verify` | verifier + code-reviewer/security-reviewer 按需 |
| `team-fix` | executor/debugger 取决于缺陷类型 |

**也可以用 tmux CLI workers 并行：**

```bash
omc team 2:claude "实现注册 API + 数据库迁移"   # Claude workers 执行
omc team 1:codex "审查安全性"                    # Codex worker 审查
omc team 1:gemini "审查 UI/UX 设计"              # Gemini worker 审查
```

### 8.2 新功能开发（中小型）—— Autopilot 模式

```
/autopilot "build a REST API for managing tasks"
```

Autopilot 单 agent 自主执行，最少交互。适合目标明确的中小型任务。

也可以用关键字触发：

```
autopilot: 给用户表加一个 last_login_at 字段，包含迁移和 API 更新
```

### 8.3 Bug 修复（简单）

```
/autopilot "fix the login redirect bug and verify it works"
```

### 8.4 Bug 修复（复杂 / 多个）—— Ralph 模式

```
/ralph "fix all TypeScript errors in src/auth/ and verify each fix"
```

Ralph 自动包含 Ultrawork 的并行能力，且带有 verify/fix 循环 —— **不到完成不停止**。

### 8.5 批量修改 / Lint 修复 —— Ultrawork 模式

```
/ultrawork "fix all lint errors"
```

或：

```
ulw: fix all ESLint warnings in src/
```

最大并行度，快速处理大量同质任务。

### 8.6 重构 —— Team（executor-high）

```
/team 1:executor-high "refactor the payment module to use the new domain model"
```

executor-high 使用 Opus 级别模型，适合复杂重构。

分步执行也可以：

```
/analyze     ← 分析当前代码结构，识别 code smell
    ↓
/plan        ← 制定重构计划
    ↓
/refactor    ← 逐步应用变换，保持行为不变
    ↓
/test        ← 跑全量测试，对比重构前后输出
    ↓
/review      ← 验证改进，检查回归
```

### 8.7 架构设计 / 规划

```
/deep-interview "我想做一个微服务迁移"         ← 苏格拉底式需求澄清
    ↓
/ralplan "按 interview 结果制定迁移计划"        ← 迭代规划共识
    ↓
/ask codex "review this migration plan"         ← Codex 交叉验证
    ↓
/ask gemini "suggest architecture improvements"  ← Gemini 建议
```

### 8.8 Code Review

```
/team 1:code-reviewer "review PR #42"
```

分步执行：

```
/analyze      ← 分析变更文件和依赖
    ↓
/review       ← 多维度 code review
    ↓
/suggest      ← 生成改进建议
```

### 8.9 日常维护（Triage）

```
/triage       ← 处理 issues、PRs、alerts，排优先级
    ↓
/implement    ← 处理已批准的小任务
    ↓
/test         ← 跑相关测试
    ↓
/summarize    ← 生成当日变更摘要
```

### 8.10 TDD 开发

```
/tdd "Implement password validation with proper edge cases"
```

路由到 `test-engineer` agent，强制 RED-GREEN-REFACTOR 流程。

也可以用关键字触发：

```
tdd implement password validation with edge cases
```

### 8.11 跨模型交叉验证

OMC 的特色能力 — 用 `/ask` 调用外部 AI 做交叉验证：

```
/ask codex "review this migration plan"         ← Codex 验证
/ask gemini "propose UI polish ideas"           ← Gemini 建议
/ccg "综合分析这个架构方案"                       ← 三模型（Claude + Codex + Gemini）综合
```

结果自动保存到 `.omc/artifacts/ask/`。

### 8.12 Agent 选型指南

| 任务类型 | 推荐 Agent | 模型 Tier |
|---|---|---|
| 快速代码查找 | `explore` | haiku（LOW） |
| 功能实现 | `executor` | sonnet（默认） |
| 复杂重构 | `executor-high` | opus（HIGH） |
| 简单调试 | `architect-low` | haiku（LOW） |
| 复杂调试 | `architect` | opus（HIGH） |
| UI 组件 | `designer` | sonnet（默认） |
| 战略规划 | `planner` | opus（HIGH） |
| 安全审查 | `security-reviewer` | opus（HIGH） |
| 构建错误修复 | `debugger` | sonnet（默认） |
| TDD | `test-engineer` | sonnet（默认） |
| Code Review | `code-reviewer` | opus（HIGH） |

### 8.13 关键字自动触发

OMC 支持在对话中直接使用关键字触发模式，不需要 `/`：

| 关键字 | 触发模式 |
|---|---|
| `autopilot`、`build me`、`I want a` | Autopilot 模式 |
| `ralph`、`don't stop`、`must complete`、`until done` | Ralph 模式 |
| `ultrawork`、`ulw`、`uw` | Ultrawork 并行模式 |
| `ralplan` | 迭代规划共识 |
| `deep interview`、`ouroboros` | 苏格拉底式需求澄清 |
| `tdd`、`test first`、`red green` | TDD 工作流 |
| `cancelomc`、`stopomc` | 停止当前模式 |

### 8.14 Skill Pipeline 自动串联

高级用法：Skill 可以在 frontmatter 中声明 handoff，自动串联成流水线：

```yaml
pipeline: [deep-interview, omc-plan, autopilot]
next-skill: omc-plan
next-skill-args: --consensus --direct
handoff: .omc/specs/deep-interview-{slug}.md
```

效果：`/deep-interview` 完成后自动将输出传给 `omc-plan`，再传给 `autopilot` 执行，无需手动串联。

### 8.15 场景速查表

| 场景 | 第一个命令 | 后续 |
|---|---|---|
| 需求不明确 | `/deep-interview` | `/ralplan` → `/team` |
| 新功能（大型） | `/ralplan` | `/team` → `/ask codex` → `/ask gemini` |
| 新功能（中小型） | `/autopilot` | `ultrawork` → `ralph` |
| 简单 Bug | `/autopilot "fix ..."` | 完成 |
| 复杂 Bug | `/autopilot "调查..."` | `/ralph "修复..."` |
| 批量修改 / Lint | `/ultrawork` 或 `ulw:` | 完成 |
| 重构 | `/team 1:executor-high` | `/review` |
| 架构设计 | `/deep-interview` | `/ralplan` → `/ask codex` → `/ask gemini` |
| Code Review | `/team 1:code-reviewer` | `/suggest` |
| TDD | `tdd <描述>` | 完成 |
| 多 Issue 并行 | `omc team (architect)` | `ralplan` → `ralph` + `ultrawork` |
| 日常维护 | `/triage` | `/implement` → `/test` → `/summarize` |
| 跨模型验证 | `/ask codex` / `/ask gemini` | `/ccg` 三模型综合 |
| 取消任何模式 | `cancelomc` / `stopomc` | — |

---

## 9. 命令速查

### 9.1 会话内 Skill / 触发词

| 命令/关键字 | 效果 |
|---|---|
| `/team N:role "..."` | Team 编排（推荐） |
| `/ccg "..."` | 三模型（Codex + Gemini）综合 |
| `/autopilot "..."` 或 `autopilot:` | 自主执行 |
| `/ralph "..."` 或 `ralph:` | 持久执行 + 验证循环 |
| `/ultrawork "..."` 或 `ulw:` | 最大并行 |
| `/ralplan "..."` 或 `ralplan:` | 迭代规划共识 |
| `/deep-interview "..."` | 苏格拉底式需求澄清 |
| `deepsearch` | 代码库搜索 |
| `ultrathink` | 深度推理 |
| `stopomc` / `cancelomc` | 停止当前模式 |

### 9.2 终端 CLI

| 命令 | 用途 |
|---|---|
| `omc setup` | 初始化配置 |
| `omc team N:provider "..."` | tmux CLI workers |
| `omc ask provider "..."` | 调用外部 AI |
| `omc autoresearch` | 自动研究 |
| `omc wait --start` | Rate-limit 恢复 |
| `omc hud` | HUD 状态栏 |
| `omc config-stop-callback` | 通知配置 |

---

## 10. 与其他工具的关系

| 组合 | 评估 |
|---|---|
| OMC + claude-mem | ⚠️ OMC 自带 session 管理（`.omc/sessions/`），与 claude-mem 可能重叠 |
| OMC + Superpowers | ⚠️ **高冲突风险**。两者都管工作流编排。OMC 用 `/autopilot`/`/ralph`，Superpowers 用 brainstorm→plan→TDD。**择一** |
| OMC + everything-claude-code | ⚠️ OMC 已有 19 agent + 36 skill，再加 ECC 全装会导致严重冲突 |
| OMC + anthropics/skills | ✅ 官方 skill 多为领域类（pdf/xlsx 等），不冲突 |
| OMC + Codex CLI + Gemini CLI | ✅ **OMC 的特色功能**，通过 `omc team` 和 `/ask` 交叉验证 |

---

## 11. 反模式

### 11.1 ❌ 同时装 OMC + Superpowers

→ 两个工作流编排器打架。选一个。

### 11.2 ❌ 小任务用 Team 模式

→ 单文件修复不需要 3 个 agent 并行，直接裸 Claude Code 更快。

### 11.3 ❌ 不启用 CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS

→ Team 模式是主推功能，不启用会回退到非 team 执行。

### 11.4 ❌ OMC 全装 + ECC 全装

→ 55+ skill 同时加载，context 爆炸。

---

## 12. 参考链接

- [GitHub 主仓](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [官网](https://ohmyclaudecode.com/)
- [文档](https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/REFERENCE.md)
- [oh-my-codex（Codex 版）](https://github.com/sigridjineth/oh-my-codex)
- [Claude Code 使用最佳实践](../claudecode/Claude%20Code%20使用最佳实践指南.md)
- [跨工具协作指南](../collaboration/跨工具协作指南.md)

---

## 13. 一句话总结

> **oh-my-claudecode = 给 Claude Code 装上多 agent 团队编排能力。** Team 模式是核心价值——plan→prd→exec→verify→fix 流水线，配合 tmux CLI workers 实现跨模型（Claude/Codex/Gemini）协作。**适合大型项目，不适合小任务。**
