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

echo "Validator negative tests passed"
