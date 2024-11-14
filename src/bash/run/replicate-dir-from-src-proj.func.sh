#!/bin/env bash

# TGT_PATH=/opt/bas/bas-wpb/bas-wpb-utl/src/bash/ bash /opt/bas/bas-wpb/bas-wpb-utl/run -a do_replicate_dir_from_bas

do_replicate_dir_from_src_proj() {

  do_require_var TGT_PATH "${TGT_PATH:-}"
  do_require_var SRC_ORG "${SRC_ORG:-}"
  do_require_var SRC_APP "${SRC_APP:-}"

  SKIP_GLOBS="${SKIP_GLOBS:-}" # Ensure SKIP_GLOBS is defined

  # Ensure TGT_PATH always DOES NOT ends with a slash
  [[ "${TGT_PATH}" == */ ]] && TGT_PATH="${TGT_PATH%/}"

  # Log the target path for reference
  echo "Target path: ${TGT_PATH}"
  # Extract 'PROJ_TYPE' from the last part of the path, after the last '-'
  PROJECT_TYPE=$(echo "${TGT_PATH}" | grep -oP '(?<=[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z]{3}/' | tr -d '\n')
  PROJECT_TYPE=${PROJECT_TYPE%/}
  echo "Project type: ${PROJECT_TYPE}"

  TGT_PROJ_PATH=$(echo "${TGT_PATH}" | grep -oP '(.*/[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z0-9]+')
  echo "TGT_PROJ_PATH : ${TGT_PROJ_PATH}"

  TGT_RELATIVE_PATH="${TGT_PATH#${TGT_PROJ_PATH}}"
  TGT_RELATIVE_PATH="${TGT_RELATIVE_PATH%/}"
  echo "Target relative path: ${TGT_RELATIVE_PATH}"

  # Construct the base source path
  BAS_PATH="$BASE_PATH/$SRC_ORG/$SRC_ORG-$SRC_APP/$SRC_ORG-$SRC_APP-${PROJECT_TYPE}"
  echo "Base path for replication: ${BAS_PATH}"

  SRC_BAS_PATH="${BAS_PATH}${TGT_RELATIVE_PATH}"
  # Ensure SRC_BAS_PATH always ends with a slash
  [[ "${SRC_BAS_PATH}" != */ ]] && SRC_BAS_PATH="${SRC_BAS_PATH}/"
  echo "Source base path: ${SRC_BAS_PATH}"
  # now WE Must ensure that the SRC_PATH_PATH ALWAYS ends with /

  # Ensure the target directory exists and is ready
  mkdir -p "${TGT_PATH}"
  cd "${TGT_PROJ_PATH}"
  if [ $(git status --porcelain | grep '^\(??\| M\)' | wc -l) -ne 0 ]; then
    do_log "FATAL: There are uncommitted changes in ${TGT_PATH} !!!
            Please commit or stash them before replicating."
    export EXIT_CODE=1
    return
  fi

  # Perform Git operations
  git pull --rebase

  # Prepare rsync exclude patterns from environment variable SKIP_GLOBS
  IFS=' ' read -r -a exclude_patterns <<<"$SKIP_GLOBS"
  exclude_args=()
  for pattern in "${exclude_patterns[@]}"; do
    exclude_args+=("--exclude=$pattern")
  done
  # make the --delete optional by using the RSYNC_DELETE_OFF environment variable
  RSYNC_DELETE_OFF="${RSYNC_DELETE_OFF:-}"

  if [ -n "${RSYNC_DELETE_OFF}" ]; then
    echo "RSYNC_DELETE_OFF is set to '${RSYNC_DELETE_OFF}'"
    echo "Will NOT delete files in ${TGT_PATH} not existing in ${SRC_BAS_PATH}"
  else
    echo "Will delete files in ${TGT_PATH} not existing in ${SRC_BAS_PATH}"
    exclude_args+=("--delete")
  fi

  # Rsync from the corresponding directory in SRC_BAS_PATH to TGT_PATH
  rsync -av "${exclude_args[@]}" --exclude='.git/' "${SRC_BAS_PATH}/" "${TGT_PATH}/"
  # use ^^^ ONLY if you know what you are doing ... it will delete files in TGT_PATH not existing in the BAS_PATH

  # Prepare for Git commit
  git add .
  git commit -m "$GIT_MSG"
  git push

  export EXIT_CODE=0
}
