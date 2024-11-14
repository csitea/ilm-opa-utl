#!/bin/env bash

# help: enforce code syncronization on application level
# usage: cd /opt/<<org>>/infra-core ; clear ; ./run -a do_pull_all_repos_in_org ; cd -
do_pull_all_app_repos() {
  j=0
  # Loop through all directories in one directory up
  while read -r dir; do
    remainder=$(($j % 3))
    test $remainder -eq 0 && echo "\nSTART ::: sleep for $j " &&
      printf "\033[2J"
    printf "\033[0;0H" && sleep 3
    {
      # Check if the directory is a git repository
      if [ -d "$dir/.git" ]; then
        abs_dir=$(perl -e 'use File::Basename; use Cwd "abs_path"; print abs_path(@ARGV[0]);' -- "$dir")
        test $remainder -eq 0 && echo -e "\n\n"
        test $remainder -eq 1 && echo -e "\n\n\n\n\n\n\n\n\n\n"
        test $remainder -eq 2 && echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        proj=$(echo "$dir" | perl -ne 's|\.\./([0-9a-zA-Z\-\.]+?)/|$1|g;print')
        echo -e "\nSTART ::: Pulling in $proj ..."
        echo working on dir: $abs_dir
        cd "$dir"
        curr_branch=$(git rev-parse --abbrev-ref HEAD)
        echo "working on $proj project the following branch: $curr_branch"
        echo "Action !!! running: git fetch --all -p ; git pull --rebase --all:"
        test $proj == "$PROJ" && continue
        git fetch --all -p
        git pull --rebase --all
        rv=$?
        test $rv != "0" && do_log "FATAL failed to pull rebase $proj" &&
          ps aux | grep 'do_pull_all_repos_in_org' | awk '{print $2}' | xargs kill -9
        # go back back to the original directory
        cd - >/dev/null
      fi
    } &

    j=$((j + 1))
  done < <(ls -d1 ../*/)

  export EXIT_CODE=0
}
