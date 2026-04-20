# OpenCode + omo（Oh My OpenAgent）使用最佳实践指南

> 整理时间：2026-04-19
> 信息来源：实测核验 [anomalyco/opencode](https://github.com/anomalyco/opencode) 和 [code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) 的 README、features.md、installation.md

---

## 0. 重要前置说明

### 0.1 概念澄清（避免常见误解）

**OpenCode 不是编辑器。** 它是一个**开源的 coding agent**（CLI / TUI），运行在终端，与 Claude Code、Codex CLI、Aider 同类，**不**是 Cursor / VSCode 的同类。其官方一句话定位是 *"The open source coding agent"*。

| 工具 | 类型 | 备注 |
|---|---|---|
| **OpenCode** | Coding Agent（终端） | TypeScript 实现，145K+ stars |
| Claude Code | Coding Agent | Anthropic 官方 |
| Cursor / VSCode | 编辑器（含 AI 补全） | 不同层级 |

### 0.2 命名变更（2026 年初已改名）

`oh-my-opencode` 项目**已改名为 omo（Oh My OpenAgent）**：

| 项目 | 旧 | 新（当前） |
|---|---|---|
| 项目名 | Oh My OpenCode | **omo / Oh My OpenAgent** |
| 仓库路径 | code-yeongyu/oh-my-opencode | **[code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)** |
| npm 包名 | `oh-my-opencode` | **`oh-my-opencode`（保留不变）** |
| `opencode.json` 中的 plugin 项 | `oh-my-opencode` | **`oh-my-openagent`**（旧名仍兼容，会出 warning） |
| 配置文件名 | `oh-my-opencode.json[c]` | **`oh-my-openagent.json[c]`**（旧名仍兼容） |

**License**：omo 采用 **SUL-1.0（Sustainable Use License）**，**不是 MIT**。商用前请阅读 license 条款。

### 0.3 omo 的真实定位（一句话）

> **多模型 agent 编排增强 for OpenCode**：把单一 AI agent 升级为分工明确的"开发团队"，通过 category 自动选模型，避免 vendor lock-in。

omo 作者明确反对锁定单一供应商，鼓励组合使用 Kimi / GLM / GPT / Claude / Gemini / MiniMax 等多家订阅。

---

## 1. 装不装 omo 的判断

omo 是个**重量级 harness 增强**，不是所有人都该装。先判断：

| 你的情况 | 建议 |
|---|---|
| 只有一个 LLM 订阅（如只 Claude Pro） | **暂不装**。直接用 OpenCode 内置能力 + 一两个 hook 即可 |
| 有 2+ 订阅且想跨模型组合 | **可以装**。omo 的 category-based 多模型编排是核心价值 |
| 项目偏 PoC / 一次性脚本 | **不装**。omo 的纪律 agent（Sisyphus / Todo Enforcer）会拖慢节奏 |
| 长期维护项目，跨 session 工作多 | **可以装**。background agents、`/init-deep` 等收益显著 |
| 企业 / 商用 | 先看 SUL-1.0 license，再决定 |

---

## 2. 安装

### 2.1 推荐方式：让 LLM agent 帮你装（官方做法）

omo 官方 README 原话：*"seriously, let an agent do it. Humans fat-finger configs."*

在你现有的任意 LLM agent 会话（Claude Code / Cursor / 已装的 OpenCode 等）中粘贴：

```
Install and configure oh-my-opencode by following the instructions here:
https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md
```

agent 会询问你 9 个订阅相关问题，再生成对应安装命令。

### 2.2 手动安装

先确认 OpenCode 已装：

```bash
opencode --version  # 不存在则参考 https://opencode.ai/docs
```

交互式安装：

```bash
bunx oh-my-opencode install
```

非交互式（按订阅情况组合 flag）：

```bash
bunx oh-my-opencode install --no-tui \
  --claude=<yes|no|max20> \
  --openai=<yes|no> \
  --gemini=<yes|no> \
  --copilot=<yes|no> \
  --opencode-zen=<yes|no> \
  --opencode-go=<yes|no> \
  --zai-coding-plan=<yes|no> \
  --kimi-for-coding=<yes|no> \
  --vercel-ai-gateway=<yes|no>
```

**flag 含义：**

| flag | 说明 |
|---|---|
| `--claude=max20` | Claude Pro/Max 20× 订阅 |
| `--claude=yes` | Claude Pro/Max 普通订阅 |
| `--openai=yes` | ChatGPT Plus（启用 GPT-5.4 → Oracle） |
| `--gemini=yes` | Google Gemini |
| `--copilot=yes` | GitHub Copilot |
| `--opencode-zen=yes` | OpenCode Zen 聚合订阅 |
| `--opencode-go=yes` | OpenCode Go（$10/月，含 GLM-5、Kimi K2.5、MiniMax M2.7） |
| `--zai-coding-plan=yes` | Z.ai Coding Plan |
| `--kimi-for-coding=yes` | Moonshot Kimi for Coding |

> ⚠️ **强警告**：没有 Claude 订阅时，主编排 Sisyphus 表现不理想（其 prompt 针对 Claude/Kimi/GLM 优化）。建议至少配 Claude / Kimi / GLM 三者之一。

### 2.3 验证安装

```bash
# 内置诊断（推荐）
bunx oh-my-opencode doctor

# 手动检查 plugin 配置
cat ~/.config/opencode/opencode.json
# 应看到 plugin 数组中包含 "oh-my-openagent"（旧版可能写 "oh-my-opencode"）
```

如果 `doctor` 提示 *"Using legacy package name"*，把 `opencode.json` 里的 `oh-my-opencode` 改成 `oh-my-openagent`。

### 2.4 卸载

```bash
# 1. 从 plugin 列表移除（兼容新旧名）
jq '.plugin = [.plugin[] | select(. != "oh-my-openagent" and . != "oh-my-opencode")]' \
   ~/.config/opencode/opencode.json > /tmp/oc.json && \
   mv /tmp/oc.json ~/.config/opencode/opencode.json

# 2. 删配置文件
rm -f ~/.config/opencode/oh-my-openagent.{json,jsonc} \
      ~/.config/opencode/oh-my-opencode.{json,jsonc}
rm -f .opencode/oh-my-openagent.{json,jsonc} \
      .opencode/oh-my-opencode.{json,jsonc}
```

### 2.5 关于 telemetry

omo 默认开启匿名 telemetry（PostHog + 哈希后的安装 ID）。关闭方式：

```bash
export OMO_SEND_ANONYMOUS_TELEMETRY=0
# 或
export OMO_DISABLE_POSTHOG=1
```

---

## 3. omo 的核心差异化能力

这一节回答："装 omo 到底值不值？" —— 列出**只有 omo 有、其他 harness 没有**的关键能力。

### 3.1 Hash-Anchored Edit Tool（最重要）

**问题背景**：所有 coding agent 失败的最大根因不是模型，而是 **edit 工具** —— 模型必须重现它之前看到的字符串才能编辑，文件一改就失败。

**omo 的解法（Hashline）**：每次读文件时给每行加 `LINE#ID` 内容哈希：

```
11#VK| function hello() {
22#XJ|   return "world";
33#MB| }
```

agent 通过 `LINE#ID` 引用编辑。如果内容变了哈希对不上，**编辑会被拒绝**而不是覆盖错误。

**实测效果**：Grok Code Fast 1 的 edit 成功率从 **6.7% → 68.3%**（仅靠改 edit 工具）。

灵感来自 [oh-my-pi](https://github.com/can1357/oh-my-pi) 和 [The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/)。

### 3.2 Category 系统（多模型自动选择）

omo 的核心抽象：**agent 选 category，category 自动映射到模型**。你不需要管哪个模型擅长什么。

| Category | 默认模型 | 适用场景 |
|---|---|---|
| `visual-engineering` | google/gemini-3.1-pro | 前端、UI/UX、设计、动画 |
| `ultrabrain` | openai/gpt-5.4 (xhigh) | 深度逻辑、复杂架构决策 |
| `deep` | openai/gpt-5.4 (medium) | 目标驱动的自主问题求解 |
| `artistry` | google/gemini-3.1-pro (high) | 高度创意/艺术任务 |
| `quick` | openai/gpt-5.4-mini | 单文件改动、typo |
| `writing` | google/gemini-3-flash | 文档、技术写作 |
| `unspecified-low` | anthropic/claude-sonnet-4-6 | 其他任务，低投入 |
| `unspecified-high` | anthropic/claude-opus-4-7 (max) | 其他任务，高投入 |

调用方式（在 agent 内）：

```typescript
task({
  category: "visual-engineering",
  prompt: "Add a responsive chart component to the dashboard"
})
```

可以在 `oh-my-openagent.jsonc` 自定义 category。

### 3.3 11 个专业化 Agent（核心团队）

> ⚠️ 修正：网上很多文档列的 agent（如 `frontend-ui-ux-engineer`、`document-writer`）**不存在**。以下是 features.md 实测列表。

**核心 agents（按 tab 切换顺序）：**

| 序号 | Agent | 默认模型 | 角色 |
|---|---|---|---|
| 1 | **Sisyphus** | claude-opus-4-7 | 主编排器，aggressive parallel execution |
| 2 | **Hephaestus** | gpt-5.4 | 自主深度执行者（GPT-native） |
| 3 | **Prometheus** | claude-opus-4-7 | 战略规划者（采访式） |
| 4 | **Atlas** | claude-sonnet-4-6 | Todo 编排执行者 |

**辅助 agents：**

| Agent | 默认模型 | 用途 |
|---|---|---|
| **Oracle** | gpt-5.4 | 架构决策、code review、调试（**只读**，不能写文件） |
| **Librarian** | minimax-m2.7 | 多仓库分析、文档查找、OSS 实现示例（只读） |
| **Explore** | grok-code-fast-1 | 快速代码搜索 + 上下文 grep（只读） |
| **Multimodal-Looker** | gpt-5.4 | 分析 PDF / 图片 / 图表（只读） |
| **Metis** | claude-opus-4-7 | 计划顾问，识别隐藏意图和模糊点 |
| **Momus** | gpt-5.4 | 计划评审者，验证清晰度/可验证性 |
| **Sisyphus-Junior** | category 决定 | category 派发的执行者 |

显式调用：

```
Ask @oracle to review this design and propose an architecture
Ask @librarian how this is implemented
Ask @explore for the policy on this feature
```

**权限矩阵**（默认）：

| Agent | 限制 |
|---|---|
| oracle / librarian / explore / momus | 只读，禁止 write/edit/task |
| multimodal-looker | 仅允许 `read` |
| atlas | 不能 delegate（task 被禁） |

### 3.4 IntentGate

在分类前**先分析用户的真实意图**，避免字面误解。例如你说"清理一下这个文件"，IntentGate 会先判断是"格式化"还是"删除冗余代码"还是"重构"。

### 3.5 Prometheus 三剑客（采访式规划）

**规划入口：** `@plan "任务描述"`
**执行入口：** `/start-work`（规划完成后）

- **Prometheus**：像真正的工程师那样**采访你**，识别 scope 和模糊点，输出可验证的 plan
- **Metis**：在 plan 落地前自动做前置分析，识别 AI 容易踩坑的地方
- **Momus**：在 Metis 之后自动评审 plan 的清晰度、可验证性、完整性

流程：`@plan`（Prometheus 采访 + Metis 分析 + Momus 评审）→ `/start-work`（Atlas 调度执行）

这是 omo 区别于普通"先 plan 后执行"模式的核心，避免 prompt-and-pray。

### 3.6 Hierarchical AGENTS.md（`/init-deep`）

```bash
/init-deep
```

自动在每个目录生成层级化 `AGENTS.md`：

```
project/
├── AGENTS.md              # 项目级
├── src/
│   ├── AGENTS.md          # src 级
│   └── components/
│       └── AGENTS.md      # 组件级
```

agent 自动按需读取最相关的 AGENTS.md，**显著降低 token 消耗** 且让 agent 更"懂"局部上下文。

### 3.7 Background Agents + Tmux 集成

并行运行多个 agent，同时继续主线工作：

```typescript
task({
  subagent_type: "explore",
  load_skills: [],
  prompt: "Find auth implementations",
  run_in_background: true
})
// 主线继续...
background_output(task_id: "bg_abc123")  // 完成时取结果
```

启用 tmux 后台 agent 可视化：

```jsonc
{
  "tmux": {
    "enabled": true,
    "layout": "main-vertical"
  }
}
```

每个 background agent 在独立 tmux pane 实时输出，结束后自动清理。

### 3.8 Ralph Loop（`/ulw-loop`）

自我引用循环，**不到 100% 不停**。适合"一定要把这个功能完整实现"的硬目标。

### 3.9 Todo Enforcer

agent 想偷懒（"我先做这部分，剩下你看看吧"）？Todo Enforcer 会把它**拽回来继续干**。

### 3.10 Comment Checker

阻止 AI 写出"这一行是 X，因为我们要 Y"这类啰嗦注释。强制注释像资深工程师写的。

### 3.11 内置 MCP

| MCP | 用途 |
|---|---|
| **Exa** | Web search |
| **Context7** | 官方文档查询 |
| **Grep.app** | GitHub 代码搜索 |

全部开箱即用，无需额外配置。

### 3.12 LSP + AST-Grep 工具链

LSP 工具（IDE 级精度）：

```
lsp_goto_definition   # 跳转到定义
lsp_find_references   # 查找所有引用
lsp_rename            # 全工作区安全重命名
lsp_diagnostics       # 预构建诊断
lsp_code_actions      # 快速修复 / 重构
lsp_hover             # 符号信息
```

AST-Grep（25 种语言）：

```typescript
ast_grep_search({ pattern: "console.log($MSG)", lang: "javascript" })
ast_grep_replace({
  pattern: "console.log($MSG)",
  rewrite: "logger.info($MSG)",
  lang: "javascript"
})
```

### 3.13 Skill-Embedded MCP

Skills 可以**自带 MCP server**，按需启动、scoped to task、用完即关。避免常驻 MCP 吃 context budget。

内置 skills：`playwright`（浏览器自动化）、`git-master`（原子提交、rebase 手术）、`frontend-ui-ux`（设计优先 UI）。

自定义路径：

- `~/.config/opencode/skills/*/SKILL.md`（用户级）
- `.opencode/skills/*/SKILL.md`（项目级）

### 3.14 Claude Code 兼容

omo 完全兼容 Claude Code 的 hooks / commands / skills / MCPs / plugins。从 Claude Code 迁移过来的配置可以原样使用。

---

## 4. 功能归属：OpenCode 内置 vs omo 提供

> **很多核心能力（Prometheus 三剑客、ultrawork、多 agent）都是 omo 提供的，不是 OpenCode 自带的。** 装 OpenCode 不等于有这些能力，必须额外安装 omo。

### 4.0.1 功能归属对照表

| 功能 | OpenCode 内置 | omo 提供 |
|---|---|---|
| `/compact`、`/clear`、`/undo`、`/redo`、`/share` | ✅ | — |
| `/init`（生成 AGENTS.md） | ✅ | — |
| `/connect`（连接 OpenCode Zen） | ✅ | — |
| Tab 模式切换（Plan ↔ Build） | ✅ | — |
| `@plan`（Prometheus 三剑客规划） | — | ✅ |
| `/start-work`（读取 plan 后 Atlas 调度执行） | — | ✅ |
| `/init-deep`（层级化 AGENTS.md） | — | ✅ |
| `ultrawork` / `ulw`（全功能编排） | — | ✅ |
| `/ulw-loop`（Ralph 循环） | — | ✅ |
| `@oracle` / `@librarian` / `@explore` 等 11 个 agent | — | ✅ |
| Hash-Anchored Edit（Hashline） | — | ✅ |
| IntentGate（意图分析） | — | ✅ |
| Category 系统（多模型自动选择） | — | ✅ |
| Todo Enforcer（防止半途而废） | — | ✅ |
| Comment Checker（注释质量检查） | — | ✅ |
| Skill-Embedded MCP | — | ✅ |
| 内置 MCP（Exa / Context7 / Grep.app） | — | ✅ |

### 4.0.2 全部命令/功能触发方式一览

**手动输入斜杠命令（`/`）：**

| 命令 | 作用 |
|---|---|
| `/start-work` | 执行入口（读取 plan 后 Atlas 调度 agent） |
| `/ulw-loop` | Ralph 循环，不到 100% 不停 |
| `/init` | 生成项目级 AGENTS.md |
| `/init-deep` | 生成层级化 AGENTS.md |
| `/compact` | 压缩上下文 |
| `/clear` | 清除上下文 |
| `/undo` / `/redo` | 撤销 / 重做 |
| `/share` | 分享对话链接 |
| `/connect` | 连接 OpenCode Zen |

**手动输入 Prompt 关键字（写在 TUI 对话框里）：**

| 关键字 | 简写 | 作用 |
|---|---|---|
| `ultrawork:` | `ulw:` | 激活全功能编排 |
| `@plan "<任务>"` | — | 规划入口（Prometheus 采访式规划） |
| `@oracle <问题>` | — | 架构决策 / code review（只读） |
| `@librarian <问题>` | — | 多仓库分析 / 文档查找（只读） |
| `@explore <问题>` | — | 快速代码搜索（只读） |
| `@multimodal-looker <问题>` | — | 分析图片 / PDF（只读） |

**自动触发（不需要手动）：**

| 功能 | 触发时机 |
|---|---|
| IntentGate | 每次你输入时自动分析意图 |
| Hash-Anchored Edit | 每次读取/编辑文件时自动启用 |
| Category 系统 | `ultrawork` 执行时自动按任务类型选模型 |
| Sisyphus 主编排 | `ultrawork` 激活后自动接管 |
| Todo Enforcer | `ultrawork` 执行中自动监控，防止半途而废 |
| Comment Checker | 写代码时自动检查注释质量 |
| Background Agent | Sisyphus 判断任务可并行时自动派发 |
| Tab 模式切换 | 按 Tab 键切换 Plan ↔ Build |

### 4.0.3 与 Superpowers 的关键区别

| 对比 | Superpowers | OpenCode + omo |
|---|---|---|
| 核心流程 | **全自动**，你说需求它自己走 | **大部分手动触发**（`@plan`、`ulw:`、`@oracle`） |
| 设计哲学 | 让你不管流程，AI 全权负责 | 给你控制权，你来调度 agent |
| 典型用法 | "我想做 X" → AI 自动 brainstorm → plan → TDD | `@plan` → `/start-work` → `ulw:` → `@oracle review` |
| 适合 | 想要"说完就不管"的纪律化流程 | 想要精细控制每一步的用户 |

---

## 5. 核心工作流

### 5.1 `ultrawork` / `ulw`：一句话激活全功能

```
ultrawork: 实现用户注册功能，包含表单、API、数据库迁移
```

激活效果：
- IntentGate 先分析意图
- Sisyphus 主编排
- 自动按 category 派发到合适的 agent + 模型
- background agent 并行执行独立子任务
- Todo Enforcer 防止半途而废

> ⚠️ 上述 `ultrawork:` 不是 shell 命令，**是写在 OpenCode TUI 对话框里的 prompt 关键字**。

### 5.2 `@plan` + `/start-work`：采访式规划与执行

复杂任务用这个，避免 prompt-and-pray：

**第一步：规划**

```
@plan "我想做一个用户管理系统"
[Prometheus 开始采访: 用户量级? 是否需要 SSO? 权限粒度?...]
[Metis 介入: 识别隐藏假设...]
[Momus 评审 plan...]
[plan 输出到 .sisyphus/plans/]
```

**第二步：执行**

```
/start-work
[Atlas 读取 plan，调度专家 agent 执行]
```

### 5.3 显式 agent 调用

```
@oracle 这个架构设计有什么问题？
@librarian React 19 的 useEffect 有什么变化？
@explore 项目里哪里用到了 JWT？
```

### 5.4 后台并行

```
让 @explore 在后台搜索所有 auth 实现，我先继续写注册接口
```

### 5.5 模式切换

| 操作 | 效果 |
|---|---|
| `Tab` | Plan ↔ Build 模式切换 |
| `/undo` | 撤销上次更改 |
| `/redo` | 重做 |
| `/share` | 生成对话分享链接 |
| `/init` | 生成项目级 AGENTS.md（基础版） |
| `/init-deep` | 生成层级化 AGENTS.md |

---

## 6. 配置最佳实践

### 6.1 配置文件位置

| 文件 | 作用 |
|---|---|
| `~/.config/opencode/opencode.json` | OpenCode 主配置 |
| `~/.config/opencode/oh-my-openagent.jsonc` | omo 用户级配置（旧名 `oh-my-opencode.jsonc` 仍兼容） |
| `.opencode/oh-my-openagent.jsonc` | omo 项目级配置 |
| `AGENTS.md`（项目根 / 子目录） | OpenCode 上下文注入入口 |

JSONC 支持注释和尾随逗号。

### 6.2 并发控制（避免烧 token）

```jsonc
{
  "background_task": {
    "defaultConcurrency": 5,
    "providerConcurrency": {
      "anthropic": 3,        // 限制贵的
      "google": 10           // 便宜的放宽
    },
    "modelConcurrency": {
      "anthropic/claude-opus-4-7": 2  // Opus 严控
    }
  }
}
```

### 6.3 禁用不需要的功能

```jsonc
{
  "disabled_hooks": [
    "comment-checker"        // 不需要注释检查
  ],
  "disabled_agents": [
    "multimodal-looker"      // 不处理图片
  ],
  "disabled_mcps": [
    "grep_app"               // 不用 GitHub 代码搜索
  ]
}
```

### 6.4 Agent 权限覆盖

```jsonc
{
  "agents": {
    "explore": {
      "permission": {
        "edit": "deny",
        "bash": "ask",
        "webfetch": "allow"
      }
    }
  }
}
```

### 6.5 自定义 Category

```jsonc
{
  "categories": {
    "my-backend": {
      "description": "Backend Go services with strict typing",
      "model": "anthropic/claude-opus-4-7",
      "variant": "max",
      "temperature": 0.3,
      "prompt_append": "Always use go.uber.org/zap for logging",
      "reasoningEffort": "high"
    }
  }
}
```

### 6.6 自定义 MCP

```jsonc
// .mcp.json 或 .opencode/.mcp.json
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

---

## 7. 模型选型建议

### 7.1 Sisyphus（主编排）的最佳模型

按 omo 作者实测：

| 模型 | 评价 |
|---|---|
| **Claude Opus 4.7** | 最佳整体体验，prompt 针对它优化 |
| **Kimi K2.5** | Claude 风格的最佳替代，性价比高 |
| **GLM 5**（Z.ai） | 稳定可用 |
| GPT-5.4 | 新增 dedicated prompt path，可用但不如前三 |
| 旧 GPT 系列 | **不推荐**，请改用 Hephaestus |

### 7.2 不同任务的模型路由（自动）

omo 已经把模型选择封装在 category 里，普通用户**不需要手动指定**。如果你想覆盖：

```jsonc
{
  "categories": {
    "visual-engineering": {
      "model": "anthropic/claude-opus-4-7"  // 覆盖默认的 gemini-3.1-pro
    }
  }
}
```

### 7.3 低成本组合（无 Claude 订阅）

omo 作者推荐的"够用"组合：

- ChatGPT Plus（$20/月）+ Kimi for Coding（限时 $0.99/月）+ Z.ai Coding Plan（$10/月）
- 或者：OpenCode Go（$10/月，已含 GLM-5/Kimi K2.5/MiniMax M2.7）

---

## 8. 日常开发工作流（按场景）

### 8.0 核心决策模型

omo 的设计哲学是 **3 条路径**，不是固定模板：

```
是简单任务吗？
  └─ YES → 直接描述任务，不需要任何命令
  └─ NO  → 解释上下文很麻烦吗？
              └─ YES → 输入 ulw 或 ultrawork，让 agent 自己搞定
              └─ NO  → 需要精确、可验证的执行吗？
                         └─ YES → @plan 规划 → /start-work 执行
                         └─ NO  → 直接用 ulw
```

| 情况 | 命令 | 适用 |
|---|---|---|
| 简单任务 | 直接描述 | 快速修复、单文件改动 |
| 复杂但懒得解释 | `ulw <描述>` | 上下文复杂，让 agent 自己判断 |
| 复杂且要精确 | `@plan` → `/start-work` | 多步骤、需要验证的编排执行 |

### 8.1 两种核心模式对比

omo 有两种核心工作模式，对应不同场景：

| 维度 | Hephaestus + ultrawork（懒人模式） | Sisyphus + Prometheus（精确模式） |
|---|---|---|
| 触发 | `ulw` / `ultrawork` | `@plan` → `/start-work` |
| Agent | 单个强大 agent，自主执行 | 编排团队：Prometheus 规划 → Atlas 调度 → 专家执行 |
| 规划方式 | 隐式，agent 自己判断 | 显式，通过采访生成结构化 plan |
| 适合 | 复杂但探索性的工作 | 精确、多步骤、需验证的工作 |
| Temperature | 较高（更有创造性） | 较低（更确定性） |

### 8.2 新系统开发（Greenfield）

**推荐路径：Prometheus 精确模式**

```
/init-deep                              ← 第一步，建立层级化知识骨架
    ↓
@plan "build X feature"                 ← Prometheus 采访式规划
    ↓                                       发现已有模式时会问："Follow it or deviate?"
    ↓
审查 .sisyphus/plans/ 中的 plan          ← 你审批
    ↓
/start-work                             ← Atlas 自动激活，调度专家 agent
    ↓                                       agent 按 category 选模型（visual-engineering / ultrabrain / deep）
    ↓
@oracle review 架构设计                  ← 终审（只读）
```

**懒人替代方案：**

```
ultrawork build X feature               ← 让 agent 自己搞定
```

**Category + Skill 组合（推荐 persona）：**

| Persona | Category | Skill | 适合 |
|---|---|---|---|
| The Designer | `visual-engineering` | `frontend-ui-ux` + `playwright` | 前端/UI 开发 |
| The Architect | `ultrabrain` | （无，纯推理） | 架构设计 |

### 8.3 既有系统加功能（Brownfield）

**推荐路径：Prometheus 精确模式**

```
/init-deep                              ← 从现有代码建立知识库
    ↓
@explore 分析项目结构和相关模块          ← 快速建图（grok-code-fast-1）
    ↓
@plan "add X feature to module Y"       ← Prometheus 进入采访模式
    ↓                                       应用 Discovery 策略："Found pattern X. Follow it?"
    ↓
审查 plan，然后 /start-work             ← Atlas 编排执行
    ↓                                       agent 参考 AGENTS.md 中的已有模式
    ↓
使用 git-master skill 提交              ← 自动原子提交
```

**git-master 原子提交规则：**

| 改动文件数 | 最少提交数 |
|---|---|
| 3+ | 2 commits |
| 5+ | 3 commits |
| 10+ | 5 commits |

**懒人替代方案：**

```
ulw add X feature to module Y, follow existing patterns
```

### 8.4 Bug 修复（简单）

**直接描述，不需要任何命令：**

```
Fix the null pointer error in UserService.java line 42
```

### 8.5 Bug 修复（复杂 / 根因不明）

**推荐路径：Oracle 分析 → ultrawork 修复**

```
@oracle "analyze the root cause of [症状]"   ← 深度分析（只读）
    ↓
@explore 找到所有受影响的代码路径              ← 快速搜索
    ↓
ulw fix the bug identified by oracle analysis  ← 执行修复
    ↓
review-work skill                              ← 5 个并行 sub-agent 验证
```

⚠️ Oracle 是只读的，它只给建议不会改代码。修复阶段才让 Sisyphus 出手。

### 8.6 批量修改 / Lint 修复

**ultrawork 最大并行：**

```
ulw fix all ESLint warnings in src/
```

### 8.7 重构

**推荐路径：`/refactor` 命令**

```
/refactor "refactor module X for better separation of concerns"
```

`/refactor` 自动集成 LSP、AST-grep、架构分析和 TDD 验证。

**大规模重构用 Prometheus 精确模式：**

```
@plan "refactor the authentication module"     ← Prometheus 采访，应用 Safety 策略
    ↓                                              问："What tests verify current behavior?"
    ↓                                              问："Rollback strategy?"
    ↓
审查 plan，然后 /start-work                    ← 执行
    ↓
ai-slop-remover skill                          ← 清理 AI 生成的代码气味
    ↓
review-work skill                              ← 5 个并行 sub-agent 终审
```

### 8.8 Code Review

**推荐路径：`review-work` skill**

```
激活 review-work skill → 启动 5 个并行 background sub-agent：
  ├── Goal verification agent    ← 目标验证
  ├── Code quality agent         ← 代码质量
  ├── Security agent             ← 安全检查
  ├── Hands-on QA agent          ← 实测 QA
  └── Context mining agent       ← 上下文挖掘
```

审查整合后的发现，用 `ulw` 修复问题。

### 8.9 架构设计

**推荐路径：Prometheus + Oracle + Librarian 三件套**

```
@plan "design architecture for X"              ← Prometheus 应用 Strategic 策略
    ↓                                              问："Expected lifespan? Scale requirements?"
    ↓
@oracle "research best practices for X"        ← 深度研究（只读）
    ↓
@librarian "lookup existing docs for X"        ← 文档查找（只读）
    ↓
审查并完善 plan
    ↓
/start-work                                    ← 开始实现
```

### 8.10 长时间任务（不完成不停止）

**`/ulw-loop` 或 `/ralph-loop`：**

```
/ulw-loop implement the entire payment module from start to finish
```

自动循环执行，不到 100% 不停。需要停止时用 `/cancel-ralph` 或 `/stop-continuation`。

### 8.11 会话交接

**结束会话前用 `/handoff`：**

```
/handoff                                      ← 生成详细上下文摘要
```

下次新会话 `/start-work` 会检查 `boulder.json`，自动恢复上次进度。

**Wisdom 积累（自动）：** 每个计划的执行经验保存在 `.sisyphus/notepads/{plan-name}/`：

| 文件 | 内容 |
|---|---|
| `learnings.md` | 完成工作中的洞察 |
| `decisions.md` | 架构和设计决策 |
| `issues.md` | 遇到的问题 |
| `verification.md` | 验证结果 |
| `problems.md` | 未解决的问题 |

### 8.12 Prometheus 四种策略（按意图自动选择）

| 意图 | 策略 | Prometheus 会问的关键问题 |
|---|---|---|
| 重构 | Safety — 行为保持 | "What tests verify current behavior?" "Rollback strategy?" |
| 从零构建 | Discovery — 模式优先 | "Found pattern X. Follow it or deviate?" |
| 中型任务 | Guardrails — 精确边界 | "What must NOT be included?" |
| 架构设计 | Strategic — 长期影响 | "Expected lifespan? Scale requirements?" |

### 8.13 场景速查表

| 场景 | 第一个命令 | 后续 |
|---|---|---|
| 快速修复 | 直接描述 | 完成 |
| 复杂但懒得解释 | `ulw <描述>` | 让它跑 |
| 复杂且要精确 | `@plan "<描述>"` | `/start-work` |
| 长时间任务 | `/ulw-loop` 或 `/ralph-loop` | `/cancel-ralph` 停止 |
| 新项目 | `/init-deep` → `@plan` | `/start-work` |
| 重构 | `/refactor "<描述>"` | `review-work` skill |
| Code Review | `review-work` skill | `ulw` 修复问题 |
| 架构设计 | `@plan` + `@oracle` + `@librarian` | `/start-work` |
| 结束会话 | `/handoff` | 下次自动恢复 |
| 简单 Bug | 直接描述 | 完成 |
| 复杂 Bug | `@oracle` → `ulw` | `review-work` |

---

## 9. 与 Claude Code 的对比与选择

| 维度 | Claude Code | OpenCode + omo |
|---|---|---|
| 模型支持 | Claude only | Claude / GPT / Gemini / Kimi / GLM / MiniMax 等 |
| 编排能力 | 单 agent + Task 子代理 | 多 agent + category 自动选模型 |
| Edit 可靠性 | 字符串匹配 | **Hash-Anchored**（更高成功率） |
| Plan 模式 | 内置 | `@plan` 三剑客 + `/start-work` 执行（更强） |
| 上下文管理 | 自动压缩 | 自动压缩 + `/init-deep` 层级化 |
| Hooks / Skills | 完整 | 完整（且兼容 Claude Code 的） |
| 开源 | 闭源 | 开源（OpenCode: MIT；omo: SUL-1.0） |
| 学习曲线 | 低 | **中-高** |

**怎么选：**

- 主要用 Claude、看重稳定 → **Claude Code**
- 想跨模型组合、对成本敏感、能接受配置成本 → **OpenCode + omo**
- 团队/企业 → 注意 omo 的 SUL-1.0 license

---

## 10. 故障排除

### 10.1 内置诊断（首选）

```bash
bunx oh-my-opencode doctor
```

会检查：plugin 注册、配置正确性、模型可用性、环境变量。

### 10.2 常见问题

| 问题 | 解决 |
|---|---|
| `Using legacy package name` warning | `opencode.json` 中 `oh-my-opencode` 改为 `oh-my-openagent` |
| Sisyphus 表现差 | 检查是否有 Claude / Kimi / GLM 任一订阅 |
| 模型调用失败 | `opencode auth login` 重新认证对应 provider |
| Background agent 卡住 | 降低 `defaultConcurrency`，避免 rate limit |
| Context 爆炸 | 用 `/init-deep` 替代单一大 AGENTS.md |
| 想看 background agent 实时输出 | 启用 tmux 集成 |

### 10.3 重置

```bash
# 卸载 plugin
jq '.plugin = [.plugin[] | select(. != "oh-my-openagent" and . != "oh-my-opencode")]' \
   ~/.config/opencode/opencode.json > /tmp/oc.json && mv /tmp/oc.json ~/.config/opencode/opencode.json

# 删配置
rm -f ~/.config/opencode/oh-my-openagent.{json,jsonc} \
      ~/.config/opencode/oh-my-opencode.{json,jsonc}

# 重装
bunx oh-my-opencode install
```

---

## 11. 命令速查

### 11.1 Prompt 关键字（写在 TUI 对话框）

| 关键字 | 简写 | 作用 |
|---|---|---|
| `ultrawork` | `ulw` | 激活全功能编排 |
| `@plan "<任务>"` | - | 规划入口（Prometheus 采访式规划） |
| `/start-work` | - | 执行入口（读取 plan 后 Atlas 调度 agent） |
| `/ulw-loop` | - | Ralph 循环，不到 100% 不停 |

### 11.2 斜杠命令

| 命令 | 作用 |
|---|---|
| `/init` | 生成项目 AGENTS.md |
| `/init-deep` | 生成层级化 AGENTS.md |
| `/compact` | 压缩上下文 |
| `/clear` | 清除上下文 |
| `/undo` / `/redo` | 撤销 / 重做 |
| `/share` | 分享对话链接 |
| `/connect` | 连接 OpenCode Zen |

### 11.3 Agent 显式调用

```
@oracle <架构问题>
@librarian <文档查询>
@explore <代码搜索>
@multimodal-looker <分析图片/PDF>
```

### 11.4 工具

```
# LSP
lsp_goto_definition / lsp_find_references / lsp_rename
lsp_diagnostics / lsp_code_actions / lsp_hover

# AST-Grep（25 语言）
ast_grep_search({ pattern, lang })
ast_grep_replace({ pattern, rewrite, lang })

# Background
task({ subagent_type, prompt, run_in_background: true })
background_output({ task_id })
```

### 11.5 诊断

```bash
bunx oh-my-opencode doctor      # 配置/模型/环境检查
opencode --version              # 版本确认
```

---

## 12. 参考链接

- [OpenCode 官方仓库](https://github.com/anomalyco/opencode)（145K+ stars）
- [OpenCode 官网 / 文档](https://opencode.ai)
- [omo / Oh My OpenAgent 仓库](https://github.com/code-yeongyu/oh-my-openagent)（52K+ stars）
- [omo 官方安装指南](https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/refs/heads/dev/docs/guide/installation.md)
- [omo Features 完整参考](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/features.md)
- [omo Configuration 文档](https://github.com/code-yeongyu/oh-my-openagent/blob/dev/docs/reference/configuration.md)
- [The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/)（Hash-Anchored Edit 的理论背景）
- [oh-my-pi](https://github.com/can1357/oh-my-pi)（Hashline 的灵感来源）

---

## 附：本文档与旧版的主要差异

为避免读者再被旧资料误导，列出修订要点：

| 旧版说法 | 修正 |
|---|---|
| OpenCode 是开源代码编辑器 | OpenCode 是开源 coding agent（CLI / TUI） |
| `sst/opencode` | 已迁移到 `anomalyco/opencode` |
| Oh My OpenCode | 已改名为 omo / Oh My OpenAgent |
| Sisyphus = Claude Opus 4.5 | claude-opus-4-7（4.5 不存在） |
| Oracle = GPT-5.2 | gpt-5.4 |
| Librarian = GLM-4.7 Free | minimax-m2.7 |
| frontend-ui-ux-engineer agent | 不存在该 agent，是 `visual-engineering` category |
| document-writer agent | 不存在 |
| `opencode-sdk` | 实际是 `@opencode-ai/sdk` |
| `.claude/rules/` | omo 用 `.opencode/skills/*/SKILL.md` |
| 缺少 Hash-Anchored Edit | omo 的头号差异化能力，必讲 |
| 缺少 Prometheus / Metis / Momus | omo 规划体系核心 |
| 缺少 IntentGate / Todo Enforcer / `/init-deep` | 全部补齐 |
| 推荐 `--claude=max20 --chatgpt=yes --gemini=yes` 一键全开 | 改为按订阅情况组合 |
| MIT license | 实际是 SUL-1.0 |
