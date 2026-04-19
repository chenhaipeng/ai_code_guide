# claude-mem 使用指南与最佳实践

> 整理时间：2026-04-19
> 信息来源：实测核验 [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) v6.5.0 README、docs.claude-mem.ai

---

## 0. 项目核心信息（实测）

| 属性 | 值 |
|---|---|
| 仓库 | [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) |
| 当前版本 | **v6.5.0** |
| Stars | **62K+** |
| License | **AGPL 3.0**（注意：是 AGPL，不是 MIT） |
| 主要语言 | TypeScript |
| 官方文档 | [docs.claude-mem.ai](https://docs.claude-mem.ai/) |
| 官网 | [claude-mem.ai](https://claude-mem.ai) |

> ⚠️ **License 提醒**：AGPL 3.0 对网络分发的代码有传染性。如果你把 claude-mem 嵌入对外提供的 SaaS，需要开源你的修改。仅本地使用不受影响。

---

## 1. 它是什么 / 不是什么

### 1.1 一句话定位

> **claude-mem 是一套基于"5 个生命周期 hook + Worker 服务 + SQLite + 向量检索"的跨会话记忆压缩系统**，让 Claude 在新会话中自动获得过往项目的上下文。

### 1.2 核心组件（实际架构）

| 组件 | 作用 |
|---|---|
| **5 个 Lifecycle Hooks** | SessionStart / UserPromptSubmit / PostToolUse / Stop / SessionEnd |
| **Smart Install** | 缓存型依赖检查（pre-hook） |
| **Worker Service** | HTTP API on port `37777`，含 Web 查看 UI 和 10 个搜索端点，由 Bun 管理 |
| **SQLite Database** | 存储 sessions / observations / summaries |
| **Chroma Vector Database** | 混合语义+关键词检索 |
| **mem-search Skill** | 自然语言查询 + progressive disclosure |

> ⚠️ **修订**：旧版文档说有"6 个 skill"（mem-search、smart-explore、smart_outline、smart_unfold、make-plan、do）。**官方 README 只列了 1 个 skill（mem-search）+ 4 个 MCP tool（search/timeline/get_observations 等）**。`smart_*`、`make-plan`、`do` 这些**可能来自旧版本或某个分支**，当前主仓 README 未明确收录。请以你实际安装版本的 `/help` 输出为准。

### 1.3 跨平台支持

claude-mem 不只支持 Claude Code：

```bash
npx claude-mem install                    # Claude Code（默认）
npx claude-mem install --ide gemini-cli   # Gemini CLI
npx claude-mem install --ide opencode     # OpenCode
```

还支持 [OpenClaw](https://openclaw.ai) gateway：

```bash
curl -fsSL https://install.cmem.ai/openclaw.sh | bash
```

---

## 2. 装不装的判断

| 你的情况 | 建议 |
|---|---|
| 单次任务 / 一次性脚本 | **不装**，浪费 |
| 长期项目，跨多个会话 | **强烈推荐**，核心痛点匹配 |
| 团队协作（多人共享 memory） | 谨慎，memory 是本地 SQLite，不天然多人同步 |
| 注重隐私 | 注意 memory 内容是明文存本地，敏感内容要用 `<private>` 标签 |
| 商用 / SaaS 嵌入 | **先看 AGPL 3.0** license |

---

## 3. 安装

### 3.1 推荐方式：plugin marketplace

```bash
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
```

重启 Claude Code，过往 session 的 context 会自动出现在新会话中。

### 3.2 npx 安装

```bash
npx claude-mem install
```

### 3.3 ⚠️ 不推荐：直接 npm install

```bash
npm install -g claude-mem  # ❌ 仅装 SDK，不会注册 hooks 和 worker
```

README 明确警告：**`npm install -g` 只装 SDK 库，不会注册 plugin hooks 也不会启动 worker service**。必须用 `npx claude-mem install` 或 plugin 命令。

### 3.4 系统要求

- **Node.js**: ≥ 18.0.0
- **Claude Code**: 支持 plugin 的最新版
- **Bun**: 进程管理器（缺失时自动装）
- **uv**: Python 包管理器（向量搜索用，缺失时自动装）
- **SQLite 3**: 持久化存储（已捆绑）

---

## 4. 工作原理

```
你说话 / 用工具
   ↓
[PostToolUse hook] → 捕获操作
   ↓
[Worker service @ :37777] → AI 压缩 → 生成语义摘要
   ↓
[SQLite + Chroma] → 持久化
   ↓
（新会话）
[SessionStart hook] → 注入相关 context
[UserPromptSubmit hook] → 按需检索
```

**关键设计：Progressive Disclosure（渐进披露）**

不会一次塞所有历史给 Claude，而是：
1. 只注入"最相关"摘要
2. Claude 主动用 `mem-search` 查具体内容
3. 用 `get_observations` 取详情

---

## 5. 核心工作流：3 层搜索（节省 ~10x token）

> ⚠️ **修订**：旧版说"~50-100 tokens/结果"。官方 README 实际数据：**search 阶段 ~50-100 tokens/结果，get_observations 阶段 ~500-1,000 tokens/结果**。两者差 10×，这就是"先查索引再取详情"的省 token 逻辑。

### 5.1 完整流程

```typescript
// Step 1: 搜索索引（轻量）
search(query="authentication bug", type="bugfix", limit=10)

// Step 2: 看 timeline 了解上下文
timeline(anchor=123, depth_before=3, depth_after=3)

// Step 3: 只取你真正要的详情
get_observations(ids=[123, 456])
```

### 5.2 4 个 MCP 搜索工具（实测列表）

| 工具 | 用途 | 何时用 |
|---|---|---|
| `search` | 全文索引 + 类型/日期/项目过滤 | 第一步，找候选 |
| `timeline` | 围绕某 observation 看时间上下文 | 看"那时候发生了什么" |
| `get_observations` | 按 ID 批量取完整详情 | 最后一步，**多 ID 一次取** |
| `mem-search` skill | 自然语言查询封装 | 让 Claude 自动决定查询策略 |

### 5.3 search 参数（实测）

```typescript
search({
  query: "authentication",       // 搜索词
  limit: 20,                     // 默认 20，最大 100
  project: "my-project",         // 项目过滤
  type: "observations" | "sessions" | "prompts",
  obs_type: "bugfix,feature,decision,discovery,change",  // 逗号分隔
  dateStart: "2026-04-01",       // YYYY-MM-DD
  dateEnd: "2026-04-19",
  orderBy: "date_desc"           // 默认；其他: date_asc / relevance
})
```

### 5.4 timeline 参数

```typescript
timeline({
  anchor: 11131,                 // 中心 observation ID
  query: "authentication",       // 或用 query 自动找锚点
  depth_before: 3,               // 默认 5，最大 20
  depth_after: 3
})
```

---

## 6. 用户实际使用方式（你只说自然语言）

### 6.1 ⚠️ 重要：不要在 CLI 里直接打 `search()`

文档里出现的 `search()` / `timeline()` 是 **MCP 工具的内部调用**，由 Claude 自动执行。**你只用自然语言**：

| 你说 | Claude 内部执行 |
|---|---|
| "我们之前怎么修这个 bug 的？" | `search(query="...", obs_type="bugfix")` → `get_observations()` |
| "上周做了什么？" | `search(dateStart="...", dateEnd="...")` |
| "飞书集成怎么配置来着？" | `search(query="飞书")` → `timeline()` |
| "记住这个项目用 pnpm" | 通过 hook 持久化到 memory |

### 6.2 Slash 命令（可选，显式触发）

```bash
/claude-mem:mem-search      # 显式搜索
```

> ⚠️ 旧版文档列了 `/claude-mem:smart-explore`、`/claude-mem:make-plan`、`/claude-mem:do` 等命令。**这些在当前 v6.5.0 README 中未提**。你的版本可能有也可能没有，以 `/help` 实际输出为准。

---

## 7. 配置

### 7.1 配置文件位置

```
~/.claude-mem/settings.json   # 自动创建，含默认值
```

可配置：AI model、worker port、数据目录、log level、context 注入策略。

### 7.2 模式与语言

claude-mem 支持多语言模式（影响生成的 observation 语言）：

```jsonc
{
  "CLAUDE_MEM_MODE": "code--zh"   // 简体中文
}
```

可用模式：

| 模式 | 说明 |
|---|---|
| `code` | 默认英文 |
| `code--zh` | 简体中文（已内置） |
| `code--ja` | 日文 |
| 其他 `code--<lang>` | 按 ISO 639-1 |

查看本地可用模式：

```bash
ls ~/.claude/plugins/marketplaces/thedotmack/plugin/modes/
```

### 7.3 Web 查看 UI

启动后访问：

```
http://localhost:37777
```

可以浏览所有 observations、切换 stable/beta 版本、调整 settings。

API 端点：

```
http://localhost:37777/api/observation/{id}
```

---

## 8. 隐私控制

### 8.1 `<private>` 标签

在对话中用 `<private>...</private>` 包裹敏感内容，**不会被持久化到 memory**：

```
<private>
我的 OpenAI key 是 sk-xxxxx，记住别记下来
</private>
```

### 8.2 数据存储位置

| 内容 | 位置 |
|---|---|
| memory 数据库 | `~/.claude-mem/` |
| 配置文件 | `~/.claude-mem/settings.json` |
| 项目级 memory | `~/.claude/projects/<project-path>/MEMORY.md` |
| 原始会话 | `*.jsonl` 文件 |

**安全建议：** 把 `~/.claude-mem/` 加入定期备份，但**不要提交到 git** 或推送到云盘（含历史对话明文）。

---

## 9. 最佳实践

### 9.1 ✅ 应该交给 memory 持久化的

1. **稳定的项目约定** —— 跨多次确认的（"这个项目用 pnpm"）
2. **架构决策 + 理由** —— 包含"为什么"
3. **关键文件路径** —— 核心模块位置
4. **用户偏好** —— 工作流、工具、沟通风格
5. **反复出现的问题与修法** —— debugging 见解

### 9.2 ❌ 不应该塞 memory 的

1. **当前会话临时上下文** —— in-progress 工作
2. **未验证信息** —— 推测/猜想
3. **单文件读出来的孤立结论** —— 上下文不足
4. **重复内容** —— 先用 `search` 检查
5. **与 CLAUDE.md 冲突的内容** —— CLAUDE.md 优先级更高
6. **敏感数据** —— 用 `<private>` 标签

### 9.3 MEMORY.md 文件组织

```
~/.claude/projects/<project-path>/
├── MEMORY.md          # 主文件，自动加载，~200 行内
├── debugging.md       # 详细调试笔记（被 MEMORY.md 链接）
├── patterns.md        # 代码模式
├── decisions.md       # 架构决策
└── sessions/*.jsonl   # 原始会话
```

**核心原则：**
- `MEMORY.md` 永远在 context 里（保持 < 200 行）
- 详细内容拆到主题文件，从 `MEMORY.md` 链接
- 按**主题**分类，不是按时间
- 定期清理过时记忆（让 Claude 帮你审计：*"扫描 MEMORY.md，列出可能过时的条目"*）

### 9.4 与其他工具的协作

| 组合 | 评估 |
|---|---|
| claude-mem + Superpowers | ✅ **推荐**。前者管记忆，后者管流程，互补 |
| claude-mem + everything-claude-code | ⚠️ everything-claude-code 自带 instinct/memory 系统，会和 claude-mem 抢话语权，**择一** |
| claude-mem + omo | ✅ omo 没有持久化记忆，claude-mem 正好补 |
| claude-mem + harness-lab | ✅ harness-lab 管 REQ 状态（强结构化），claude-mem 管 observation（弱结构化），互补 |

---

## 10. 故障排除

### 10.1 MCP 工具调用错误

```
Error: Either query or filters required
```

→ `search()` 必须至少提供 `query` 或一个过滤条件。

### 10.2 MEMORY.md 过大

```bash
# 让 Claude 帮你重组
"MEMORY.md 太长了，帮我把详细内容拆到主题文件，保留摘要和链接"
```

### 10.3 找不到历史

1. 确认项目路径：`ls ~/.claude/projects/`
2. 用更宽泛搜索词
3. 直接看 `*.jsonl` 原始文件

### 10.4 Worker 没启动

```bash
# 检查 worker 端口
lsof -i :37777

# 重启 Claude Code，让 SessionStart hook 重新拉起 worker
```

### 10.5 AGPL 协议担忧

如果你的项目要走商业分发，**优先咨询法律顾问**。仅本地用不受影响。

---

## 11. Beta 功能

claude-mem 提供 beta channel，含实验功能如 **Endless Mode**（仿生记忆架构，用于超长会话）。

切换 stable / beta：

```
http://localhost:37777 → Settings
```

详情：[Beta Features 文档](https://docs.claude-mem.ai/beta-features)

---

## 12. 参考链接

- [GitHub 主仓](https://github.com/thedotmack/claude-mem)
- [官方文档站](https://docs.claude-mem.ai/)
- [Installation Guide](https://docs.claude-mem.ai/installation)
- [Search Tools Guide](https://docs.claude-mem.ai/usage/search-tools)
- [Architecture Overview](https://docs.claude-mem.ai/architecture/overview)
- [Configuration Guide](https://docs.claude-mem.ai/configuration)

---

## 附：本文档与旧版的主要差异

| 旧版说法 | 修正 |
|---|---|
| 6 个技能（含 smart-explore、smart_outline、smart_unfold、make-plan、do） | 当前 v6.5.0 主 README 只明确列了 1 skill（mem-search）+ 4 MCP tools；旧 skill 可能已废弃或在分支中 |
| 缺 license 信息 | **AGPL 3.0**（重要） |
| 缺版本号 | v6.5.0 |
| 缺 Web UI / 端口 37777 信息 | 补齐 |
| 缺 `<private>` 隐私控制 | 补齐 |
| 缺多语言模式（code--zh 等） | 补齐 |
| 缺跨平台支持（Gemini CLI / OpenCode） | 补齐 |
| 缺与其他工具的协作矩阵 | 补齐 |
| `npm install -g` 没说危险 | 补 README 警告 |
