# Claude Code Plugin Marketplace 完全指南
> 整理时间：2026-04-19
>
> ⚠️ **本文档定位：插件市场全景 + 安装指南**
> 核心概念见 [Claude Code 核心概念指引](./Claude%20Code%20核心概念指引.md)。
> 工作流实践见 [Claude Code 使用最佳实践指南](./Claude Code 使用最佳实践指南.md)。
> 各插件详细使用见对应专题文档。

---

## 目录
+ [概述](#概述)
+ [一、官方市场](#一官方市场)
+ [二、社区热门市场](#二社区热门市场)
+ [三、专业领域市场](#三专业领域市场)
+ [四、推荐安装清单](#四推荐安装清单)
+ [五、内置功能与 Skills 速查](#五内置功能与-skills-速查)
+ [六、常用命令](#六常用命令)
+ [七、市场对比与选择](#七市场对比与选择)
+ [八、社区精选资源](#八社区精选资源)
+ [九、故障排除](#九故障排除)
+ [附录](#附录)

---

## 概述
Claude Code 支持通过插件市场（Plugin Marketplace）扩展功能。用户可以添加多个市场，然后在 `/plugin → Discover` 中浏览所有可用插件。

**核心概念：**

+ **Marketplace**: 插件市场，本质是一个 GitHub 仓库目录
+ **Plugin**: 插件，包含 Skills、Agents、Commands、Hooks 等组件
+ **Skill**: 技能，教导 Claude 完成特定任务的可复用指令集

---

## 一、官方市场
### 1.1 claude-plugins-official
| 属性 | 值 |
| --- | --- |
| 仓库 | `anthropics/claude-plugins-official` |
| Stars | 9K+ |
| 状态 | 默认已添加 |
| 插件数量 | 53+ |


**内部插件 (plugins/):**

| 插件名 | 类型 | 功能 |
| --- | --- | --- |
| `typescript-lsp` | LSP | TypeScript 真正的类型检查 |
| `pyright-lsp` | LSP | Python 类型检查 |
| `rust-analyzer-lsp` | LSP | Rust 语言支持 |
| `gopls-lsp` | LSP | Go 语言支持 |
| `jdtls-lsp` | LSP | Java 语言支持 |
| `kotlin-lsp` | LSP | Kotlin 语言支持 |
| `swift-lsp` | LSP | Swift 语言支持 |
| `csharp-lsp` | LSP | C# 语言支持 |
| `clangd-lsp` | LSP | C/C++ 语言支持 |
| `php-lsp` | LSP | PHP 语言支持 |
| `lua-lsp` | LSP | Lua 语言支持 |
| `frontend-design` | Skill | 设计系统、无障碍标准 |
| `security-guidance` | Hook | 被动扫描安全漏洞 |
| `pr-review-toolkit` | Tool | PR 代码审查工具 |
| `feature-dev` | Dev | 功能开发工作流 |
| `hookify` | Auto | 自动将技能转换为钩子 |
| `ralph-loop` | Loop | 迭代开发循环 |
| `explanatory-output-style` | Style | 解释决策背后的原因 |
| `learning-output-style` | Style | 学习模式输出风格 |
| `code-review` | Command | 代码审查 |
| `code-simplifier` | Agent | 清理 AI 生成的代码 |
| `commit-commands` | Command | Git 提交命令集 |
| `plugin-dev` | Dev | 插件开发工具 |
| `agent-sdk-dev` | Dev | Agent SDK 开发 |


**外部插件 (external_plugins/):**

| 插件名 | 功能 |
| --- | --- |
| `github` | GitHub 集成 |
| `gitlab` | GitLab 集成 |
| `playwright` | 浏览器自动化测试 |
| `context7` | 查阅最新文档（非训练数据） |
| `firebase` | Firebase 集成 |
| `supabase` | Supabase 集成 |
| `stripe` | Stripe 支付集成 |
| `slack` | Slack 集成 |
| `asana` | Asana 任务管理 |
| `linear` | Linear 项目管理 |
| `laravel-boost` | Laravel 开发增强 |
| `greptile` | 代码搜索 |
| `serena` | Serena 集成 |


**更新命令：**

```bash
/plugin marketplace update claude-plugins-official
```

---

### 1.2 anthropics/skills
| 属性 | 值 |
| --- | --- |
| 仓库 | `anthropics/skills` |
| Stars | 85K+ |
| 说明 | Anthropic 官方技能仓库 |


**安装：**

```bash
/plugin marketplace add anthropics/skills
```

**主要技能包：**

| 技能包 | 内容 |
| --- | --- |
| `document-skills` | docx, pdf, pptx, xlsx 文档创建与编辑 |
| `example-skills` | 创意设计、开发技术、企业通讯等示例 |


**独立技能：**

| 技能 | 用途 |
| --- | --- |
| `pdf` | 读取、创建、编辑、填写 PDF 表单 |
| `docx` | 创建和编辑 Word 文档 |
| `xlsx` | 创建和编辑 Excel 表格 |
| `pptx` | 创建和编辑 PowerPoint 演示文稿 |
| `skill-creator` | 创建新技能、优化现有技能 |
| `mcp-builder` | 构建 MCP 服务器 |
| `webapp-testing` | Web 应用自动化测试 |
| `theme-factory` | 生成配色主题（10种预设） |
| `canvas-design` | 画布设计 |
| `algorithmic-art` | 算法艺术生成 |
| `brand-guidelines` | 品牌指南 |
| `slack-gif-creator` | 创建 Slack GIF 动画 |
| `web-artifacts-builder` | 构建 Web Artifacts |


---

## 二、社区热门市场
### 2.1 everything-claude-code ⚠️ 推荐"按需挑选"而非整体安装
| 属性 | 值 |
| --- | --- |
| 仓库 | `affaan-m/everything-claude-code` |
| Stars | 160K+ |
| 作者 | Affaan Mustafa |
| 版本 | v1.10.0 |
| 定位 | 多 harness 通用 agent 优化系统（Claude Code / Codex / Cursor / Opencode / Gemini CLI 等） |


**⚠️ 关键提醒：一次全装，没有 subset 机制**

`plugin.json` 中 `skills` 和 `commands` 字段使用整目录通配（`["./skills/"]`、`["./commands/"]`），通过 `/plugin install` 会**一次性加载全部 156 个 skills + 72 个 commands + 38 个 agents**。你不能在安装时挑选子集。

**代价不是磁盘空间，而是触发面**：每个 skill 的 `description` 都会进入模型的候选列表，让它每轮从 156 项里判定"哪个相关"，无关 skill 越多，误触发概率越高，主任务 token 预算越紧。

**推荐做法：改走"手动挑选"路径**，参见 [§8.4 按需挑选 Skill（推荐）](#84-按需挑选-skill推荐)。完整的 34 个 skill 分类推荐见 [everything-claude-code 深度使用指南](../oh-my-claudecode/everything-claude-code 深度使用指南.md)。

**一键安装（不推荐普通用户使用，仅供评估）：**

```bash
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code
```

**包含内容（实测数据）：**

+ 38 个专业 Agent（语言 reviewer / build-resolver、architect、planner、tdd-guide 等）
+ 34 个 Skills（实测 `.agents/skills/` 目录）
+ 3 个斜杠命令
+ Hooks、rules、contexts、mcp-configs 完整体系

**支持语言：** TypeScript、Python、Go、Java、Kotlin、Rust、C++、C#、Dart/Flutter 等

**项目结构：**

```plain
everything-claude-code/
├── .claude-plugin/    # 插件和市场清单
├── .claude/           # Claude Code 专用配置
├── .codex/ .cursor/ .gemini/ .opencode/ ...  # 多 harness 适配
├── agents/            # 专业化子代理定义
├── commands/          # 斜杠命令
├── skills/            # 工作流定义
├── hooks/             # 事件驱动钩子
├── rules/             # 始终遵循的规则（注意：全局注入系统提示，慎拷）
├── mcp-configs/       # MCP 服务器配置
└── contexts/          # 动态系统提示注入
```

---

### 2.2 claude-mem ⭐ 必装
| 属性 | 值 |
| --- | --- |
| 仓库 | `thedotmack/claude-mem` |
| Stars | 62K+ |
| License | AGPL 3.0（商用注意） |
| 功能 | 跨会话长记忆（SQLite + Chroma 向量检索） |


**安装：**

```bash
/plugin marketplace add thedotmack/claude-mem
```

**说明：** 解决 Claude Code 上下文丢失问题，让 Claude 能够跨会话保持上下文和偏好设置。

> 详细使用见 [claude-mem 使用指南与最佳实践](./claude-mem 使用指南与最佳实践.md)。

---

### 2.3 superpowers-marketplace
| 属性 | 值 |
| --- | --- |
| 仓库 | `obra/superpowers-marketplace` |
| Stars | 159K+ |
| 作者 | Jesse Vincent |
| 功能 | 14 个流程 skill，强制 brainstorm → plan → TDD → review |


**安装：**

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**覆盖流程：** brainstorm → plan → TDD → review → verify → ship

> 详细使用见 [Superpowers 使用最佳实践指南](../superpower/Superpowers 使用最佳实践指南.md)。

---

### 2.4 awesome-claude-plugins
| 属性 | 值 |
| --- | --- |
| 仓库 | `ComposioHQ/awesome-claude-plugins` |
| 功能 | 精选插件注册中心 + 工具路由器 |


**安装：**

```bash
/plugin marketplace add ComposioHQ/awesome-claude-plugins
```

**说明：** 将 Claude 转变为跨多服务的工作流编排器，连接数百个外部服务。

---

### 2.5 awesome-claude-skills
| 属性 | 值 |
| --- | --- |
| 仓库 | `ComposioHQ/awesome-claude-skills` |
| Stars | 31.7K+ |
| 功能 | Claude 技能库，1000+ SaaS 联动 |


**说明：** 通过 Composio 实现 Claude 与 Gmail、Slack、GitHub、Notion、Jira 等 78 款 SaaS 应用的自动化联动。

---

### 2.6 openai/skills
| 属性 | 值 |
| --- | --- |
| 仓库 | `openai/skills` |
| 功能 | OpenAI 官方 Skills Catalog（Codex 专用） |


> ⚠️ **注意**：这是 OpenAI 官方仓库，部分 Skills 可能需要适配才能在 Claude Code 中使用。
>

---

## 三、专业领域市场
### 3.1 安全领域
**trailofbits/skills**

```bash
/plugin marketplace add trailofbits/skills
```

+ 智能合约安全工具包
+ `building-secure-contracts` 技能

### 3.2 Go 开发
**JetBrains/go-modern-guidelines**

```bash
/plugin marketplace add JetBrains/go-modern-guidelines
/plugin install modern-go-guidelines
```

+ 现代 Go 代码规范
+ JetBrains 官方出品

### 3.3 UI/UX 设计
**ui-ux-pro-max-skill**

```bash
/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
/plugin install ui-ux-pro-max@ui-ux-pro-max-skill
```

+ UI/UX 专业增强
+ 设计系统支持

### 3.4 多步骤任务规划
**OthmanAdi/planning-with-files**

```bash
/plugin marketplace add OthmanAdi/planning-with-files
```

+ 参考 Manus 的 Agent 方法
+ 适合复杂多步骤任务

### 3.5 Hooks 精通
**disler/claude-code-hooks-mastery**

```bash
/plugin marketplace add disler/claude-code-hooks-mastery
```

+ Claude Code Hooks 完整指南
+ 事件驱动自动化

---

## 四、推荐安装清单

> **⚠️ 前置忠告：不要一次装全部**
>
> 功能重叠会相互干扰。`everything-claude-code`、`claude-mem`、`superpowers` 三者都在 memory / 工作流 / hooks 层面抢话语权，**同时全装会导致 skill 误触发、hooks 冲突、上下文膨胀**。先装一个跑一段时间，再决定加什么。

### 4.1 快速安装脚本
```bash
# ========== 必装 ⭐⭐⭐ ==========

# 官方技能仓库（最小噪声、无冲突）
/plugin marketplace add anthropics/skills

# ========== 推荐 ⭐⭐（三选一，不要同时装）==========

# A. 跨会话长记忆 —— 痛点：Claude 每次会话重新开始
/plugin marketplace add thedotmack/claude-mem

# B. 全流程开发工作流 —— 痛点：缺乏 TDD/调试/验收纪律
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# C. 工具集成中心 —— 痛点：需要连 Slack/Jira/Notion 等 SaaS
/plugin marketplace add ComposioHQ/awesome-claude-plugins

# ========== 按需 ⭐ ==========

# 安全方向
/plugin marketplace add trailofbits/skills

# Go 开发
/plugin marketplace add JetBrains/go-modern-guidelines

# UI/UX 设计
/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill

# Hooks 精通
/plugin marketplace add disler/claude-code-hooks-mastery

# ========== 进阶 / 评估用 ==========

# everything-claude-code：156 skills 全量加载，触发面大
# 推荐改走 §8.4「按需挑选 Skill」路径，而非整体安装
# /plugin marketplace add affaan-m/everything-claude-code
# /plugin install everything-claude-code@everything-claude-code
```

### 4.2 关于 rules 的重要说明

过往版本曾建议将 `everything-claude-code/rules/*` 整目录拷贝到 `~/.claude/rules/`，**这条建议已废弃，不要这么做**。

原因：

+ `~/.claude/rules/` 下的规则会**全局注入每次会话的系统提示**，整目录拷贝意味着无关规则也永久吃 token 预算
+ 规则之间可能互相矛盾，批量引入会让 Claude 行为难以解释
+ 与插件机制本身的 rules 加载路径重复，容易两份漂移

正确做法：**按需逐条挑选**。想引入某条规则时，打开对应 `.md` 文件阅读内容，确认你认同后再单独拷贝到 `~/.claude/rules/`。

---

## 五、内置功能与 Skills 速查
> ⚠️ **重要区分**：Claude Code 有**内置功能**（无需安装）和**需安装的 Skills/Plugins**。
>

### 5.1 内置功能（开箱即用）
以下功能**无需安装任何插件**，Claude Code 默认支持：

| 功能 | 调用方式 | 说明 |
| --- | --- | --- |
| **Plan** | `/plan` | 规划模式，禁用编辑工具，专注规划 |
| **Playwright** | 自动触发 | 浏览器自动化，测试、截图等 |
| **Init** | `/init` | 初始化项目，生成 CLAUDE.md |
| **Review** | `/review` | 代码审查 |
| **Test** | `/test` | 运行测试 |
| **PR** | `/pr` | 创建 Pull Request |
| **Commit** | `/commit` | 智能 Git 提交 |


### 5.2 需安装的 Skills 分类
#### 文档处理类
| Skill | 用途 | 安装来源 |
| --- | --- | --- |
| `pdf` | 读取、创建、编辑、填写 PDF | `anthropics/skills` |
| `docx` | 创建和编辑 Word 文档 | `anthropics/skills` |
| `xlsx` | 创建和编辑 Excel 表格 | `anthropics/skills` |
| `pptx` | 创建和编辑 PowerPoint | `anthropics/skills` |


#### 开发工作流类
| Skill | 用途 | 安装来源 |
| --- | --- | --- |
| `tdd` | 测试驱动开发 | 社区插件 |
| `e2e` | 端到端测试 | 社区插件 |
| `refactor-clean` | 代码清理 | 社区插件 |
| `build-fix` | 修复编译错误 | 社区插件 |
| `update-docs` | 文档同步 | 社区插件 |
| `security-review` | 安全审计 | 社区插件 |
| `security-guidance` | 安全漏洞扫描 | 官方插件 |


#### 设计与创意类
| Skill | 用途 | 安装来源 |
| --- | --- | --- |
| `frontend-design` | 设计系统、无障碍标准 | `anthropics/skills` |
| `theme-factory` | 配色主题生成（10 种预设） | `anthropics/skills` |
| `canvas-design` | 画布设计（PNG/PDF） | `anthropics/skills` |
| `algorithmic-art` | p5.js 算法艺术 | `anthropics/skills` |
| `brand-guidelines` | 品牌指南 | `anthropics/skills` |
| `slack-gif-creator` | Slack GIF 动画 | `anthropics/skills` |
| `web-artifacts-builder` | React/Tailwind Web 构建 | `anthropics/skills` |


> 💡 **提示**：内置功能占比很高，先熟练使用内置功能，再按需安装插件。
>

---

## 六、常用命令
### 6.1 插件管理
```bash
# 打开插件管理器
/plugin

# 浏览发现插件
/plugin → Discover

# 安装插件
/plugin install <plugin-name>@<marketplace>

# 卸载插件
/plugin uninstall <plugin-name>

# 启用/禁用
/plugin enable <plugin-name>
/plugin disable <plugin-name>

# 列出已安装
/plugin list
```

### 6.2 市场管理
```bash
# 添加市场
/plugin marketplace add <repo>

# 列出所有市场
/plugin marketplace list

# 更新市场
/plugin marketplace update <marketplace-name>

# 移除市场
/plugin marketplace rm <marketplace-name>
```

### 6.3 安装范围
| 范围 | 说明 | 适用场景 |
| --- | --- | --- |
| 用户范围 | 仅自己，所有项目 | 个人效率工具 |
| 项目范围 | 当前仓库，团队共享 | 团队工具 |
| 本地范围 | 当前仓库，仅你 | 临时测试 |


---

## 七、市场对比与选择
### 7.1 综合对比
| 市场 | Stars | 定位 | 适合人群 |
| --- | --- | --- | --- |
| **everything-claude-code** | 160K+ | 大型 skill/agent 集合 | 需要按需挑选特定 skill |
| **claude-mem** | 62K+ | 跨会话长记忆 | 需要跨会话上下文的用户 |
| **superpowers** | 159K+ | 流程纪律（14 skill） | 追求标准化开发流程的团队/个人 |
| **awesome-claude-plugins** | - | 工具集成 | 需要连接外部 SaaS 服务的用户 |
| **awesome-claude-skills** | 31.7K+ | 技能库 | 需要丰富技能选择的用户 |
| **trailofbits/skills** | - | 安全审计 | Web3/区块链开发者 |
| **go-modern-guidelines** | - | Go 规范 | Go 语言开发者 |
| **ui-ux-pro-max** | - | UI/UX | 前端设计师 |


### 7.2 选择建议
| 你的需求 | 推荐市场 |
| --- | --- |
| 刚开始使用 Claude Code | `anthropics/skills`（官方市场，最稳） |
| 需要跨会话记忆 | `claude-mem` |
| 追求标准化开发流程 | `superpowers` |
| 需要连接外部服务 | `awesome-claude-plugins` |
| Go 语言开发 | `go-modern-guidelines` |
| Web3/区块链开发 | `trailofbits/skills` |
| UI/UX 设计 | `ui-ux-pro-max-skill` |
| 文档处理 | 安装 `anthropics/skills` 市场后使用 `pdf`, `docx`, `xlsx`, `pptx` |


---

## 八、社区精选资源
### 8.1 社区热门 Skills
| Skill | Stars | 用途 | 来源 |
| --- | --- | --- | --- |
| **Superpowers** | 159K+ | 流程纪律：brainstorm→plan→TDD→review→verify | obra/superpowers-marketplace |
| **claude-mem** | 62K+ | 跨会话长记忆，解决上下文丢失 | thedotmack/claude-mem |
| **awesome-claude-skills** | 32K+ | Skills 聚合目录，270K+ 技能 | travisvn/awesome-claude-skills |
| **Claude Code Skills** | 82+ | 完整交付工作流 | levnikolaevich/claude-code-skills |
| **GitHub PR Review** | - | PR 代码审查（高质量） | aidankinzett/claude-git-pr-skill |


### 8.2 Skills 聚合平台
| 平台 | 网址 | 说明 |
| --- | --- | --- |
| **SkillsMP** | skillsmp.com | 270K+ Skills 聚合，智能搜索 |
| **Awesome Claude Skills** | github.com/travisvn/awesome-claude-skills | 精选 Skills 列表 |
| **Awesome Claude Code** | github.com/hesreallyhim/awesome-claude-code | 22K+ Stars，综合资源 |


### 8.3 按场景推荐
| 场景 | 推荐 Skills/插件 |
| --- | --- |
| **日常开发** | `git-workflow`, `code-review`, `commit-commands` |
| **文档处理** | `pdf`, `docx`, `xlsx`, `pptx` |
| **前端开发** | `frontend-design`, `ui-ux-pro-max` |
| **测试** | `testing-tdd`, `webapp-testing`, `e2e` |
| **安全** | `security-guidance`, `building-secure-contracts` |
| **长记忆** | `claude-mem` |
| **技能创建** | `skill-creator`, `mcp-builder` |


### 8.4 按需挑选 Skill（推荐）

对于大型 skill 集合仓库（尤其是 `everything-claude-code`），**推荐手动挑选而非 `/plugin install` 整体安装**，以控制触发面、避免与现有插件冲突。

**第一步：常驻克隆（便于日后 `git pull` 升级）**

```bash
# 放到常驻位置，不要 /tmp
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git \
  ~/src/everything-claude-code

# 官方 skills 同理
git clone --depth 1 https://github.com/anthropics/skills.git ~/src/anthropic-skills
```

**第二步：按需拷贝（skill 是目录，不是单个文件）**

```bash
# 每个 skill 是一个带 SKILL.md 的完整目录，可能还有 references/、scripts/
# 一定用 cp -r 拷贝整个目录
cp -r ~/src/everything-claude-code/.agents/skills/tdd-workflow \
      ~/.claude/skills/

cp -r ~/src/anthropic-skills/skills/<skill-name> ~/.claude/skills/
```

**第三步：升级**

```bash
cd ~/src/everything-claude-code && git pull
# 对已选的 skill 重新 cp -r 覆盖即可
```

**挑选原则：**

+ **优先过程类 skill**（systematic-debugging、tdd、verification-before-completion 等）——跨项目通用，价值高
+ **领域类 skill 按栈挑**（go-reviewer、python-reviewer 等）——只在对应语言项目生效，不用就闲置
+ **跳过自治长循环类**（`loop-*`、`gan-*`、`devfleet` 等）——这些偏后台 agent 场景，不适合交互式编程
+ **装前读 `description`**：skill 触发完全靠 frontmatter 里的 `description`，描述过宽（如"Use when writing code"）会频繁误触发，污染所有会话
+ **查重**：在拷贝前用 `ls ~/.claude/skills/` 检查是否已有同名概念的 skill（例如 `superpowers` 已自带 `systematic-debugging`、`test-driven-development` 等，重复拷贝会冲突）

---

## 九、故障排除
### 9.1 常见问题
| 问题 | 解决方案 |
| --- | --- |
| **插件安装失败** | 检查网络连接，确认仓库地址正确；尝试先 `update` 市场再安装 |
| **插件不生效** | 运行 `/plugin list` 确认已启用；检查是否在正确的项目目录 |
| **Skills 无法触发** | 确认描述与触发词匹配；检查 SKILL.md 格式是否正确 |
| **市场更新失败** | 删除本地缓存后重新添加：`rm -rf ~/.claude/plugins/marketplaces/<name>` |
| **插件冲突** | 禁用可疑插件逐一排查：`/plugin disable <name>` |


### 9.2 调试命令
```bash
# 查看已安装插件状态
/plugin list

# 查看市场列表
/plugin marketplace list

# 重新加载插件
/plugin reload <plugin-name>

# 查看插件详情
/plugin info <plugin-name>
```

### 9.3 版本要求
| 组件 | 最低版本 | 说明 |
| --- | --- | --- |
| Claude Code | 最新版 | 部分插件需要最新版本支持 |
| Node.js | 18+ | LSP 插件依赖 |
| Python | 3.8+ | Python LSP 依赖 |


> 💡 **提示**：遇到问题时，首先尝试更新 Claude Code 和相关市场到最新版本。
>

---

## 附录
### A. 插件结构
```plain
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # 插件元数据 (必需)
├── .mcp.json            # MCP 服务器配置 (可选)
├── commands/            # 斜杠命令 (可选)
├── agents/              # Agent 定义 (可选)
├── skills/              # Skill 定义 (可选)
├── hooks/               # 钩子 (可选)
└── README.md            # 文档
```

### B. Skill 结构
```plain
skill-name/
├── SKILL.md (必需)
│   ├── YAML frontmatter (name, description)
│   └── Markdown 指令
└── 资源文件 (可选)
    ├── scripts/    - 可执行代码
    ├── references/ - 文档引用
    └── assets/     - 模板、图标等
```

### C. 创建自定义 Skill 快速指南
1. **创建目录**

```bash
mkdir -p ~/.claude/skills/my-skill
```

2. **编写 SKILL.md**

```markdown
---
name: my-skill
description: 触发条件描述，Claude 会根据此描述决定何时使用
---

# 你的技能指令

在这里编写详细的指令，告诉 Claude 如何完成特定任务。
```

3. **验证安装**

```bash
# 重启 Claude Code 或运行
/skill list
```

> 💡 **推荐**：使用 `skill-creator` 技能可以获得更专业的创建和优化体验。
>

### D. 相关链接
+ [Claude Code 官方文档](https://code.claude.com/docs)
+ [Agent Skills 标准](https://agentskills.io)
+ [Anthropic 官方技能仓库](https://github.com/anthropics/skills)
+ [官方插件目录](https://github.com/anthropics/claude-plugins-official)
+ [What are skills?](https://support.claude.com/en/articles/12512176-what-are-skills)
+ [Using skills in Claude](https://support.claude.com/en/articles/12512180-using-skills-in-claude)
+ [Creating custom skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)

---

> **插件市场的核心原则 = 先用内置功能，再按痛点加插件。** 官方市场优先，社区插件按需挑选，大型 skill 集合（如 everything-claude-code）推荐手动挑选而非全装。

> 📅 **数据说明**：Stars 数量等数据截至 2026-04-19，可能随时间变化，请以 GitHub 实际数据为准。

