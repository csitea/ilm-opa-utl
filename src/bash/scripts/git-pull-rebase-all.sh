#!/bin/bash
    current_dir=$(pwd)/..

    # Find all git repositories and execute git pull --rebase
    find "$current_dir" -type d -name .git | while read -r repo; do
        repo_dir=$(dirname "$repo")
        echo "Updating $repo_dir"
        cd "$repo_dir" || continue
        git pull --rebase
        test "$?" -ne 0 && exit 1
        cd "$current_dir" || return
    done

