#!/usr/bin/env bash
# Fails if the repository tracks anything that looks like SRTR patient-level
# data. Run from the repository root: bash .github/scripts/check-no-patient-data.sh
#
# Three checks on files tracked by git:
#   1. Data-file formats SRTR SAFs come in (or are converted to).
#   2. CSV/TSV/TXT files whose header has an SRTR identifier column.
#      Synthetic test data is allowed only under tests/testthat/fixtures/
#      in a file whose name starts with "synthetic-".
#   3. Any single file over 5 MB.
set -euo pipefail

fail=0

formats=$(git ls-files | grep -iE '\.(sas7bdat|sas7bcat|xpt|parquet|feather|arrow|dta|sav)$' || true)
if [ -n "$formats" ]; then
  echo "::error::Data files in SAF formats are tracked. SRTR data must never be committed:"
  echo "$formats"
  fail=1
fi

ids='(^|[,;	"])(TRR_ID|TRR_FOL_ID|PX_ID|PERS_ID|DONOR_ID|CAN_ID|TX_ID|REC_ID)([,;	"]|$)'
while IFS= read -r f; do
  case "$f" in
    tests/testthat/fixtures/synthetic-*) continue ;;
  esac
  if head -n 1 -- "$f" | grep -qiE "$ids"; then
    echo "::error file=$f::Header has an SRTR identifier column. Real SRTR data must never be committed; synthetic test data belongs in tests/testthat/fixtures/synthetic-*."
    fail=1
  fi
done < <(git ls-files | grep -iE '\.(csv|tsv|txt)$' || true)

big=$(git ls-files -z | xargs -0 -r du -k -- 2>/dev/null | awk '$1 > 5120 {printf "%s (%.1f MB)\n", $2, $1/1024}')
if [ -n "$big" ]; then
  echo "::error::Files over 5 MB are tracked. Check that none holds data:"
  echo "$big"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "No patient-level data found."
fi
exit "$fail"
