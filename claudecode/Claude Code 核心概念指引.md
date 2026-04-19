# Claude Code 核心概念指引

> 整理时间：2026-04-19
> 信息来源：Claude Code 官方文档（docs.claude.com/docs/claude-code）+ 实测核验
>
> ⚠️ **本文档定位**：核心概念的**精炼参考**，不是教程。配套阅读：
> - [Claude Code 使用最佳实践指南](./Claude Code 使用最佳实践指南.md) —— 工作流与实践
> - [Claude Code Plugin Marketplace 完全指南](./Claude Code Plugin Marketplace 完全指南.md) —— 插件市场
> - [claude-mem 使用指南](./claude-mem 使用指南与最佳实践.md) —— 跨会话记忆
> - [Superpowers 使用最佳实践指南](../superpower/Superpowers 使用最佳实践指南.md) —— 流程纪律插件

---

## 0. Claude Code 是什么

> **Claude Code 是 Anthropic 官方的"agentic 编程命令行工具"**，提供对模型的低层访问，不强加工作流，几乎所有行为都可脚本化。

| 属性 | 值 |
|---|---|
| 类型 | Coding Agent（CLI / TUI / IDE 扩展） |
| 同类竞品 | OpenCode、Codex CLI、Aider |
| 不同类 | Cursor / VSCode（编辑器，不是 coding agent） |
| 核心特性 | 低层级、无强制工作流；保守权限默认；几乎全可脚本化 |
| 当前最新模型 | Opus 4.7、Sonnet 4.6、Haiku 4.5 |

**Fast 模式**：基于 Claude Opus 4.6 提供更快输出（不降级到小模型）。可用 `/fast` 切换，仅 Opus 4.6 上可用。

---

## 1. 7 大核心概念一览

```
┌─────────────────────────────────────────────────────┐
│  CLAUDE.md（项目记忆）— 自动加载的上下文             │
└──────────────┬──────────────────────────────────────┘
               ↓ 指导
┌──────────┬──────────┬──────────┬───────────────────┐
│  Agents  │  Skills  │ Commands │  MCP / Hooks      │
│ 专家角色 │ 自动技能 │ 手动命令 │  外部集成 / 钩子   │
└──────────┴──────────┴──────────┴───────────────────┘
               ↓ 组织
┌─────────────────────────────────────────────────────┐
│  Plugins —— 把上述全部打包分发                       │
└──────────────┬──────────────────────────────────────┘
               ↓ 控制
┌─────────────────────────────────────────────────────┐
│  Settings.json —— 权限、环境、模型、行为             │
└─────────────────────────────────────────────────────┘
```

| 概念 | 触发方式 | 存储位置 | 学习曲线 |
|---|---|---|---|
| **CLAUDE.md** | 自动加载到上下文 | 项目根 / `~/.claude/CLAUDE.md` | 低 |
| **Skills** | description 匹配自动激活 | `.claude/skills/<name>/SKILL.md` | 中 |
| **Agents** | `@agent` 显式调用或自动派发 | `.claude/agents/<name>.md` | 低 |
| **Commands** | `/command` 手动执行 | `.claude/commands/<name>.md` | 低 |
| **Plugins** | 安装后自动加载 | marketplace 分发 | 中-高 |
| **MCP Servers** | 工具调用时按需 | `.mcp.json` | 中-高 |
| **Hooks** | 事件触发 | `settings.json` | 高 |

---

## 2. CLAUDE.md（项目记忆）

### 2.1 核心机制

CLAUDE.md 是一个 Markdown 文件，每次会话**自动加载到上下文**作为项目长期记忆。

### 2.2 位置优先级（实测，从高到低）

```
1. 项目根 ./CLAUDE.md          ← 项目特异，提交 git
2. 子目录 ./src/CLAUDE.md      ← 子目录覆盖父级
3. ~/.claude/CLAUDE.md         ← 用户级，所有项目通用
```

### 2.3 写什么 / 不写什么

| ✅ 适合写 | ❌ 不适合写 |
|---|---|
| 技术栈、关键命令（test/build/lint） | 敏感信息（密码、API key） |
| 代码风格约定 | 频繁变化的临时状态 |
| 关键目录布局 | 详细实现代码 |
| 团队禁止事项 | 环境变量值（应在 `.env`） |
| 文档同步规则 | 一次性任务备注 |

### 2.4 实战要点

- **越短越好**：CLAUDE.md 每轮都占 token，超过 200 行会显著拖慢
- **写约束不写文档**："用 pnpm 不是 npm" > "我们的 npm 习惯..."
- **嵌套使用**：大型 monorepo 可在每个子模块放一个，避免根 CLAUDE.md 膨胀
- **配合 `/init-deep`** 类工具自动生成层级结构（见相关插件）

