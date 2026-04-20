# Superpowers 使用最佳实践指南

> 整理时间：2026-04-19
> 信息来源：实测核验 [obra/superpowers](https://github.com/obra/superpowers) 主仓 README、skills 目录、hooks.json

---

## 0. 它是什么 / 不是什么

### 0.1 一句话定位

> **Superpowers 是一套"软件开发方法论 + 自动触发的 skill 库"**，强制 AI agent 按 *brainstorm → plan → TDD → review → ship* 的纪律工作，不是工具集合，是**工作流编织器**。

| 属性 | 实际情况 |
|---|---|
| 仓库 | [obra/superpowers](https://github.com/obra/superpowers) |
| Stars | 159K+（实测） |
| 作者 | Jesse Vincent（[Prime Radiant](https://primeradiant.com)） |
| License | MIT |
| 主要语言 | Shell |
| 跨平台支持 | Claude Code / Codex CLI / Codex App / Cursor / OpenCode / Copilot CLI / Gemini CLI |

### 0.2 它不是什么

- **不是 harness**（不和 Claude Code / OpenCode 同层；它是装在 harness 里的 plugin）
- **不是 skill 大杂烩**（与 `everything-claude-code` 截然不同：obra/superpowers **只有 14 个 skill**，且每个都精挑过）
- **不是模型相关**（无任何模型/provider 依赖）
- **不是"建议"**（其设计哲学：skill 是 *mandatory workflows, not suggestions*）

### 0.3 14 个内置 skill 全集（实测列表）

```
skills/
├── brainstorming                    # 苏格拉底式需求澄清
├── writing-plans                    # 拆解为 2-5 分钟级任务
├── executing-plans                  # 批次执行 + 人工 checkpoint
├── subagent-driven-development      # 每任务起新 subagent + 双阶段 review
├── dispatching-parallel-agents      # 并行 subagent 协调
├── using-git-worktrees              # 隔离 worktree
├── test-driven-development          # 严格 RED-GREEN-REFACTOR
├── systematic-debugging             # 4 阶段根因调试
├── verification-before-completion   # 宣称完成前必须验证
├── requesting-code-review           # 完成后 review checklist
├── receiving-code-review            # 收到 review 后如何回应
├── finishing-a-development-branch   # merge/PR/cleanup 决策
├── writing-skills                   # Meta：教你写新 skill
└── using-superpowers                # Meta：introduces 整个 skill 系统
```

> ⚠️ **重要**：网上一些资料把 superpowers 描述为"上百个 skill 的市场"，那是把 Anthropic 官方 [`claude-plugins-official`](https://github.com/anthropics/claude-plugins-official) 中**包含**的 superpowers 与 `obra/superpowers` 主仓混淆了。**主仓只有这 14 个**，全部是 process skill（流程类），无领域 skill（语言 reviewer 等）。

---

## 1. 装不装的判断

| 你的情况 | 建议 |
|---|---|
| 写 PoC / 一次性脚本 | **不装**。superpowers 强制 brainstorm + TDD，会拖慢节奏 |
| 已经有自己的工作流且严格执行 | **不装**。会和你的纪律冲突 |
| 长期项目，常被 AI "偷工减料" 困扰 | **强烈推荐装** |
| 多人协作项目，希望统一 AI 行为 | **推荐装**（确保团队 AI 都按同一节奏工作） |
| 习惯 *"快速试错 + 不写测试"* | **不装**。TDD 是硬性要求 |
| 重视过程而非速度 | **推荐装** |

**核心适配性问题：**

> Superpowers 的核心是**强制纪律**，它会让 *"先 plan 再 code"*、*"先 test 再 impl"*、*"宣称完成前先验证"* 变成绕不过去的步骤。这对**长期质量是好事**，对**短期速度是负担**。先想清楚你要哪种。

---

## 2. 安装

### 2.1 Claude Code（最常用）

**方式 A：Anthropic 官方 marketplace**

```bash
/plugin install superpowers@claude-plugins-official
```

**方式 B：作者维护的 marketplace（更新最快）**

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

> 推荐方式 B —— 主仓更新会先到 `obra/superpowers-marketplace`，再同步到 Anthropic 官方。

### 2.2 OpenCode

```
让 OpenCode agent 跑：
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
```

### 2.3 Codex CLI

```bash
/plugins
# 搜索 superpowers，选 Install Plugin
```

### 2.4 Cursor

```text
/add-plugin superpowers
```

### 2.5 Copilot CLI

```bash
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace
```

### 2.6 Gemini CLI

```bash
gemini extensions install https://github.com/obra/superpowers
gemini extensions update superpowers   # 升级
```

### 2.7 验证安装

启动新会话，输入任何创建性请求（"帮我加一个 X 功能"），观察是否：

- 模型先反问需求（brainstorming 触发）
- 不直接写代码

如果直接开写，说明 `using-superpowers` skill 没自动激活。检查：

```bash
# 看 SessionStart hook 是否注册
cat ~/.claude/settings.json | jq '.hooks.SessionStart'
```

---

## 3. 核心设计哲学（理解这 4 条胜过读 14 个 SKILL.md）

### 3.1 Skill 优先级 > 系统提示，但 < 用户指令

源自 `using-superpowers` skill：

```
1. 用户显式指令（CLAUDE.md/AGENTS.md/直接请求）  ← 最高
2. Superpowers skills                            ← 中
3. 默认系统提示                                   ← 最低
```

**这意味着：** 你**永远是老板**。你说"这次跳过 TDD"，AI 必须听你的，不能拿 skill 当挡箭牌。

### 3.2 1% 原则

> *"Even a 1% chance a skill might apply means that you should invoke the skill to check."*

AI 在每次回应**前**必须先扫一遍 skill 列表。这是为什么 superpowers 启用后 AI 看起来"反应慢" —— 它在做 skill check。

### 3.3 Rigid vs Flexible

| 类型 | 例子 | 行为 |
|---|---|---|
| **Rigid** | TDD、systematic-debugging | 一字不差遵守，不允许"灵活" |
| **Flexible** | 大多数 pattern | 按情境调整 |

skill 自身会声明类型。**TDD 和 debugging 是 rigid 的设计意图**：纪律一旦被"灵活掉"就失去价值。

### 3.4 Evidence over claims

`verification-before-completion` skill 的核心 —— 在说 "fixed"、"works"、"tests pass" 之前，**必须贴出实际命令的输出**。

---

## 4. 全部 Skill 触发方式一览

> **14 个 skill 中，13 个自动触发，1 个需要手动 `/`，1 个需要用户确认。不需要记住任何命令，正常对话即可。**

### 4.0.1 按触发方式分类

**全自动触发（11 个）：**

| Skill | 触发时机 | 触发信号 |
|---|---|---|
| `using-superpowers` | 会话启动时 | SessionStart hook 自动加载 |
| `brainstorming` | 你提出创建性需求 | "我想做 X"、"帮我加 X" |
| `writing-plans` | brainstorming 完成后 | design doc 产出后自动进入 |
| `executing-plans` | plan 审批后 | 你说 "go" 或 "开始执行" |
| `subagent-driven-development` | plan 审批后，任务多且独立 | AI 判断并行更高效时自动选择 |
| `dispatching-parallel-agents` | 执行中发现 2+ 个任务无依赖 | AI 自动派发并行 subagent |
| `test-driven-development` | 开始写代码时 | 任何需要写实现代码的时刻 |
| `systematic-debugging` | 遇到 bug 或测试失败 | 测试红灯、报错、unexpected behavior |
| `verification-before-completion` | AI 准备说"做完了" | AI 内部自检点，不需要你触发 |
| `requesting-code-review` | 任务代码写完后 | 实现完成时自动触发 |
| `finishing-a-development-branch` | 所有任务 + review 通过 | 全部完成后自动触发 |

**需要用户确认（1 个）：**

| Skill | 触发方式 |
|---|---|
| `using-git-worktrees` | AI 每次都会提议创建 worktree，**你同意才执行**，拒绝则跳过 |

**需要外部输入触发（1 个）：**

| Skill | 触发方式 |
|---|---|
| `receiving-code-review` | 你在 PR 上留了 comment / 给了 review 反馈后才触发 |

**需要手动 `/` 触发（1 个）：**

| Skill | 触发方式 |
|---|---|
| `writing-skills` | 你想创建自定义新 skill 时，手动输入 `/writing-skills` |

### 4.0.2 按流程阶段看触发顺序

```
会话启动 → using-superpowers（自动）
    ↓
你提需求 → brainstorming（自动）
    ↓
设计通过 → using-git-worktrees（AI 提议，你确认）
    ↓
开始规划 → writing-plans（自动）
    ↓
你审批 → executing-plans 或 subagent-driven-development（AI 自动选）
    ↓          ↘ 如果任务独立 → dispatching-parallel-agents（自动）
    ↓
写代码 → test-driven-development（自动）
    ↓ 遇到 bug → systematic-debugging（自动）
    ↓ 即将完成 → verification-before-completion（自动）
    ↓
代码完成 → requesting-code-review（自动）
    ↓ 收到反馈 → receiving-code-review（自动）
    ↓
全部通过 → finishing-a-development-branch（自动）
```

### 4.0.3 如何确认 Superpowers 是否生效

提出一个需求后，**看 AI 的第一反应**：

| AI 行为 | 说明 |
|---|---|
| 先反问你的需求、追问细节 | Superpowers brainstorming **已生效** |
| 直接开始写代码 | Claude Code 默认行为，Superpowers **未生效** |

如果未生效，排查：

```bash
cat ~/.claude/settings.json | jq '.hooks.SessionStart'
# 没有输出或为空 → hook 没注册 → Superpowers 没激活
```

兜底方案：手动输入 `/superpowers:brainstorming 你的需求` 强制走 Superpowers 流程。

---

## 4. 标准工作流（7 步法）

按 README 的标准化流程：

```
1. brainstorming                    ← 用户启动对话
   ↓ (输出 design 文档)
2. using-git-worktrees              ← 隔离工作区
   ↓
3. writing-plans                    ← 拆 2-5 分钟级任务
   ↓ (用户审批)
4. subagent-driven-development      ← 每任务起 subagent
   或 executing-plans               ← 批次 + checkpoint
   ↓
5. test-driven-development          ← RED-GREEN-REFACTOR
   ↓ (在每个任务内嵌)
6. requesting-code-review           ← 任务间 review
   ↓ (critical 阻塞)
7. finishing-a-development-branch   ← merge/PR 决策
```

### 4.1 阶段一：Brainstorm

启动一个新 feature 时，**不要直接说 "实现 X"**，让模型自然进入 brainstorming：

```
我想做一个用户通知系统
```

模型会反问：
- 通知渠道（站内 / 邮件 / push）？
- 实时性要求？
- 谁触发？
- 失败重试策略？

**反模式：** 上来就说 *"实现一个支持站内 + 邮件、用 Redis 队列、5 次重试的通知系统"*。这等于跳过 brainstorming，superpowers 会接受但效果减半。

### 4.2 阶段二：Worktree

`using-git-worktrees` 自动在 design 通过后触发，会创建独立 worktree。

**好处：** 主分支不被污染，可以并行开多个 feature。

**注意：** 你的工作目录会被切到 worktree 里，记得用 `cd` 或新开 terminal 看进度。

### 4.3 阶段三：Plan

`writing-plans` 会输出一个**任务列表**，每个任务：
- 2-5 分钟可完成
- 包含确切文件路径
- 包含完整代码片段
- 包含 verification 步骤

**最佳实践：** **一定要审 plan**。superpowers 设计就是"plan 是契约"，不审就直接 go = 让 AI 自由发挥。

### 4.4 阶段四：Execute

两种执行模式：

| 模式 | 适用 | 特点 |
|---|---|---|
| `subagent-driven-development` | 任务独立性强 | 每任务起新 subagent + 双阶段 review |
| `executing-plans` | 任务有依赖 | 批次执行 + 人工 checkpoint |

**双阶段 review** 是 superpowers 的关键设计：
1. 第一阶段：是否符合 spec
2. 第二阶段：代码质量是否 OK

任一失败 → 回炉重做。

### 4.5 阶段五：TDD（贯穿）

`test-driven-development` 在 implement 阶段强制激活：

```
RED:    写一个失败的 test
        ↓ (必须看到它失败)
GREEN:  写最少代码让它通过
        ↓ (看到它通过)
REFACTOR: 清理
        ↓
COMMIT
```

**Iron Law（铁律）：** *"NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST"*

如果 AI 先写了实现再补 test，superpowers 会让它**删掉重写**。

### 4.6 阶段六：Review

任务完成后 `requesting-code-review` 自动触发，按严重度报告问题：

- **Critical** → 阻塞，必须修
- **Major** → 强烈建议修
- **Minor** → 可选

### 4.7 阶段七：Finish

`finishing-a-development-branch` 会问你：

- Merge？
- 开 PR？
- 保留 branch？
- 丢弃？

并清理 worktree。

---

## 5. 关键 Skill 深度使用

### 5.1 brainstorming —— 不只是"问一堆问题"

它是**苏格拉底式设计精炼**，核心不是穷举问题，而是：

1. 把模糊需求变成可验证的 spec
2. 一段一段呈现 design 给你 review（避免一次塞一大段）
3. 落盘 design 文档（后续 plan 的输入）

**最佳实践：**
- **耐心回答问题**。每次跳过问题等于丢失一份未来调试的线索
- **不要在 brainstorming 阶段贴代码**。你贴了代码，模型会顺着代码走，失去问"为什么要这么设计"的角度
- **保留 design 文档**，作为 PR 描述或文档基础

### 5.2 systematic-debugging —— 4 阶段根因调试

适用：**任何 bug、test 失败、unexpected behavior**。

```
1. Reproduce       ← 先稳定复现
2. Isolate         ← 二分 / 缩小范围
3. Root cause      ← 找到真正原因（不是症状）
4. Fix + verify    ← 修，并验证修对了
```

**反模式：** "我猜可能是 X，改改试试" → systematic-debugging 不允许这种 *guess-and-check*。

### 5.3 verification-before-completion —— 防止"我以为修好了"

激活时机：**你即将说 "done"、"fixed"、"tests pass"** 时。

要求：
- 必须运行实际命令（不是看代码推测）
- 必须贴出命令输出（不是只说 "passed"）
- evidence 在前，结论在后

**这条是 superpowers 给你最大的"AI 不撒谎"保障，单独装这一条都值。**

### 5.4 using-git-worktrees —— 不只是 git 操作

设计意图：**让 feature 工作完全隔离**。

激活后会：
- 自动选择 worktree 目录（智能避免冲突）
- 在新分支启动
- 跑项目 setup（install deps）
- 验证 test baseline 是绿的

**好处：** 主目录永远干净，可以同时开 3-4 个 worktree 让不同 subagent 并行干活。

### 5.5 dispatching-parallel-agents —— 真正的并行

适用：**2+ 个独立任务，没有共享 state、没有时序依赖**。

会一次性派发多个 subagent，结果汇总后继续。

**反模式：** 以为"加并行就快"。如果任务之间有共享代码改动（同一文件），并行会冲突。

### 5.6 receiving-code-review —— 别盲目同意

收到 review 反馈时激活。设计意图：**反对"performative agreement"（演技式同意）**。

要求：
- 技术质疑要先验证
- 不清楚就追问，不要假装懂
- 同意 ≠ 接受，要带判断

**为什么重要：** AI 默认偏 agreeable，看到批评就改。这条 skill 强制它**先评估再行动**。

---

## 6. 与其他工具的协作

### 6.1 与 CLAUDE.md / AGENTS.md 的关系

**用户指令 > Superpowers**。如果你在 CLAUDE.md 写了：

```md
不使用 TDD，本项目是 PoC
```

Superpowers 会让位。这是设计意图，不是 bug。

### 6.2 与 Memory 系统的关系

Superpowers 自带工作流，但不持久化用户偏好。**用户偏好放 memory**，**工作流由 Superpowers 接管**。

### 6.3 与其他 skill 包的关系

| 组合 | 评估 |
|---|---|
| Superpowers + everything-claude-code | **冲突高**。两者都管"如何工作"，skill 重名（systematic-debugging、tdd 等）会互相覆盖 |
| Superpowers + claude-mem | **OK**。前者管流程，后者管记忆，不冲突 |
| Superpowers + 官方 anthropics/skills | **OK**。官方 skill 多为领域类（pdf、xlsx 等），与 Superpowers 互补 |
| Superpowers + omo（OpenCode） | **OK 但重复**。omo 有自己的 Sisyphus 编排，superpowers 在 OpenCode 里更适合做"细粒度纪律层" |

**单一 skill 包原则：** 不要装两个 process skill 包，会让 AI 在多个工作流之间打架。

### 6.4 与 hooks 的关系

Superpowers 自身**几乎不用 hooks**（仅 SessionStart 注册一个 skill loader）。它的所有纪律都靠 skill 的 description 触发，不靠 hook 强制。

**含义：** Superpowers 是"软"约束（依赖模型听话），不是"硬"约束（hook 可以阻断 tool call）。如果你需要硬约束（例如"提交前必须跑测试"），仍需自己写 hook。

---

## 7. 反模式 / 常见误用

### 7.1 ❌ 启动后绕过 brainstorming

```
"实现一个完整的 OAuth 系统，用 NextAuth + JWT + refresh token + ..."
```

→ 你已经写完 design 了，brainstorming 没东西可问。**等于关掉了 superpowers 70% 的价值**。

**正确：**
```
"我想加用户登录"
```

让 brainstorming 自然展开。

### 7.2 ❌ 跳过 plan review

```
"go" / "do it" / "looks good"（没真读 plan）
```

→ AI 自由发挥，跑偏后责任归你。

### 7.3 ❌ "TDD 太慢，跳过这次"

→ 这正是 `using-superpowers` 的 Red Flags 表里的反模式：*"Thinking 'skip TDD just this once'? Stop. That's rationalization."*

**正确做法：** 如果项目真的不该用 TDD（PoC），写到 CLAUDE.md。**不要每次现编理由跳过**。

### 7.4 ❌ 同时装多个 process skill 包

→ everything-claude-code + Superpowers + 自己写的 hook = AI 不知道听谁的。

### 7.5 ❌ 把 superpowers 当 task tracker

→ 它管"如何做"，不管"做什么"。task / 需求管理用别的工具（Linear / GitHub Issues / harness-lab 等）。

### 7.6 ❌ 在 subagent 里期待 skill 触发

`using-superpowers` 开头就有 `<SUBAGENT-STOP>`：被作为 subagent 派发时**自动跳过**整个 skill 系统。

→ 含义：subagent 是"专业工人"，不是"工头"。**编排逻辑只在主线 agent 中生效**。

---

## 8. 何时该禁用 / 关闭

| 场景 | 操作 |
|---|---|
| 写 throwaway prototype | CLAUDE.md 加："本项目跳过 TDD 和 brainstorming" |
| 探索性 spike | 临时说 "这次直接试，不走流程" |
| Skill 触发太频繁拖慢节奏 | 检查是否同时装了重叠的 skill 包，移除一个 |
| 完全不想要 | `/plugin uninstall superpowers` |

### 8.1 项目级降噪写法

```md
<!-- CLAUDE.md -->
## Project conventions
- This is a research prototype. Skip TDD.
- No need for brainstorming on small fixes (<20 lines).
- Always use systematic-debugging for production bugs.
```

Superpowers 会**部分让位**：跳过 TDD 和小改的 brainstorming，但保留 debugging 纪律。

---

## 9. 升级与版本管理

### 9.1 Claude Code

```bash
/plugin update superpowers
```

或者直接 `/plugin install` 重装。

### 9.2 Gemini CLI

```bash
gemini extensions update superpowers
```

### 9.3 其他 harness

通常自动检测 marketplace 更新；可手动重新 install。

### 9.4 升级注意

- 升级后 **重启会话**，让 SessionStart hook 重新注册新版 skill
- 升级前看 [RELEASE-NOTES.md](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md)，关注 skill description 变化（影响触发行为）

---

## 10. 故障排除

| 问题 | 原因与修复 |
|---|---|
| Skill 不触发 | 1) 检查 SessionStart hook 是否注册；2) 重启会话；3) 看是否有覆盖性的 CLAUDE.md 规则 |
| AI 跳过 brainstorming 直接写代码 | 多半是用户给了过详细的需求，模型判断"无需澄清" |
| TDD 让进度太慢 | 真不适合的项目在 CLAUDE.md 标注；适合的项目这正是 superpowers 的价值 |
| 多个 skill 同时被触发，冲突 | `using-superpowers` 给出优先级：process > implementation；多 skill 包冲突需要卸载一个 |
| Subagent 里没有 skill 行为 | 设计如此，subagent 不加载 skill 系统 |
| 升级后行为变化 | 看 RELEASE-NOTES，多半是某个 skill description 改了导致触发条件变化 |

---

## 11. 适用场景对照表

| 场景 | 适合度 | 理由 |
|---|---|---|
| 个人长期项目 | ⭐⭐⭐⭐⭐ | 完美匹配 |
| 团队共享 AI 工作流 | ⭐⭐⭐⭐⭐ | 统一纪律 |
| 生产 bug 修复 | ⭐⭐⭐⭐⭐ | systematic-debugging + verification 黄金组合 |
| 重构 | ⭐⭐⭐⭐ | TDD 保护 + plan 防止失控 |
| 写文档 | ⭐⭐ | brainstorming/TDD 不太适用 |
| Hackathon / 24h 项目 | ⭐ | 流程开销 > 质量收益 |
| 数据分析 notebook | ⭐ | 探索性强，TDD 不匹配 |
| 学习新 framework | ⭐⭐ | brainstorming 有帮助，但 TDD 学起来慢 |

---

## 12. 与本 repo 其他文档的对照

| 工具 | 层级 | 关系 |
|---|---|---|
| Claude Code / OpenCode / Codex | Harness（容器） | 运行 AI 的"操作系统" |
| omo（Oh My OpenAgent） | Harness 增强 | 给 OpenCode 加多模型编排 |
| everything-claude-code | Skill / Agent 包 | 156 skill 全装，触发面大 |
| **Superpowers** | **Process skill 包** | **14 个精选流程 skill，强制纪律** |
| harness-lab | 项目治理协议 | REQ 生命周期管理 |
| claude-mem | 记忆插件 | 跨会话上下文 |

**简单选择树：**

- 想要**强制纪律** → Superpowers
- 想要**领域 skill 大全** → everything-claude-code（按需挑选）
- 想要**REQ 治理流程** → harness-lab
- 想要**跨会话记忆** → claude-mem

⚠️ Superpowers 和 everything-claude-code 不要同时装。

---

## 13. 一句话总结

> **Superpowers 的本质 = 用 14 个 skill 强制你的 AI 走完整的工程流程。** 它不让你写得更快，但让 AI 写出来的代码**值得信任**。代价是节奏慢、对话多。**适合长期项目，不适合一次性脚本。**

---

## 14. 参考链接

- [obra/superpowers 主仓](https://github.com/obra/superpowers)
- [obra/superpowers-marketplace](https://github.com/obra/superpowers-marketplace)
- [作者发布介绍博客](https://blog.fsck.com/2025/10/09/superpowers/)
- [Discord 社区](https://discord.gg/35wsABTejz)
- [Prime Radiant](https://primeradiant.com)
