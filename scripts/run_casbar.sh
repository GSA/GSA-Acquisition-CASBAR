#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
casbar_dir="$(dirname "$script_dir")"
git_paths=(dita Graphics source html html5 pdf docx epub publication-metadata.json)
no_git=false
forward_args=()
for argument in "$@"; do
  if [[ "$argument" == "--no-git" ]]; then
    no_git=true
  else
    forward_args+=("$argument")
  fi
done

fail() {
  printf 'CASBAR: %s\n' "$*" >&2
  exit 1
}

check_git_checkout() {
  git -C "$casbar_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "CASBAR must be a Git checkout to push results"
  branch="$(git -C "$casbar_dir" symbolic-ref --quiet --short HEAD)" || fail "Check out a branch before running CASBAR"
  upstream="$(git -C "$casbar_dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}')" || fail "Set an upstream for $branch"
  [[ "$upstream" == "origin/$branch" ]] || fail "Expected upstream origin/$branch; found $upstream"
  git -C "$casbar_dir" diff --quiet && git -C "$casbar_dir" diff --cached --quiet || fail "Commit or discard tracked local changes first"
  [[ -z "$(git -C "$casbar_dir" status --porcelain --untracked-files=all -- "${git_paths[@]}")" ]] || fail "Generated output paths contain untracked files"
  git -C "$casbar_dir" fetch --quiet origin "$branch" || fail "Could not fetch origin/$branch"
  [[ "$(git -C "$casbar_dir" rev-parse HEAD)" == "$(git -C "$casbar_dir" rev-parse '@{u}')" ]] || fail "Local branch must match origin/$branch before conversion"
}

commit_and_push() {
  git -C "$casbar_dir" fetch --quiet origin "$branch" || fail "Could not recheck origin/$branch"
  [[ "$(git -C "$casbar_dir" rev-parse HEAD)" == "$(git -C "$casbar_dir" rev-parse '@{u}')" ]] || fail "Remote branch changed during conversion; review local output before retrying"
  git -C "$casbar_dir" add -A -- "${git_paths[@]}"
  if git -C "$casbar_dir" diff --cached --quiet; then
    echo "CASBAR output is unchanged; no commit needed"
    return
  fi
  git -C "$casbar_dir" commit -m "Refresh CASBAR Chapter 99 from GovInfo"
  git -C "$casbar_dir" push origin "HEAD:$branch" || fail "Commit remains local; push to origin/$branch failed"
  echo "Pushed CASBAR commit $(git -C "$casbar_dir" rev-parse --short HEAD) to origin/$branch"
}

if [[ -f "$casbar_dir/dita/VolumeChapter_99_T48_7010.dita" ]]; then
  for argument in "${forward_args[@]}"; do
    if [[ "$argument" == "--output" ]]; then
      exec python3 "$script_dir/convert_chapter.py" "${forward_args[@]}"
    fi
  done
  if [[ "$no_git" == false ]]; then
    check_git_checkout
  fi
  sync_formats=()
  reading_formats=false
  for argument in "${forward_args[@]}"; do
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
  python3 "$script_dir/convert_chapter.py" "${forward_args[@]}" --output "$work_dir" --skip-publish
  if (( ${#sync_formats[@]} )); then
    python3 "$script_dir/sync_to_casbar_repo.py" "$casbar_dir" --from-output "$work_dir" --formats "${sync_formats[@]}"
  else
    python3 "$script_dir/sync_to_casbar_repo.py" "$casbar_dir" --from-output "$work_dir"
  fi
  if [[ "$no_git" == false ]]; then
    commit_and_push
  fi
else
  exec python3 "$script_dir/convert_chapter.py" "${forward_args[@]}"
fi
