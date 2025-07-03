#!/bin/bash

# Check if file is provided
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <json-file> [hiveViewURLPrefix]"
    exit 1
fi

# Dependencies check
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

json_file="$1"
hive_view_prefix="${2:-}"
hive_view_prefix="${hive_view_prefix%/}" # Remove trailing slash if present
suite_id="$(basename "$json_file" .json)"

# Convert JSON to markdown using jq
{
    echo "## Test: $(jq -r .name "$json_file")"
    echo "<details><summary>Description</summary>$(jq -r .description "$json_file")</details>"
    echo
    echo "### Client Versions"
    jq -r '.clientVersions | to_entries[] | "- **\(.key)**: \(.value)"' "$json_file"
    echo
    echo "### Test Summary"
    echo
    echo "| Total | ✅ | ❌ |"
    echo "|-------------|-----------|-----------|"
    echo "| $(jq -r '.testCases | length' "$json_file") | $(jq -r '[.testCases[].summaryResult.pass] | map(select(. == true)) | length' "$json_file") | $(jq -r '[.testCases[].summaryResult.pass] | map(select(. == false)) | length' "$json_file") |"
    echo
    if [ -n "$hive_view_prefix" ]; then
        echo "Detailed results: [$hive_view_prefix/$suite_id]($hive_view_prefix/$suite_id)"
    fi
    echo
} > "${json_file%.*}.md"

echo "Markdown file created: ${json_file%.*}.md"
