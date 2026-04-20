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

## 6. 日常开发工作流（按场景）

### 6.0 模式选择速查

| 场景 | 推荐模式 | 关键字触发 |
|---|---|---|
| 新功能（大型，需要规划） | `ralplan` → `team` → `ralph` | `/oh-my-codex:ralplan` |
| 新功能（目标明确） | `autopilot` → `ultrawork` → `ralph` | `autopilot` / `build me` / `I want a` |
| Bug 修复（简单） | 直接描述或 `build-fix` | `/oh-my-codex:build-fix` |
| Bug 修复（复杂） | `plan` → `ralph` → `ultraqa` | `/oh-my-codex:plan` |
| 重构 | `plan` → `ralph` | `/oh-my-codex:plan` |
| 批量修改 / Lint 修复 | `ultrawork` 或 `ecomode` | `ulw` / `ultrawork` / `eco` |
| Code Review | `code-review` + `security-review` | `/oh-my-codex:code-review` |
| TDD 开发 | `tdd` | `/oh-my-codex:tdd` |
| 多个 Issue 并行处理 | `team` + `ralplan` + `ralph` | `swarm` |
| 成本敏感 | `ecomode` | `eco` / `ecomode` / `budget` |

### 6.1 四种推荐 Workflow 模式

官方推荐了 4 种命名的 Workflow 模式：

**Full-Auto from PRD（大型功能，需要规划）：**

```
ralplan → team → ralph
```

1. `$ralplan` 收集需求，planner + architect + critic 达成共识
2. `$team` 启动并行 tmux workers 构建实现
3. `$ralph` 持久运行直到所有内容验证通过

**No-Brainer（目标明确，直接干）：**

```
autopilot → ultrawork → ralph
```

1. `$autopilot` 自主执行
2. `$ultrawork` 并行化子任务
3. `$ralph` 持久运行直到验证完成

**Fix / Debugging（Bug 和错误修复）：**

```
plan → ralph → ultraqa
```

1. `$plan` 调查并创建修复策略
2. `$ralph` 实现修复直到完成
3. `$ultraqa` 循环 test → verify → fix 直到全部通过

**Parallel Issue Handling（多个 Issue / Ticket 并行处理）：**

```
omx team (architect) → omx team (workers) → ralplan → ralph + ultrawork → ultraqa
```

1. 启动 architect workers 分析所有 issue，草拟完整 plan
2. workers 在独立 worktree 并行工作，各提交 PR
3. 审查合并 PR，然后 `$ralplan` 解决冲突
4. `$ralph` + `$ultrawork` + `$ultraqa` 直到全部测试通过

### 6.2 新功能开发（大型）—— Full-Auto from PRD

```
/oh-my-codex:ralplan "Build a user notification system with email, push, and in-app channels"
    ↓                                           planner + architect + critic 达成共识
    ↓
/oh-my-codex:ultrawork "Execute the plan"       ← 并行实现
    ↓
/oh-my-codex:ralph "Verify everything works"    ← 持久验证直到完成
    ↓
/oh-my-codex:code-review                        ← 终审
```

**也可以用 Team 流水线：**

```
team-plan → team-prd → team-exec → team-verify → team-fix（循环）
```

| 阶段 | Agent 路由 |
|---|---|
| `team-plan` | explore（haiku）+ planner（opus），可选 analyst/architect |
| `team-prd` | analyst（opus），可选 product-manager/critic |
| `team-exec` | executor（sonnet）+ 任务相关专家（designer, build-fixer, test-engineer 等） |
| `team-verify` | verifier（sonnet）+ security-reviewer/code-reviewer/quality-reviewer 按需 |
| `team-fix` | executor/build-fixer/debugger 取决于缺陷类型 |

### 6.3 新功能开发（中小型）—— No-Brainer

```
/oh-my-codex:autopilot "Build a REST API for managing tasks"
```

或直接用关键字：

```
autopilot: 给用户表加一个 last_login_at 字段，包含迁移和 API 更新
```

### 6.4 Bug 修复（简单 / 构建错误）

```
/oh-my-codex:build-fix
```

或直接描述：

```
Fix the null pointer error in UserService.java line 42
```

### 6.5 Bug 修复（复杂 / 根因不明）

```
/oh-my-codex:plan "Investigate why login fails intermittently"
    ↓                                           debugger + explore 分析根因
    ↓
/oh-my-codex:ralph "Fix the race condition in auth middleware"
    ↓                                           持久修复直到验证通过
    ↓
/oh-my-codex:ultraqa                            ← QA 循环：test → verify → fix
```

