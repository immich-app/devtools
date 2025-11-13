#!/bin/sh
output=$(/mdq "$@")

if [ -n "$GITHUB_OUTPUT" ]; then
    output_name="${MDQ_OUTPUT_NAME:-result}"
    echo "$output_name=$output" >> "$GITHUB_OUTPUT"
fi

echo "$output"