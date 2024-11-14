#!/bin/env bash

# USAGE:
# TGT_ORG=ilm TGT_APP=opa SRC_PATH=/opt/bas/bas-wpb/bas-wpb-utl/src/bash/ bash /opt/bas/bas-wpb/bas-wpb-utl/run -a do_replicate_dir_to_tgt_proj
#
do_replicate_dir_to_tgt_proj() {

  do_require_var SRC_PATH "${SRC_PATH:-}"
  do_require_var TGT_ORG "${TGT_ORG:-}"
  do_require_var TGT_APP "${TGT_APP:-}"

  declare -a REQUIRED_VARS=(HOST_NAME EXIT_CODE RUN_UNIT PROJ_PATH APP_PATH ORG_PATH BASE_PATH PROJ ENV GROUP USER UID GID OS LOG_DIR LOG_FILE)
  do_require_run_vars "${REQUIRED_VARS[@]}"
  SKIP_GLOBS="${SKIP_GLOBS:-}"

  # TODO: check if SRC_PATH exists and it is a directory
  if [ ! -d "${SRC_PATH}" ]; then
    do_log "FATAL: ${SRC_PATH} is not a directory or does not exist."
    export EXIT_CODE=1
    return
  fi

  # Ensure SRC_PATH always ends with a slash
  [[ "${SRC_PATH}" != */ ]] && SRC_PATH="${SRC_PATH}/"

  # Log the source path for reference
  echo "Source path: ${SRC_PATH}"

  # Extract 'PROJ_TYPE' from the last part of the path, after the last '-'
  PROJECT_TYPE=$(echo "${SRC_PATH}" | grep -oP '(?<=[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z]{3}/' | tr -d '\n')
  PROJECT_TYPE=${PROJECT_TYPE%/}
  echo "Project type: ${PROJECT_TYPE}"

  SRC_PROJ_PATH=$(echo "${SRC_PATH}" | grep -oP '(.*/[a-zA-Z]{3}-[a-zA-Z]{3}-)[a-zA-Z0-9]+')
  echo "SRC_PROJ_PATH : ${SRC_PROJ_PATH}"

  # todo: convert
  # /opt/bas/bas-wpb/bas-wpb-inf/src/terraform/008-gcp-subzones/
  # to /src/terraform/008-gcp-subzones/
  SRC_RELATIVE_PATH="${SRC_PATH#${SRC_PROJ_PATH}}"

  # TODO: ensure that the SRC_RELATIVE_PATH ALWAYS ends up with a slash
  [[ "${SRC_RELATIVE_PATH}" != */ ]] && SRC_RELATIVE_PATH="${SRC_RELATIVE_PATH}/"
  echo "Source relative path: ${SRC_RELATIVE_PATH}"

  # Construct the target base path
  BAS_PATH="$BASE_PATH/$TGT_ORG/$TGT_ORG-$TGT_APP/$TGT_ORG-$TGT_APP-${PROJECT_TYPE}"
  TGT_BAS_PATH="${BAS_PATH}""${SRC_RELATIVE_PATH}"
  echo "Target base path for replication: ${TGT_BAS_PATH}"

  # Ensure TGT_BAS_PATH does not end with a slash
  [[ "${TGT_BAS_PATH}" == */ ]] && TGT_BAS_PATH="${TGT_BAS_PATH%/}"
  echo "Target base path: ${TGT_BAS_PATH}"

  # Ensure the base directory exists and is ready
  mkdir -p "${TGT_BAS_PATH}"
  cd "${BAS_PATH}"
  if [ $(git status --porcelain | grep '^\(??\| M\)' | wc -l) -ne 0 ]; then
    do_log "FATAL: There are uncommitted changes in ${TGT_BAS_PATH} !!!
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
    echo "Will NOT delete files in ${TGT_BAS_PATH} not existing in ${SRC_PATH}"
  else
    echo "Will delete files in ${TGT_BAS_PATH} not existing in ${SRC_PATH}"
    exclude_args+=("--delete")
  fi
  # Rsync from the corresponding directory in SRC_PATH to TGT_BAS_PATH
  rsync -av "${exclude_args[@]}" --exclude='.git/' "${SRC_PATH}" "${TGT_BAS_PATH}/"
  # use ^^^ ONLY if you know what you are doing ... it will delete files in TGT_BAS_PATH not existing in the SRC_PATH

  # Prepare for Git commit
  git add .
  git commit -m "$GIT_MSG"
  git push

  export EXIT_CODE=0
}
