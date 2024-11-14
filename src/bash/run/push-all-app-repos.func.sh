#!/bin/env bash

do_push_all_app_repos() {
  do_require_var GIT_MSG "${GIT_MSG:-}"

  local git_msg="$GIT_MSG"

  local start_dir=$(dirname "$(pwd)")

  find "$start_dir" -type d -name .git | while read -r repo; do
    local repo_dir=$(dirname "$repo")
    echo "Processing $repo_dir"
    cd "$repo_dir" || continue

    git add .
    git commit -m "$git_msg"
    git push

    # Return to the original directory
    cd - >/dev/null
  done

  export EXIT_CODE=0
}
