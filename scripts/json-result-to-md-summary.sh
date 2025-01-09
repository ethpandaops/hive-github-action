#!/bin/bash

# Check if file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <json-file>"
    exit 1
fi

# Dependencies check
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

json_file="$1"

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
} > "${json_file%.*}.md"

echo "Markdown file created: ${json_file%.*}.md"
