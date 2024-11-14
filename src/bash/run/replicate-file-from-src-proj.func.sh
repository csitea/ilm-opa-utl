#!/bin/env bash

# TGT_PATH=/opt/bas/bas-wpb/bas-wpb-utl/src/bash/run.sh bash /opt/bas/bas-wpb/bas-wpb-utl/run -a do_replicate_file_src_proj

do_replicate_file_from_src_proj() {
  do_require_var TGT_PATH "${TGT_PATH:-}" # Ensure TGT_PATH is defined
  do_require_var SRC_ORG "${SRC_ORG:-}"
  do_require_var SRC_APP "${SRC_APP:-}"

  SKIP_GLOBS="${SKIP_GLOBS:-}" # Ensure SKIP_GLOBS is defined

  # Log the target path for reference
  echo "Target path: ${TGT_PATH}"
  # Extract 'PROJ_TYPE' from the last part of the path, after the last '-'
  PROJECT_TYPE=$(echo "${TGT_PATH}" | grep -oP '(?<=[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z]{3}/' | tr -d '\n')
  PROJECT_TYPE=${PROJECT_TYPE%/}

  TGT_PROJ_PATH=$(echo "${TGT_PATH}" | grep -oP '(.*/[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z0-9]+')
  echo "TGT_PROJ_PATH : ${TGT_PROJ_PATH}"

  TGT_RELATIVE_PATH="${TGT_PATH#${TGT_PROJ_PATH}}"
  TGT_RELATIVE_PATH="${TGT_RELATIVE_PATH%/}"
  echo "Target relative path: ${TGT_RELATIVE_PATH}"

  # Construct the base source path
  BAS_PATH="$BASE_PATH/$SRC_ORG/$SRC_ORG-$SRC_APP/$SRC_ORG-$SRC_APP-${PROJECT_TYPE}"
  echo "Base path for replication: ${BAS_PATH}"

  SRC_BAS_PATH="${BAS_PATH}${TGT_RELATIVE_PATH}"
  echo "Source base path: ${SRC_BAS_PATH}"
  # now WE Must ensure that the SRC_PATH_PATH ALWAYS ends with /

  # Ensure the target directory exists and is ready
  mkdir -p $(dirname "${TGT_PATH}")
  cd "${TGT_PROJ_PATH}"
  if [ $(git status --porcelain | grep '^\(??\| M\)' | wc -l) -ne 0 ]; then
    do_log "FATAL: There are uncommitted changes in ${TGT_PATH} !!!
            Please commit or stash them before replicating."
    export EXIT_CODE=1
    return
  fi

  # Perform Git operations
  git pull --rebase

  cp -v "${SRC_BAS_PATH}" "${TGT_PATH}"
  # use ^^^ ONLY if you know what you are doing ... it will delete files in TGT_PATH not existing in the BAS_PATH

  # Prepare for Git commit
  git add .
  git commit -m "$GIT_MSG"
  git push

  export EXIT_CODE=0
}
