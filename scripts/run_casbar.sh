#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
casbar_dir="$(dirname "$script_dir")"
if [[ -f "$casbar_dir/dita/VolumeChapter_99_T48_7010.dita" ]]; then
  for argument in "$@"; do
    if [[ "$argument" == "--output" ]]; then
      exec python3 "$script_dir/convert_chapter.py" "$@"
    fi
  done
  sync_formats=()
  reading_formats=false
  for argument in "$@"; do
    if [[ "$argument" == "--formats" ]]; then
      reading_formats=true
      continue
    fi
    if [[ "$argument" == --* ]]; then
      reading_formats=false
    fi
    if [[ "$reading_formats" == true ]]; then
      sync_formats+=("$argument")
    fi
  done
  work_dir="$(mktemp -d -t casbar-conversion.XXXXXX)"
  trap 'rm -rf "$work_dir"' EXIT
  python3 "$script_dir/convert_chapter.py" "$@" --output "$work_dir" --skip-publish
  if (( ${#sync_formats[@]} )); then
    python3 "$script_dir/sync_to_casbar_repo.py" "$casbar_dir" --from-output "$work_dir" --formats "${sync_formats[@]}"
  else
    python3 "$script_dir/sync_to_casbar_repo.py" "$casbar_dir" --from-output "$work_dir"
  fi
else
  exec python3 "$script_dir/convert_chapter.py" "$@"
fi
