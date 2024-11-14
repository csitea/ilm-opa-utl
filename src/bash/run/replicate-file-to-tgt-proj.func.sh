#!/bin/env bash

# Usage:
# SRC_PATH=/path/to/source/file GIT_MSG="Commit message" TGT_ORG=org TGT_APP=app PROJECT_TYPE=type bash /path/to/script -a do_replicate_file_to_tgt_proj

do_replicate_file_to_tgt_proj() {

  do_require_var SRC_PATH "${SRC_PATH:-}"
  do_require_var GIT_MSG "${GIT_MSG:-}"
  do_require_var TGT_ORG "${TGT_ORG:-}"
  do_require_var TGT_APP "${TGT_APP:-}"

  # Log the source path for reference
  echo "Source path: ${SRC_PATH}"

  # Extract 'project_type' from the last part of the path, after the last '-'
  local extracted_project_type=$(echo "${SRC_PATH}" | grep -oP '(?<=[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z]{3}/' | tr -d '\n')

  # Use PROJECT_TYPE if set, otherwise use extracted_project_type
  PROJECT_TYPE=${PROJECT_TYPE:-$extracted_project_type}
  PROJECT_TYPE=${PROJECT_TYPE%/}
  echo "Project type: ${PROJECT_TYPE}"

  SRC_PROJ_PATH=$(echo "${SRC_PATH}" | grep -oP '(.*/[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z0-9-]*/' | sed 's|/[^/]*$||')
  echo "SRC_PROJ_PATH : ${SRC_PROJ_PATH}"

  # Convert /opt/bas/bas-wpb/bas-wpb-inf/src/terraform/008-gcp-subzones/
  # to /src/terraform/008-gcp-subzones/
  SRC_RELATIVE_PATH="${SRC_PATH#${SRC_PROJ_PATH}/}"

  # Construct the base replication path
  BAS_PATH="$BASE_PATH/$TGT_ORG/$TGT_ORG-$TGT_APP/$TGT_ORG-$TGT_APP-${PROJECT_TYPE}"
  echo "Base path for Git operations: ${BAS_PATH}"

  TGT_PATH="${BAS_PATH}/${SRC_RELATIVE_PATH}"
  echo "Target path for replication: ${TGT_PATH}"

  # Ensure the target directory exists
  mkdir -p "$(dirname "${TGT_PATH}")"

  # Ensure we are in the correct directory and it's clean
  cd "${BAS_PATH}" || {
    do_log "FATAL: Cannot change to ${BAS_PATH}"
    export EXIT_CODE=1
    return 1
  }
  if [ $(git status --porcelain | grep '^\(??\| M\)' | wc -l) -ne 0 ]; then
    do_log "FATAL: There are uncommitted changes in ${BAS_PATH} !!!
            Please commit or stash them before replicating."
    export EXIT_CODE=1
    return 1
  fi

  # Perform Git operations
  git pull --rebase || { do_log "WARNING: Git pull failed. Proceeding with replication anyway."; }

  # Copy from SRC_PATH to the corresponding file in BAS_PATH
  cp -v "${SRC_PATH}" "${TGT_PATH}" || {
    do_log "FATAL: Failed to copy file"
    export EXIT_CODE=1
    return 1
  }

  # Prepare for Git commit
  git add "${TGT_PATH}"
  git commit -m "${GIT_MSG}" || { do_log "WARNING: Git commit failed. No changes to commit."; }
  git push || { do_log "WARNING: Git push failed. Please push changes manually."; }

  export EXIT_CODE=0
}
