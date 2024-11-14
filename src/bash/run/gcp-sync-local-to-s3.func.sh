#!/bin/bash

do_gcp_sync_local_to_s3() {
  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}

  echo $APP_PATH
  dev_wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' ${APP_PATH}/${ORG}-${APP}-cnf/${ORG}-${APP}/dev.env.yaml)
  tst_wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' ${APP_PATH}/${ORG}-${APP}-cnf/${ORG}-${APP}/tst.env.yaml)
  prd_wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' ${APP_PATH}/${ORG}-${APP}-cnf/${ORG}-${APP}/prd.env.yaml)
  all_wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' ${APP_PATH}/${ORG}-${APP}-cnf/${ORG}-${APP}/all.env.yaml)
  cur_wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' ${APP_PATH}/${ORG}-${APP}-cnf/${ORG}-${APP}/${ENV}.env.yaml)
  DEFAULT_OLD_WPB_FQDN=$cur_wpb_fqdn
  old_wpb_fqdn=${old_wpb_fqdn:-$DEFAULT_OLD_WPB_FQDN}

  # # Adjust the regex to match both http and https protocols
  # find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
  #   "s|https?://$old_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  # find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
  #   "s|https?://$dev_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  # find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
  #   "s|https?://$tst_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  # find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
  #   "s|https?://$prd_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +

  # Define variables
  export DEFAULT_SRC_DIR="${APP_PATH}/$ORG-$APP-dat/src/web/html/" # Source directory
  export SRC_DIR="${SRC_DIR:-$DEFAULT_SRC_DIR}"
  export GCS_BUCKET="gs://${ORG}-${APP}-${ENV}-bucket" # GCS bucket name

  # Dry run of gsutil rsync command for safety
  gsutil -m rsync -d -r -n -x ".git/|wp-config.php" ${SRC_DIR} ${GCS_BUCKET}

  # If you're satisfied with the dry run output, remove the -n flag to perform the actual sync
  # gsutil -m rsync -d -r -x ".git/|wp-config.php" ${SRC_DIR} ${GCS_BUCKET}

  export EXIT_CODE=$?
}
