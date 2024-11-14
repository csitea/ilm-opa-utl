#!/bin/bash

do_gcp_sync_src_s3_to_tgt_s3() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var SRC_ENV ${SRC_ENV:-}
  do_require_var TGT_ENV ${TGT_ENV:-}

  # Define source and target credentials
  SRC_CREDENTIALS=$(eval echo ~/.gcp/.${ORG}/key-${ORG}-${APP}-${SRC_ENV}.json)
  TGT_CREDENTIALS=$(eval echo ~/.gcp/.${ORG}/key-${ORG}-${APP}-${TGT_ENV}.json)

  # Define source and destination buckets
  SRC_BUCKET="gs://${ORG}-${APP}-${SRC_ENV}-site"
  TGT_BUCKET="gs://${ORG}-${APP}-${TGT_ENV}-site"

  # Authenticate for source project
  gcloud auth activate-service-account --key-file=$SRC_CREDENTIALS

  # Set up a named configuration for the target project
  gcloud config configurations create target_config
  gcloud config set account $(jq -r '.client_email' $TGT_CREDENTIALS)
  gcloud auth activate-service-account --key-file=$TGT_CREDENTIALS

  # # Dry run of gsutil rsync command for safety
  # gsutil -m rsync -d -r -n \
  #   -x "wp-config\.php|wp-content/plugins/|wp-content/themes/" \
  #   ${SRC_BUCKET} ${TGT_BUCKET}

  #If you're satisfied with the dry run output, remove the -n flag to perform the actual sync
  gsutil -m rsync -d -r \
    -x "wp-config\.php" \
    ${SRC_BUCKET} ${TGT_BUCKET}

  export EXIT_CODE=$?

  # Clean up: remove the target configuration and revoke all authentications
  gcloud config configurations delete target_config --quiet
  gcloud auth revoke --all

  return $EXIT_CODE
}
