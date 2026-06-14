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
check_file "templates/workflow.yaml"
check_file "scripts/test-validate-template.sh"

require_text() {
  local path="$1"
  local text="$2"
  if ! grep -F "$text" "$root/$path" >/dev/null 2>&1; then
    echo "MISSING text in $path: $text"
    failures=$((failures + 1))
  fi
}

check_workflow_structure() {
  local path="$root/templates/workflow.yaml"
  local output
  local issue_count

  output="$(
    awk '
      function trim(value) {
        sub(/^[[:space:]]+/, "", value)
        sub(/[[:space:]]+$/, "", value)
        return value
      }

      function clean_scalar(value) {
        sub(/[[:space:]]+#.*$/, "", value)
        gsub(/"/, "", value)
        return trim(value)
      }

      function clean_list(value) {
        value = clean_scalar(value)
        sub(/^\[/, "", value)
        sub(/\]$/, "", value)
        return value
      }

      function field(item_id, key) {
        return values[item_id SUBSEP key]
      }

      function has_item_ref(item_id, key, ref,   refs, parts, count, i) {
        refs = clean_list(field(item_id, key))
        if (refs == "") {
          return 0
        }
        count = split(refs, parts, ",")
        for (i = 1; i <= count; i++) {
          if (trim(parts[i]) == ref) {
            return 1
          }
        }
        return 0
      }

      function allowed_workflow_status(value) {
        return value == "pending" || value == "drafting" || value == "review" || value == "ready" || value == "consumed" || value == "verified" || value == "archived" || value == "skipped"
      }

      function allowed_content_status(value) {
        return value == "Draft" || value == "AI Extracted" || value == "Human Confirmed" || value == "Frozen" || value == "Deprecated" || value == "Archived"
      }

      function expected_artifact(item_id, item_type) {
        if (item_type == "spec") {
          return "docs/superpowers/specs/" item_id ".md"
        }
        if (item_type == "plan") {
          return "docs/superpowers/plans/" item_id ".md"
        }
        return ""
      }

      function expected_archive(item_type) {
        if (item_type == "spec") {
          return "docs/superpowers/specs/archive/"
        }
        if (item_type == "plan") {
          return "docs/superpowers/plans/archive/"
        }
        return ""
      }

      function validate_refs(item_id, key,   refs, parts, count, i, ref) {
        refs = clean_list(field(item_id, key))
        if (refs == "") {
          return
        }
        count = split(refs, parts, ",")
        for (i = 1; i <= count; i++) {
          ref = trim(parts[i])
          if (ref != "" && !(ref in seen)) {
            print "INVALID workflow reference in " item_id ": " ref
          }
        }
      }

      /^current:/ {
        current = $0
        sub(/^current:[ ]*/, "", current)
        current = clean_scalar(current)
      }

      /^  - id: / {
        item_id = $3
        ids[++id_count] = item_id
        seen[item_id] = 1
        seen_count[item_id]++
        next
      }

      item_id != "" && /^    [A-Za-z_]+:/ {
        key = $1
        sub(/:$/, "", key)
        value = $0
        sub(/^    [^:]+:[ ]*/, "", value)
        values[item_id SUBSEP key] = clean_scalar(value)
      }

      END {
        required[1] = "type"
        required[2] = "artifact_path"
        required[3] = "archive_path"
        required[4] = "status"
        required[5] = "content_status"
        required[6] = "depends_on"
        required[7] = "triggers"

        if (current != "" && !(current in seen)) {
          print "INVALID workflow current item: " current
        }

        for (item_id in seen_count) {
          if (seen_count[item_id] > 1) {
            print "DUPLICATE workflow id: " item_id
          }
        }

        for (i = 1; i <= id_count; i++) {
          item_id = ids[i]
          for (required_index = 1; required_index <= 7; required_index++) {
            key = required[required_index]
            if (field(item_id, key) == "") {
              print "MISSING workflow field for " item_id ": " key
            }
          }

          item_type = field(item_id, "type")
          artifact = field(item_id, "artifact_path")
          archive = field(item_id, "archive_path")
          workflow_status = field(item_id, "status")
          content_status = field(item_id, "content_status")

          if (!allowed_workflow_status(workflow_status)) {
            print "INVALID workflow status for " item_id ": " workflow_status
          }

          if (!allowed_content_status(content_status)) {
            print "INVALID workflow content_status for " item_id ": " content_status
          }

          if (item_type != "spec" && item_type != "plan") {
            print "INVALID workflow type for " item_id ": " item_type
          } else {
            expected_item_artifact = expected_artifact(item_id, item_type)
            expected_item_archive = expected_archive(item_type)
            if (artifact != expected_item_artifact) {
              print "INVALID workflow artifact_path for " item_id ": expected " expected_item_artifact ", got " artifact
            }
            if (archive != expected_item_archive) {
              print "INVALID workflow archive_path for " item_id ": expected " expected_item_archive ", got " archive
            }
          }

          if (workflow_status == "archived" && content_status != "Archived") {
            print "INVALID workflow archive state for " item_id ": archived requires content_status Archived"
          }

          if (workflow_status == "skipped") {
            if (field(item_id, "optional") != "true") {
              print "INVALID workflow skip state for " item_id ": skipped requires optional: true"
            }
            if (field(item_id, "skip_requires") == "") {
              print "MISSING workflow skip_requires for skipped item: " item_id
            }
          }

          validate_refs(item_id, "depends_on")
          validate_refs(item_id, "triggers")
        }

        if (field("10-ux-prototype", "optional") != "true") {
          print "INVALID UX workflow gate: 10-ux-prototype must be optional"
        }
        if (field("10-ux-prototype", "skip_requires") == "") {
          print "MISSING UX workflow gate: 10-ux-prototype skip_requires"
        }
        if (clean_list(field("05-domain-research", "triggers")) != "10-ux-prototype") {
          print "INVALID UX workflow gate: 05-domain-research should trigger only 10-ux-prototype"
        }
        if (clean_list(field("10-ux-prototype", "triggers")) != "20-architecture") {
          print "INVALID UX workflow gate: 10-ux-prototype should trigger 20-architecture"
        }
        if (!has_item_ref("20-architecture", "depends_on", "05-domain-research") || !has_item_ref("20-architecture", "depends_on", "10-ux-prototype")) {
          print "INVALID UX workflow gate: 20-architecture must depend on 05-domain-research and 10-ux-prototype"
        }
      }
    ' "$path"
  )"

  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
    issue_count="$(printf '%s\n' "$output" | sed '/^[[:space:]]*$/d' | wc -l | tr -d ' ')"
    failures=$((failures + issue_count))
  fi
}

for spec in \
  "00-idea-brief.md" \
  "01-product-spec.md" \
  "02-e2e-acceptance.md" \
  "03-delivery-report.md" \
  "05-domain-research.md" \
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
  require_text "AI-BOOTSTRAP.md" "docs/workflow.yaml"
  require_text "AI-BOOTSTRAP.md" 'docs/workflow.yaml.current` 为权威当前 item'
  require_text "AI-BOOTSTRAP.md" '当前阶段以 `docs/workflow.yaml.current` 为权威'
  require_text "AI-BOOTSTRAP.md" '90-implementation-plan` 为止；进入代码实现后'
  require_text "AI-BOOTSTRAP.md" "docs/superpowers/specs/"
  require_text "AI-BOOTSTRAP.md" "docs/superpowers/specs/archive/"
  require_text "AI-BOOTSTRAP.md" "docs/superpowers/plans/"
  require_text "AI-BOOTSTRAP.md" "docs/superpowers/plans/archive/"
  require_text "AI-BOOTSTRAP.md" "docs/research/"
  require_text "AI-BOOTSTRAP.md" "docs/superpowers/specs/05-domain-research.md"
  require_text "AI-BOOTSTRAP.md" "Domain Research / Data Discovery"
  require_text "AI-BOOTSTRAP.md" ".template/specs/05-domain-research.md"
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
  require_text "README.md" "docs/workflow.yaml"
  require_text "README.md" "docs/superpowers/specs/"
  require_text "README.md" "docs/superpowers/specs/archive/"
  require_text "README.md" "docs/superpowers/plans/"
  require_text "README.md" "docs/superpowers/plans/archive/"
  require_text "README.md" "docs/research/"
  require_text "README.md" "docs/superpowers/specs/05-domain-research.md"
  require_text "README.md" "## 标准闭环流程"
  require_text "README.md" "10-ux-prototype"
  require_text "README.md" "20-architecture"
  require_text "README.md" ".template/templates/"
  require_text "README.md" ".template/scripts/validate-template.sh"
  require_text "README.md" ".template/scripts/test-validate-template.sh"
  require_text "AGENTS.md" "docs/progress.md"
  require_text "AGENTS.md" "docs/prompt.md"
  require_text "AGENTS.md" "docs/superpowers/plans/archive/"
  require_text "AGENTS.md" "## 4. 开发流程（强制 Superpowers 工作流）"
  require_text "CLAUDE.md" "## 4. 开发流程（强制 Superpowers 工作流）"
  require_text "CLAUDE.md" "docs/progress.md"
  require_text "CLAUDE.md" "docs/prompt.md"
  require_text "CLAUDE.md" "docs/superpowers/plans/archive/"
  require_text "templates/runtime-prompt.md" "Prompt 执行台账"
  require_text "templates/runtime-prompt.md" "Domain Research / Data Discovery"
  require_text "templates/runtime-prompt.md" "docs/superpowers/specs/05-domain-research.md"
  require_text "templates/runtime-prompt.md" "docs/superpowers/plans/90-implementation-plan.md"
  require_text "templates/runtime-prompt.md" "Not Started / In Progress / Needs Review / Human Confirmed / Consumed / Verified / Archived / Done / Skipped / Blocked"
  require_text "templates/workflow.yaml" "docs/superpowers/specs/archive/"
  require_text "templates/workflow.yaml" "docs/superpowers/plans/archive/"
  require_text "templates/workflow.yaml" "本文件跟踪 spec/plan 脚手架到 90-implementation-plan 为止"
  require_text "templates/workflow.yaml" "items:"
  require_text "templates/workflow.yaml" "type: spec"
  require_text "templates/workflow.yaml" "type: plan"
  require_text "templates/workflow.yaml" "artifact_path:"
  require_text "templates/workflow.yaml" "archive_path:"
  require_text "templates/workflow.yaml" "content_status:"
  require_text "templates/workflow.yaml" "skipped"
  require_text "templates/workflow.yaml" "depends_on: [05-domain-research, 10-ux-prototype]"
  require_text "prompt.md" "docs/progress.md"
  require_text "prompt.md" "## 通用状态转移规则"
  require_text "prompt.md" '执行任何阶段 prompt 前，先读取 `docs/workflow.yaml.current`'
  require_text "prompt.md" "Domain Research / Data Discovery"
  require_text "prompt.md" "docs/superpowers/specs/05-domain-research.md"
  require_text "prompt.md" "docs/superpowers/plans/90-implementation-plan.md"
  require_text "prompt.md" "Domain Research / Data Discovery：[路径]"
  require_text "prompt.md" "docs/research/：[路径或无]"
  require_text "prompt.md" "交付门禁"
  require_text "reference/documentation-governance.md" "## 主流程状态机"
  require_text "reference/documentation-governance.md" 'docs/workflow.yaml.current` 是当前 spec / plan item 的权威来源'
  require_text "reference/documentation-governance.md" "pending / drafting / review / ready / consumed / verified / archived / skipped"

  if [[ -f "$root/templates/workflow.yaml" ]]; then
    check_workflow_structure
  fi
fi

if [[ "$failures" -gt 0 ]]; then
  echo "Template validation failed: $failures issue(s)"
  exit 1
fi

echo "Template validation passed"
