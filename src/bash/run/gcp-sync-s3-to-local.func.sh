#!/bin/bash

do_gcp_sync_s3_to_local() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}

  YAML_CONF_FILE="$BASE_PATH/$ORG/$ORG-$APP/$ORG-$APP-cnf/$ORG-$APP/$ENV.env.yaml"
  DOMAIN=$(yq -r '.env.dns.tld_domain' $YAML_CONF_FILE)
  fqn_host_name=$(yq -r '.env.dns.wpb_fqdn' $YAML_CONF_FILE)

  export GOOGLE_APPLICATION_CREDENTIALS=$(eval echo ~/.gcp/.${ORG}/key-${ORG}-${APP}-${ENV}.json)

  # Authenticate using the service account key file
  gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

  # Define variables
  export GCS_BUCKET="gs://${ORG}-${APP}-${ENV}-site"                           # GCS bucket name
  export DEFAULT_TGT_DIR="${APP_PATH}/$ORG-$APP-dat/${ORG}-${APP}-${ENV}-site" # Target directory
  export TGT_DIR="${TGT_DIR:-$DEFAULT_TGT_DIR}"

  # Ensure the target directory exists
  mkdir -p ${TGT_DIR}

  # # Dry run of gsutil rsync command for safety
  # gsutil -m rsync -d -r -n \
  #   -x "wp-config\.php \
  #   ${GCS_BUCKET} ${TGT_DIR}

  # If you're satisfied with the dry run output, remove the -n flag to perform the actual sync
  gsutil -m rsync -d -r \
    -x "wp-config\.php" \
    ${GCS_BUCKET} ${TGT_DIR}

  export EXIT_CODE=$?

}
