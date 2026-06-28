# Continuous Improvement Loop 设计

## 目标

把一套可复用的“持续优化 Loop”沉淀进 `coding_template`，用于指导 AI 在已有代码库上做增量改造，也兼容从 0 到 1 项目。该 Loop 必须强制 AI：

- 先定义最终目标与验收标准，再拆解 `Phase`
- 以 `Phase` 为大循环、以“关键改动” 为小循环推进
- 每完成一个关键改动或一个 `Phase` 都立即验证，不攒积压
- 未达到验收标准前不得停止，除非连续三轮自救失败并进入 `blocked`
- 把执行证据落到 `spec / plan / verify / decision / workflow / prompt ledger`

## 适用范围

### 默认场景

- 已有代码库上的增量改造
- 已交付产品的持续优化、重构、工具层重做、能力增强
- 需要持续验证与多阶段推进的复杂任务

### 兼容场景

- 从 0 到 1 的新项目

### 不适合默认使用的场景

- 单次一次性小改动
- 不需要阶段拆分、验证链路或持续推进的短任务

## 设计原则

1. **增量改造优先**：模板默认假设项目已有代码、已有约束、已有行为，需要在现有系统上推进。
2. **验收标准驱动停止**：默认停止条件只有“达到总控验收标准”。
3. **大循环按 Phase，小循环按关键改动**：Phase 管方向，关键改动管节奏。
4. **先自救，后阻塞**：遇到问题先换路径、补证据、缩范围；连续三轮仍失败才允许 `blocked`。
5. **决策必须落盘**：遇到分歧或默认采用推荐方案时，必须记录到 `docs/decision.md`。
6. **验证证据优先于主观判断**：构建、测试、E2E、真实证据缺一不可。

## 文档模型

持续优化 Loop 强制产出以下 5 类文档。

### 1. 总控 spec

路径：`docs/superpowers/specs/YYYY-MM-DD-Phase00-<topic>-main.md`

职责：

- 定义最终目标
- 定义最终验收标准
- 定义总 Phase 图
- 定义各 Phase 的依赖关系
- 定义必做 / 可跳过 Phase
- 定义整体回归与 E2E 口径

`Phase00` 只做主控，不承载具体实现步骤。

### 2. Phase spec

路径：`docs/superpowers/specs/YYYY-MM-DD-PhaseNN-<topic>.md`

每个 `Phase` 一个 spec，必须包含：

- `Phase 编号`
- `目标`
- `上游依赖`
- `输入依据`
- `输出产物`
- `推荐方案`
- `风险 / 边界`
- `验收条件`
- `回写要求`
- `下一 Phase 触发条件`

编号代表依赖顺序，不只是展示顺序。

### 3. Phase plan

路径：`docs/superpowers/plans/YYYY-MM-DD-PhaseNN-<topic>-plan.md`

职责：

- 把该 `Phase` 拆成可执行步骤
- 明确每一步修改范围
- 明确验证命令
- 明确局部 E2E 路径
- 明确回滚方式与失败处理

### 4. Verify 报告

路径：`docs/e2e/verify/YYYY-MM-DD-PhaseNN-<topic>-verify.md`

职责：

- 记录构建结果
- 记录测试结果
- 记录 E2E 结果
- 记录关键证据、风险和未达项
- 判断该 `Phase` 是否达成验收标准

### 5. 决策记录

路径：`docs/decision.md`

格式固定为：

- 决策问题
- 备选方案
- 选择
- 理由
- 影响范围
- 相关文件

## 命名与编号规则

### 命名规则

- `Phase00`：`YYYY-MM-DD-Phase00-<topic>-main.md`
- `Phase01+` spec：`YYYY-MM-DD-PhaseNN-<topic>.md`
- `Phase01+` plan：`YYYY-MM-DD-PhaseNN-<topic>-plan.md`
- `Phase01+` verify：`YYYY-MM-DD-PhaseNN-<topic>-verify.md`

### 编号规则

- `Phase00` 永远是总控 spec
- `Phase01+` 才是可执行阶段
- 一个 `Phase` 可以依赖多个前置 `Phase`
- 未满足依赖的 `Phase` 不能进入执行
- Phase 编号必须显式写入文件内容和状态机

## Loop 状态机

### 一、大循环：Phase 级 Loop

每个 `Phase` 走完完整闭环，再进入下一个 `Phase`。

建议状态：

- `pending`
- `ready`
- `in_progress`
- `verifying`
- `passed`
- `failed`
- `blocked`
- `archived`

状态规则：

- `pending -> ready`：所有依赖 `Phase` 都已 `passed`
- `ready -> in_progress`：开始执行该 `Phase plan`
- `in_progress -> verifying`：本轮关键改动完成
- `verifying -> passed`：该 `Phase` 验收标准全部满足
- `verifying -> failed`：任一验收项未满足
- `failed -> in_progress`：进入下一轮修复 / 补齐
- `blocked`：连续三轮自救失败
- `passed -> archived`：该 `Phase` 完成并退出活跃上下文

只有 `passed` 的 `Phase` 才能触发下游 `Phase` 进入 `ready`。

### 二、小循环：关键改动级 Loop

Phase 内每个关键改动都必须走小闭环：

