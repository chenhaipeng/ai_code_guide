# everything-claude-code 深度使用指南

> 整理时间：2026-04-19
> 信息来源：实测核验 [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) v1.10.0 主仓 README、plugin.json、skills 目录

---

## 0. 项目核心信息

| 属性 | 值 |
|---|---|
| 仓库 | [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) |
| 当前版本 | **v1.10.0** |
| Stars | **160K+** |
| License | **MIT** |
| 作者 | Affaan Mustafa |
| 官网 | [ecc.tools](https://ecc.tools) |
| 定位 | "Battle-tested Claude Code plugin" — 38 agents、34 skills、3 commands 的超大型技能包 |

---

## 1. 它是什么 / 不是什么

### 1.1 一句话定位

> **everything-claude-code（ECC）是一个面向 Claude Code 的大规模 skill/agent 集合**，覆盖从 TDD、安全审查、前后端模式到投资人材料、视频剪辑等数十个场景。

### 1.2 它不是什么

- **不是 harness**（它装在 Claude Code / OpenCode / Codex 等 harness 之内）
- **不是工作流纪律工具**（与 Superpowers 不同，ECC 不强制 brainstorm → plan → TDD 流程；它是技能超市，不是流程编织器）
- **不是精挑细选的**（160K+ stars 的代价：量大面广，好坏参半）

### 1.3 与 Superpowers 的对比

| 维度 | everything-claude-code | Superpowers |
|---|---|---|
| Skills 数量 | 34 | 14 |
| Agents 数量 | 38 | 0（用 subagent 替代） |
| 设计哲学 | 超市：按需挑选 | 纪律：强制流程 |
| 安装方式 | 全装或手动挑选 | 全装（量少，无冲突） |
| 适合 | 需要特定领域 skill | 需要开发流程纪律 |
| 冲突风险 | 高（与其他流程插件冲突） | 低 |

---

## 2. 核心问题：安装即全装

### 2.1 plugin.json 的声明方式

```jsonc
{
  "skills": ["./skills/"],     // 通配符 — 加载整个目录
  "agents": ["./agents/*.md"], // 38 个 agent 全部加载
  "commands": ["./commands/"]  // 3 个 command 全部加载
}
```

**意味着**：`/plugin install` 会一次性把 34 skills + 38 agents + 3 commands **全部装进你的 Claude Code**。

### 2.2 全装的问题

1. **context 污染** — 34 个 skill 的 description 每轮都被扫描，增加模型判断负担
2. **误触发** — 部分 skill description 写得宽泛（如 `coding-standards`），容易在不相关场景被激活
3. **与其他插件冲突** — ECC 的 `tdd-workflow`、`verification-loop` 与 Superpowers 的同功能 skill 重名
4. **token 浪费** — 你可能永远不会用 `investor-outreach` 或 `x-api`，但它们占你的上下文预算

### 2.3 推荐安装方式：常驻克隆 + 按需挑选

**不要用 `/plugin install`**，改用：

```bash
# 1. 常驻克隆到固定位置（不污染项目 .claude/）
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git \
  ~/everything-claude-code-reference

# 2. 按需复制你要的 skill
cp -r ~/everything-claude-code-reference/.agents/skills/tdd-workflow \
  /your-project/.claude/skills/

# 3. 按需复制你要的 agent
cp ~/everything-claude-code-reference/.agents/agents/code-reviewer.md \
  /your-project/.claude/agents/
```

**升级**：

```bash
cd ~/everything-claude-code-reference && git pull
```

---

## 3. 完整 Skill 清单与分类推荐

### 3.1 通用过程类（⭐ 推荐多数项目使用）

这类 skill 跨项目、跨语言，属于"开发方法论"。

| Skill | 描述 | 推荐度 | 与 Superpowers 重叠？ |
|---|---|---|---|
| **tdd-workflow** | TDD 流程，80%+ 覆盖率要求 | ⭐⭐⭐ | ✅ 与 Superpowers tdd 重叠，择一 |
| **verification-loop** | 综合验证系统 | ⭐⭐⭐ | ✅ 与 Superpowers verification 重叠 |
| **coding-standards** | 跨项目编码约定（命名、可读性） | ⭐⭐ | 部分 |
| **security-review** | 安全审查清单（auth、输入、密钥、支付） | ⭐⭐⭐ | Superpowers 无此 skill |
| **agent-introspection-debugging** | AI agent 自调试（捕获、诊断、恢复） | ⭐⭐ | 无 |
| **agent-sort** | 为特定 repo 定制 ECC 安装计划 | ⭐⭐ | 无（meta skill，帮你筛选 ECC 自身） |
| **strategic-compact** | 在逻辑节点手动压缩上下文 | ⭐⭐ | 无 |
| **documentation-lookup** | 通过 Context7 MCP 查最新文档 | ⭐⭐⭐ | Superpowers 无此 skill |

### 3.2 栈/领域类（按你的技术栈挑选）

| Skill | 描述 | 适用 |
|---|---|---|
| **frontend-patterns** | React/Next.js 状态管理、性能优化 | React 项目 |
| **frontend-design** | 高设计质量的前端界面 | 前端重设计项目 |
| **frontend-slides** | HTML 演示文稿（可转 PPT） | 需要做 presentation |
| **backend-patterns** | Node.js/Express/Next.js API 设计 | Node.js 后端 |
| **bun-runtime** | Bun 运行时、包管理、打包 | Bun 项目 |
| **nextjs-turbopack** | Next.js 16+ 和 Turbopack | Next.js 项目 |
| **e2e-testing** | Playwright E2E 测试 | 需要端到端测试 |
| **mcp-server-patterns** | 构建 MCP Server（Node/TypeScript） | 开发 MCP Server |
| **claude-api** | Anthropic Claude API 使用模式 | 开发 Claude 集成 |

### 3.3 垂直行业/内容类（按需挑选）

| Skill | 描述 | 适用 |
|---|---|---|
| **api-design** | REST API 设计模式（分页、错误、版本） | API 设计 |
| **article-writing** | 长文写作（博客、教程、Newsletter） | 内容创作 |
| **brand-voice** | 品牌写作风格提取与应用 | 品牌内容 |
| **content-engine** | 多平台内容系统（X/LinkedIn/TikTok/YouTube） | 社媒运营 |
| **crosspost** | 多平台内容分发 | 社媒运营 |
| **investor-materials** | 投资人材料（Pitch Deck、One-pager） | 融资 |
| **investor-outreach** | 投资人沟通（冷邮件、跟进） | 融资 |
| **market-research** | 市场研究、竞品分析 | 商业决策 |
| **product-capability** | PRD → 实现计划 | 产品开发 |
| **video-editing** | AI 视频剪辑工作流 | 视频制作 |
| **fal-ai-media** | fal.ai 图像/视频/音频生成 | AI 媒体 |

### 3.4 集成/搜索类（需要对应 MCP）

| Skill | 描述 | 前置依赖 |
|---|---|---|
| **deep-research** | 多源深度研究（Firecrawl + Exa） | Firecrawl MCP + Exa MCP |
| **exa-search** | Exa 神经搜索 | Exa MCP |
| **x-api** | X/Twitter API 集成 | X API Key |
| **dmux-workflows** | 多 agent 编排（dmux/tmux） | dmux 安装 |
| **documentation-lookup** | 最新文档查询 | Context7 MCP |

### 3.5 跳过（特定场景或 meta 用途）

| Skill | 理由 |
|---|---|
| **everything-claude-code** | ECC 自身的开发约定，不是给你项目用的 |
| **eval-harness** | 评估 Claude Code 会话的元框架，研究用途 |
| **product-capability** | 仅适合用 ECC 做 PRD → SRS 转换的场景 |

---

## 4. 完整 Agent 清单（38 个）

### 4.1 代码审查类（按语言）

| Agent | 语言/领域 |
|---|---|
| code-reviewer | 通用代码审查 |
| typescript-reviewer | TypeScript |
| python-reviewer | Python |
| go-reviewer | Go |
| java-reviewer | Java |
| kotlin-reviewer | Kotlin |
| rust-reviewer | Rust |
| cpp-reviewer | C++ |
| csharp-reviewer | C# |
| flutter-reviewer | Flutter/Dart |
| database-reviewer | 数据库 |
| healthcare-reviewer | 医疗/HIPAA |

### 4.2 构建排错类

| Agent | 语言 |
|---|---|
| build-error-resolver | 通用构建错误 |
| go-build-resolver | Go |
| java-build-resolver | Java |
| kotlin-build-resolver | Kotlin |
| rust-build-resolver | Rust |
| cpp-build-resolver | C++ |
| dart-build-resolver | Dart |
| pytorch-build-resolver | PyTorch |

### 4.3 流程/工具类

| Agent | 功能 |
|---|---|
| architect | 架构设计 |
| planner | 任务规划 |
| chief-of-staff | 统筹协调 |
| tdd-guide | TDD 引导 |
| e2e-runner | E2E 测试执行 |
| doc-updater | 文档更新 |
| docs-lookup | 文档查询 |
| refactor-cleaner | 重构清理 |
| performance-optimizer | 性能优化 |
| security-reviewer | 安全审查 |
| harness-optimizer | Harness 优化 |
| loop-operator | 循环操作 |

### 4.4 GAN 评估类

| Agent | 功能 |
|---|---|
| gan-planner | GAN 计划 |
| gan-generator | GAN 生成 |
| gan-evaluator | GAN 评估 |

### 4.5 开源治理类

| Agent | 功能 |
|---|---|
| opensource-forker | 开源 fork |
| opensource-packager | 开源打包 |
| opensource-sanitizer | 开源清理 |

### 4.6 Agent 挑选建议

- **日常开发**：`code-reviewer`（或你的语言 reviewer）+ `build-error-resolver`
- **不用全装**：如果你不是 C++ 开发者，`cpp-build-resolver` 和 `cpp-reviewer` 完全不需要
- **GAN 类**：除非你在做 GAN 相关工作，否则 `gan-*` 三个全部跳过

---

## 5. Commands（3 个）

| Command | 触发 | 功能 |
|---|---|---|
| `/feature-development` | 手动 | 功能开发流程 |
| `/database-migration` | 手动 | 数据库迁移 |
| `/add-language-rules` | 手动 | 为特定语言添加规则 |

---

## 6. 最佳实践

### 6.1 ✅ 推荐做法

1. **用常驻克隆，不用 `/plugin install`** — 避免全装
2. **每个项目只挑 3-5 个 skill** — 少而精
3. **通用过程类优先** — tdd-workflow、security-review、documentation-lookup
4. **只挑你语言对应的 reviewer** — Python 项目不需要 Java-reviewer
5. **与 Superpowers 择一** — 流程纪律类不要同时装两个

### 6.2 ❌ 不要做的事

1. **不要全装** — 34 skills + 38 agents 同时加载会严重拖慢
2. **不要同时装 Superpowers + ECC 的流程类 skill** — tdd/verification 必须择一
3. **不要装你用不到的领域 skill** — 不做融资就不需要 investor-*
4. **不要相信"160K stars = 质量"** — stars 来自项目广度，不等于每个 skill 都好

### 6.3 挑选决策树

```
你的项目需要什么？
│
├─ 开发流程纪律（TDD、验证、规划）
│   ├─ 已装 Superpowers → 跳过 ECC 的 tdd/verification
│   └─ 没装 Superpowers → 挑 tdd-workflow + verification-loop
│
├─ 代码审查
│   └─ 挑你语言的 reviewer agent（如 python-reviewer）
│
├─ 安全审查
│   └─ security-review skill（Superpowers 没有这个）
│
├─ 前端开发
│   └─ frontend-patterns + frontend-design（按需）
│
├─ 后端开发（Node.js）
│   └─ backend-patterns + api-design
│
├─ 特定框架
│   ├─ Next.js → nextjs-turbopack
│   ├─ Bun → bun-runtime
│   └─ Claude API → claude-api
│
├─ 内容/营销
│   └─ 按需从 article-writing / content-engine / crosspost 中选
│
└─ 研究
    └─ deep-research（需要 Exa MCP）
```

---

## 7. 与其他工具的协作

| 组合 | 评估 |
|---|---|
| ECC + Superpowers | ⚠️ **择一** 流程类 skill（tdd/verification），其余互补 |
| ECC + claude-mem | ✅ ECC 无持久记忆，claude-mem 补 |
| ECC 单独使用 | ✅ 如果不需要 Superpowers 的流程强制力 |
| ECC 全装 + 其他插件 | ❌ **高风险冲突**，context 污染严重 |

---

## 8. 故障排除

| 问题 | 解决 |
|---|---|
| Skill 误触发 | 检查 description 是否太宽泛；考虑从 `.claude/skills/` 移除不需要的 |
| Agent 不响应 | 检查 `.claude/agents/` 中的文件是否存在 |
| 常驻克隆更新失败 | `cd ~/everything-claude-code-reference && git pull` |
| 与 Superpowers 冲突 | 两者 tdd/verification skill 择一，删除另一个 |

---

## 9. 参考链接

- [GitHub 主仓](https://github.com/affaan-m/everything-claude-code)
- [官网 ecc.tools](https://ecc.tools)
- [Harness Engineering 概念与实践](../harness-engineering/Harness%20Engineering%20概念与实践指南.md)
- [Superpowers 使用指南](../superpower/Superpowers 使用最佳实践指南.md)
- [Claude Code 使用最佳实践](../claudecode/Claude Code 使用最佳实践指南.md)

---

## 附：本文档数据来源

- `plugin.json`（v1.10.0）— 38 agents、34 skills（目录通配符）、3 commands
- `.agents/skills/*/SKILL.md` — 34 个 skill 的 frontmatter description
- 仓库 metadata — 160K+ stars、MIT license
- 所有 skill description 均从 GitHub API 实时提取
