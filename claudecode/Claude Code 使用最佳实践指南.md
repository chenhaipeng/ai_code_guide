# Claude Code 使用最佳实践指南

> 整理时间：2026-04-19
>
> ⚠️ **本文档定位：索引 + 实践要点**
>
> 详细概念见 [Claude Code 核心概念指引](./Claude%20Code%20核心概念指引.md)。
> 插件市场见 [Claude Code Plugin Marketplace 完全指南](./Claude Code Plugin Marketplace 完全指南.md)。
> Harness 工程方法论见 [../harness-engineering/Harness Engineering 概念与实践指南.md](../harness-engineering/Harness%20Engineering%20概念与实践指南.md)。

---

## 0. 给"我应该装什么"的快速答案

| 你的情况 | 推荐配置 |
|---|---|
| 刚开始用 Claude Code，没装任何插件 | **先用 1-2 周裸机**，再决定加什么 |
| 老忘记上次会话讨论了什么 | 装 [claude-mem](./claude-mem 使用指南与最佳实践.md) |
| AI 偷懒、不写测试、跳验证 | 装 [Superpowers](../superpower/Superpowers 使用最佳实践指南.md) |
| 团队希望 AI 行为一致 | 团队级 CLAUDE.md + Superpowers |
| 想批量挑选 skill | 走 [everything-claude-code 深度指南](../oh-my-claudecode/everything-claude-code 深度使用指南.md)的"按需挑选"路径 |
| 跨多种 LLM 订阅 / 想跨模型编排 | 转 [OpenCode + omo](../opencode/📚 OpenCode + Oh My OpenCode 使用最佳实践指南.md) |

**核心原则：** 插件少而精 > 多而乱。Claude Code 的杠杆按"投入产出"排序：

```
CLAUDE.md > permissions 收纳 > hooks > skills > agents > MCP > plugins
（小投入大收益）                                        （大投入大收益）
```

---

## 1. 第一周：把基础打实

### 1.1 写一份合格的 CLAUDE.md

**核心原则**（详见[核心概念指引 §2](./Claude%20Code%20核心概念指引.md)）：

- 控制在 200 行以内
- 写**约束**和**事实**，不写礼貌话
- 包含：技术栈、关键命令（test/build/lint）、关键目录、禁止事项

**最小可用模板：**

```markdown
# 项目名

## 技术栈
- Backend: ...
- Frontend: ...
- DB: ...

## 关键命令
- 测试: `<具体命令>`
- 构建: `<具体命令>`
- Lint: `<具体命令>`

## 目录约定
- `src/api/` - 路由层（不写业务）
- `src/services/` - 业务逻辑
- `src/repos/` - 数据访问

## 禁止
- 不直接 push 到 main
- 不硬编码密钥
- 不在 router 写业务
```

### 1.2 用 `/permissions` 收纳常用调用

不要一开始给 `*` 大权。每被弹窗打断一次：

```
/permissions
```

把那条规则加入 allow。一周后能消除 80% 弹窗。

