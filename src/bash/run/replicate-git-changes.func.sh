#!/bin/env bash

do_replicate_git_changes() {

  do_require_var SRC_COMMIT_HASH "${SRC_COMMIT_HASH:-}"
  do_require_var TGT_COMMIT_HASH "${TGT_COMMIT_HASH:-}"
  do_require_var TGT_ORG "${TGT_ORG:-}"
  do_require_var TGT_APP "${TGT_APP:-}"

  SRC_BASE_PATH=$PROJ_PATH

  # Extract 'PROJECT_TYPE' from the last part of the path, after the last '-'
  PROJECT_TYPE=$(echo "${SRC_BASE_PATH}" | grep -oP '[a-zA-Z]+(?=/?$)' | tr -d '\n')
  PROJECT_TYPE=${PROJECT_TYPE%/} # Ensure no trailing slash
  echo "Project type: ${PROJECT_TYPE}"

  # Construct the base replication path
  TGT_BASE_PATH="$BASE_PATH/$TGT_ORG/$TGT_ORG-$TGT_APP/$TGT_ORG-$TGT_APP-${PROJECT_TYPE}"

  # Get the list of changes from git diff, formatted to show statuses and paths
  git diff --name-status ${TGT_COMMIT_HASH} ${SRC_COMMIT_HASH} | while read status file_path; do
    # Resolve the SRC_PATH and TGT_PATH based on file_path
    local SRC_PATH="${SRC_BASE_PATH}/${file_path}"
    local TGT_PATH="${TGT_BASE_PATH}/${file_path}"

    case $status in
    M | A) # Modified or Added files
      do_log "INFO File $file_path was $status ( added or modified). Syncing to target project..."
      export SRC_PATH="${SRC_PATH}" # Set environment variable for existing function
      export GIT_MSG="Sync: Update due to $status of $file_path"
      ./run -a do_replicate_file_to_bas
      ;;
    D) # Deleted files
      echo "File $file_path was deleted. Removing from target project..."
      if [ -f "${TGT_PATH}" ]; then
        rm -v "${TGT_PATH}"
        # Assuming we want to commit these changes, you would navigate and handle Git commits here
        cd "${TGT_BASE_PATH}"
        git add "${file_path}"
        git commit -m "$JIRA_TICKET Sync: Remove deleted file $file_path"
        git push
      else
        echo "No target file to delete at ${TGT_PATH}"
      fi
      ;;
    esac

  done
  export EXIT_CODE="0"
}
