#!/bin/env bash

# TGT_PATH=/opt/org/org-app/org-app-utl ./run -a do_replicate_proj_from_src_proj
do_replicate_proj_from_src_proj() {

  REQUIRED_VARS=(HOST_NAME EXIT_CODE RUN_UNIT PROJ_PATH APP_PATH APP_NAME ORG_PATH BASE_PATH PROJ ENV GROUP USER UID GID OS)
  do_require_run_vars "${REQUIRED_VARS[@]}"

  do_require_var TGT_PATH "${TGT_PATH:-}" # Ensure TGT_PATH is defined
  SKIP_GLOBS="${SKIP_GLOBS:-}"            # Ensure SKIP_GLOBS is defined

  # Ensure TGT_PATH always DOES NOT ends with a slash
  [[ "${TGT_PATH}" == */ ]] && TGT_PATH="${TGT_PATH%/}"
  TGT_ORG_APP="$(basename "$(dirname "$TGT_PATH")")"
  do_extract_org_app "$TGT_ORG_APP"
  quit_on "extracting SRC_ORG_APP"
  TGT_ORG="$ORG"
  TGT_APP="$APP"
  TGT_ORG_DOT_APP="${TGT_ORG}.${TGT_APP}"

  # Extract the source organization and application from the path
  SRC_ORG_APP="${SRC_ORG_APP:-$APP_NAME}"
  do_extract_org_app "$SRC_ORG_APP"
  quit_on "extracting SRC_ORG_APP"
  SRC_ORG="$ORG"
  SRC_APP="$APP"
  SRC_ORG_DOT_APP="${SRC_ORG}.${SRC_APP}"

  # Log the target path for reference
  do_log "INFO Target path: ${TGT_PATH}"
  # Extract 'PROJ_TYPE' from the last part of the path, after the last '-'
  PROJECT_TYPE=$(echo "${TGT_PATH}" | grep -oP '(?<=-)[a-zA-Z]{3}$')
  # echo "Project type: ${PROJECT_TYPE}"
  # sleep 10

  # Construct the base source path
  BAS_PATH="$BASE_PATH/$SRC_ORG/$SRC_ORG-$SRC_APP/$SRC_ORG-$SRC_APP-${PROJECT_TYPE}"
  echo "Base path for replication: ${BAS_PATH}"

  SRC_BAS_PATH="${BAS_PATH}"
  # Ensure SRC_BAS_PATH always ends with a slash
  [[ "${SRC_BAS_PATH}" != */ ]] && SRC_BAS_PATH="${SRC_BAS_PATH}/"
  echo "Source base path: ${SRC_BAS_PATH}"
  # now WE Must ensure that the TGT_PATH_PATH ALWAYS ends with /

  # Ensure the target directory exists and is ready
  mkdir -p "${TGT_PATH}"
  cd "${TGT_PATH}"
  if [ $(git status --porcelain | grep '^\(??\| M\)' | wc -l) -ne 0 ]; then
    do_log "FATAL: There are uncommitted changes in ${TGT_PATH} !!!
            Please commit or stash them before replicating."
    export EXIT_CODE=1
    return
  fi

  # Perform Git operations only if there is a .git directory
  test -d .git && git pull --rebase

  # Prepare rsync exclude patterns from environment variable SKIP_GLOBS
  IFS=' ' read -r -a exclude_patterns <<<"$SKIP_GLOBS"
  exclude_args=()
  for pattern in "${exclude_patterns[@]}"; do
    exclude_args+=("--exclude=$pattern")
  done
  # make the --delete optional by using the RSYNC_DELETE_OFF environment variable
  RSYNC_DELETE_OFF="${RSYNC_DELETE_OFF:-}"

  if [ -d .git ]; then
    if [ -n "${RSYNC_DELETE_OFF}" ]; then
      echo "RSYNC_DELETE_OFF is set to '${RSYNC_DELETE_OFF}'"
      echo "Will NOT delete files in ${TGT_PATH} not existing in ${SRC_BAS_PATH}"
    else
      echo "Will delete files in ${TGT_PATH} not existing in ${SRC_BAS_PATH}"
      exclude_args+=("--delete")
    fi
  fi

  # Rsync from the corresponding directory in SRC_BAS_PATH to TGT_PATH
  rsync -av "${exclude_args[@]}" --exclude='.git/' "${SRC_BAS_PATH}/" "${TGT_PATH}/"
  STR_TO_SRCH=$SRC_ORG_APP STR_TO_REPL=$TGT_ORG_APP DIR_TO_MORPH=$TGT_PATH do_morph_dir
  quit_on "morphing dir"
  STR_TO_SRCH=$SRC_ORG_DOT_APP STR_TO_REPL=$TGT_ORG_DOT_APP DIR_TO_MORPH=$TGT_PATH do_morph_dir
  quit_on "morphing dir"
  STR_TO_SRCH="/$SRC_ORG/"
  STR_TO_REPL="/$TGT_ORG/"
  find "${TGT_PATH}" -type f -name '.env' -exec sed -i "s|$STR_TO_SRCH|$STR_TO_REPL|g" {} \;
  # use ^^^ ONLY if you know what you are doing ... it will delete files in TGT_PATH not existing in the BAS_PATH

  # Prepare for Git commit
  test -d .git && git add .
  test -d .git && git commit -m "$GIT_MSG"
  test -d .git && git push

  export EXIT_CODE=0
}
