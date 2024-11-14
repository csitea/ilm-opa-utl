#!/bin/env bash

# SRC_PATH=src/bash/ bash /opt/bas/bas-wpb/bas-wpb-utl/run -a do_broadcast_dir_from_bas

do_broadcast_dir_from_bas() {
  do_require_var SRC_PATH "${SRC_PATH:-}" # Ensure SRC_PATH is defined
  SKIP_GLOBS="${SKIP_GLOBS:-}"            # Ensure SKIP_GLOBS is defined

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

  receiver_projects=$(cat $PROJ_PATH/cnf/projects.lst)
  for tgt_proj_path in $receiver_projects; do

    TGT_PATH=$tgt_proj_path/$(basename $tgt_proj_path)-$PROJECT_TYPE$SRC_RELATIVE_PATH
    do_log "INFO TGT_PATH: ${TGT_PATH:-}"
    TGT_PATH=${TGT_PATH%/} bash $PROJ_PATH/run -a do_replicate_dir_from_bas
    test $? -ne 0 && do_log "ERROR failed to replicate $SRC_PATH to $TGT_PATH" && exit 1

    do_log "INFO TGT_PATH: $TGT_PATH"
    # Prepare rsync exclude patterns from environment variable SKIP
  done
  export EXIT_CODE=0
}