### 6.6 重构

```
/oh-my-codex:plan "Refactor the API layer for better separation of concerns"
    ↓                                           architect 制定重构计划
    ↓
/oh-my-codex:ralph "Execute the refactoring plan"
    ↓                                           持久执行，使用 LSP/AST 工具链
    ↓
/oh-my-codex:code-review                        ← 终审
```

**Agent 序列（标准）：**

```
explore → architect → executor → test-engineer → quality-reviewer → verifier
```

### 6.7 批量修改 / Lint 修复

```
/oh-my-codex:ultrawork "fix all lint errors in src/"
```

或关键字：

```
ulw fix all TypeScript errors
```

**成本敏感时用 ecomode：**

```
eco fix all ESLint warnings in src/
```

### 6.8 Code Review

```
/oh-my-codex:code-review
/oh-my-codex:security-review
```

**Agent 序列（标准）：**

```
style-reviewer + quality-reviewer + api-reviewer + security-reviewer
```

### 6.9 TDD 开发

```
/oh-my-codex:tdd "Implement password validation with proper edge cases"
```

路由到 `test-engineer` agent，强制 RED-GREEN-REFACTOR 流程。

### 6.10 Agent 选型指南

**Build/Analysis Lane：**

| Agent | 模型 | 适合 |
|---|---|---|
| `explore` | haiku | 快速代码搜索、文件/符号映射 |
| `analyst` | opus | 需求澄清、验收标准、隐藏约束 |
| `planner` | opus | 任务排序、执行计划、风险标记 |
| `architect` | opus | 系统设计、边界定义、接口设计 |
| `debugger` | sonnet | 根因分析、回归隔离、故障诊断 |
| `executor` | sonnet | 聚焦实现、重构、功能开发 |
| `deep-executor` | opus | 复杂自主目标导向任务 |
| `verifier` | sonnet | 完成验证、声明校验、测试充分性 |

**Review Lane：**

| Agent | 模型 | 适合 |
|---|---|---|
| `style-reviewer` | haiku | 格式、命名、惯用法、lint 规范 |
| `quality-reviewer` | sonnet | 逻辑缺陷、可维护性、反模式 |
| `api-reviewer` | sonnet | API 契约、版本管理、向后兼容 |
| `security-reviewer` | sonnet/opus | 漏洞、信任边界、认证授权 |
| `performance-reviewer` | sonnet | 热点、复杂度、内存/延迟优化 |
| `code-reviewer` | opus | 综合审查，覆盖所有关注点 |

**Domain Specialists：**

| Agent | 模型 | 适合 |
|---|---|---|
| `test-engineer` | sonnet | 测试策略、覆盖率、flaky-test 加固 |
| `build-fixer` | sonnet | 构建/工具链/类型错误修复 |
| `designer` | sonnet | UX/UI 架构、交互设计 |
| `writer` | haiku | 文档、迁移说明、用户指引 |

**验证规模指南：**

| 改动规模 | verifier 模型 |
|---|---|
| 小改动（<5 文件，<100 行） | haiku |
| 标准改动 | sonnet |
| 大型/安全/架构改动（>20 文件） | opus |

### 6.11 关键字自动触发

在对话中直接输入关键字即可触发，不需要 `/`：

| 关键字 | 触发模式 |
|---|---|
| `autopilot`、`build me`、`I want a` | Autopilot 模式 |
| `ultrawork`、`ulw`、`uw` | Ultrawork 并行模式 |
| `ultrapilot`、`parallel build` | 并行 Autopilot（路由到 Team） |
| `ralph`、`don't stop`、`must complete` | Ralph 持久模式 |
| `eco`、`ecomode`、`budget`、`save-tokens` | Ecomode 成本敏感模式 |
| `swarm N agents` | Swarm 协调模式（路由到 Team） |
| `pipeline`、`chain agents` | Pipeline 顺序模式 |
| `plan` | 规划模式 |
| `tdd`、`test first`、`red green` | TDD 工作流 |

**冲突规则：**
- 显式关键字（`ulw`、`eco`）覆盖默认
- `ecomode` 优先级高于 `ultrawork`
- Ralph 包含 Ultrawork（持久化包装）
- Autopilot 和 Ultrapilot 互斥

### 6.12 场景速查表

