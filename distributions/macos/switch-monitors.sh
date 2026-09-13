#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 || ! $1 =~ ^[12]$ || ( $# -eq 2 && $2 != --dry-run ) ]]; then
    echo "Usage: $0 {1|2} [--dry-run]" >&2
    exit 2
fi
pc=$1
dry_run=${2:-}
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config=${MONITOR_INPUTS_CONFIG:-"$script_dir/../monitor-inputs.json"}
# Shortcuts does not normally inherit an interactive shell's Homebrew PATH.
export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
command -v jq >/dev/null || { echo 'Install dependencies: brew install m1ddc jq' >&2; exit 1; }

# Build and validate the complete batch first, including stable display UUIDs.
commands=$(jq -ber --arg key "pc$pc" '
    if type != "array" or length == 0 then error("Expected a nonempty monitor array") else . end
    | if all(.[];
        (.name | type == "string" and test("^[^\\t\\r\\n]+$")) and
        (.displayUuid | type == "string" and test("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$")) and
        (.[$key] | type == "number" and . == floor and . >= 0 and . <= 65535))
      then . else error("Invalid monitor entry: fill displayUuid with System UUIDs from m1ddc display list detailed; check names and input values") end
    | if ([.[].displayUuid | ascii_downcase] | unique | length) == length
      then . else error("Each monitor must have a unique displayUuid") end
    | .[] | [.name, .displayUuid, .[$key]] | @tsv
' "$config")

if [[ -z $dry_run ]]; then
    command -v m1ddc >/dev/null || { echo 'Install m1ddc: brew install m1ddc' >&2; exit 1; }
fi

status=0
while IFS=$'\t' read -r name identifier input; do
    if [[ -n $dry_run ]]; then
        printf '%s -> PC %s: m1ddc display %s set input %s\n' "$name" "$pc" "$identifier" "$input"
    else
        printf '%s -> PC %s (input %s)\n' "$name" "$pc" "$input"
        if ! m1ddc display "$identifier" set input "$input"; then
            printf 'Failed to send input for %s; continuing with remaining monitors.\n' "$name" >&2
            status=1
        fi
    fi
done <<< "$commands"
exit "$status"
