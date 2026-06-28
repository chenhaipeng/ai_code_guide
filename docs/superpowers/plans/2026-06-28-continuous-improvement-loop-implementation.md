# Continuous Improvement Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a reusable Continuous Improvement Loop mainline to `coding_template` so existing-codebase projects can run `Phase00-main -> PhaseNN spec -> PhaseNN plan -> verify` loops under Superpowers until acceptance gates are met.

**Architecture:** Extend the current template instead of forking it. Add the loop as a second standard mainline across template docs, runtime prompt structure, workflow metadata, and validator coverage. Keep the existing product-delivery mainline intact while making loop-specific outputs, stopping conditions, and self-heal rules explicit and machine-checkable.

**Tech Stack:** Markdown docs, YAML template metadata, Bash validator scripts, `awk` workflow checks, `perl -0pi` negative-test fixtures, `rg`/`grep` text assertions, Git.

---

## Files

- Modify: `coding_template/prompt.md`
- Modify: `coding_template/AI-BOOTSTRAP.md`
- Modify: `coding_template/README.md`
- Modify: `coding_template/reference/documentation-governance.md`
- Modify: `coding_template/templates/runtime-prompt.md`
- Modify: `coding_template/templates/workflow.yaml`
- Modify: `coding_template/AGENTS.md`
- Modify: `coding_template/CLAUDE.md`
- Modify: `coding_template/scripts/validate-template.sh`
- Modify: `coding_template/scripts/test-validate-template.sh`

### Task 1: Add Continuous Improvement Loop To The Main Prompt And Bootstrap Docs

**Files:**
- Modify: `coding_template/prompt.md`
- Modify: `coding_template/AI-BOOTSTRAP.md`
- Modify: `coding_template/README.md`
- Modify: `coding_template/reference/documentation-governance.md`

- [ ] **Step 1: Add the new loop prompt section to `coding_template/prompt.md`**

Insert a new section near the end of `coding_template/prompt.md`, before the existing generic prompts, with this exact structure:

The bracketed forms inside the snippet below are literal template syntax and must be kept as-is.

```md
## 持续优化 Loop

> 适用：已有代码库上的增量改造、重构、工具层重做、长期持续优化；默认优先于从 0 到 1 主线。
>
> 停止条件：只有 `Phase00-main` 中定义的最终验收标准达成，或连续三轮自救失败并明确 `blocked`，才允许停止。

### 持续优化总控 spec

```text
我的目标是：[最终目标]

请不要直接实现，先按持续优化 Loop 生成总控 spec，并写入：
`docs/superpowers/specs/YYYY-MM-DD-Phase00-[topic]-main.md`

要求：
1. 明确定义最终目标和最终验收标准
2. 将工作拆分为 `Phase01+`
3. 每个 Phase 必须有编号、主题、依赖关系、推荐方案和验收条件
4. 明确哪些 Phase 必做、哪些按需
5. 明确最终 E2E / 回归口径

验证：没有最终验收标准、没有依赖顺序、没有 Phase 编号，不进入下一步。
```

### Phase 拆解 spec

```text
总控 spec：[路径]
当前待拆解 Phase：[Phase 编号]

请生成该 Phase 的 spec，并写入：
`docs/superpowers/specs/YYYY-MM-DD-[Phase 编号]-[topic].md`

要求：
1. 写明目标、上游依赖、输入依据、输出产物
2. 默认按推荐方案或最佳实践执行
3. 如存在方案分歧，默认选择推荐方案并要求记录到 `docs/decision.md`
4. 写明风险、边界、验收条件、回写要求和下一 Phase 触发条件

验证：没有验收条件、没有依赖、没有回写要求，不进入 plan。
```

### Phase Plan

```text
当前 Phase spec：[路径]

请使用 Superpowers 的 planning 工作流生成该 Phase 的实施计划，并写入：
`docs/superpowers/plans/YYYY-MM-DD-[Phase 编号]-[topic]-plan.md`

要求：
1. 拆成可执行的小步
2. 每一步明确修改范围、验证命令、局部 E2E 路径
3. 每完成一个关键改动立即验证，不攒积压
4. 验证失败先修复，不继续下一个关键改动

验证：没有验证命令或没有局部 E2E 路径，不进入实现。
```

### Phase 执行与验证

```text
请执行当前 Phase。

执行要求：
1. 大循环按 Phase 推进，小循环按关键改动推进
2. 每完成一个关键改动，立即执行构建、相关测试和必要的局部 E2E
3. 验证结果写入 `docs/e2e/verify/YYYY-MM-DD-[Phase 编号]-[topic]-verify.md`
4. 任务状态变化后，更新对应 spec、plan、`docs/workflow.yaml` 和 `docs/prompt.md`
5. 未达到当前 Phase 验收标准，不进入下一个 Phase
```

### Loop 恢复 / 阻塞上报

```text
当前 Phase：[Phase 编号]
当前问题：[问题描述]