| 场景 | 第一个命令 | 后续 |
|---|---|---|
| 快速修复 | 直接描述 | 完成 |
| 构建错误 | `/oh-my-codex:build-fix` | 完成 |
| 复杂 Bug | `/oh-my-codex:plan` | `ralph` → `ultraqa` |
| 新功能（大） | `/oh-my-codex:ralplan` | `team` → `ralph` |
| 新功能（中） | `/oh-my-codex:autopilot` | `ultrawork` → `ralph` |
| 重构 | `/oh-my-codex:plan` | `ralph` → `code-review` |
| 批量修改 | `/oh-my-codex:ultrawork` | 完成 |
| 成本敏感批量 | `eco <描述>` | 完成 |
| Code Review | `/oh-my-codex:code-review` | `security-review` |
| TDD | `/oh-my-codex:tdd` | 完成 |
| 多 Issue 并行 | `omx team (architect)` | `ralplan` → `ralph` → `ultraqa` |
| 取消任何模式 | `/oh-my-codex:cancel` | — |

---

## 7. Hook 系统

### 7.1 生命周期 Hook

| Hook | 时机 | 作用 |
|---|---|---|
| `UserPromptSubmit` | 提交输入时 | 关键字/模式检测 |
| `SessionStart` | 会话启动 | 恢复上下文、drift 检查 |
| `PreToolUse` | 工具执行前 | 预检和策略 |
| `PostToolUse` | 工具执行后 | 验证/记录 |
| `PostToolUseFailure` | 工具失败后 | 失败处理 |
| `Stop` | 会话停止 | 持久化和续接支持 |

### 7.2 Hook 路径

```
~/.codex/hooks/         # 当前路径
```

> 升级逻辑能识别旧的 `.claude/hooks/` 所有权标记，减少误冲突检测。

---

## 8. LSP + AST 工具链

这是 oh-my-codex 的**差异化能力**：

### 8.1 LSP 工具

```
lsp_goto_definition    # 跳转到定义
lsp_find_references    # 查找所有引用
lsp_rename             # 安全重命名
lsp_diagnostics        # 诊断信息
lsp_code_actions       # 快速修复/重构
lsp_hover              # 符号信息
```

### 8.2 AST-Grep

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

## 9. 实用工具

### 9.1 HUD 使用情况监控

状态栏集成 + Token 用量轮询：

```bash
omx hud
```

### 9.2 Rate Limit 恢复

```bash
omx wait           # 检查状态
omx wait --start   # 启用自动恢复
```

支持 tmux pane 扫描和自动 resume。

### 9.3 项目 Session 管理器

基于 worktree + tmux 的隔离工作流：

- 多个实现分支并行运行
- 每个 pane/worktree 一个任务
- 快速上下文切换

---

## 10. 命令速查

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

## 11. 与其他工具的关系

| 组合 | 评估 |
|---|---|
| oh-my-codex + oh-my-claudecode | ✅ 分别用于 Codex CLI 和 Claude Code，不冲突。同一个作者体系 |
| oh-my-codex + Codex CLI 原生 | ✅ 增强关系，OMX 在 Codex 上层运行 |
| oh-my-codex + everything-claude-code | ⚠️ 不同平台，但设计理念类似。不需要同时用 |
| oh-my-codex + Superpowers | ⚠️ Superpowers 支持 Codex CLI，两者可能冲突 |

---

## 12. 反模式

### 12.1 ❌ 小任务用 swarm/ultrawork

→ 简单修复不需要编排层，直接用原生 Codex。

### 12.2 ❌ 不跑 `doctor conflicts`

→ 升级后可能存在 hook 冲突，务必验证。

### 12.3 ❌ 忽略 legacy `.claude/hooks` 残留

→ OMX 能识别旧的 hook 路径，但最好清理避免混淆。

---

## 13. 参考链接

- [GitHub 主仓](https://github.com/sigridjineth/oh-my-codex)
- [oh-my-claudecode（Claude Code 版）](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [OpenAI Codex CLI](https://github.com/openai/codex)
- [Harness Engineering 概念与实践](../harness-engineering/Harness%20Engineering%20概念与实践指南.md)
- [跨工具协作指南](../collaboration/跨工具协作指南.md)

---

## 14. 一句话总结

> **oh-my-codex = 给 Codex CLI 装上多 agent 编排 + LSP/AST 工具链 + 强制 Hook 纪律。** 跟 oh-my-claudecode 是同一设计理念在 Codex 上的实现，30+ agent + 8 种执行模式覆盖从规划到验证的完整流程。