**推荐基线 allow（按需调整）：**

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(rg:*)",
      "Bash(ls:*)",
      "Read(./**)"
    ],
    "deny": [
      "Bash(rm -rf:*)"
    ]
  }
}
```

### 1.3 用 hooks 把"易忘的纪律"自动化

Hooks 比 prompt 提醒可靠 100 倍（详见[核心概念指引 §8](./Claude%20Code%20核心概念指引.md)）。

**最高 ROI 的 3 个 hook：**

| Hook | 事件 | 作用 |
|---|---|---|
| 自动 format | PostToolUse on `Write/Edit` | 写完文件自动 prettier/black/gofmt |
| Git push 审计 | PostToolUse on `Bash(git push)` | 记录所有 push |
| 危险命令拦截 | PreToolUse on `Bash(rm -rf:*)` | 阻断 |

---

## 2. 第二周：上 1-2 个插件

按你的痛点 **二选一** 或 **二者都用**：

### 2.1 痛点：跨会话上下文丢失

→ 装 [claude-mem](./claude-mem 使用指南与最佳实践.md)

```bash
/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem
```

效果：新会话自动注入相关历史 context；可用 `mem-search` 主动查历史。

### 2.2 痛点：AI 不守纪律（偷懒、跳测试、宣称完成不验证）

→ 装 [Superpowers](../superpower/Superpowers 使用最佳实践指南.md)

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

效果：14 个流程 skill 强制 brainstorm → plan → TDD → review → verify。

### 2.3 ⚠️ 不要同时装多个流程类插件

`Superpowers` + `everything-claude-code` 同装会冲突（两者都管"如何工作"，skill 重名）。**择一**。

---

## 3. Skill / Agent / Command 选择规则

### 3.1 三选一的判断

| 你想要的效果 | 选 |
|---|---|
| 模型在某种情况下**自动**用某流程 | **Skill** |
| 你**自己想随时**唤起某操作 | **Slash Command** |
| 任务需要**独立上下文 / 并行 / 专家视角** | **Agent (subagent)** |

### 3.2 Skill 的 description 决定一切

❌ `Use when writing code` — 太宽，每次误触发

✅ `Use when implementing any feature or bugfix, before writing implementation code` — 明确"WHEN"

### 3.3 Agent 的最佳用途

不是"分工感"，而是**上下文隔离**：

- 用 Agent 做大量探索性搜索（不污染主线 context）
- 用 Agent 跑 reviewer（独立视角）
- 用 Agent 并行处理 N 个独立子任务

---

## 4. MCP 配置最佳实践

### 4.1 安全

```jsonc
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"  // 不要直接写值
      }
    }
  }
}
```

### 4.2 项目级 vs 用户级

| 范围 | 配置位置 |
|---|---|
| 项目专用（团队共享） | `.mcp.json`（提交 git，不带 secret） |
| 跨项目通用 | `~/.claude.json` |

### 4.3 不信任的 MCP 不装

MCP server 能读你给它的所有 context，包括 secret。装前看代码或来源。

---

## 5. 上下文管理实战

### 5.1 让 Claude "忘记前面"

| 场景 | 操作 |
|---|---|
| 任务跑偏想重启 | `/clear` |
| 长会话 token 接近上限 | `/compact` |
| 切换完全不同任务 | 开新会话（让 memory 接力） |

### 5.2 减少 CLAUDE.md 的 token 开销

- 拆成层级（每个子目录一个）
- 大文档拆出去，CLAUDE.md 留摘要 + 链接
- 项目稳定后定期审计 CLAUDE.md，删过时条目

### 5.3 子代理用法

**适用：** 探索性搜索（"找出项目里所有 auth 相关代码"）

```
让 explore agent 在后台搜索 ...，我先继续做 X
```

**不适用：** 主线持续推进的任务、需要中间细节的任务。

---

## 6. 调试与故障排除

### 6.1 启用 debug

```bash
claude --debug
```

### 6.2 常见问题

| 问题 | 解决 |
|---|---|
| Skill 不触发 | 检查 description；重启会话 |
| Hook 不执行 | 手动跑脚本 `./.claude/hooks/<x>.sh`；看权限 |
| MCP 起不来 | `claude --debug` 看启动日志；检查 token env |
| 上下文消耗过快 | 拆 CLAUDE.md；用 `/compact` |
| 配置不生效 | 看层级优先级（local > project > user） |
| `/plugin install` 失败 | 先 `/plugin marketplace update <name>` |

### 6.3 文件位置速查

```
项目级：
  .claude/CLAUDE.md
  .claude/settings.json
  .claude/settings.local.json (gitignore)
  .claude/agents/, .claude/skills/, .claude/commands/, .claude/hooks/
  .mcp.json

用户级：
  ~/.claude/CLAUDE.md
  ~/.claude/settings.json
  ~/.claude/agents/, .claude/skills/ (跨项目通用)

插件：
  ~/.claude/plugins/marketplaces/<owner>/<repo>/...