请先按持续优化 Loop 自救，不要立即停止：
1. 第一轮：换实现路径，不扩大范围
2. 第二轮：补证据、补日志、补最小验证，缩小问题面
3. 第三轮：缩小到达成当前验收标准所需的最小闭环

如果三轮后仍无法推进：
- 标记为 `blocked`
- 更新 `docs/prompt.md` 和 `docs/workflow.yaml`
- 写入 `docs/decision.md`
- 在 verify 报告中写明阻塞项、已尝试路径、仍缺失的外部条件和需要的人类输入
```
```

- [ ] **Step 2: Verify the new prompt section is present**

Run:

```bash
rg -n "持续优化 Loop|持续优化总控 spec|Phase 拆解 spec|Loop 恢复 / 阻塞上报" coding_template/prompt.md
```

Expected:

```text
4 matching lines from `coding_template/prompt.md`, one each for:
- `## 持续优化 Loop`
- `### 持续优化总控 spec`
- `### Phase 拆解 spec`
- `### Loop 恢复 / 阻塞上报`
```

- [ ] **Step 3: Update `coding_template/AI-BOOTSTRAP.md` to recognize the second mainline**

Add a new subsection under the methodology and stage-diagnosis sections with this content:

```md
### 持续优化 Loop 主线

当项目目标是已有代码库上的增量改造、重构、工具层重做或长期持续优化时，默认优先选择持续优化 Loop，而不是从 `00-idea-brief` 开始的产品交付主线。

持续优化 Loop 的权威入口是：

- `docs/superpowers/specs/YYYY-MM-DD-Phase00-[topic]-main.md`
- `docs/superpowers/specs/YYYY-MM-DD-PhaseNN-[topic].md`
- `docs/superpowers/plans/YYYY-MM-DD-PhaseNN-[topic]-plan.md`
- `docs/e2e/verify/YYYY-MM-DD-PhaseNN-[topic]-verify.md`

Loop 停止条件只有两种：

1. 达到 `Phase00-main` 中定义的最终验收标准
2. 连续三轮自救失败并进入 `blocked`

AI 不得以“主要功能差不多了”或“测试大部分通过”作为停止理由。
```

Also extend the bootstrap stage-selection guidance with:

```md
- 如果当前任务是已有项目的增量改造，先判断是否应创建 `Phase00-main`，而不是直接进入实现阶段。
```

- [ ] **Step 4: Update `coding_template/README.md` to document the new mainline**

Add a new subsection after `## 标准闭环流程` with this content:

```md
## 持续优化 Loop（已有项目优先）

对于已有代码库上的增量改造、重构、工具层重做和长期持续优化，模板默认优先使用持续优化 Loop：

1. 先写 `Phase00-main` 总控 spec，定义最终目标和最终验收标准
2. 再拆 `Phase01+` spec，明确依赖关系和编号
3. 每个 Phase 单独写 plan
4. 每个 Phase 完成后写 verify 报告
5. 任务状态变化后同步更新对应 spec / plan、`docs/workflow.yaml` 和 `docs/prompt.md`
6. 未达到最终验收标准前不得停止，除非连续三轮自救失败并进入 `blocked`

命名规则：

- `docs/superpowers/specs/YYYY-MM-DD-Phase00-[topic]-main.md`
- `docs/superpowers/specs/YYYY-MM-DD-PhaseNN-[topic].md`
- `docs/superpowers/plans/YYYY-MM-DD-PhaseNN-[topic]-plan.md`
- `docs/e2e/verify/YYYY-MM-DD-PhaseNN-[topic]-verify.md`
```

- [ ] **Step 5: Update governance guidance for the loop documents**

Extend `coding_template/reference/documentation-governance.md` with this block under the lifecycle/state sections:

```md
## 持续优化 Loop 文档

当项目采用持续优化 Loop 时，长期导航状态除了现有 `workflow.yaml` 和 `prompt.md` 执行台账外，还必须能够回答：

- 当前总控主题是什么
- 当前 Phase 是哪个
- 该 Phase 依赖是否满足
- 最近一次验证是否通过
- 当前是否处于自救第几轮
- 是否已经进入 `blocked`

`Phase00-main` 是总控设计快照；`PhaseNN spec`、`PhaseNN plan` 和 `PhaseNN verify` 仍属于过程产物。它们的价值在推动闭环，而不是长期维护成“活真相”。
```

