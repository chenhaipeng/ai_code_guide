# Vibe Coding Agent 最佳实践指南

> 整理时间：2026-05-03
> 信息来源：实测核验 [WeFI-TECH/vibe-coding-agents](https://github.com/WeFI-TECH/vibe-coding-agents) 主仓 README、DESIGN_PHILOSOPHY、各 agent AGENTS.md、PIPELINE 设计文档、HARNESS_REFERENCE_CONFIG、9 轮跨组合实验数据

---

## 0. 它是什么 / 不是什么

### 0.1 一句话定位

> **Vibe Coding Agents 是一套"银行级 AI 编码 SOP 流水线框架"**，定义 7 个专一职责的 agent 角色 + 2 个 pipeline（`/vibe-req` 和 `/vibe-coding`）+ 3 个人类介入点，把业务需求→代码→审查→决策的全流程数字化、可审计，且模型/工具中性。

| 属性 | 值 |
|---|---|
| 仓库 | [WeFI-TECH/vibe-coding-agents](https://github.com/WeFI-TECH/vibe-coding-agents) |
| License | MIT |
| 核心形态 | Markdown 框架（CC slash command + subagent 定义） |
| 当前版本 | V2.9（PRD 结构化 agent）+ V2.10（多系统群 Architect） |
| 适用场景 | 受监管行业（银行/医疗/电信）、跨团队协作、需要审计 trace |
| 不适用场景 | typo 修复、探索性 demo、单文件 hotfix |

### 0.2 它不是什么

- **不是通用 AI 编码工具**（不和 Cline / Cursor / Aider 同层；它是装在这些工具之上的 SOP 框架）
- **不是 vendor lock-in**（角色定义跟 LLM/harness 解耦；5 种 harness preset 可选）
- **不是全自动 AI 编码**（3 个人类介入点不可跳过；AI 执行，人类决策）
- **不是替代 PR review**（Gate 2 approve 后仍走传统 CI/CD + PR 流程）
- **不是轻量工具**（5-9 个 repo 联动、30 分钟起跑，适合复杂需求而非日常小改）

### 0.3 核心价值主张

| 对比维度 | 通用 AI 工具（Cline/Cursor） | Vibe Coding Agents |
|---|---|---|
| 可审计的决策过程 | ❌ | ✅ PRD→tech_spec→diff→review→briefing 全链路可追溯 |
| Don't-touch 红线强制 | ❌ | ✅ Checker 强制 grep 检查红名单，违规直接 REJECT |
| 跨团队 scope 切分 | ❌ | ✅ SA Agent 强制标注 OUT-OF-SCOPE |
| 跨 LLM 族对抗审稿 | ❌ | ✅ Maker 和 Checker 用不同 LLM lineage |
| 任意 harness/LLM | ❌ vendor lock | ✅ 5 种 harness preset |
| Fabrication 防御 | ❌ 靠人审 | ✅ Checker Category A grep 验证每个新 symbol |

---

## 1. 核心架构：七条设计原则

基于 9 轮跨 LLM 组合实验数据提炼的设计信念：

### 原则 1：抑制错误胜于修复错误

Pipeline 设计成"AI 难做错"——每个 agent 都有 HARD-GATE（编程式约束），违反则 abort，而不是产出垃圾让下游处理。

**实测依据**：9 个 run 中，框架硬规则（don't-touch enforcement + fabrication grep）成功把 budget-tier LLM 的质量拉到 mid-tier 水平。

### 原则 2：人类决策，AI 执行

AI 不替人类做业务决策（PRD 内容取舍），不替人类做接受决策（代码 merge）。

**三个不可跳过的人类介入点**：

| Gate | 位置 | 决策 |
|---|---|---|
| PRD Review | PO 输出 PRD 后 | GitHub PR review |
| Gate 1 | SA 输出 tech_spec 后 | approve / edit / bounce-to-PO / abort |
| Gate 2 | Insight 输出 briefing 后 | approve(MERGE) / 回 Maker / 回 SA / abort |

### 原则 3：工具中性 / 模型中性

角色定义（`AGENTS.md`）不绑定具体 LLM 或 harness。3 年换 5 代模型不用重写角色定义。

### 原则 4：可审计性是默认输出

任何一行代码改动可追溯到："哪份 PRD → 哪次 SA 转换 → 哪次 Maker 实现 → 哪个人类在 Gate N 拍板"。

### 原则 5：跨族对抗审稿

Maker 和 Checker 必须用不同 LLM lineage。

**实测依据**：

| Tier | 自审表现 | 说明 |
|---|---|---|
| Top（Sonnet/GPT-5） | 5/5 干净 | 自审够用 |
| Mid（DeepSeek/GLM） | 3/3 干净 | 含 1 次抓真问题 |
| Budget（mimo/qmodel） | 1/2 漏，1/2 翻车 | **必须跨族** |

### 原则 6：专家流水线，不要通才

7 个专一职责 agent 串联，不靠一个 super agent 端到端。单 agent 失败不污染整链。

### 原则 7：分层切片

四层独立 repo：业务需求 / 方法论 / 系统知识 / 代码，各层 owner、生命周期、变更频率不同。

---

## 2. 7 个 Agent 角色

### 2.1 角色总览

| Agent | Pipeline | 职责 | 类比 |
|---|---|---|---|
| **PO** | vibe-req | 非结构化业务输入 → 结构化 PRD | 产品经理助理 |
| **SA** | vibe-req | PRD → 系统 tech_spec，可 bounce 回 PO | 系统分析师 |
| **Architect** | vibe-req（多系统时） | 跨系统 design review | 跨系统架构审查 |
| **Maker** | vibe-coding | tech_spec → 代码 + 单元测试 + 自测 | 开发 |
| **Tester** | vibe-coding | 跑 build + 测试，PASS/FAIL | 自动化测试 |
| **Checker** | vibe-coding | 静态审稿（5 类违规检测） | 代码审稿员 |
| **Insight** | vibe-coding | 综合所有 stage 产出，写 1 页 briefing | Tech Lead briefing |
| **Conductor** | 异常处理 | worker 失败时 triage + 决策 | Incident handler |

### 2.2 Agent 定义的文件结构

每个 agent 由 4 个文件定义（总和 < 25KB，保持注意力聚焦）：

```
<role>-agent/
├── AGENTS.md           # 角色定义 + HARD-GATE（≤5-7KB）
├── INPUT_SCHEMA.md     # 输入协议（≤6KB）
├── OUTPUT_SCHEMA.md    # 输出协议（≤6KB）
└── DEPLOYMENT.md       # 部署假设（≤4KB）
```

### 2.3 每个 Agent 的 HARD-GATE 机制

**HARD-GATE = 不可绕过的硬性约束**。违反即 BLOCKED/REJECT，不是"建议"。

| Agent | 关键 HARD-GATE |
|---|---|
| **SA** | 不写代码；不做业务决策；必须引用 codebase 证据；必须列 Out-of-scope |
| **Maker** | 不碰 don't-touch 区；不编造 symbol；必须写单元测试；必须自测；必须 commit |
| **Tester** | 只跑 build + 测试；不修代码 |
| **Checker** | 只读不写；不跑代码；必须是 adversarial（默认怀疑）；每个发现必须 cite file:line |
| **Insight** | 不替人类做 routing 决策 |

---

## 3. 两条 Pipeline

### 3.1 vibe-req（业务需求结构化）

```
[原始业务输入]
  邮件 / Google Doc / Figma / Confluence / 口述 / Slack / Jira
          ↓
    [PO Agent] → 结构化 PRD
          ↓ PR review（PRD owner + dev tech lead）
          ↓ merge
    [SA Agent] → tech_spec
          ├─ VALID/PARTIAL → Gate 1
          └─ BOUNCE-TO-PO → Gate 1 → 退回 PO 修正
          ↓ PR review（dev tech lead）
          ↓ merge
    ★ vibe-req 终点 = vibe-coding 起点
```

**PO ↔ SA bounce loop**：SA 发现 PRD 有以下问题时可 bounce：
- Unimplementable（grep 找不到声称的 service）
- Doesn't match reality（PRD 跟 codebase 实际不符）
- Internal conflicts（PRD 自相矛盾）
- Missing critical info（blocker 级缺失）
- Cross-PRD conflict（跟其他 active PRD 冲突）

### 3.2 vibe-coding（代码生成 + 审查）

```
tech_spec.md
      ↓
[Maker] ←── FAIL auto-retry（max 3）──┐
   ↓                                  │
[Tester] ─────────────────────────────┘
   ├─ PASS → [Checker] → [Insight] → ══ Gate 2 ══
   └─ STUCK after 3 → [Insight] → Gate 2
                                        ↓
                                    代码 PR
```

**关键设计决策**：
- Tester FAIL 自动回 Maker，不打扰人类（3 次都 FAIL 才升级）
- Tester PASS 才跑 Checker（跑不通的代码不值得花 Checker 5-11 min）
- Conductor 只管 worker 异常，不管 routing

### 3.3 多系统扩展（V2.10）

当 PRD 涉及多个系统群时，先分别运行各系统 SA，再由 Architect 做 cross-review：

```
PRD → [SA x N] → [Architect → design-review.md] → Gate 1 → [Maker x N]
```

Architect **detects, doesn't design**——只标 BLOCKER/WARNING/INFO。

---

## 4. Checker 的五类审查（核心防御机制）

| Category | 检测内容 | 方法 | Verdict 影响 |
|---|---|---|---|
| **A — Fabrication** | 新引入的 symbol 是否真实存在 | 逐个 grep 验证 | fabrication > 0 → REJECT |
| **B — Don't-touch** | diff 是否触碰红名单文件 | 文件列表 vs 红名单 pattern | violation > 0 → REJECT |
| **C — Convention** | 是否遵循项目编码规范 | 对照 AGENTS.md 约定 | 建议 |
| **D — Scope drift** | 是否改了 spec 没说的文件 | diff 文件 vs spec item 表 | drift > 0 → NEEDS-CHANGES |
| **E — Test substance** | 测试是否有实质断言 | 检测 assertNotNull-only 测试 | theater > 0 → NEEDS-CHANGES |

**Verdict 规则**：

```
fabrication > 0 OR dont_touch > 0 → REJECT
scope_drift > 0 OR test_theater > 0 → NEEDS-CHANGES
else → APPROVE
```

---

## 5. 四层 Repo Hierarchy — 完整目录结构

### 5.1 四层总览

```
Layer 1: 业务层（1 repo，跨系统）      ← business-prds
              PRD，owner = Compliance/PM
   ↓
Layer 2: 方法论层（1 repo，跨系统）    ← vibe-coding-agents（本框架）
              agent 角色定义 + slash command
   ↓
Layer 3: 系统知识层（per-system 一个） ← <system>-vibe-coding
              architecture/ + repos/AGENTS.md + tech_specs/
   ↓
Layer 4: 代码层（per-subsystem 一个）  ← 实际生产代码 repo
              ifes-ams, ifes-async, icrc-*, ams-*, ...
```

**为什么必须分层**：

| 原因 | 说明 |
|---|---|
| Owner 不同 | 业务/tech lead/SRE/dev 各管一层 |
| 变更频率不同 | PRD 年级 vs 代码日级 |
| 审计要求不同 | 业务层合规审、代码层 SOX 审 |
| 跨系统复用 | PRD 是跨系统资产，代码是 per-system |

**一次任务联动 5-9 个 repo**。

### 5.2 Layer 1：business-prds（业务需求层）

**owner**：Compliance / PM / 业务方
**生命周期**：年级（需求驱动）
**初始化**：业务方或 tech lead 手工创建，每个 PRD 一个文件

```
business-prds/
├── compliance/                             # 合规类 PRD
│   └── 2026-04-OJK-RIPLAY.md              # 文件名 = 日期 + 主题
├── feature/                               # 功能类 PRD
│   └── 2026-04-paylater-rate-tier.md
├── infra/                                 # 基础设施类 PRD
│   └── 2026-03-aws-migration.md
└── ...
```

**单个 PRD 文件的格式**（YAML frontmatter + 标准 markdown 段）：

```markdown
---
prd_id: PRD-2026-04-OJK-RIPLAY            # 必填，唯一标识
title: OJK RIPLAY Email Consolidation      # 必填
owner: Compliance Division (Yuni)           # 必填，PRD owner
status: active                              # active | draft | closed
target_systems_hint: [ifes, icrc, ams]      # 业务方猜测，非权威
related_prds: []                            # 关联 PRD
created: 2026-04-20
deadline: 2026-06-30                        # 监管 deadline
sources:                                    # 原始来源（审计后路）
  google_doc: https://docs.google.com/...
  confluence: https://xxx.atlassian.net/...
regulator_reference: OJK Reg 37/2025        # 监管法规号
---

# PRD — OJK RIPLAY Email Consolidation

## Background           ← 业务背景 / 监管背景
## Current state        ← 当前状态描述
## Required change      ← 具体要求
## Acceptance criteria  ← 验收标准
## Out of scope         ← 不在本 PRD 范围的
## Open questions       ← 待 PRD owner 回答的问题
## Deadline             ← 截止日期
## Contact              ← PRD owner 联系方式
```

**谁更新**：PRD owner（Compliance/PM）通过 GitHub PR review 流程。PO Agent 可辅助结构化，但人类 approve 后才 merge。

### 5.3 Layer 2：vibe-coding-agents（方法论层）

**owner**：AI methodology team
**生命周期**：季级（agent 框架升级）
**初始化**：clone 即可，不需要项目级初始化

```
vibe-coding-agents/
├── .claude/                                # CC 入口
│   ├── commands/
│   │   ├── vibe-coding.md                  # /vibe-coding <tech_spec> slash command
│   │   └── vibe-req.md                     # /vibe-req <input> slash command
│   ├── agents/
│   │   ├── vibe-po.md                      # PO Agent 定义
│   │   ├── vibe-sa.md                      # SA Agent 定义
│   │   ├── vibe-architect.md               # Architect Agent（V2.10 多系统）
│   │   ├── vibe-maker.md                   # Maker Agent 定义
│   │   ├── vibe-tester.md                  # Tester Agent 定义
│   │   ├── vibe-checker.md                 # Checker Agent 定义
│   │   ├── vibe-insight.md                 # Insight Agent 定义
│   │   └── vibe-conductor.md               # Conductor 异常处理
│   └── INSTALL.md                          # 安装指南
├── hermes-skills/                          # Hermes orchestrator 入口
│   ├── vibe-coding/SKILL.md
│   └── vibe-req/SKILL.md
├── sa-agent/                               # SA 角色完整定义
│   ├── AGENTS.md                           #   角色定义 + HARD-GATE（≤5-7KB）
│   ├── INPUT_SCHEMA.md                     #   输入协议（≤6KB）
│   ├── OUTPUT_SCHEMA.md                    #   输出协议（≤6KB）
│   └── DEPLOYMENT.md                       #   部署假设（≤4KB）
├── maker-agent/                            # Maker 角色完整定义（同上 4 文件）
├── tester-agent/                           # Tester 角色完整定义
├── checker-agent/                          # Checker 角色完整定义
├── insight-agent/                          # Insight 角色完整定义
├── conductor-agent/                        # Conductor 角色完整定义
├── architect-agent/                        # Architect 角色完整定义（V2.10）
├── po-agent/                               # PO 角色完整定义（V2.9）
├── docs/                                   # 架构 briefing 文档
│   ├── DESIGN_PRINCIPLES_V29.zh.md
│   └── DESIGN_PRINCIPLES_V29.en.md
├── .vibe-coding/
│   └── config.yaml.example                 # 项目级 stage routing 配置
├── README.md
├── DESIGN_PHILOSOPHY.md                    # 设计哲学（WHY）
├── PIPELINE_V28_DESIGN.md                  # V2.8 实施细节（HOW）
├── PIPELINE_V29_DESIGN.md                  # V2.9 PRD 结构化设计
├── PIPELINE_V210_MULTI_SYSTEM_DESIGN.md    # V2.10 多系统设计
├── HARNESS_REFERENCE_CONFIG.md             # 5 种 harness 推荐配置
├── GLOSSARY.md                             # 术语速查
├── TRAINING.md                             # 团队培训上手指南
├── ATTRIBUTION.md                          # 致谢 / License
└── experiments/                            # 历史实验数据
    └── v2.8-phase1-runs/
```

**谁更新**：AI methodology team。其他团队不直接改此 repo（通过 PR 贡献）。

### 5.4 Layer 3：\<system\>-vibe-coding（系统知识层）⭐ 重点

**owner**：各 dev team（tech lead 主导）
**生命周期**：5-10 年（系统知识跨多代工具）
**初始化**：dev team tech lead 手工创建，SA agent 在 pipeline 运行中自动填充 tech_specs/

```
ifes-vibe-coding/                          # 以 IFES 系统为例
│
├── architecture/                          # ── 系统总览（tech lead 手工编写）──
│   ├── overview.md                        #    系统架构概览：组件图、调用链、部署拓扑
│   ├── glossary.md                        #    领域术语表：业务名词 ↔ 代码映射
│   │                                      #    （SA 用来 gloss PRD 术语；Insight 用来翻译 jargon）
│   ├── dont-touch.md                      #    红名单：不可触碰的文件/类/配置
│   │                                      #    （Checker Category B 强制 grep 检查）
│   └── platforms.md                       #    平台文档（如 5 个 platform 的差异）
│
├── repos/                                 # ── per-subsystem 操作手册（dev team 手工编写）──
│   ├── ifes-ams/
│   │   └── AGENTS.md                      #    AMS 子系统的编码规范（≤15KB）
│   ├── ifes-async/
│   │   └── AGENTS.md                      #    Async 子系统的编码规范
│   ├── ifes-core/
│   │   └── AGENTS.md
│   ├── ifes-front/
│   │   └── AGENTS.md
│   ├── ifes-lpfront/
│   │   └── AGENTS.md
│   ├── ifes-lph5/
│   │   └── AGENTS.md
│   ├── ifes-resmh5/
│   │   └── AGENTS.md
│   └── ifes-um/
│       └── AGENTS.md
│
├── tech_specs/                            # ── SA 历史输出（agent 自动生成 + 人工 review）──
│   └── PRD-2026-04-OJK-RIPLAY/            #    按 prd_id 组织目录
│       └── tech_spec.md                   #    SA 产出的 tech_spec（含 frontmatter 审计字段）
│                                          #    新 SA 运行时读此目录获取"团队记忆"
│
└── _benchmarks/                           #    验证证据（Phase A/B benchmark 结果）
```

#### `architecture/dont-touch.md`（红名单）— 推荐格式

⭐ 这是 Checker Category B 强制检查的依据，**必须准确完整**。

```markdown
# Don't-Touch Zones — IFES System

## 全局红名单（所有子系统不可触碰）

| Pattern | 原因 | 违规后果 |
|---|---|---|
| `*Const.java` | 业务常量，跨多 repo 引用，改一个值十几个服务行为变 | 跨系统故障 |
| `*_pri.pem` | 私钥，commit 进 git = P0 安全事故 | 安全事故 |
| `error.conf` | 监管阈值，修改需 compliance 签字 | 合规违规 |
| `limit.cfg` | 同上 | 合规违规 |
| `lib/` | 第三方 vendor JAR，upgrade 需 ops 走 ITSM | 依赖链断裂 |
| `share/<common>/` | 跨 repo DTO，改一处影响多 repo | 接口不兼容 |

## per-subsystem 特殊红名单

### ifes-ams
- `AmsPathConst.java` — 路径常量
- `rmb-definition.yml` — RMB 路由规则

### ifes-async
- （无额外红名单）
```

#### `repos/<subsystem>/AGENTS.md` — 推荐段落结构

⭐ 框架**未定义内部 schema**，以下是从参考项目中 Maker/Checker 的消费方式反推的推荐格式：

```markdown
# <子系统名> 操作手册

## 1. 子系统概述
<!-- 1-2 段：这个子系统做什么、在系统中的位置 -->

## 2. 项目结构
<!-- 目录树 + 关键目录说明 -->
<!-- Maker 用来定位文件；SA 用来判断 scope -->

## 3. 编码规范

### 3.1 Service/Impl 模式
<!-- 如：Controller → Service → DAO 分层约定 -->
<!-- Checker Category C Convention adherence 检查依据 -->

### 3.2 命名约定
<!-- 类名 / 方法名 / 变量名 / 包名规则 -->

### 3.3 错误处理
<!-- 异常体系、错误码规则、日志级别 -->

### 3.4 数据库访问
<!-- DAO 模式、MyBatis/JPA 约定、SQL 规范 -->

## 4. 依赖与构建
<!-- Gradle/Maven 配置说明、依赖版本管理 -->

## 5. 测试规范
<!-- 测试目录结构、mock 框架、测试命名 -->

## 6. RMB 集成（如适用）
<!-- RMB 服务暴露/消费约定、序列化规则 -->

## 7. 常见陷阱
<!-- 新人容易犯的错、已知坑点 -->

## 8. 本子系统红名单
<!-- 继承全局红名单 + 本子系统特有的 -->
```

**大小约束**：≤ 15KB。超过说明子系统应拆分。

#### `tech_specs/` — SA 历史输出目录

```
tech_specs/
├── PRD-2026-04-OJK-RIPLAY/
│   └── tech_spec.md           # SA agent 自动写入，人工 PR review 后 merge
├── PRD-2026-03-BETA-GAMMA/
│   └── tech_spec.md
└── ...                        # 每次 pipeline 运行自动增加
```

**每个 tech_spec.md 的 frontmatter 审计字段**（SA agent 强制生成）：

```yaml
---
prd_id: PRD-2026-04-OJK-RIPLAY
prd_source: WeFI-TECH/business-prds/compliance/2026-04-OJK-RIPLAY.md
prd_commit: a1b2c3d                  # PRD 在 SA 跑时的 git SHA
prd_owner: Compliance Division (Yuni)
spec_run_id: 2026-04-27-01
status: PARTIAL
target_subsystems: [ifes-ams, ifes-async]
related_specs:                        # 同 PRD 其他系统的 tech_spec
  - icrc-vibe-coding/tech_specs/PRD-2026-04-OJK-RIPLAY/tech_spec.md
---
```

**谁初始化**：目录空建即可，SA agent 在后续 pipeline 运行中自动填充。

**谁更新**：SA agent 每次运行自动写入。人类在 PR review 中可能要求 SA 修改，SA 重跑后覆盖。

**为什么重要**：这是 SA agent 的"团队记忆"。新 PRD 进来时，SA 自动读 `tech_specs/` 找历史模式（"半年前类似改动怎么做的"），避免每次从 0 推理。这是通用 AI coding 工具没有的能力。

### 5.5 Layer 4：代码层（实际生产代码）

**owner**：各 dev team
**生命周期**：日级（持续开发）
**初始化**：已有 repo，Maker agent 在 pipeline 中 clone 到 workspace

```
# 示例：IFES 系统的 8 个代码 repo
ifes-ams/           # 账户管理系统
ifes-async/         # 异步服务
ifes-core/          # 核心模块
ifes-front/         # 前端
ifes-lpfront/       # LP 前端
ifes-lph5/          # LP H5
ifes-resmh5/        # 资源管理 H5
ifes-um/            # 用户管理
```

**Maker agent 工作方式**：clone 到 `~/vibe-coding-tasks/<task-id>/2-maker/workdir/code/<subsystem>/`，在 workspace 内 commit，不直接改 repo。Gate 2 approve 后由人类手动 push。

### 5.6 一次 pipeline 运行的 workspace 目录

每次 `/vibe-coding` 或 `/vibe-req` 启动时，在 `~/vibe-coding-tasks/` 下生成独立 workspace：

```
~/vibe-coding-tasks/
  task-<prd-name>-<timestamp>/
    ├── 0-input/
    │   └── prd.md                        # PRD 副本
    ├── 1-sa/
    │   ├── output/tech_spec.md           # SA 产出
    │   └── workdir/
    ├── 2-maker/
    │   ├── output/SUMMARY.md             # Maker 产出
    │   └── workdir/code/<subsystem>/     # Maker clone 的代码 + diff
    ├── 3-tester/
    │   ├── output/test-report.md         # Tester 产出
    │   └── workdir/test-output.log       # 完整测试日志
    ├── 4-checker/
    │   └── output/review.md              # Checker 产出
    ├── 5-insight/
    │   └── output/briefing.md            # Insight 产出（给人类 Gate 2）
    ├── _human_gate/
    │   ├── gate-1-decision.md            # Gate 1 决策记录
    │   └── gate-2-decision.md            # Gate 2 决策记录
    ├── _state/
    │   ├── pipeline.json                 # pipeline 状态机（当前 stage/iteration/attempts）
    │   ├── preflight.ok                  # preflight 通过标记
    │   ├── toolchain.json                # 检测到的工具链信息
    │   ├── active-config.yaml            # 当前使用的 harness preset
    │   └── outcome.json                  # 最终结果（MERGE/ABORT/ERROR）
    ├── _logs/
    │   └── sa.log, maker.log, ...        # 各 stage 日志
    └── _incidents/
        └── incident-N.md                 # Conductor 异常记录（仅失败时生成）
```

**生命周期**：pipeline 跑完后由 cleanup 流程决定保留哪些产物（incident.md / 5 个 stage outputs / session logs）+ 删除中间 workspace。不复用。

### 5.7 四层各部分的初始化和更新责任矩阵

| 层 | 部分 | 谁初始化 | 谁更新 | 更新时机 |
|---|---|---|---|---|
| L1 | business-prds/*.md | PRD owner / PO Agent 辅助 | PRD owner（通过 PR review） | 新需求进来 / 需求变更 |
| L2 | 整个 repo | AI methodology team | AI methodology team | 月度框架升级 |
| L3 | architecture/ | dev team tech lead 手工 | dev team tech lead | 系统架构变更 |
| L3 | repos/\<sub\>/AGENTS.md | 各子系统 dev team 手工 | dev team | PR 落地时更新编码规范 |
| L3 | tech_specs/ | SA agent 自动生成 | SA agent 每次 pipeline 运行 | 每次 `/vibe-coding` 跑完 |
| L4 | 生产代码 | 已有 repo | Maker agent 产出 diff + 人类 merge | 每次任务 |

---

## 6. Harness 选型与模型配置

### 6.1 五种 Harness Preset

| Harness | 价格 | SA | Maker | Checker | 跨族策略 |
|---|---|---|---|---|---|
| **Claude Code** | 高 | Opus 4.7 | Sonnet 4.6 | Opus 4.7 | Anthropic 内 lineage 分化 |
| **Hermes** | 低 | GLM-5.1 | mimo-v2.5-pro | GLM-5.1 | **真跨族**（GLM ↔ mimo） |
| **Codex** | 高 | gpt-5-codex | gpt-5-codex | gpt-5-codex | 同 lineage（ChatGPT 普通 tier 限制） |
| **Qoder** | 低 | ultimate | performance | ultimate | effort 分级（Qoder 自己路由） |
| **OpenClaw** | 低 | glm-5.1 | deepseek-v4-pro | glm-5.1 | **真跨族**（GLM ↔ DeepSeek） |

### 6.2 五条铁律

1. `reasoning_effort: high` 必开
2. **Qoder `qmodel` 永久红名单**（Run 4 唯一翻车——2 fab + 1 dt 违规）
3. **Hermes 不用单 provider 全包**——Maker 必须跨出 GLM 族（Run 6 同族盲区）
4. **Claude Code Opus 不当 Maker**——只当 SA/Checker（Run 1 实测 Maker 位 BLOCKED）
5. **OpenClaw thinking level 跟 model 绑定**——glm-5.1 只支持 off/on；deepseek 支持 off/medium/high

### 6.3 选型决策树

```
预算 + 习惯？
│
├─ 公司报销 Anthropic  → Claude Code（Sonnet + Opus Checker）
├─ 公司报销 OpenAI      → Codex CLI
├─ 自费、习惯 IDE       → 【默认】Qoder（effort 分级）
├─ 自费、CLI 老手       → Hermes（GLM + mimo/deepseek）
└─ 已部署 openclaw      → OpenClaw（zai/glm + deepseek）
```

---

## 7. Agent 定义的 prompt 模式（如何写好一个 Agent）

从参考项目的 agent 定义中提炼的最佳 prompt 编写模式：

### 7.1 四段式结构

```markdown
---
name: vibe-<role>
description: 一句话职责描述
tools: Read Glob Grep Write Edit Bash
model: <推荐 model>
---

## Identity（你是谁）
## Job（你的输入/输出/状态）
## HARD-GATES（不可违反的约束，编号列表）
## What you read（上下文来源，必须精确到路径）
## What you produce（输出 schema，frontmatter 格式）
## Tone（语气要求）
## Final assistant message（返回给 orchestrator 的摘要格式）
```

### 7.2 HARD-GATE 编写原则

- **用"DO NOT"句式**，不用"建议/尽量避免"
- **每条编号**，方便 Checker 引用"违反 HARD-GATE 3"
- **必须可机器验证**（grep / file pattern / test count），不用主观判断
- **数量控制在 5-7 条**，超过说明角色定义太复杂

### 7.3 输出 Schema 设计

```yaml
# frontmatter 必须字段
---
status: VALID | PARTIAL | AMBIGUOUS | OUT-OF-SCOPE
spec_run_id: YYYY-MM-DD-NN
# ... 审计字段
---
```

**关键设计**：status 用有限枚举（不是自由文本），orchestrator 据此做 routing。

### 7.4 模块大小纪律

| 文件类型 | 大小上限 | 超过说明 |
|---|---|---|
| 单个 agent 4 文件总和 | < 25KB | 角色定义太复杂，应拆分 |
| AGENTS.md | ≤ 5-7KB | 注意力聚焦 |
| INPUT/OUTPUT_SCHEMA | ≤ 6KB each | 协议过于复杂 |
| DEPLOYMENT.md | ≤ 4KB | 部署假设太多 |
| 项目知识库 per-repo AGENTS.md | ≤ 15KB | 子系统该拆 |

---

## 8. 实测数据：9 轮跨组合实验

同一 PRD（OJK RIPLAY 邮件合并），9 种 harness × LLM 组合并行：

| Run | Harness + LLM | Tier | 结果 |
|---|---|---|---|
| 2 | Codex + GPT-5.5-codex | Top | ✅ APPROVE 0 违规 |
| 3 | Qoder + default(Sonnet) | Top | ✅ APPROVE 0 违规 |
| 8 | CC + Sonnet 4.6 | Top | ✅ APPROVE 0 违规 |
| 5 | OpenClaw + DeepSeek | Mid | ✅ APPROVE 0 违规 |
| 7 | OpenClaw + minimax | Mid | ✅ APPROVE 0 违规 |
| 9 | Hermes + GLM-5.1 | Mid | ⚠️ NEEDS-CHANGES（自抓 scope drift） |
| 1 | CC + Opus 4.7 | Top | ⚠️ Maker BLOCKED（Opus 死守 HARD-GATE） |
| 6 | Hermes + mimo-pro | Budget | ❌ 盲区：漏 don't-touch 违规 |
| 4 | Qoder + qmodel | Budget | ❌ 翻车：2 fab + 1 dt + 1 drift |

**关键发现**：

1. 框架本身能把 budget-tier 拉到 mid-tier 质量
2. 同一 LLM 自审盲区只在 budget-tier 出现
3. 跨族原则的真实价值在 budget-tier（top/mid 自审够用）
4. SA 是最高杠杆 stage——SA 失误浪费下游所有时间
5. 自动 retry 有效——iter 1 Maker 11.5 min vs iter 2 Maker 2 min

---

## 9. 与其他工具的关系

### 9.1 Vibe Coding Agents 在工具生态中的位置

| 层级 | 工具 | 说明 |
|---|---|---|
| **SOP 框架** | Vibe Coding Agents | 本工具——定义 agent 角色和流水线 |
| **Harness（运行时）** | Claude Code / Hermes / Qoder / Codex / OpenClaw | 执行 agent 的容器 |
| **Process 插件** | [Superpowers](../superpower/Superpowers%20使用最佳实践指南.md) | 单 agent 内部纪律约束（brainstorm → TDD → review） |
| **SDD 工具** | [SpecKit / OpenSpec](../speckit/SpecKit%20+%20OpenSpec%20使用最佳实践指南.md) | 规格驱动开发 |
| **IDE 增强** | Cursor / Cline | 单 dev IDE 加速 |

### 9.2 与 Superpowers 的关系

| 维度 | Superpowers | Vibe Coding Agents |
|---|---|---|
| 粒度 | 单 agent 内部纪律 | 多 agent 流水线编排 |
| 触发方式 | 自动（14 skill 自动触发） | 手动（`/vibe-coding` slash command） |
| 人类介入 | brainstorm 环节 | 3 个硬性 Gate |
| 适用场景 | 所有项目 | 受监管/跨团队/需审计 |
| 冲突风险 | **无** | 流程 vs 纪律，互补 |

### 9.3 何时用 Vibe Coding Agents

```
你的任务？
│
├─ Fix typo / 改 log 级别          → 直接 IDE 改，5 秒搞定 ❌ 不用
├─ 探索性 demo / POC               → Cursor / Cline ❌ 不用
├─ 一行代码紧急 hotfix             → 走 hotfix 流程 ❌ 不用
├─ 单文件重构                      → IDE 足够 ❌ 不用
│
├─ OJK/监管合规改动                → ✅ 用（审计 trace + scope 切分）
├─ 跨多子系统改动                  → ✅ 用（SA 帮你切影响范围）
├─ 涉及 don't-touch 区的需求       → ✅ 用（Checker 强制抓违规）
├─ 跨团队协调需求                  → ✅ 用（SA OUT-OF-SCOPE 早期识别）
└─ 需要给业务方解释"为什么这么改"   → ✅ 用（全链路 audit trail）
```

---

## 10. 安装与使用

### 10.1 全局安装

```bash
# Clone
git clone git@github.com:WeFI-TECH/vibe-coding-agents.git ~/wefi-tech/vibe-coding-agents

# 软链接到 ~/.claude/（全局可用）
mkdir -p ~/.claude/commands ~/.claude/agents
ln -sf ~/wefi-tech/vibe-coding-agents/.claude/commands/vibe-coding.md ~/.claude/commands/
ln -sf ~/wefi-tech/vibe-coding-agents/.claude/commands/vibe-req.md ~/.claude/commands/
for a in vibe-architect vibe-checker vibe-conductor vibe-insight vibe-maker vibe-po vibe-sa vibe-tester; do
  ln -sf ~/wefi-tech/vibe-coding-agents/.claude/agents/$a.md ~/.claude/agents/
done
```

### 10.2 使用流程

```
有原始业务需求？
    ↓ /vibe-req <input>
    → PO Agent 结构化 → PRD PR
    → SA Agent → tech_spec PR
    ↓ tech_spec PR merge
    ↓ /vibe-coding <tech_spec>
    → Maker → Tester → Checker → Insight
    → 代码 PR（手动 push + 走 PR review）

已有 tech_spec？
    → /vibe-coding <tech_spec>  ← 直接起跑
```

### 10.3 常见 fail mode

| 症状 | 原因 | 修法 |
|---|---|---|
| `/vi` 补全里没有 `/vibe-coding` | 没装软链或没加 `--with-claude-config` | 重跑安装步骤 |
| Worker stage 卡住 | 默认 mimo quota 满 | 选 zai/glm-5.1 或 Qoder ultimate |
| SA 给 PARTIAL 直接 approve | Sonnet 找活 bias | SA 用 Opus/GLM 做 strict reading |
| Gate 2 后等待自动 push | V2.8 不自动 push | 手动 push + PR 创建 |

---

## 11. 可借鉴的设计模式（通用化）

即使不在银行场景，以下模式值得借鉴到任何 AI agent 系统：

### 11.1 角色 prompt 模板

```markdown
# 通用 Agent 角色定义模板

## Identity
你是什么角色，你的唯一职责是什么。

## Job
- Input：接收什么
- Output：产出什么，status 有哪些枚举值
- 在 pipeline 中的位置

## HARD-GATES（不可违反）
1. 你 **DO NOT** 做 X（那是 Y 的职责）
2. 你 **MUST** 验证 Z（grep / pattern / test）
...

## What you read
精确的路径列表，不靠猜测。

## What you produce
Schema 格式定义，status 用有限枚举。

## Tone
角色的语气要求。

## Final assistant message
返回给 orchestrator 的固定格式摘要。
```

### 11.2 HARD-GATE 编写技巧

- ✅ 用"DO NOT"硬性句式，不用"建议"
- ✅ 每条可机器验证（grep/pattern/count）
- ✅ 编号方便引用
- ❌ 不用主观判断词（"合理""适当"）
- ❌ 不超过 7 条

### 11.3 流水线设计技巧

| 技巧 | 说明 |
|---|---|
| 状态驱动 routing | agent 输出有限枚举 status，orchestrator 据此 routing |
| FAIL 自动 retry | Tester FAIL 回 Maker，最多 3 次，不打扰人类 |
| 先验证再审查 | Tester PASS 才跑 Checker，不浪费审查资源 |
| workspace 隔离 | 每次任务物理独立目录，agent 间通过文件协议交换 |
| 退回循环 | SA ↔ PO bounce、Checker → Maker 退回 |
| 审计 trace 嵌入 | frontmatter 必含 prd_id/prd_source/prd_commit |

### 11.4 跨模型对抗审稿

**核心洞察**：每个 LLM 有系统性 blindspot，跨族审稿消除共同盲区。

**实施方式**：
- Maker 用 A 族（如 Anthropic Sonnet），Checker 用 B 族（如 GLM-5.1）
- Budget-tier 必须跨族；Top-tier 自审可接受
- 不要用同一族内同模型自审

---

## 12. 反模式

| 反模式 | 表现 | 后果 |
|---|---|---|
| **把 V2.8 当 Cursor 用** | "帮我加一个 if 分支" | 流程 30 分钟起，日常小事 overkill |
| **跳过 Gate 1 直接 approve** | 看都不看 tech_spec | Maker 白干 5-15 分钟 |
| **期待自动 push PR** | Gate 2 后干等 | 必须手动 push + 创建 PR |
| **Tester FAIL 手动调试** | 打断自动 retry 循环 | 3 次都 FAIL 才需人类介入 |
| **忽略 Checker NEEDS-CHANGES** | 嫌烦直接 approve | 问题到 PR review 才暴露 |
| **SA 用找活型模型** | Sonnet SA 给 PARTIAL | SA 失误 = 下游全白干 |
| **单族自审** | Maker=Checker=同一模型 | budget-tier 必翻车 |
| **编造 symbol** | `EDM_CODE_FOO = "FOO"` 不存在于 codebase | Checker 会 grep 抓出来 REJECT |
| **测试剧场** | 只写 `assertNotNull(x)` | Checker Category E 标记 NEEDS-CHANGES |
| **Scope drift** | 改了 spec 没说的文件 | Checker Category D 标记 NEEDS-CHANGES |

---

## 13. 一句话总结

> **Vibe Coding Agents 的核心不是 AI 编码能力，而是"事前抑制 > 事后审查"的 SOP 纪律**——通过专一职责 agent + HARD-GATE + 跨族审稿 + 人类 Gate，让 budget-tier LLM 也能产出银行级质量代码，且全链路可审计。

---

## 相关文档

- [Harness Engineering 概念与实践指南](../harness-engineering/Harness%20Engineering%20概念与实践指南.md)——理解 harness 的基础设施概念
- [Superpowers 使用最佳实践指南](../superpower/Superpowers%20使用最佳实践指南.md)——单 agent 内部流程纪律
- [跨工具协作指南](../collaboration/跨工具协作指南.md)——工具组合与冲突分析
- [Claude Code 核心概念指引](../claudecode/Claude%20Code%20核心概念指引.md)——理解 slash command / subagent / AGENTS.md
