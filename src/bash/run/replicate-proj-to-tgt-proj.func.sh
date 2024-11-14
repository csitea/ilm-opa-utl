#!/bin/env bash
# Usage:
# SRC_PATH=/opt/bas/bas-wpb/bas-wpb-wui TGT_ORG=ilm TGT_APP=opa./run -a do_replicate_proj_to_bas

do_replicate_proj_to_tgt_proj() {

  do_require_var SRC_PATH "${SRC_PATH:-}" # Ensure SRC_PATH is defined
  do_require_var TGT_ORG "${TGT_ORG:-}"
  do_require_var TGT_APP "${TGT_APP:-}"

  SKIP_GLOBS="${SKIP_GLOBS:-}" # Ensure SKIP_GLOBS is defined

  # Ensure SRC_PATH always ends with a slash
  [[ "${SRC_PATH}" != */ ]] && SRC_PATH="${SRC_PATH}/"

  # Log the source path for reference
  echo "Source path: ${SRC_PATH}"

  # Extract 'PROJ_TYPE' from the last part of the path, after the last '-'
  PROJECT_TYPE=$(echo "${SRC_PATH}" | grep -oP '(?<=[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z]{3}/?' | tr -d '\n')
  PROJECT_TYPE=${PROJECT_TYPE%/}
  echo "Project type: ${PROJECT_TYPE}"

  # Construct the base replication path
  BAS_PATH="$BASE_PATH/$TGT_ORG/$TGT_ORG-$TGT_APP/$TGT_ORG-$TGT_APP-${PROJECT_TYPE}"
  echo "Base path for Git operations: ${BAS_PATH}"

  # Ensure we are in the correct directory and it's clean
  mkdir -p "${BAS_PATH}"
  cd "${BAS_PATH}"
  if [ $(git status --porcelain | grep '^\(??\| M\)' | wc -l) -ne 0 ]; then
    do_log "FATAL: There are uncommitted changes in ${BAS_PATH} !!!
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
    echo "Will NOT delete files in ${BAS_PATH} not existing in ${SRC_PATH}"
  else
    echo "Will delete files in ${BAS_PATH} not existing in ${SRC_PATH}"
    exclude_args+=("--delete")
  fi

  # Rsync from SRC_PATH to the corresponding directory in BAS_PATH
  # do not use --delte option to avoid deleting files in BAS_PATH
  rsync -av "${exclude_args[@]}" --exclude='.git/' "${SRC_PATH}" "${BAS_PATH}"

  # --delete
  # use ^^^ ONLY if you know what you are doing ... it will delete files in BAS_PATH not exising in the SRC_PATH
  mkdir -p ${BAS_PATH}
  cd ${BAS_PATH}
  # Prepare for Git commit
  git add .
  git commit -m "$GIT_MSG<"
  git push

  export EXIT_CODE=0
}
