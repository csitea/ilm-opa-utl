#!/bin/bash

do_gcp_replicate_src_bucket_data_to_tgt_bucket() {
  # Set error handling
  set -e

  REQUIRED_VARS=(HOST_NAME EXIT_CODE RUN_UNIT PROJ_PATH APP_PATH APP_NAME ORG_PATH BASE_PATH PROJ ENV GROUP USER UID GID OS)
  do_require_run_vars "${REQUIRED_VARS[@]}"

  REQUIRED_VARS=(SRC_ORG SRC_APP SRC_ENV TGT_ORG TGT_APP TGT_ENV)
  do_require_run_vars "${REQUIRED_VARS[@]}"

  # Set bucket names
  SRC_BUCKET="${SRC_ORG}-${SRC_APP}-${SRC_ENV}-site"
  TGT_BUCKET="${TGT_ORG}-${TGT_APP}-${TGT_ENV}-site"

  # Set base path for service account keys
  BASE_KEY_PATH=$(eval echo "~/.gcp")

  # Set service account key paths using the new naming convention and expanded home directory
  SRC_ADMIN_KEY_PATH="$BASE_KEY_PATH/.$SRC_ORG/key-$SRC_ORG-$SRC_APP-$SRC_ENV.json"
  TGT_ADMIN_KEY_PATH="$BASE_KEY_PATH/.$TGT_ORG/key-$TGT_ORG-$TGT_APP-$TGT_ENV.json"

  # Check if service account key files exist
  if [[ ! -f "$SRC_ADMIN_KEY_PATH" ]]; then
    do_log "INFO Error: Source service account key file not found at $SRC_ADMIN_KEY_PATH"
    quit_on "the source service account key file not found"
  fi

  if [[ ! -f "$TGT_ADMIN_KEY_PATH" ]]; then
    do_log "INFO Error: Target service account key file not found at $TGT_ADMIN_KEY_PATH"
    quit_on "the target service account key file not found"
  fi

  # Debugging: Print out the path being used for credentials
  echo "Using source credentials from: $SRC_ADMIN_KEY_PATH"
  echo "Using target credentials from: $TGT_ADMIN_KEY_PATH"

  # Perform the sync operation in a subshell to enforce the use of credentials
  (
    export GOOGLE_APPLICATION_CREDENTIALS="$SRC_ADMIN_KEY_PATH"
    do_log "INFO Starting sync from gs://$SRC_BUCKET to gs://$TGT_BUCKET"
    gsutil -m rsync -r -d gs://$SRC_BUCKET gs://$TGT_BUCKET
  )
  
  if [ $? -ne 0 ]; then
    quit_on "sync operation failed"
  fi

  export EXIT_CODE="0"
}