---

## 3. Skills（技能）

### 3.1 核心机制

Skill 是带 frontmatter 的 Markdown 文件，**触发完全靠 `description` 字段匹配**。

```markdown
---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging
（skill 内容）
```

### 3.2 触发原理

模型每次回应**前**扫一遍 skill 列表的 description。匹配（哪怕只有 1% 可能）→ 加载 skill 内容。

### 3.3 存储位置

```
.claude/skills/<name>/
├── SKILL.md          # 必须，frontmatter + 内容
├── references/       # 可选，被 SKILL.md 引用的子文档
└── scripts/          # 可选，skill 用的脚本
```

### 3.4 description 写法的好坏决定一切

| 写法 | 效果 |
|---|---|
| `Use when writing code` | ❌ 太宽，每次都误触发 |
| `Use when implementing any feature or bugfix, before writing implementation code` | ✅ 明确条件 + 时机 |

**原则：** 描述"WHEN to use"而不是"What it does"。

### 3.5 与 Hook 的对比

| 维度 | Skill | Hook |
|---|---|---|
| 强制性 | 软（依赖模型听话） | 硬（可阻断 tool call） |
| 触发 | description 匹配 | 事件（PreToolUse 等） |
| 失败行为 | 模型可能跳过 | 强制阻断 |
| 适用 | 引导工作流 | 必须执行的纪律 |

---

## 4. Agents（代理）

### 4.1 与 Sub-agents 的区别

> ⚠️ 这是最容易混淆的两个概念：

| 概念 | 含义 |
|---|---|
| **Agents（项目级）** | `.claude/agents/*.md` 中定义的"专家角色" |
| **Sub-agents** | 通过 `Agent` 工具派发的、有独立上下文的执行单元 |

二者关系：你可以**通过 Agent 工具派发一个 Sub-agent，并指定它扮演某个项目级 Agent**。

### 4.2 何时用 Agent

- 任务需要**独立上下文**（不污染主线）
- 任务**完全可并行**（无共享状态）
- 大量探索性搜索（结果汇总后回主线）

### 4.3 何时不用

- 任务需要主线持续推进
- 需要中间步骤的细节
- 任务有顺序依赖（subagent 启动慢，串行反而吃亏）

### 4.4 文件结构（最小）

```markdown
---
name: code-reviewer
description: Use after major project step is complete, to review against plan and standards
tools: Read, Grep, Bash
---

你是资深 code reviewer。当被调用时：
1. 对照 plan 检查实现
2. 按 critical / major / minor 分级
3. 输出可操作建议
```

---

## 5. Slash Commands（斜杠命令）

### 5.1 核心机制

`.claude/commands/<name>.md` 中定义。用户输入 `/<name>` 触发。

### 5.2 与 Skill 的对比

| 维度 | Slash Command | Skill |
|---|---|---|
| 触发方式 | 用户**显式**输入 `/cmd` | 模型**判断**自动激活 |
| 适合 | 用户可预知何时需要的操作 | 让模型在合适时机自动用的工作流 |
| 例子 | `/onboard`、`/release` | `systematic-debugging`、`tdd` |

**简单规则：** 你想"我每次需要这个，主动叫它出来" → command；你想"模型应该在 X 情况下自动用它" → skill。

### 5.3 参数

```markdown
---
description: Create a new API endpoint
---

# 创建 API: $ARGUMENTS

按 RESTful 规范实现 $ARGUMENTS 接口...
```

调用：`/create-api users`

---

## 6. Plugins（插件）

### 6.1 核心机制

把 agents / skills / commands / hooks / MCP 配置打包成一个**可分发**的目录，通过 marketplace 发布。

### 6.2 关键概念

| 概念 | 说明 |
|---|---|
| **Marketplace** | 一个 GitHub 仓库，含 `marketplace.json` |
| **Plugin** | marketplace 中的一个条目 |
| **`.claude-plugin/plugin.json`** | 插件清单（声明它含哪些 agents/skills/commands） |

### 6.3 安装

```bash
/plugin marketplace add <owner>/<repo>
/plugin install <plugin-name>@<marketplace-name>
```

详见 [Claude Code Plugin Marketplace 完全指南](./Claude Code Plugin Marketplace 完全指南.md)。

---

## 7. MCP Servers（模型上下文协议）

### 7.1 核心机制

