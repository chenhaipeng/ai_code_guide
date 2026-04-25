# SpecKit + OpenSpec 使用最佳实践指南

> 整理时间：2026-04-25
> 信息来源：实测核验 [github/spec-kit](https://github.com/github/spec-kit) 主仓 README、docs 目录、模板文件；[Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) v1.3.0 主仓 README、docs 目录、schema 文件

---

## 0. 它们是什么 / SDD 方法论概述

### 0.1 Spec-Driven Development（SDD）核心思想

传统开发流程：代码是主体，spec 是辅助文档。SDD **反转这个关系**——spec 是 source of truth，代码是 spec 的表达。

```
传统：需求文档（容易过时）→ 写代码 → spec 沦为摆设
SDD：  写 spec（活文档）  → AI 按 spec 生成代码 → spec 始终是真相
```

SDD 解决的核心问题：**AI coding agent 很强，但需求如果只存在于聊天记录里，结果不可预测。** SDD 给 AI 一个结构化的"合同"，让输出可控、可验证。

### 0.2 两个工具的一句话定位

| 工具 | 一句话 |
|---|---|
| **Spec Kit** | GitHub 官方出品，阶段式 SDD 工具包——先写 spec，再生成 plan/tasks，最后让 AI 按任务执行 |
| **OpenSpec** | Fission-AI 出品，流式 SDD 框架——以 delta spec 为核心，面向棕地项目(存量系统)的轻量 spec 管理 |

### 0.3 快速属性对比

| 属性 | Spec Kit | OpenSpec |
|---|---|---|
| 仓库 | [github/spec-kit](https://github.com/github/spec-kit) | [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) |
| 出品方 | GitHub | Fission-AI |
| License | MIT | MIT |
| 语言 | Python | TypeScript |
| CLI 名 | `specify` | `openspec` |
| 包管理 | pip / uvx | npm / pnpm / yarn / bun |
| AI 工具支持 | 26+ | 25+ |
| 核心方法论 | 阶段式：specify → clarify → plan → tasks → implement | 流式：propose → apply → archive（可自由组合） |
| 对棕地项目 | 可以，但侧重完整 spec 文档 | **原生优化**——delta spec 只描述变更部分 |

### 0.4 它们不是什么

- **不是 harness**（不和 Claude Code / OpenCode 同层；是装在 harness 里的工具）
- **不是流程纪律工具**（不像 Superpowers 强制 brainstorm → TDD → review 流程；SDD 工具管的是"需求和设计"，不管代码纪律）
- **不互斥**（理论上可以同时用，但实践中选一个就够）

---

## 1. Spec Kit（GitHub 官方）

### 1.1 核心概念

Spec Kit 的核心是一套**阶段式工作流**，每个阶段产出一种 artifact：

```
constitution（项目宪法）
    ↓
spec（需求规格）
    ↓
clarify（澄清模糊点）
    ↓
plan（技术方案）
    ↓
tasks（任务清单）
    ↓
implement（执行）
```

**Constitution（宪法）** 是 Spec Kit 独有的概念——一份定义项目核心原则的文档，包含"Nine Articles"：

| 条款 | 核心要求 |
|---|---|
| Library-first | 优先用已有库，不造轮子 |
| CLI interfaces | 优先 CLI 接口 |
| TDD mandate | 测试驱动开发 |
| Simplicity gate | 复杂度必须有回报 |
| Anti-abstraction | 不做 premature abstraction |
| Integration testing | 集成测试不可少 |
| Documentation | 关键决策必须文档化 |
| Security by default | 安全是默认项 |
| Performance awareness | 性能不能是事后补丁 |

### 1.2 安装

```bash
# 一次性运行（推荐试水）
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT> --ai claude

# 持久安装
uv tool install git+https://github.com/github/spec-kit.git
specify init <PROJECT> --ai claude

# 验证
specify check
```

### 1.3 工作流详解

**Step 1：初始化**

```bash
specify init my-project --ai claude
```

生成的目录结构：

```
specs/
  constitution.md     # 项目宪法（全局约束，所有 spec 都受其约束）
  001-feature-name/
    spec.md           # 需求规格
    plan.md           # 技术方案
    tasks.md          # 任务清单
    contracts/        # 接口契约（可选）
  002-next-feature/   # 第二个功能，同样受 constitution 约束
    spec.md
    plan.md
    tasks.md
```

**增量开发时 Constitution 的作用：** Constitution 在 `/speckit.plan`（技术方案）阶段才生效，而非 spec 创建阶段。`/speckit.plan` 模板包含 "Constitution Check" 门禁——如果 plan 违反宪法原则（比如没做 TDD），必须填写 "Complexity Tracking" 表说明原因和替代方案。Constitution 是**全局约束基线**，单一文档作用于所有功能。

**Spec Kit 的 spec 之间没有关联机制。** 每个 `001-feature-a/`、`002-feature-b/` 是完全独立的 spec，不互相引用、不声明依赖。每个 spec 也只描述新功能的 WHAT 和 WHY，**不需要**重写已有系统的描述。这意味着各 spec 是"平铺"的功能描述，而 OpenSpec 的 spec 是"累积"的领域真相——详见 §4.6。

**Step 2：写宪法**

在 AI agent 中执行：

```
/speckit.constitution
```

AI 会引导你建立项目核心原则。**所有后续 spec 都受宪法约束。**

**Step 3：写 spec**

```
/speckit.specify
```

描述你要构建什么。**只写 WHAT 和 WHY，不写 HOW。** AI 会按模板生成结构化 spec。

**Step 4：澄清**

```
/speckit.clarify
```

这一步自动扫描 spec 中的模糊点，生成澄清问题。**务必在 plan 之前执行，减少返工。**

**Step 5：做 plan**

```
/speckit.plan
```

AI 根据 spec + clarify 结果生成技术方案，包含架构决策、技术栈选择、组件划分。

**Step 6：拆任务**

```
/speckit.tasks
```

将 plan 拆解为可执行的任务清单，每个任务粒度为 2-5 分钟。

**Step 7：执行**

```
/speckit.implement
```

AI 按 tasks.md 逐项执行。

### 1.4 辅助命令

| 命令 | 用途 | 触发方式 |
|---|---|---|
| `/speckit.analyze` | 跨 artifact 一致性分析——检查 spec、plan、tasks 之间是否有矛盾 | 👤 主动 |
| `/speckit.checklist` | 生成质量检查清单，相当于"英文版单元测试" | 👤 主动 |

### 1.5 命令触发方式总结

**Spec Kit 的所有命令都是👤主动触发（人工输入命令）**。不存在 AI 自动触发的命令。你需要按顺序手动执行每一步：

| 命令 | 触发方式 | 说明 |
|---|---|---|
| `/speckit.constitution` | 👤 主动 | 手动输入，AI 引导你写宪法 |
| `/speckit.specify` | 👤 主动 | 手动输入，描述需求 |
| `/speckit.clarify` | 👤 主动 | 手动输入，AI 扫描模糊点 |
| `/speckit.plan` | 👤 主动 | 手动输入，AI 生成技术方案 |
| `/speckit.tasks` | 👤 主动 | 手动输入，AI 拆任务 |
| `/speckit.implement` | 👤 主动 | 手动输入，AI 逐项执行 |
| `/speckit.analyze` | 👤 主动 | 手动输入，一致性检查 |
| `/speckit.checklist` | 👤 主动 | 手动输入，质量检查 |

> 这和 Superpowers 不同——Superpowers 的 brainstorming、TDD、review 等 skill 是由 SessionStart hook 注册后**自动触发**的（AI 会在合适的时机自动调用），不需要你手动输入命令。

### 1.5 扩展系统

Spec Kit 有成熟的扩展生态：

- **Presets**：`lean`（精简）、`scaffold`（脚手架）、`self-test`（自测）等内置预设
- **Community extensions**：社区贡献的领域扩展
- **Extension API**：完整的扩展开发、发布指南

社区项目举例：

| 项目 | 用途 |
|---|---|
| [speckit-companion](https://github.com/alfredoperez/speckit-companion) | VS Code 扩展 |
| [speckit-status](https://github.com/mkatanski/speckit-status) | 终端可视化任务进度 |
| [claude-speckit-template](https://github.com/jabelk/claude-speckit-template) | Claude Code 专用模板 |

### 1.6 适用场景

| 场景 | 推荐度 | 理由 |
|---|---|---|
| 绿地项目（从零开始） | ⭐⭐⭐ | 完整 spec 文档对绿地项目最自然 |
| 团队协作，需要统一 spec 规范 | ⭐⭐⭐ | Constitution 机制强制团队一致性 |
| 已有项目，做小改动 | ⭐⭐ | 可以用，但要写完整 spec，有点重 |
| PoC / 快速原型 | ❌ | 阶段式流程拖慢节奏 |

---

## 2. OpenSpec（Fission-AI）

### 2.1 核心概念

OpenSpec 的核心是**变更（Change）**，不是文档。每个变更是一个文件夹，包含所有相关 artifact：

```
openspec/
  specs/                  # 系统当前行为的真相（按领域组织）
    user/spec.md          # 用户域：注册、登录、权限
    order/spec.md         # 订单域：下单、支付、退款
    product/spec.md       # 商品域：搜索、详情、库存
  changes/                # 提议的变更（每个变更一个文件夹）
    <change-name>/
      proposal.md         # 为什么 + 做什么
      specs/              # delta spec（只描述变更部分）
      design.md           # 怎么做（技术方案）
      tasks.md            # 实施清单
      .openspec.yaml      # 变更元数据（可选）
  config.yaml             # 项目配置（可选）
```

**三个关键概念：**

**Specs（领域 spec）**：系统当前行为的真相，**按领域（domain）组织**。每个 domain 是一个功能域（如用户、订单、商品），其 `spec.md` 描述该领域当前的全部行为。使用 RFC 2119 关键词（SHALL / MUST / SHOULD）和 Given/When/Then 格式。当你做变更时，delta spec 只描述某个 domain 的变更部分，不动其他 domain 的 spec。

**Changes**：提议的修改。多个 change 可以并行存在互不冲突。

**Delta Specs**（OpenSpec 的核心创新）：**不重写完整 spec，只描述变更部分**：

```markdown
## ADDED Requirements
- 系统 SHALL 支持暗黑模式切换

## MODIFIED Requirements
- 登录流程 MUST 在 3 步内完成（原为 5 步）

## REMOVED Requirements
- ~~系统 SHALL 发送邮件通知~~（改用站内通知）
```

### 2.2 安装

```bash
# npm
npm install -g @fission-ai/openspec

# pnpm（推荐）
pnpm add -g @fission-ai/openspec

# 验证
openspec --version

# 初始化项目
openspec init
```

### 2.3 OPSX 工作流详解

OPSX（OpenSpec eXperience）是 OpenSpec v1.0+ 的工作流，**基于动作而非阶段**——你可以按任何顺序操作任何 artifact。

**快捷路径（core profile，大多数情况用这个）：**

```
/opsx:propose → /opsx:apply → /opsx:archive
```

**展开路径（custom profile，复杂变更用）：**

```
/opsx:new → /opsx:ff 或 /opsx:continue → /opsx:apply → /opsx:verify → /opsx:archive
```

**澄清机制：** OpenSpec **没有独立的澄清命令**（不像 Spec Kit 有 `/speckit.clarify`）。澄清逻辑内嵌在 `/opsx:propose` 流程中——AI 在生成 proposal 时会先分析现有 spec 和你的需求描述，自动识别模糊点并提问，然后才生成完整 artifact。如果你需要更可控的澄清过程，可以用 custom profile 的 `/opsx:new` → `/opsx:continue` 逐步模式，proposal 阶段同样包含澄清逻辑。

**全命令参考：**

| 命令 | 用途 | Profile |
|---|---|---|
| `/opsx:propose` | 一步创建 change + 所有规划 artifact | core |
| `/opsx:explore` | 思考/调研/比较方案（不产生 artifact） | core |
| `/opsx:apply` | 按 tasks.md 执行实施 | core |
| `/opsx:archive` | 完成变更，合并 delta spec，归档 | core |
| `/opsx:new` | 新建变更脚手架 | custom |
| `/opsx:continue` | 创建下一个 artifact（逐一） | custom |
| `/opsx:ff` | 快进：一次性创建所有规划 artifact | custom |
| `/opsx:verify` | 三维度验证（完整性/正确性/一致性） | custom |
| `/opsx:sync` | 手动合并 delta spec 到对应 domain 的主 spec | custom |
| `/opsx:bulk-archive` | 批量归档，带冲突检测 | custom |
| `/opsx:onboard` | 引导式教程（15-30 分钟） | custom |

**archive 和 sync 的合并机制：** 两者都是按 domain 合并。一个 change 的 delta spec 如果修改了 `user/` 域，只会合并到 `openspec/specs/user/spec.md`，不会动其他 domain 的 spec。`/opsx:archive` 是 sync 的自动化版本——除了合并 delta spec，还会把 change 文件夹移到 `changes/archive/` 保留完整历史。

```text
changes/add-dark-mode-pref/
  specs/
    user-spec.md            # delta: ADDED 暗黑模式偏好
                               ↓ archive/sync
openspec/specs/
  user/spec.md              # 只更新这个文件
  order/spec.md             # 不动
  product/spec.md           # 不动
```

**命令触发方式：** 和 Spec Kit 一样，OpenSpec 的所有命令都是👤主动触发（人工输入）。不存在 AI 自动触发的命令。澄清是唯一带"自动感"的行为——但严格来说澄清不是独立命令，而是 `/opsx:propose` 执行过程中的内嵌逻辑。

| 命令 | 触发方式 | 说明 |
|---|---|---|
| `/opsx:propose` | 👤 主动 | 手动输入，AI 一步生成所有规划 artifact（含内嵌澄清） |
| `/opsx:explore` | 👤 主动 | 手动输入，AI 调研分析 |
| `/opsx:apply` | 👤 主动 | 手动输入，AI 按 tasks 执行 |
| `/opsx:archive` | 👤 主动 | 手动输入，合并 delta + 归档 |
| `/opsx:new` | 👤 主动 | 手动输入，创建变更脚手架 |
| `/opsx:continue` | 👤 主动 | 手动输入，生成下一个 artifact |
| `/opsx:ff` | 👤 主动 | 手动输入，快进生成所有 artifact |
| `/opsx:verify` | 👤 主动 | 手动输入，三维度验证 |
| `/opsx:sync` | 👤 主动 | 手动输入，合并 delta 到主 spec |
| `/opsx:bulk-archive` | 👤 主动 | 手动输入，批量归档 |
| `/opsx:onboard` | 👤 主动 | 手动输入，引导教程 |

### 2.4 CLI 命令

```bash
# 浏览
openspec list                          # 列出所有变更
openspec view                          # 交互式 dashboard
openspec show <change>                 # 查看变更详情

# 验证
openspec validate                      # 校验 artifact 完整性
openspec validate --json               # JSON 输出（CI 用）

# 生命周期
openspec archive <change>              # 归档变更

# 状态和指引
openspec status                        # 当前项目状态
openspec instructions <artifact> --json # 获取 AI 指令（含模板+上下文）
```

### 2.5 Schema 系统（自定义工作流）

OpenSpec 的自定义机制是 **Schema**——用 YAML 定义 artifact 类型和依赖关系：

```bash
# Fork 内置 schema
openspec schema fork spec-driven my-workflow

# 从零创建
openspec schema init research-first --artifacts "research,proposal,tasks"
```

内置 schema 的依赖图：

```
proposal（根）
    ├── specs
    └── design
        └── tasks
```

**依赖是"使能者"而非"门禁"**——显示哪些 artifact 可以创建，而非强制顺序。不需要的 artifact 可以跳过。

Schema 存放位置（优先级从高到低）：

| 位置 | 用途 |
|---|---|
| `openspec/schemas/<name>/` | 项目级（随项目提交） |
| `~/.local/share/openspec/schemas/<name>/` | 用户级（跨项目共享） |
| npm 包内置 | 默认 |

### 2.6 项目配置

`openspec/config.yaml` 支持三个级别的定制：

```yaml
schema: spec-driven           # 默认工作流 schema
context: |                     # 注入所有 artifact 的项目上下文
  Tech stack: TypeScript, React, Node.js, PostgreSQL
  API style: RESTful
  Testing: Jest + React Testing Library
rules:                         # 按 artifact 注入规则
  proposal:
    - Include rollback plan
    - Identify affected teams
  specs:
    - Use Given/When/Then format
  design:
    - Include sequence diagrams for complex flows
```

### 2.7 适用场景

| 场景 | 推荐度 | 理由 |
|---|---|---|
| 棕地项目（已有代码库做修改） | ⭐⭐⭐ | Delta spec 原生优化棕地场景 |
| 需要并行处理多个变更 | ⭐⭐⭐ | change 文件夹天然隔离，互不冲突 |
| 快速迭代 | ⭐⭐⭐ | 流式工作流，没有阶段门禁 |
| 绿地项目 | ⭐⭐ | 可以用，但 delta spec 的优势不明显 |
| 需要严格阶段控制 | ⭐⭐ | 可以用 custom profile 实现，但不如 Spec Kit 自然 |

---

## 3. 与 Claude Code 规范体系的对比

很多人第一次接触这些工具时会问："这些东西和 CLAUDE.md 有什么区别？不是都在给 AI 写约束吗？"

**答案：形式相似，但本质不同。** 这一章把所有"给 AI 写约束"的机制放在一起对比。

### 3.1 四种约束机制的本质区别

| 维度 | CLAUDE.md | Constitution（Spec Kit） | Config（OpenSpec） | Skills（Superpowers） |
|---|---|---|---|---|
| **是什么** | 项目提示词 | 项目宪法 | 项目配置 | 工作流定义 |
| **谁来写** | 你自己 | AI 引导你写 | 你自己 + 模板 | 插件预设 |
| **内容自由度** | 完全自由 | Nine Articles 框架 | Schema + rules | 14 个固定 skill |
| **AI 能忽略吗** | **能**（建议性质） | **能**（建议性质） | **能**（建议性质） | **不能**（强制执行） |
| **与后续 artifact 联动** | 无 | **有**（所有 spec 受宪法约束） | **有**（context/rules 注入 artifact） | **有**（skill 链式触发） |
| **跨项目复用** | 手动复制 | 随 spec 目录提交 | 随 openspec/ 提交 | 插件自动加载 |
| **适合写什么** | 技术栈、目录约定、禁止事项 | 项目级编码原则 | 工作流规则 + 项目上下文 | 开发流程（brainstorm、TDD、review） |
| **文件位置** | 项目根目录 | `specs/constitution.md` | `openspec/config.yaml` | `~/.claude/plugins/` |

### 3.2 为什么需要 CLAUDE.md 之外的机制

**CLAUDE.md 能做到的事：**

```
✅ 告诉 AI 你的技术栈
✅ 告诉 AI 目录约定
✅ 告诉 AI 禁止事项（不 push main、不硬编码密钥）
✅ 告诉 AI 测试/构建/lint 命令
✅ 写"先写测试再写代码"
```

**CLAUDE.md 做不到的事：**

| 你想做的 | CLAUDE.md | 需要什么 |
|---|---|---|
| 让 AI 在写 spec 前自动识别模糊点 | 写了 AI 也不一定执行 | Spec Kit 的 `/speckit.clarify` |
| 让 spec 之间有统一的约束基线 | 各个 spec 独立，无联动 | Spec Kit 的 Constitution |
| 让变更自动追踪（只写 delta） | CLAUDE.md 无此概念 | OpenSpec 的 Delta Spec |
| 让 AI 必须先写失败测试再写代码 | 写了"先写测试"AI 可以跳过 | Superpowers 的 TDD skill |
| 让 AI 完成后必须跑命令验证 | 写了"跑测试"AI 可以口头说"跑了" | Superpowers 的 verification skill |
| 让 AI 遇到 bug 不瞎猜 | CLAUDE.md 不会改变 AI 的调试行为 | Superpowers 的 systematic-debugging |

### 3.3 Constitution vs CLAUDE.md：详细对比

两者看起来很像——都是"项目级约束文档"。但有关键区别：

| 维度 | CLAUDE.md | Constitution |
|---|---|---|
| **创建方式** | 你自己写 | `/speckit.constitution`，AI 引导你写 |
| **内容范围** | 想写什么写什么 | 固定 Nine Articles 框架（library-first、TDD、simplicity gate...） |
| **约束对象** | AI agent 的通用行为 | **所有后续 spec 文档** |
| **联动机制** | 无。CLAUDE.md 是独立的提示词 | **有**。写 spec 时 AI 会用 Constitution 校验——比如 Constitution 定了"TDD mandatory"，spec 里就不能出现"不需要测试" |
| **修改后** | 改了就改了，无后续效果 | 改了 Constitution 后需要重新 `/speckit.analyze` 检查已有 spec 是否违反新条款 |
| **本质** | 给 AI 的备忘录 | 给整个 spec 体系的法律基线 |

**简单类比**：CLAUDE.md 是"个人备忘录"——你想写什么写什么，AI 读不读看心情。Constitution 是"宪法"——定义了之后，所有法律（spec）都不能违反它。

### 3.4 OpenSpec config.yaml vs CLAUDE.md

| 维度 | CLAUDE.md | OpenSpec config.yaml |
|---|---|---|
| **结构化程度** | 自由格式 Markdown | 结构化 YAML（schema、context、rules） |
| **注入方式** | 整体注入会话 | 按 artifact 精准注入（rules 仅注入匹配的 artifact） |
| **context 字段** | 无此概念 | `context` 注入所有 artifact，`rules` 按 artifact 类型注入 |
| **工作流定义** | 无 | `schema` 字段定义 artifact 依赖图 |

**config.yaml 的优势**：精准注入。CLAUDE.md 是一股脑塞给 AI，config.yaml 可以做到"design artifact 才注入序列图规则，proposal artifact 才注入回滚计划规则"。

### 3.5 应该把约束写在哪？

**实用建议：CLAUDE.md 是基础，其他工具按需叠加。**

```
所有项目（必须有）
└── CLAUDE.md：技术栈、目录约定、禁止事项、关键命令

需要 SDD 时（按需叠加）
├── Spec Kit Constitution：项目级编码原则（Nine Articles）
└── OpenSpec config.yaml：工作流规则 + 精准注入

需要代码纪律时（按需叠加）
└── Superpowers Skills：强制 brainstorm → TDD → review 流程
```

| 约束内容 | 写在哪 | 理由 |
|---|---|---|
| 技术栈、目录约定 | CLAUDE.md | 基础信息，所有项目都需要 |
| 禁止事项（不 push main、不硬编码密钥） | CLAUDE.md | 全局规则 |
| 测试/构建/lint 命令 | CLAUDE.md | AI 每次都需要 |
| 项目编码原则（library-first、anti-abstraction） | Constitution | 约束所有后续 spec |
| 按 artifact 的精准规则 | OpenSpec config.yaml | 只注入给匹配的 artifact |
| 强制 TDD / review / verification | Superpowers | 文档管不了，必须用工作流 |

---

## 4. 对比与选型（含 Superpowers）

### 4.1 三个工具的本质区别

| 维度 | Spec Kit | OpenSpec | Superpowers |
|---|---|---|---|
| **解决什么问题** | 需求管理（把需求写清楚） | 变更管理（管增量改动） | 代码纪律（强制高质量流程） |
| **管什么阶段** | 开发前的规划 | 开发中的变更追踪 | 开发执行全过程 |
| **核心手段** | Spec 是 source of truth | Delta spec 描述变更 | 强制 brainstorm → TDD → review |
| **本质** | 文档（AI 可以忽略） | 文档（AI 可以忽略） | 工作流（AI 绕不过去） |
| **Stars** | 90.8K | 42.9K | 167K |
| **出品方** | GitHub | Fission-AI | Jesse Vincent |
| **语言** | Python | TypeScript | Shell |
| **License** | MIT | MIT | MIT |

> ⚠️ **关键理解**：CLAUDE.md、Constitution、config.yaml 都是"建议"——AI 可以选择忽略。Superpowers 的 skill 是**工作流**——AI 必须按步骤走，绕不过去。

### 4.2 各工具的优势场景与理由

#### Superpowers 的优势场景

| 场景 | 理由 |
|---|---|
| ⭐ **重构项目** | 重构最怕"改着改着行为变了不知道"。Superpowers 强制 TDD 先写测试保护现有行为，再改代码，改完 verification 必须跑命令验证。CLAUDE.md 写"先写测试"AI 可以忽略，Superpowers 的 TDD skill 绕不过去 |
| ⭐ **长期项目 / 核心业务** | brainstorming 苏格拉底式追问帮你把方案想透，systematic-debugging 遇到 bug 不瞎猜而是根因分析，verification-before-completion 不允许口头说"搞定了"。这些是产出高质量代码的核心保障 |
| ⭐ **团队统一 AI 行为** | 团队成员的 CLAUDE.md 各不相同，Superpowers 统一强制流程，确保所有人用 AI 的方式一致 |
| 多人协作 PR 频繁 | code review 自动触发，按严重性分级，关键问题阻塞流程 |

**为什么 CLAUDE.md 不够？**

| 维度 | CLAUDE.md | Superpowers |
|---|---|---|
| 本质 | 文档，AI 可以忽略 | 工作流，AI 绕不过去 |
| brainstorm | 不会自动触发 | 自动苏格拉底式追问 |
| TDD | 写了"先写测试"AI 可以跳过 | 强制 RED-GREEN-REFACTOR |
| bug 处理 | AI 容易瞎猜改 | 4 阶段根因分析 |
| 宣称完成 | AI 可以口头说"搞定了" | 必须跑命令验证 |
| code review | 不会自动触发 | 自动触发 + 严重性分级 |

#### Spec Kit 的优势场景

| 场景 | 理由 |
|---|---|
| ⭐ **绿地项目（从零开始）** | 全新项目没有历史 spec，Spec Kit 的完整 spec 文档最适合从零定义系统行为。Constitution（Nine Articles）帮团队在项目初期就建立统一约束基线 |
| ⭐ **团队协作 / 多人定义需求** | Constitution 机制确保所有人对"什么是好代码"有一致理解（library-first、TDD、simplicity gate 等），避免各写各的。**注意：Constitution 比 CLAUDE.md 强在联动**——后续所有 spec 自动受宪法约束，CLAUDE.md 没有这种联动 |
| 大型功能 / 需求复杂 | `/speckit.clarify` 独立澄清步骤帮你在 plan 之前把模糊点全部扫清，减少后续返工 |
| 需要跨 artifact 一致性检查 | `/speckit.analyze` 自动检查 spec、plan、tasks 之间是否有矛盾 |

#### OpenSpec 的优势场景

| 场景 | 理由 |
|---|---|
| ⭐ **棕地项目（已有代码库做修改）** | Delta spec 只描述 ADDED/MODIFIED/REMOVED，不需要重写整个系统的 spec。这是 OpenSpec 相比 Spec Kit 的核心杀手锏 |
| ⭐ **频繁小改动 / 快速迭代** | 流式工作流没有阶段门禁，`/opsx:propose` → `/opsx:apply` → `/opsx:archive` 三步搞定。启动成本最低 |
| ⭐ **并行处理多个功能** | 每个 change 独立文件夹，天然隔离互不冲突。`/opsx:bulk-archive` 批量归档带冲突检测 |
| 需求频繁变更 | Delta spec 天然标记 MODIFIED/REMOVED，不需要重写原始 spec。Archive 时合并到主 spec，历史可追溯 |
| 想快速试水 SDD | `npm install -g @fission-ai/openspec` + `openspec init` 几秒完成，无 Constitution 等前置步骤 |

### 4.3 核心差异（Spec Kit vs OpenSpec）

| 维度 | Spec Kit | OpenSpec |
|---|---|---|
| **哲学** | 阶段式，先想清楚再做 | 流式，边想边做随时调 |
| **Spec 格式** | 完整文档 | Delta（只写变更） |
| **对棕地** | 可以，但要写完整 spec | **原生优化** |
| **对绿地** | **原生优化** | 可以，delta 优势弱 |
| **自定义** | 扩展 API + 社区生态 | Schema YAML（更轻量） |
| **启动成本** | 中（需要 constitution + spec） | 低（`openspec init` 几秒完成） |
| **Constitution** | 有（Nine Articles） | 无 |
| **澄清** | 独立命令 `/speckit.clarify`，显式执行 | 内嵌在 `/opsx:propose` 中，自动进行 |
| **并行变更** | Git branch 隔离 | 原生支持多个 change 文件夹 |
| **验证** | `/speckit.analyze` + `/speckit.checklist` | `/opsx:verify`（三维度） |
| **社区生态** | 较大（GitHub 出品加持） | 较小但活跃 |

### 4.4 选型决策树

```
你最关心什么？
├── 代码质量 / 重构 / 长期项目
│   └── Superpowers（强制 TDD + review + verification，绕不过去）
│
├── 需求管理（把需求写清楚再动手）
│   ├── 绿地项目 / 团队协作
│   │   └── Spec Kit（Constitution 统一规范，完整 spec 理清全局）
│   └── 棕地项目 / 快速迭代
│       └── OpenSpec（Delta spec 只写变更，启动最快）
│
└── 既要质量又要规划？
    └── Superpowers + OpenSpec 组合
        Superpowers 管代码纪律，OpenSpec 管变更追踪
        ⚠️ 不要同时装 Superpowers 的 planning 和 Spec Kit 的 planning
```

**一句话选型建议：**

- **重构 / 长期项目 / 追求高质量** → Superpowers（强制纪律产出高质量代码）
- **绿地项目 / 团队协作 / 重视需求规范** → Spec Kit（Constitution + 完整 spec）
- **棕地项目 / 频繁小改动 / 快速迭代** → OpenSpec（Delta spec 是杀手锏）
- **不确定 / 想快速试水** → OpenSpec（安装几秒，三步上手）
- **质量 + 变更管理都要** → Superpowers + OpenSpec（一个管纪律，一个管变更）

### 4.5 组合使用的注意事项

⚠️ **不要装两套规划系统**：Superpowers 的 brainstorming + writing-plans 和 Spec Kit 的 specify + plan 功能重叠，同时装会让 AI agent 在两个工作流之间混乱。选一套规划工具即可。

✅ **推荐组合**：

| 组合 | 各自职责 | 适用场景 |
|---|---|---|
| **Superpowers 单独使用** | 规划 + 纪律一把抓 | 大多数项目，尤其是重构 |
| **Superpowers + OpenSpec** | Superpowers 管纪律，OpenSpec 管变更追踪 | 大型棕地项目 + 高质量要求 |
| **Spec Kit 单独使用** | 需求管理 + 轻量执行 | 绿地项目，不强制 TDD |
| **OpenSpec 单独使用** | 变更管理 + 轻量执行 | 棕地快速迭代，不强制 TDD |

### 4.6 Spec Kit 的平铺 spec vs OpenSpec 的累积 spec

表面看起来两者很像——都是"一个功能一个文件夹"，每个 spec 都只写新功能的 WHAT 和 WHY。但**组织方式和 spec 的生命周期**有关键区别。

**核心区别：spec 的组织模型不同。**

| 维度 | Spec Kit | OpenSpec |
|---|---|---|
| **spec 组织** | 按功能编号平铺（`001-`、`002-`） | 按领域累积（`user/`、`order/`） |
| **spec 之间** | 完全独立，不互相关联 | 同一领域共享一个 spec，通过 delta 更新 |
| **spec 演化** | 每个 spec 是一次性产物 | 主 spec 随变更不断累积更新 |
| **增量开发** | 每次创建一个全新的独立 spec | delta spec 只写变更，archive 后合并到主 spec |

**举个例子**：假设电商系统，先做了用户注册功能，后来又给用户加了暗黑模式偏好。

**Spec Kit 的做法**——平铺的独立 spec：

```
specs/
  constitution.md
  001-user-registration/
    spec.md           # 用户注册的完整需求（独立文档）
    plan.md
    tasks.md
  002-dark-mode-preference/
    spec.md           # 暗黑模式偏好的完整需求（独立文档）
    plan.md           # ← Constitution Check 在这个阶段生效
    tasks.md
```

每个 spec 独立，不引用其他 spec。`002-dark-mode-preference/spec.md` 只写暗黑模式偏好本身的需求，**不会重写** `001-user-registration/spec.md` 的内容。但两者之间也没有关联——如果你想知道"用户模块整体的行为"，需要自己把 001 和 002 的 spec 拼起来看。

**OpenSpec 的做法**——累积的领域 spec：

```
openspec/
  specs/
    user/spec.md      # 用户领域的完整行为真相（持续累积）
  changes/
    add-registration/
      specs/          # delta: ADDED 用户注册相关需求
      tasks.md
    add-dark-mode-pref/
      specs/          # delta: ADDED 暗黑模式偏好需求
      tasks.md
  changes/archive/
    2026-04-20-add-registration/   # archive 后，delta 已合并到 user/spec.md
    2026-04-25-add-dark-mode-pref/
```

`user/spec.md` 始终是"用户领域当前行为的完整真相"。每次 archive，delta 自动合并进去。你想知道"用户模块整体的行为"，只需看 `user/spec.md`，不需要翻历史。

**Constitution 和 Delta Spec 解决的是不同层面的问题**：

| 问题 | Spec Kit 怎么做 | OpenSpec 怎么做 |
|---|---|---|
| 全局原则约束 | Constitution 在 plan 阶段强制检查 | config.yaml 的 rules 注入 artifact |
| 跨功能一致性 | Constitution Check 门禁（违反需填表说明） | 主 spec 作为真相，delta archive 后自动合并 |
| 了解系统整体 | 需要翻多个独立 spec 拼凑 | 按领域看 spec，每个 domain 都是完整的 |
| 历史追溯 | 每个 spec 独立存在，编号即历史 | `changes/archive/` 保留完整变更历史 |

**简单类比**：
- Spec Kit = 一摞独立的合同，每份合同是一个功能，互不引用
- OpenSpec = 一本按领域组织的活字典，每次变更更新字典内容，但保留修改记录

---

## 5. 日常开发工作流（按场景）

### 5.0 核心决策模型

SDD 工具的介入程度取决于任务复杂度：

```
是简单任务吗？
  └─ YES → 不需要 SDD 工具，直接让 AI 写代码
  └─ NO  → 改动涉及多个模块吗？
              └─ YES → 用 SDD 工具（先 spec 再实现）
              └─ NO  → 改动会不会影响其他功能？
                         └─ YES → 用 SDD 工具（spec 帮你理清影响面）
                         └─ NO  → 可以不用，直接改
```

| 情况 | 是否需要 SDD | 推荐工具 |
|---|---|---|
| 单文件 bug 修复 | ❌ | 直接让 AI 改 |
| 单文件小功能 | ❌ | 直接让 AI 改 |
| 跨 2-3 个模块的功能 | ✅ | OpenSpec（轻量） |
| 大型新功能 / 新模块 | ✅ | Spec Kit 或 OpenSpec 均可 |
| 架构级重构 | ✅ | Superpowers（强制 TDD + verification） |
| 团队协作的大型需求 | ✅ | Spec Kit（Constitution 保一致性） |

### 5.1 绿地项目：从零开始建新系统

**Spec Kit 路径（推荐）：**

```
specify init my-project --ai claude       ← 初始化
    ↓
/speckit.constitution                     ← 建立项目原则（Nine Articles）
    ↓
/speckit.specify                          ← 描述要建什么（只写 WHAT/WHY）
    ↓
/speckit.clarify                          ← 澄清模糊点
    ↓
/speckit.plan                             ← 生成技术方案
    ↓
/speckit.tasks                            ← 拆任务（2-5 分钟粒度）
    ↓
/speckit.implement                        ← 逐项执行
    ↓
/speckit.analyze                          ← 一致性检查
```

**OpenSpec 路径（更轻量）：**

```
openspec init                             ← 几秒初始化
    ↓
/opsx:propose                             ← 一步生成 proposal + specs + design + tasks
    ↓
审查 artifact                             ← 检查 AI 生成的规划是否合理
    ↓
/opsx:apply                               ← 执行
    ↓
/opsx:archive                             ← 归档，spec 成为系统真相
```

### 5.2 棕地项目：给现有系统加功能

**OpenSpec 路径（推荐，delta spec 是杀手锏）：**

```
openspec init                             ← 首次初始化（已初始化则跳过）
    ↓
/opsx:explore                             ← 可选：先调研影响面
    ↓
/opsx:propose                             ← 描述变更，自动生成 delta spec
    ↓                                       delta spec 只写 ADDED/MODIFIED/REMOVED
    ↓                                       不需要重写整个系统的 spec
    ↓
审查 delta spec                           ← 确认变更范围是否合理
    ↓
/opsx:apply                               ← 执行
    ↓
/opsx:archive                             ← delta 合并到主 spec，保留审计历史
```

**Spec Kit 路径（适合大改动）：**

```
/speckit.specify                          ← 描述新功能需求
    ↓
/speckit.clarify                          ← 澄清与现有系统的交互
    ↓
/speckit.plan                             ← 技术方案（需说明与现有代码的关系）
    ↓
/speckit.tasks                            ← 拆任务
    ↓
/speckit.implement                        ← 执行
```

### 5.3 并行处理多个功能

**OpenSpec 天然支持：**

```
/opsx:propose add-dark-mode               ← 变更 A
/opsx:propose fix-login-redirect          ← 变更 B（同时进行，互不冲突）
    ↓
/opsx:apply add-dark-mode                 ← 先做 A
/opsx:apply fix-login-redirect            ← 再做 B
    ↓
/opsx:bulk-archive                        ← 批量归档，自动检测冲突
```

**Spec Kit 用 Git branch 隔离：**

```
/speckit.specify（feature A）→ /speckit.plan → /speckit.tasks → 切 branch → implement
/speckit.specify（feature B）→ /speckit.plan → /speckit.tasks → 切 branch → implement
    ↓
合并时手动解决冲突
```

### 5.4 Bug 修复（简单）

**不需要 SDD 工具。** 直接让 AI 改：

```
Fix the null pointer error in UserService.java line 42
```

### 5.5 Bug 修复（复杂 / 根因不明）

**OpenSpec 路径（推荐）：**

```
/opsx:explore                             ← 先调研，分析根因
    ↓
/opsx:propose                             ← 描述修复方案，生成 delta spec
    ↓                                       delta 只描述修复部分，不会过度改动
    ↓
/opsx:apply                               ← 执行
    ↓
/opsx:archive                             ← 归档
```

**Spec Kit 路径：**

```
/speckit.specify                          ← 描述 bug 的期望行为 vs 实际行为
    ↓
/speckit.clarify                          ← 澄清触发条件和影响范围
    ↓
/speckit.plan → /speckit.tasks → /speckit.implement
```

### 5.6 重构

**Superpowers 路径（推荐，强制 TDD + verification）：**

```
你提需求 → brainstorming 自动触发        ← 苏格拉底式追问，理清重构目标和风险
    ↓
writing-plans 自动触发                    ← 拆解为 2-5 分钟任务
    ↓
你批准 plan → executing-plans             ← 逐任务执行
    ↓
TDD 自动强制                              ← 先写失败测试保护现有行为 → 再重构 → 跑测试通过
    ↓
遇到 bug → systematic-debugging           ← 不瞎猜，4 阶段根因分析
    ↓
即将宣称完成 → verification               ← 必须跑命令验证，不能口头说"搞定了"
    ↓
requesting-code-review                    ← 自动 code review，按严重性分级
```

**Spec Kit 路径（完整 spec 理清全局）：**

```
/speckit.specify                          ← 描述重构目标和约束
    ↓                                       "保持外部行为不变，改善内部结构"
    ↓
/speckit.clarify                          ← 识别依赖关系和风险点
    ↓
/speckit.plan                             ← 重构方案（分阶段、可回滚）
    ↓
/speckit.tasks                            ← 每个重构步骤独立可验证
    ↓
/speckit.implement                        ← 逐步执行
    ↓
/speckit.analyze                          ← 确保行为不变
```

### 5.7 需求变更（改已完成的功能）

**OpenSpec 路径（推荐，delta spec 天然适合）：**

```
/opsx:propose                             ← 描述需求变更
    ↓                                       delta spec 自动标记为 MODIFIED/REMOVED
    ↓                                       不需要重写原始 spec
    ↓
/opsx:apply                               ← 执行修改
    ↓
/opsx:archive                             ← delta 合并到主 spec，历史可追溯
```

### 5.8 场景速查表

| 场景 | 推荐工具 | 第一个命令 | 关键点 |
|---|---|---|---|
| 绿地项目 | Spec Kit | `/speckit.constitution` | 先建宪法再写 spec |
| 棕地加功能 | OpenSpec | `/opsx:propose` | Delta spec 只写变更 |
| 并行多功能 | OpenSpec | `/opsx:propose` × N | 每个 change 独立文件夹 |
| 简单 bug 修复 | 不需要 | 直接描述 | 不引入 SDD 开销 |
| 复杂 bug | OpenSpec | `/opsx:explore` | 先调研再 propose |
| 大重构 | **Superpowers** | 直接提需求 | 强制 TDD + verification |
| 需求变更 | OpenSpec | `/opsx:propose` | Delta 自然标记变更 |
| 团队新需求 | Spec Kit | `/speckit.constitution` | Constitution 统一规范 |

---

## 6. 反模式

### 6.1 通用反模式

| 反模式 | 为什么不好 | 正确做法 |
|---|---|---|
| spec 里写 HOW（技术实现） | 限制方案选择，spec 和代码耦合 | spec 只写 WHAT 和 WHY |
| 写完 spec 就不管了 | spec 和代码很快脱节 | 每次变更都更新 spec |
| 跳过 clarify 直接 plan | 模糊需求导致返工 | 先 clarify 再 plan |
| 把 spec 当作文档库 | 变成没人看的死文档 | spec 是活文档，每次变更都走 spec 流程 |
| CLAUDE.md 里写"先写测试"就以为够了 | AI 可以忽略，实际上经常跳过 | 要强制 TDD 就用 Superpowers |
| Constitution 和 CLAUDE.md 写重复内容 | 维护两份，容易不一致 | CLAUDE.md 写技术事实，Constitution 写原则 |

### 6.2 Spec Kit 特有反模式

| 反模式 | 为什么不好 |
|---|---|
| 跳过 Constitution 直接写 spec | 后续 spec 缺少约束基线 |
| 一个 spec 塞太多功能 | 难以管理，建议拆分 |
| 不用 `/speckit.analyze` | artifact 之间矛盾没被发现 |

### 6.3 OpenSpec 特有反模式

| 反模式 | 为什么不好 |
|---|---|
| 不 archive 完成的 change | delta spec 不会合并到主 spec，spec 逐渐过时 |
| 给 change 起模糊名字（`feature-1`、`update`） | 难以追踪和回溯 |
| 在一个 change 里塞多个不相关改动 | 破坏变更的原子性 |
| 不用 `/opsx:verify` 就 archive | 实现可能偏离 spec |

### 6.4 OpenSpec 的变更命名建议

```
✅ 好名字：add-dark-mode、fix-login-redirect、optimize-product-query
❌ 坏名字：feature-1、update、changes、wip
```

---

## 7. 快速上手路径

### 7.1 Spec Kit 快速上手（5 分钟）

```bash
# 1. 安装并初始化
uvx --from git+https://github.com/github/spec-kit.git specify init my-project --ai claude

# 2. 在 AI agent 中依次执行
/speckit.constitution     # 建立项目原则
/speckit.specify          # 描述你要建什么
/speckit.clarify          # 澄清模糊点
/speckit.plan             # 生成技术方案
/speckit.tasks            # 拆任务
/speckit.implement        # 执行
```

### 7.2 OpenSpec 快速上手（3 分钟）

```bash
# 1. 安装并初始化
npm install -g @fission-ai/openspec
openspec init

# 2. 在 AI agent 中执行
/opsx:onboard             # 引导教程（首次推荐）
# 或者直接开始
/opsx:propose             # 描述变更 → 自动生成所有规划 artifact
/opsx:apply               # 执行实施
/opsx:archive             # 归档，合并 delta spec
```

---

## 8. 一句话总结

> **CLAUDE.md 管基础约定，Spec Kit / OpenSpec 管需求规划，Superpowers 管代码纪律——三者各司其职。** 需求规划选 Spec Kit（绿地）或 OpenSpec（棕地），代码质量靠 Superpowers 强制流程，CLAUDE.md 是所有项目的基线。

---

**相关文档：**

- [Claude Code 使用最佳实践指南](../claudecode/Claude%20Code%20使用最佳实践指南.md)
- [Superpowers 使用最佳实践指南](../superpower/Superpowers%20使用最佳实践指南.md)
- [OpenCode + omo 使用最佳实践指南](../opencode/📚 OpenCode + Oh My OpenCode 使用最佳实践指南.md)
- [Harness Engineering 概念与实践指南](../harness-engineering/Harness%20Engineering%20概念与实践指南.md)