- [ ] **Step 6: Run a doc-shape verification pass**

Run:

```bash
rg -n "持续优化 Loop|Phase00-main|三轮自救|未达到最终验收标准前不得停止" \
  coding_template/prompt.md \
  coding_template/AI-BOOTSTRAP.md \
  coding_template/README.md \
  coding_template/reference/documentation-governance.md
```

Expected: every file above returns at least one matching line.

- [ ] **Step 7: Commit the mainline doc updates**

```bash
git add coding_template/prompt.md coding_template/AI-BOOTSTRAP.md coding_template/README.md coding_template/reference/documentation-governance.md
git commit -m "docs: add continuous improvement loop mainline"
```

### Task 2: Add Loop Ledger To The Runtime Prompt Template

**Files:**
- Modify: `coding_template/templates/runtime-prompt.md`

- [ ] **Step 1: Add loop metadata fields**

Insert these fields under `## 元信息`:

The bracketed forms inside the snippet below are literal template syntax and must be kept as-is.

```md
- 当前 loop 主题：[如无写“无”]
- 当前 loop 模式：[产品交付主线 / 持续优化 Loop]
- 当前 Phase：[如无写“无”]
- 最近一次自救轮次：[0 / 1 / 2 / 3]
```

- [ ] **Step 2: Add a dedicated loop ledger table**

Insert this new section after `## Prompt 执行台账`:

```md
## Loop 执行台账

> 目的：当项目采用持续优化 Loop 时，记录 `Phase00-main`、`PhaseNN`、关键改动、自救轮次和最终验收达成度。未采用持续优化 Loop 时，本节可保留为空表。

| Loop 主题 | 当前 Phase | Phase 状态 | 当前关键改动 | 最近一次验证结果 | 自救轮次 | 当前阻塞项 | 最终验收标准达成度 | 最近更新时间 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [topic 或无] | [Phase00 / Phase01 / 无] | [pending / ready / in_progress / verifying / passed / failed / blocked / archived] | [描述或无] | [通过 / 不通过 / 未验证] | [0 / 1 / 2 / 3] | [描述或无] | [百分比或文字说明] | [YYYY-MM-DD HH:mm] | [说明] |
```

- [ ] **Step 3: Add loop-specific update rules**

Append these bullets under `## 更新规则`:

```md
- 当项目采用持续优化 Loop 时，阶段切换之外还必须同步更新“Loop 执行台账”。
- `Loop 执行台账`中的 `Phase 状态` 只允许使用：`pending / ready / in_progress / verifying / passed / failed / blocked / archived`。
- 自救轮次达到 `3` 后，如仍未满足当前 Phase 验收标准，必须把阻塞项写入 `docs/decision.md` 和 verify 报告。
- 如果最终回复声称“完成”或“通过”，`Loop 执行台账` 中的最终验收标准达成度必须与 verify 报告一致。
```

- [ ] **Step 4: Verify the runtime prompt additions**

Run:

```bash
rg -n "Loop 执行台账|当前 loop 主题|当前 Phase|自救轮次达到 `3`" coding_template/templates/runtime-prompt.md
```

Expected:

```text
4 matching lines from `coding_template/templates/runtime-prompt.md`, covering:
- `## Loop 执行台账`
- `当前 loop 主题`
- `当前 Phase`
- `自救轮次达到 `3` 后`
```

- [ ] **Step 5: Commit the runtime prompt changes**

```bash
git add coding_template/templates/runtime-prompt.md
git commit -m "docs: add loop ledger to runtime prompt template"
```

### Task 3: Extend Workflow Metadata And AI Entry Rules For Phase Looping

**Files:**
- Modify: `coding_template/templates/workflow.yaml`
- Modify: `coding_template/AGENTS.md`
- Modify: `coding_template/CLAUDE.md`

- [ ] **Step 1: Add loop metadata comments and fields to `templates/workflow.yaml`**

Extend the top comment block with:

```yaml
# 持续优化 Loop 补充字段：
#   phase_id        : Phase00 / Phase01 / ...
#   phase_type      : main | phase
#   acceptance_gate : 当前 item 的验收门禁摘要
#   loop_status     : pending | ready | in_progress | verifying | passed | failed | blocked | archived
#   retry_count     : 连续自救轮次，默认 0
#
# 这些字段用于已有项目的持续优化 Loop；不替代现有 workflow/content 状态，而是补充 Phase 级主线控制。
```

Then add this commented example block after the default `items:` list:

```yaml
# 持续优化 Loop 示例（按需复制到目标项目运行态 docs/workflow.yaml）:
#   - id: 2026-06-28-Phase00-source-tool-main
#     type: spec
#     phase_id: Phase00
#     phase_type: main
#     artifact_path: docs/superpowers/specs/2026-06-28-Phase00-source-tool-main.md
#     archive_path: docs/superpowers/specs/archive/
#     status: review
#     content_status: Human Confirmed
#     depends_on: []
#     triggers: [2026-06-28-Phase01-repo-index]
#     acceptance_gate: 最终验收标准已写入总控 spec
#     loop_status: ready
#     retry_count: 0
```

- [ ] **Step 2: Update `AGENTS.md` with loop execution rules**

Under `## 4. 开发流程（强制 Superpowers 工作流）`, add:

```md
### 持续优化 Loop（已有项目优先）

当任务是已有代码库上的增量改造、重构、工具层重做或长期持续优化时，默认优先使用持续优化 Loop：

1. 先创建 `Phase00-main` 总控 spec
2. 再拆分 `Phase01+` spec，并显式写明依赖顺序和编号
3. 每个 `Phase` 单独生成 plan
4. 每个 `Phase` 完成后写 verify 报告
5. 每次关键改动后立即执行构建、测试和必要 E2E
6. 未达到最终验收标准前不得停止，除非连续三轮自救失败并进入 `blocked`

命名规则：

- `docs/superpowers/specs/YYYY-MM-DD-Phase00-[topic]-main.md`
- `docs/superpowers/specs/YYYY-MM-DD-PhaseNN-[topic].md`
- `docs/superpowers/plans/YYYY-MM-DD-PhaseNN-[topic]-plan.md`
- `docs/e2e/verify/YYYY-MM-DD-PhaseNN-[topic]-verify.md`
```

Apply the same block to `coding_template/CLAUDE.md`.

- [ ] **Step 3: Verify agent entrypoint alignment**

Run:

```bash
diff -u coding_template/AGENTS.md coding_template/CLAUDE.md
```

Expected: no output.

Then run:

```bash
rg -n "持续优化 Loop（已有项目优先）|未达到最终验收标准前不得停止|Phase00-\\[topic\\]-main" coding_template/AGENTS.md coding_template/CLAUDE.md
```

Expected: both files return matches for all three phrases.

- [ ] **Step 4: Commit workflow metadata and entrypoint updates**

```bash
git add coding_template/templates/workflow.yaml coding_template/AGENTS.md coding_template/CLAUDE.md
git commit -m "docs: add loop workflow metadata and entry rules"
```

### Task 4: Add Validator Coverage For Loop Mainline Artifacts

**Files:**
- Modify: `coding_template/scripts/test-validate-template.sh`
- Modify: `coding_template/scripts/validate-template.sh`

- [ ] **Step 1: Write failing negative tests for missing loop coverage**

Add these cases to `coding_template/scripts/test-validate-template.sh` inside `expect_fail()`:

```bash
    missing-loop-prompt)
      perl -0pi -e 's/^## 持续优化 Loop\n.*?(?=\n## |\z)//ms' "$case_root/prompt.md"
      ;;
    missing-runtime-loop-ledger)
      perl -0pi -e 's/^## Loop 执行台账\n.*?(?=\n## |\z)//ms' "$case_root/templates/runtime-prompt.md"
      ;;
    missing-workflow-loop-fields)
      perl -0pi -e 's/^# 持续优化 Loop 补充字段：\n.*?(?=\n# 默认主线|\z)//ms' "$case_root/templates/workflow.yaml"
      ;;
    missing-agent-loop-rules)
      perl -0pi -e 's/^### 持续优化 Loop（已有项目优先）\n.*?(?=\n### |\n## |\z)//ms' "$case_root/AGENTS.md"
      ;;
    missing-claude-loop-rules)
      perl -0pi -e 's/^### 持续优化 Loop（已有项目优先）\n.*?(?=\n### |\n## |\z)//ms' "$case_root/CLAUDE.md"
      ;;
```

And add these assertions at the bottom:

```bash
expect_fail missing-loop-prompt "MISSING text in prompt.md: ## 持续优化 Loop"
expect_fail missing-runtime-loop-ledger "MISSING text in templates/runtime-prompt.md: ## Loop 执行台账"
expect_fail missing-workflow-loop-fields "MISSING text in templates/workflow.yaml: 持续优化 Loop 补充字段"
expect_fail missing-agent-loop-rules "MISSING text in AGENTS.md: ### 持续优化 Loop（已有项目优先）"
expect_fail missing-claude-loop-rules "MISSING text in CLAUDE.md: ### 持续优化 Loop（已有项目优先）"
```

- [ ] **Step 2: Run the negative tests to confirm they fail before validator updates**

