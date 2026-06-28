#!/usr/bin/env bash
set -euo pipefail

template_root="$(cd "$(dirname "$0")/.." && pwd)"
validator="$template_root/scripts/validate-template.sh"
tmp_root="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

copy_case() {
  local name="$1"
  local case_root="$tmp_root/$name"
  cp -R "$template_root" "$case_root"
  printf '%s\n' "$case_root"
}

expect_pass() {
  local name="$1"
  local case_root
  case_root="$(copy_case "$name")"
  "$validator" "$case_root" >"$tmp_root/$name.out"
}

expect_fail() {
  local name="$1"
  local expected="$2"
  local case_root
  local output
  case_root="$(copy_case "$name")"

  case "$name" in
    bad-current)
      perl -0pi -e 's/current: ""/current: "missing-item"/' "$case_root/templates/workflow.yaml"
      ;;
    ux-bypass)
      perl -0pi -e 's/depends_on: \[05-domain-research, 10-ux-prototype\]/depends_on: [05-domain-research]/' "$case_root/templates/workflow.yaml"
      ;;
    bad-status)
      perl -0pi -e 's/status: pending/status: unknown-state/' "$case_root/templates/workflow.yaml"
      ;;
    archived-with-draft-content)
      perl -0pi -e 's/status: pending/status: archived/' "$case_root/templates/workflow.yaml"
      ;;
    bad-plan-archive)
      perl -0pi -e 's#archive_path: docs/superpowers/plans/archive/#archive_path: docs/superpowers/specs/archive/#' "$case_root/templates/workflow.yaml"
      ;;
    missing-bootstrap-workflow-authority)
      perl -0pi -e 's/^.*docs\/workflow\.yaml\.current.*权威.*\n//mg' "$case_root/AI-BOOTSTRAP.md"
      ;;
    missing-bootstrap-post-plan-layering)
      perl -0pi -e 's/^.*90-implementation-plan.*docs\/e2e\/verify.*\n//mg' "$case_root/AI-BOOTSTRAP.md"
      ;;
    missing-governance-state-machine)
      perl -0pi -e 's/^## 主流程状态机\n.*?(?=\n## |\z)//ms' "$case_root/reference/documentation-governance.md"
      ;;
    missing-prompt-transition-rule)
      perl -0pi -e 's/^## 通用状态转移规则\n.*?(?=\n---\n)//ms' "$case_root/prompt.md"
      ;;
    missing-runtime-ledger-split)
      perl -0pi -e 's/^> Prompt 状态枚举：.*\n//m' "$case_root/templates/runtime-prompt.md"
      ;;
    obsolete-progress-template)
      printf '# obsolete\n' > "$case_root/templates/progress.md"
      ;;
    obsolete-progress-reference)
      printf '\nobsolete docs/progress.md reference\n' >> "$case_root/README.md"
      ;;
    obsolete-spec-template-dir)
      mkdir -p "$case_root/specs"
      printf '# obsolete\n' > "$case_root/specs/00-idea-brief.md"
      ;;
    missing-delivery-outside-workflow)
      perl -0pi -e 's/^.*03-delivery-report.*不进入.*workflow.*\n//mg' "$case_root/AI-BOOTSTRAP.md"
      ;;
    missing-workflow-self-check)
      perl -0pi -e 's/^\| `docs\/workflow\.yaml` .*?\n//m' "$case_root/AI-BOOTSTRAP.md"
      ;;
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
    *)
      echo "Unknown test case: $name"
      return 1
      ;;
  esac

  if output="$("$validator" "$case_root" 2>&1)"; then
    echo "Expected validation failure for $name, but it passed"
    return 1
  fi

  if ! printf '%s\n' "$output" | grep -F "$expected" >/dev/null 2>&1; then
    echo "Expected validation failure for $name to contain: $expected"
    echo "Actual output:"
    printf '%s\n' "$output"
    return 1
  fi
}

expect_pass baseline
expect_fail bad-current "INVALID workflow current item: missing-item"
expect_fail ux-bypass "INVALID UX workflow gate: 20-architecture must depend on 05-domain-research and 10-ux-prototype"
expect_fail bad-status "INVALID workflow status for 00-idea-brief: unknown-state"
expect_fail archived-with-draft-content "INVALID workflow archive state for 00-idea-brief: archived requires content_status Archived"
expect_fail bad-plan-archive "INVALID workflow archive_path for 90-implementation-plan: expected docs/superpowers/plans/archive/, got docs/superpowers/specs/archive/"
expect_fail missing-bootstrap-workflow-authority "MISSING text in AI-BOOTSTRAP.md: docs/workflow.yaml.current"
expect_fail missing-bootstrap-post-plan-layering "MISSING text in AI-BOOTSTRAP.md: 90-implementation-plan"
expect_fail missing-governance-state-machine "MISSING text in reference/documentation-governance.md: ## 主流程状态机"
expect_fail missing-prompt-transition-rule "MISSING text in prompt.md: ## 通用状态转移规则"
expect_fail missing-runtime-ledger-split "MISSING text in templates/runtime-prompt.md: Prompt 状态枚举"
expect_fail obsolete-progress-template "INVALID obsolete template file: templates/progress.md"
expect_fail obsolete-progress-reference "INVALID obsolete progress.md reference found"
expect_fail obsolete-spec-template-dir "INVALID obsolete spec template dir: specs/"
expect_fail missing-delivery-outside-workflow "MISSING text in AI-BOOTSTRAP.md: 03-delivery-report"
expect_fail missing-workflow-self-check "MISSING text in AI-BOOTSTRAP.md: | \`docs/workflow.yaml\`"
expect_fail missing-loop-prompt "MISSING text in prompt.md: ## 持续优化 Loop"
expect_fail missing-runtime-loop-ledger "MISSING text in templates/runtime-prompt.md: ## Loop 执行台账"
expect_fail missing-workflow-loop-fields "MISSING text in templates/workflow.yaml: 持续优化 Loop 补充字段"
expect_fail missing-agent-loop-rules "MISSING text in AGENTS.md: ### 持续优化 Loop（已有项目优先）"
expect_fail missing-claude-loop-rules "MISSING text in CLAUDE.md: ### 持续优化 Loop（已有项目优先）"

echo "Validator negative tests passed"