1. 读取当前 `Phase spec` 和 `Phase plan` 中本步直接相关内容
2. 执行一个关键改动
3. 立即验证：
   - 构建
   - 相关测试
   - 必要时局部 E2E
4. 记录结果
5. 判断：
   - 是否达到当前 `Phase` 验收条件
   - 未达成则继续下一关键改动
   - 若失败则先修复，不能跳到后续改动

### 三、停止条件

默认合法停止只有两种：

1. 达到 `Phase00-main` 中定义的最终验收标准
2. 连续三轮自救失败，进入 `blocked`

以下都不构成“完成”：

- “主要功能差不多了”
- “测试大部分通过”
- “核心链路先能跑”
- “E2E 以后再补”
- “文档先交，代码后补”

### 四、自救机制

默认自救三轮：

1. **第一轮**：换实现路径，不扩大范围
2. **第二轮**：补证据、补日志、补最小验证，缩小问题面
3. **第三轮**：缩小该 `Phase` 内目标，只保留达成当前验收标准所需的最小闭环

三轮后仍无法推进，才允许：

- 标记 `blocked`
- 写入 `docs/decision.md`
- 在 verify 报告中写清：
  - 阻塞项
  - 已尝试路径
  - 仍缺失的外部条件
  - 需要的人类输入

## 与 Superpowers 的关系

持续优化 Loop 不替代现有 Superpowers 技能，而是在其上叠加一层主线控制：

- `brainstorming`：生成 `Phase00-main` 或重大增量需求设计
- `writing-plans`：生成各 `Phase plan`
- `TDD / debugging / verification`：执行 `Phase` 内关键改动闭环
- `requesting-code-review`：在关键阶段或收口前做质量审查

Loop 负责回答“现在做到哪一步、下一轮该做什么、何时才能停”；Superpowers 负责回答“这一类工作应该怎样执行”。

## 模板改造范围

这套能力应作为 `coding_template` 的第二条标准主线，而不是另起一套模板。

### 1. 修改 `.template/prompt.md`

新增“持续优化 Loop”专用 prompt 组：

- 总控 spec prompt
- `Phase` 拆解 spec prompt
- `Phase plan` prompt
- `Phase` 执行 prompt
- `Phase verify` prompt
- `Loop 恢复 / 阻塞上报` prompt

必须把以下规则写死：

- 必须先建 `Phase00-main`
- 必须拆 `Phase01+`
- 必须有依赖编号
- 必须每个 `Phase` 对应 spec / plan / verify
- 必须每个关键改动立即验证
- 未达到最终验收标准前不得停止

### 2. 修改 `.template/templates/runtime-prompt.md`

新增 `Loop 执行台账`，至少跟踪：

- 当前总控主题
- 当前 `Phase`
- `Phase` 状态
- 当前关键改动
- 最近一次验证结果
- 连续自救轮次
- 当前阻塞项
- 最终验收标准达成度

### 3. 修改 `.template/templates/workflow.yaml`

保留现有 spec / plan 生命周期模型，同时补充可表达 `Phase loop` 的字段或规则，例如：

- `phase_id`
- `phase_type: main | phase`
- `depends_on`
- `acceptance_gate`
- `loop_status: pending | ready | in_progress | verifying | passed | failed | blocked | archived`
- `retry_count`

目标不是推翻现有状态机，而是让 `Phase loop` 拥有可机读状态。

### 4. 修改 validator

至少新增以下校验：

- 是否存在且只存在一个 `Phase00-main`
- `Phase01+` 文件名是否符合命名规则
- 每个 `Phase spec` 是否有 `depends_on` 和验收条件
- 每个 `Phase` 是否存在对应 plan
- 每个已完成 `Phase` 是否存在对应 verify
- 出现决策分歧时是否追加到 `docs/decision.md`
- 若结论写“完成 / 通过”，是否存在对应验收证据
- `blocked` 前是否记录了至少三轮自救

## 兼容现有主线的方式

现有模板保留两条主线：

1. **产品交付主线**：从 `idea -> spec -> plan -> implementation -> e2e -> delivery`
2. **持续优化 Loop 主线**：从 `Phase00-main -> Phase01+ specs -> Phase plans -> execute/verify loop -> final acceptance`

默认选择规则：

- 已有项目增量改造：优先使用“持续优化 Loop”
- 新项目从 0 到 1：默认使用现有产品交付主线
- 若新项目在后续进入长期增量优化，可从第一条主线切换到第二条主线

## 验收标准

本设计完成后，应满足：

1. `coding_template` 能为任意项目生成一套可执行的持续优化 Loop 文档骨架
2. AI 能按 `Phase00-main -> PhaseNN spec -> PhaseNN plan -> verify` 顺序推进
3. `loop` 的停止条件、自救机制、阻塞条件是显式可机读的
4. 模板能通过校验器阻止“口头 loop、没有文档产物”的退化行为
5. 这套主线能服务存量项目增量改造，也不破坏原有产品交付主线

## 不在本次设计范围

- 直接实现 `coding_template` 文件改造
- 为某个具体业务项目生成 `Phase00-main` 和 `PhaseNN` 文档
- 引入第三条独立模板体系
- 定义与 Superpowers 无关的全新执行框架
