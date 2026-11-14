#!/usr/bin/env bash
set -euo pipefail
# Run only in an isolated, inspected checkout. No installation/download here.
audit_dir="$(cd "$(dirname "$0")" && pwd)"
startup_dir="$(mktemp -d)"
trap 'rm -rf "$startup_dir"' EXIT
: > "$startup_dir/empty"
export R_ENVIRON="$startup_dir/empty" R_ENVIRON_USER="$startup_dir/empty"
export R_PROFILE="$startup_dir/empty" R_PROFILE_USER="$startup_dir/empty"
export SRTR_LIVE_TESTS=false
unset SRTR_WD
"${AUDIT_RSCRIPT:-Rscript}" --vanilla "$audit_dir/run.R" "$audit_dir" "${1:-contracts}" "$startup_dir/empty"