Run:

```bash
./coding_template/scripts/test-validate-template.sh
```

Expected: FAIL with the first missing-loop message because the validator does not yet require those strings.

- [ ] **Step 3: Extend `validate-template.sh` to enforce loop mainline presence**

Add these `require_text` checks in `coding_template/scripts/validate-template.sh`:

```bash
  require_text "prompt.md" "## 持续优化 Loop"
  require_text "prompt.md" "### 持续优化总控 spec"
  require_text "prompt.md" "### Phase 拆解 spec"
  require_text "prompt.md" "### Loop 恢复 / 阻塞上报"
  require_text "AI-BOOTSTRAP.md" "持续优化 Loop 主线"
  require_text "README.md" "## 持续优化 Loop（已有项目优先）"
  require_text "reference/documentation-governance.md" "## 持续优化 Loop 文档"
  require_text "templates/runtime-prompt.md" "## Loop 执行台账"
  require_text "templates/runtime-prompt.md" "当前 loop 主题"
  require_text "templates/runtime-prompt.md" "最终验收标准达成度"
  require_text "templates/workflow.yaml" "持续优化 Loop 补充字段"
  require_text "templates/workflow.yaml" "phase_type: main | phase"
  require_text "templates/workflow.yaml" "loop_status: pending | ready | in_progress | verifying | passed | failed | blocked | archived"
  require_text "AGENTS.md" "### 持续优化 Loop（已有项目优先）"
  require_text "AGENTS.md" "未达到最终验收标准前不得停止"
  require_text "CLAUDE.md" "### 持续优化 Loop（已有项目优先）"
  require_text "CLAUDE.md" "未达到最终验收标准前不得停止"
```

- [ ] **Step 4: Re-run validator and negative tests until both pass**

Run:

```bash
./coding_template/scripts/validate-template.sh ./coding_template
./coding_template/scripts/test-validate-template.sh
```

Expected:

```text
Template validation passed
Validator negative tests passed
```

- [ ] **Step 5: Commit validator coverage**

```bash
git add coding_template/scripts/validate-template.sh coding_template/scripts/test-validate-template.sh
git commit -m "test: validate continuous improvement loop template"
```

### Task 5: Run The Full Template Verification Sweep And Close The Loop

**Files:**
- Modify: `coding_template/prompt.md`
- Modify: `coding_template/AI-BOOTSTRAP.md`
- Modify: `coding_template/README.md`
- Modify: `coding_template/reference/documentation-governance.md`
- Modify: `coding_template/templates/runtime-prompt.md`
- Modify: `coding_template/templates/workflow.yaml`
- Modify: `coding_template/AGENTS.md`
- Modify: `coding_template/CLAUDE.md`
- Modify: `coding_template/scripts/validate-template.sh`
- Modify: `coding_template/scripts/test-validate-template.sh`

- [ ] **Step 1: Run a consolidated presence scan across every loop surface**

Run:

```bash
rg -n "持续优化 Loop|Phase00-main|Loop 执行台账|phase_type: main |未达到最终验收标准前不得停止|三轮自救" \
  coding_template/prompt.md \
  coding_template/AI-BOOTSTRAP.md \
  coding_template/README.md \
  coding_template/reference/documentation-governance.md \
  coding_template/templates/runtime-prompt.md \
  coding_template/templates/workflow.yaml \
  coding_template/AGENTS.md \
  coding_template/CLAUDE.md \
  coding_template/scripts/validate-template.sh \
  coding_template/scripts/test-validate-template.sh
```

Expected: every target file returns loop-related matches.

- [ ] **Step 2: Run the canonical template verification commands**

Run:

```bash
./coding_template/scripts/validate-template.sh ./coding_template
./coding_template/scripts/test-validate-template.sh
git diff --stat
git status --short
```

Expected:

```text
Template validation passed
Validator negative tests passed
<diff stat only for the intended template files>
<clean status or only the intended modified files before final commit>
```

- [ ] **Step 3: Make the final integration commit**

```bash
git add coding_template docs/superpowers/plans/2026-06-28-continuous-improvement-loop-implementation.md
git commit -m "feat: add continuous improvement loop template"
```

- [ ] **Step 4: Prepare execution notes for the next worker**

Add this execution summary to the final response after implementation:

```text
- 持续优化 Loop 已成为 `coding_template` 第二条标准主线
- 已有项目增量改造默认优先走 `Phase00-main -> PhaseNN spec -> PhaseNN plan -> verify`
- validator 已强制要求 loop 文档骨架、运行态台账和入口规则
- 下一步可以用任意真实项目验证一轮模板安装和 loop 执行
```