[Model Context Protocol](https://modelcontextprotocol.io) 是一个开放协议，让 LLM 通过统一接口调用外部工具/数据源。

### 7.2 与 Bash 工具的对比

| 维度 | MCP Server | Bash 工具 |
|---|---|---|
| 接口 | 结构化（JSON Schema） | 自由文本（命令行） |
| 类型安全 | ✅ | ❌ |
| 适合 | 外部 SaaS、长期集成 | 本地一次性命令 |
| 性能 | 进程常驻 | 每次新启动 |

### 7.3 配置位置

```jsonc
// .mcp.json（项目级）或 ~/.claude.json（用户级）
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### 7.4 安全建议

- **永不**把 token 直接写进 `.mcp.json`，用 `${ENV_VAR}` 引用
- `.mcp.json` 提交 git 时**不带 secrets**
- 不信任的 MCP server 不要装 —— 它能读你给它的所有上下文

---

## 8. Hooks（钩子）

### 8.1 核心机制

在生命周期事件触发 shell 命令。配置在 `settings.json`。

### 8.2 主要事件

| 事件 | 触发时机 | 典型用途 |
|---|---|---|
| `SessionStart` | 会话启动 | 加载项目状态 |
| `UserPromptSubmit` | 用户提交输入后 | 注入额外上下文 |
| `PreToolUse` | 工具执行前 | **拦截危险操作** |
| `PostToolUse` | 工具执行后 | 自动格式化、记录审计 |
| `Stop` | 模型停止 | 显示总结 |
| `SessionEnd` | 会话结束 | 持久化 memory |

### 8.3 PreToolUse 的硬约束能力

PreToolUse 返回非 0 退出码会**阻断 tool call**。这是 hook 比 skill 强大的地方：

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash(rm -rf*)",
      "hooks": [{
        "type": "command",
        "command": "echo 'Blocked dangerous rm -rf' && exit 1"
      }]
    }]
  }
}
```

### 8.4 调试 Hook

```bash
# 手动跑一遍
./.claude/hooks/your-hook.sh

# 在 Claude Code 内开启 debug
claude --debug
```

---

## 9. Settings.json（配置系统）

### 9.1 层级和优先级（从高到低）

```
1. Enterprise managed         （IT 管理）
2. Command-line arguments     （--flag）
3. .claude/settings.local.json（个人覆盖，gitignore）
4. .claude/settings.json      （项目共享，提交 git）
5. ~/.claude/settings.json    （用户级，所有项目）
```

### 9.2 权限配置

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(git status:*)",
      "Bash(npm run:*)",
      "Read(./src/**)"
    ],
    "deny": [
      "Bash(rm -rf:*)"
    ],
    "ask": [
      "Bash(*)"
    ]
  }
}
```

**最佳实践：** 从默认权限开始，**被打断时**再加具体的，避免一次给 `*` 大权。

### 9.3 关键字段

| 字段 | 用途 |
|---|---|
| `permissions` | 工具权限白/黑名单 |
| `env` | 环境变量 |
| `model` | 默认模型 |
| `hooks` | hook 注册 |
| `mcpServers` | MCP 配置（可移到 `.mcp.json`） |

---

## 10. 易混淆概念辨析

### 10.1 Agents vs Skills vs Commands

| 维度 | Agents | Skills | Commands |
|---|---|---|---|
| **谁触发** | 用户 `@` 或主线模型派发 | 模型自动判断 | 用户 `/` |
| **上下文** | 独立（subagent） | 共享主线 | 共享主线 |
| **适合** | 隔离任务、并行 | 引导工作流 | 用户预知的快捷操作 |

### 10.2 CLAUDE.md vs Skills

| 维度 | CLAUDE.md | Skills |
|---|---|---|
| **加载** | 永远在 context | 按需加载 |
| **大小** | 应保持小（< 200 行） | 可以大（按需才进 context） |
| **内容** | 项目通用约定 | 特定流程的操作手册 |

### 10.3 Skills vs Hooks

| 维度 | Skills | Hooks |
|---|---|---|
| **强制性** | 软（依赖模型） | 硬（可阻断） |
| **触发** | description 匹配 | 事件 |
| **适合** | "应该这么做" | "必须这么做" |

### 10.4 MCP vs Bash vs Hooks

| 维度 | MCP | Bash | Hooks |
|---|---|---|---|
| **谁主动** | 模型按需调用 | 模型按需调用 | 系统在事件点触发 |
| **接口** | 结构化 | 自由文本 | shell |
| **状态** | 长驻进程 | 一次性 | 一次性 |

### 10.5 项目级 vs 用户级 vs 插件级

| 层级 | 路径 | 适合 |
|---|---|---|
| **项目级** | `.claude/` | 团队共享，提交 git |
| **个人覆盖** | `.claude/settings.local.json` | 仅自己的偏好，gitignore |
| **用户级** | `~/.claude/` | 跨所有项目的偏好 |
| **插件级** | marketplace 分发 | 复用社区/团队成果 |

---

## 11. 使用场景决策树

```
有任务需求
    │
    ├─ 需要 Claude 永远知道（不论问什么）？
    │   └─ → CLAUDE.md
    │
    ├─ 特定场景下让 Claude 自动按某流程做？
    │   └─ → Skill
    │
    ├─ 我自己想随时主动唤起的操作？
    │   └─ → Slash Command
    │
    ├─ 需要专家视角 / 隔离上下文 / 并行执行？
    │   └─ → Agent (subagent)
    │
    ├─ 接入外部服务（GitHub、Slack、DB）？
    │   └─ → MCP Server
    │
    ├─ 必须强制执行（不允许跳过）？
    │   └─ → Hook
    │
    └─ 多个上述能力打包给团队/社区？
        └─ → Plugin