```

---

## 7. 团队协作

### 7.1 提交什么、不提交什么

| 文件 | 提交 git？ |
|---|---|
| `.claude/CLAUDE.md` | ✅ 是 |
| `.claude/settings.json` | ✅ 是 |
| `.claude/settings.local.json` | ❌ 否（gitignore） |
| `.claude/agents/`, `skills/`, `commands/` | ✅ 是 |
| `.claude/hooks/` | ✅ 是（脚本本身） |
| `.mcp.json` | ✅ 是（不含 secret 时） |

### 7.2 团队规范建议

- **主 CLAUDE.md** 团队共享，**个人偏好**放 `~/.claude/CLAUDE.md`
- 通过 PR review CLAUDE.md 改动，确保不会单方面"改 AI 行为"
- 团队插件清单写进 README，避免成员凭印象装

---

## 8. 反模式（避坑清单）

### 8.1 ❌ 一上来给 `* allow`
- 失去权限审查能力，危险命令毫无阻拦
- 正确：默认开始，渐进放行

### 8.2 ❌ CLAUDE.md 写成长文档
- 每轮吃 token，越长越拖慢
- 正确：< 200 行，详细内容拆出去

### 8.3 ❌ 同时装多个"工作流"插件
- everything-claude-code + Superpowers + 自定义 hook = 行为不可预测
- 正确：选一个流程主导者

### 8.4 ❌ Skill description 写"What"
- `Use to write tests` → 每次误触发
- 正确：写 `Use when ...`

### 8.5 ❌ 把 hook 写得很慢
- PostToolUse 每次工具都跑，> 2s 会让交互卡顿
- 正确：复杂工作放 background，hook 只做轻量动作

### 8.6 ❌ 接受 AI 的"已修复"宣称不验证
- AI 默认 agreeable，可能没真跑过
- 正确：让它贴出实际命令输出（或装 Superpowers 的 verification skill）

### 8.7 ❌ MCP 把 token 直接写进配置
- secret 进了 git 历史
- 正确：用 `${ENV_VAR}` 引用

---

## 9. 推荐资源

### 9.1 本工程内的相关文档
- [Claude Code 核心概念指引](./Claude%20Code%20核心概念指引.md)
- [Claude Code Plugin Marketplace 完全指南](./Claude Code Plugin Marketplace 完全指南.md)
- [claude-mem 使用指南](./claude-mem 使用指南与最佳实践.md)
- [Superpowers 使用最佳实践指南](../superpower/Superpowers 使用最佳实践指南.md)
- [everything-claude-code 深度使用指南](../oh-my-claudecode/everything-claude-code 深度使用指南.md)
- [OpenCode + omo 使用指南](../opencode/📚 OpenCode + Oh My OpenCode 使用最佳实践指南.md)
- [Harness Engineering 概念与实践](../harness-engineering/Harness%20Engineering%20概念与实践指南.md)

### 9.2 官方资源
- [Claude Code 官方文档](https://docs.claude.com/docs/claude-code)
- [Claude Code Best Practices（Anthropic 工程博客）](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Anthropic 官方 Skills 仓库](https://github.com/anthropics/skills)

### 9.3 实测过的社区资源（按推荐度）

| 项目 | Stars | 备注 |
|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | 159K+ | ⭐⭐⭐ 流程纪律，少而精 |
| [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | 62K+ | ⭐⭐⭐ 跨会话记忆 |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | 160K+ | ⭐⭐ 量大，建议按需挑选 |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | - | 资源索引 |

---

## 10. 一句话总结

> **Claude Code 的最佳实践 = 把约束写在正确的层级。** CLAUDE.md 写永久约束，permissions 收纳重复弹窗，hook 把易忘的纪律自动化，skill 引导工作流，agent 隔离上下文。**层级正确 > 工具数量。**

---

## 附：本文档与旧版的主要差异

| 旧版 | 新版 |
|---|---|
| 778 行，重复 marketplace、core 概念 | 重构为索引 + 实践要点，约 280 行 |
| 仅推荐过时项目（templates / awesome） | 加入实测过的本工程交叉链接 |
| 无与 OpenCode / omo 的对比指引 | 加入"什么时候转 OpenCode"建议 |
| 无"反模式"章节 | 新增 §8 反模式清单 |
| Skill / Agent / Command 选择缺失 | 新增 §3 决策表 |
| 团队协作规范缺失 | 新增 §7 |
