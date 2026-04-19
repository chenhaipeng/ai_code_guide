# oh-my-codex 使用最佳实践指南

> 整理时间：2026-04-19
> 信息来源：实测核验 [sigridjineth/oh-my-codex](https://github.com/sigridjineth/oh-my-codex) README

---

## 0. 项目核心信息

| 属性 | 值 |
|---|---|
| 仓库 | [sigridjineth/oh-my-codex](https://github.com/sigridjineth/oh-my-codex) |
| 作者 | Sigrid Jin（oh-my-claudecode Ambassador） |
| License | **MIT** |
| 定位 | 多 agent 编排插件 for OpenAI Codex CLI |
| npm 包名 | `oh-my-codex` |
| 核心组件 | 30+ Agent、35+ Skill、LSP/AST 工具链、Hook 系统 |
| 语言 | TypeScript |

> ⚠️ **注意**：oh-my-codex 的作者 Sigrid Jin 是 oh-my-claudecode 的 Ambassador。两者设计理念和功能高度相似，但分别面向 Codex CLI 和 Claude Code。

---

## 1. 它是什么 / 不是什么

### 1.1 一句话定位

> **oh-my-codex（OMX）是给 OpenAI Codex CLI 加多 agent 编排、结构化规划和 LSP/AST 工具链的插件**，让 Codex 表现得像一个实用的工程指挥。

### 1.2 核心能力

- **可复用的专业化 agent**（30+），显式分工
- **多步规划 + review-first** 模式
- **Hook 系统强制执行纪律和验证**
- **并行执行模式**加速吞吐
- **LSP + AST 工具**实现类型感知和结构化编辑
- **Drift 检测 + 可恢复会话**

---

## 2. 装不装的判断

| 你的情况 | 建议 |
|---|---|
| 日常用 Codex CLI 做小任务 | **不装**。原生 Codex 够用 |
| 大型项目需要多步规划 + agent 分工 | **推荐** |
| 需要 LSP 级精度的代码操作 | **推荐**。LSP + AST-Grep 是差异化能力 |
| 已有自定义 hooks 体系 | ⚠️ 检查 hook 冲突（OMX 会安装多个 lifecycle hooks） |

---

## 3. 安装

### 3.1 插件方式（Codex 支持 plugin 时）

```bash
codex plugin marketplace add https://github.com/sigridjineth/oh-my-codex
codex plugin install oh-my-codex
```

### 3.2 CLI 源码安装（通用）

```bash
git clone https://github.com/sigridjineth/oh-my-codex.git
cd oh-my-codex
npm install
npm run build
node dist/cli/index.js install
```

资源安装到 `~/.codex/`（hooks、agents、CODEX.md、HUD 配置）。

### 3.3 验证安装

```bash
node dist/cli/index.js doctor conflicts --json
# 期望输出："hasConflicts": false

codex exec "Reply exactly: OK"
```

### 3.4 系统要求

- **Node.js** >= 20
- **Codex CLI** 已安装并认证
- **可选**：tmux（session 恢复、rate-limit resume、项目管理）

---

## 4. 核心编排模式

### 4.1 模式一览

| 模式 | 用途 |
|---|---|
| **autopilot** | 广域自主执行，从 prompt 到实现 |
| **ultrawork** | 最大并行，高吞吐 |
| **ultrapilot** | 并行 autopilot + 所有权模式 |
| **swarm** | N-agent 协调执行 + claim/checkpoint |
| **pipeline** | 顺序阶段交接 |
| **ecomode** | 成本敏感模式 |
| **ralph** | 持久模式 + 反复验证 |
| **ultraqa** | QA 重度循环 + 验证 loop |

### 4.2 快速开始

```bash
# 结构化规划
/oh-my-codex:plan Build a migration-safe auth refactor

# 代码审查
/oh-my-codex:review

# 最大并行执行
/oh-my-codex:ultrawork Refactor service boundaries

# 安全审查
/oh-my-codex:security-review

# 代码审查
/oh-my-codex:code-review
```

---

## 5. Agent 体系与 Tier 路由

### 5.1 30+ 专业化 Agent

覆盖架构、执行、审查、QA、安全、文档、研究等角色。

### 5.2 Tier 路由

| Tier | 适合 | 成本 |
|---|---|---|
| `-low` | 简单快速任务 | 低 |
| 默认 | 平衡复杂度 | 中 |
| `-high` | 深度推理、关键审查 | 高 |

### 5.3 推荐流程

1. **Plan** → 用 high-tier agent
2. **Execute** → 用平衡 agent
3. **Verify** → 用 critic/reviewer/security 角色
4. **Finalize** → QA + 用户流程检查

### 5.4 Agent 调用

使用 `oh-my-codex:<agent>` 标识符：

```
Agent(subagent_type="oh-my-codex:reviewer", prompt="Review auth module")
Agent(subagent_type="oh-my-codex:architect", prompt="Design payment system")
```

---

## 6. Hook 系统

### 6.1 生命周期 Hook

| Hook | 时机 | 作用 |
|---|---|---|
| `UserPromptSubmit` | 提交输入时 | 关键字/模式检测 |
| `SessionStart` | 会话启动 | 恢复上下文、drift 检查 |
| `PreToolUse` | 工具执行前 | 预检和策略 |
| `PostToolUse` | 工具执行后 | 验证/记录 |
| `PostToolUseFailure` | 工具失败后 | 失败处理 |
| `Stop` | 会话停止 | 持久化和续接支持 |

### 6.2 Hook 路径

```
~/.codex/hooks/         # 当前路径
```

> 升级逻辑能识别旧的 `.claude/hooks/` 所有权标记，减少误冲突检测。

---

## 7. LSP + AST 工具链

这是 oh-my-codex 的**差异化能力**：

### 7.1 LSP 工具

```
lsp_goto_definition    # 跳转到定义
lsp_find_references    # 查找所有引用
lsp_rename             # 安全重命名
lsp_diagnostics        # 诊断信息
lsp_code_actions       # 快速修复/重构
lsp_hover              # 符号信息
```

### 7.2 AST-Grep

结构化代码搜索和替换：

```typescript
ast_grep_search({ pattern: "console.log($MSG)", lang: "javascript" })
ast_grep_replace({
  pattern: "console.log($MSG)",
  rewrite: "logger.info($MSG)",
  lang: "javascript"
})
```

支持 25 种语言。

---

## 8. 实用工具

### 8.1 HUD 使用情况监控

状态栏集成 + Token 用量轮询：

```bash
omx hud
```

### 8.2 Rate Limit 恢复

```bash
omx wait           # 检查状态
omx wait --start   # 启用自动恢复
```

支持 tmux pane 扫描和自动 resume。

### 8.3 项目 Session 管理器

基于 worktree + tmux 的隔离工作流：

- 多个实现分支并行运行
- 每个 pane/worktree 一个任务
- 快速上下文切换

---

## 9. 命令速查

| 命令 | 用途 |
|---|---|
| `/oh-my-codex:plan "..."` | 结构化规划 |
| `/oh-my-codex:review` | 代码审查 |
| `/oh-my-codex:ultrawork "..."` | 最大并行 |
| `/oh-my-codex:security-review` | 安全审查 |
| `/oh-my-codex:code-review` | 代码审查 |
| `node dist/cli/index.js install` | 安装/更新 |
| `node dist/cli/index.js doctor conflicts --json` | 诊断冲突 |
| `omx hud` | HUD 状态 |
| `omx wait --start` | Rate-limit 恢复 |

---

## 10. 与其他工具的关系

| 组合 | 评估 |
|---|---|
| oh-my-codex + oh-my-claudecode | ✅ 分别用于 Codex CLI 和 Claude Code，不冲突。同一个作者体系 |
| oh-my-codex + Codex CLI 原生 | ✅ 增强关系，OMX 在 Codex 上层运行 |
| oh-my-codex + everything-claude-code | ⚠️ 不同平台，但设计理念类似。不需要同时用 |
| oh-my-codex + Superpowers | ⚠️ Superpowers 支持 Codex CLI，两者可能冲突 |

---

## 11. 反模式

### 11.1 ❌ 小任务用 swarm/ultrawork

→ 简单修复不需要编排层，直接用原生 Codex。

### 11.2 ❌ 不跑 `doctor conflicts`

→ 升级后可能存在 hook 冲突，务必验证。

### 11.3 ❌ 忽略 legacy `.claude/hooks` 残留

→ OMX 能识别旧的 hook 路径，但最好清理避免混淆。

---

## 12. 参考链接

- [GitHub 主仓](https://github.com/sigridjineth/oh-my-codex)
- [oh-my-claudecode（Claude Code 版）](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [OpenAI Codex CLI](https://github.com/openai/codex)
- [Harness Engineering 概念与实践](../harness-engineering/Harness%20Engineering%20概念与实践指南.md)
- [跨工具协作指南](../collaboration/跨工具协作指南.md)

---

## 13. 一句话总结

> **oh-my-codex = 给 Codex CLI 装上多 agent 编排 + LSP/AST 工具链 + 强制 Hook 纪律。** 跟 oh-my-claudecode 是同一设计理念在 Codex 上的实现，30+ agent + 8 种执行模式覆盖从规划到验证的完整流程。
