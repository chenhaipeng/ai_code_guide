#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"
failures=0

check_file() {
  local path="$1"
  if [[ ! -f "$root/$path" ]]; then
    echo "MISSING file: $path"
    failures=$((failures + 1))
  fi
}

check_dir() {
  local path="$1"
  if [[ ! -d "$root/$path" ]]; then
    echo "MISSING dir: $path"
    failures=$((failures + 1))
  fi
}

check_file "README.md"
check_file "AI-BOOTSTRAP.md"
check_file "prompt.md"
check_file "AGENTS.md"
check_file "CLAUDE.md"
check_dir "specs"
check_dir "templates"
check_dir "scripts"
check_file "templates/decision.md"
check_file "templates/progress.md"
check_file "templates/runtime-prompt.md"

require_text() {
  local path="$1"
  local text="$2"
  if ! grep -F "$text" "$root/$path" >/dev/null 2>&1; then
    echo "MISSING text in $path: $text"
    failures=$((failures + 1))
  fi
}

for spec in \
  "00-idea-brief.md" \
  "01-product-spec.md" \
  "02-e2e-acceptance.md" \
  "03-delivery-report.md" \
  "10-ux-prototype.md" \
  "20-architecture.md" \
  "30-data-design.md" \
  "40-api-and-pages.md" \
  "50-implementation-constraints.md" \
  "90-implementation-plan.md"; do
  check_file "specs/$spec"
done

if command -v grep >/dev/null 2>&1; then
  if grep -R "将 .template/ 加入目标项目的 .gitignore" "$root" --exclude "validate-template.sh" >/dev/null 2>&1; then
    echo "INVALID old .template gitignore instruction found"
    failures=$((failures + 1))
  fi

  for spec_path in "$root"/specs/*.md; do
    [[ -f "$spec_path" ]] || continue
    if ! grep -q "规格状态" "$spec_path"; then
      echo "MISSING spec status: ${spec_path#$root/}"
      failures=$((failures + 1))
    fi
  done

  require_text "AI-BOOTSTRAP.md" "docs/progress.md"
  require_text "AI-BOOTSTRAP.md" "docs/prompt.md"
  require_text "AI-BOOTSTRAP.md" "Prompt 执行台账"
  require_text "AI-BOOTSTRAP.md" ".template/templates/"
  require_text "AI-BOOTSTRAP.md" ".template/scripts/"
  require_text "AI-BOOTSTRAP.md" "validate-template.sh"
  require_text "AI-BOOTSTRAP.md" "规格状态"
  require_text "AI-BOOTSTRAP.md" "AI Extracted"
  require_text "AI-BOOTSTRAP.md" "Human Confirmed"
  require_text "AI-BOOTSTRAP.md" "默认随项目入库"
  require_text "README.md" "docs/progress.md"
  require_text "README.md" "docs/prompt.md"
  require_text "README.md" ".template/templates/"
  require_text "README.md" ".template/scripts/validate-template.sh"
  require_text "AGENTS.md" "docs/progress.md"
  require_text "AGENTS.md" "docs/prompt.md"
  require_text "CLAUDE.md" "docs/progress.md"
  require_text "CLAUDE.md" "docs/prompt.md"
  require_text "templates/runtime-prompt.md" "Prompt 执行台账"
  require_text "templates/runtime-prompt.md" "Not Started / In Progress / Done / Skipped / Needs Review / Blocked"
  require_text "prompt.md" "docs/progress.md"
  require_text "prompt.md" "交付门禁"
fi

if [[ "$failures" -gt 0 ]]; then
  echo "Template validation failed: $failures issue(s)"
  exit 1
fi

echo "Template validation passed"
