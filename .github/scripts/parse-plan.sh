#!/usr/bin/env bash
set -uo pipefail

# Parses terragrunt run-all plan output and formats it as markdown
# with collapsible sections per module.
#
# Usage: parse-plan.sh <plan-output-file> <group-name>

RAW_FILE="$1"
GROUP_NAME="$2"

# Strip ANSI escape codes for parsing (colors are preserved in CI log output)
FILE=$(mktemp)
sed "s/$(printf '\033')\[[0-9;]*m//g" "$RAW_FILE" > "$FILE"
trap 'rm -f "$FILE"' EXIT

echo "### $GROUP_NAME"
echo ""

# Extract unique module names from terragrunt log prefixes
# Format: "HH:MM:SS.mmm (INFO|STDOUT|STDERR) [module/name] ..."
modules=$(grep -oP '\d+:\d+:\d+\.\d+\s+(?:INFO|STDOUT|STDERR)\s+\[\K[\w/-]+(?=\])' "$FILE" | sort -u)

if [ -z "$modules" ]; then
  echo "⚠️ No modules detected in plan output — the output format may have changed."
  echo ""
  exit 1
fi

for module in $modules; do
  # Extract tofu output lines for this module, stripping everything up to "tofu: "
  module_output=$(grep -P "(?:STDOUT|STDERR)\s+\[$module\] tofu: " "$FILE" | sed "s#.*\[$module\] tofu: ##")

  if [ -z "$module_output" ]; then
    echo "<details><summary>ℹ️ <code>$module</code> — No plan output</summary></details>"
    echo ""
    continue
  fi

  if echo "$module_output" | grep -q "No changes"; then
    echo "<details><summary>✅ <code>$module</code> — No changes</summary></details>"
    echo ""
  elif echo "$module_output" | grep -qE "Error:|error:"; then
    echo "<details><summary>❌ <code>$module</code> — Error</summary>"
    echo ""
    echo '```'
    echo "$module_output" | grep -A5 -E "Error:|error:"
    echo '```'
    echo "</details>"
    echo ""
  else
    summary=$(echo "$module_output" | grep -oE 'Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy\.' | tail -1)

    # Extract just the plan output: everything from "OpenTofu used" or resource lines onward,
    # excluding init/refresh noise
    plan_output=$(echo "$module_output" | grep -vE \
      'Initializing|Downloading|Installing |Installed |Found |Locking |Lock |Using |Reusing|Successfully configured|successfully initialized|providers\.lock|find_in_parent|includes|Reading\.\.\.|Read complete|Refreshing state|backend|OpenTofu will|use this backend|Upgrading|terraform\.io|registry\.opentofu|has been successfully|copying configuration|Copied!|Acquiring state lock|^\s*$' \
    )

    echo "<details><summary>⚠️ <code>$module</code> — ${summary:-Changes detected}</summary>"
    echo ""
    echo '```hcl'
    echo "$plan_output"
    echo '```'
    echo "</details>"
    echo ""
  fi
done