```

---

## 12. 配置最佳实践速查

### 12.1 CLAUDE.md
- < 200 行
- 写约束、写事实、写禁止
- 不写敏感信息

### 12.2 Skills
- description 写"WHEN to use"
- 一个 skill 一件事
- 优先 process skill（debugging、tdd）

### 12.3 Agents
- 用于上下文隔离，不是为了"专业感"
- 限制权限（reviewer 应该只读）

### 12.4 Hooks
- PreToolUse 用于安全约束
- PostToolUse 用于自动化（format、audit）
- fail-loud：失败要醒目，不要静默

### 12.5 MCP
- token 走 `${ENV_VAR}`，不进配置文件
- 不信任的不装

### 12.6 Settings 权限
- 默认开始，渐进放行
- 用 `Bash(cmd:*)` 形式，避免 `*`

---

## 13. 常见问题

### Q: Skill 不触发怎么办？
1. 看 description 是否够明确
2. 检查 frontmatter 格式
3. 重启会话让 SessionStart hook 重新扫描

### Q: 如何减少上下文消耗？
1. 缩短 CLAUDE.md，详细内容拆到子文件
2. 用层级化 CLAUDE.md（每个子目录一个）
3. 用 `/compact` 主动压缩
4. 长任务定期开新会话 + memory 接力

### Q: Skills vs Slash Commands 怎么选？
- 你**自己决定何时用** → Command
- 模型**应该自动决定** → Skill

### Q: Hook 调试？
```bash
./.claude/hooks/<your-hook>.sh   # 手动跑
claude --debug                   # 看完整日志
```

### Q: MCP Server 起不来？
1. 看是否有 token 环境变量未设
2. `npx -y` 第一次安装慢，等一下
3. `claude --debug` 看 MCP 启动日志

---

## 14. 相关文档与资源

### 本工程内文档
- [Claude Code 使用最佳实践指南](./Claude Code 使用最佳实践指南.md)
- [Claude Code Plugin Marketplace 完全指南](./Claude Code Plugin Marketplace 完全指南.md)
- [claude-mem 使用指南](./claude-mem 使用指南与最佳实践.md)
- [Superpowers 使用最佳实践指南](../superpower/Superpowers 使用最佳实践指南.md)

### 官方文档
- [Claude Code 官方文档](https://docs.claude.com/docs/claude-code)
- [Settings 参考](https://docs.claude.com/docs/claude-code/settings)
- [Skills 文档](https://docs.claude.com/docs/claude-code/skills)
- [Plugins 文档](https://docs.claude.com/docs/claude-code/plugins)
- [Agent SDK](https://docs.anthropic.com/docs/claude-code/sdk)
- [MCP 协议](https://modelcontextprotocol.io)

### 社区
- [Anthropic Skills](https://github.com/anthropics/skills)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code Best Practices（官方博客）](https://www.anthropic.com/engineering/claude-code-best-practices)

---

## 附：本文档与旧版的主要差异

| 旧版问题 | 修订 |
|---|---|
| 2131 行，markdown 嵌套混乱（示例 `##` 被当章节） | 重构为 14 节，每节聚焦单一概念 |
| 大量过时配置示例（FastAPI/Vue 项目堆砌） | 删除业务示例，留通用模式 |
| Settings 权限格式不一致 | 统一为 `allow/deny/ask` |
| 缺与本工程其他文档的交叉引用 | 头部和末尾均建立导航 |
| "中文社区资源"含未核实链接 | 移除，仅留官方与可验证资源 |
| 无 Fast 模式 / 最新模型说明 | 补 Opus 4.7 / Sonnet 4.6 / Haiku 4.5 / Fast 模式 |
| MCP / Hook 安全建议缺失 | 各节末加 "安全建议" |
