#!/bin/bash

do_gcp_remove_files_from_gs_found_in_web_host() {

  # Ensure required variables are set
  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}

  # Set the path to the service account key file
  export KEY_FPATH_SA_VM=$(eval echo "~/.gcp/.${ORG}/${ORG}-${APP}-${ENV}-sa-compute-instance.json")
  do_log "INFO using KEY_FPATH_SA_VM:$KEY_FPATH_SA_VM"

  # Authenticate with the service account
  gcloud auth activate-service-account sa-compute-instance@$ORG-$APP-${ENV}.iam.gserviceaccount.com --key-file="${KEY_FPATH_SA_VM}"
  quit_on "authenticating the service account to access the gcp bucket"

  # List the bucket to ensure it is accessible
  gsutil ls -L -b gs://${ORG}-${APP}-${ENV}-site/
  quit_on "listing the bucket gs://${ORG}-${APP}-${ENV}-site/"

  # Set the bucket and local directory variables
  BUCKET="gs://${ORG}-${APP}-${ENV}-site/2024/07/"
  LOCAL_DIR="/var/www/html/wp-content/uploads/"
  do_log "INFO BUCKET:$BUCKET LOCAL_DIR:$LOCAL_DIR"

  # Get the list of files in the bucket
  gsutil ls -r "${BUCKET}**" | awk -F'/' '{print $NF}' | sort >/tmp/bucket_files.txt
  quit_on "listing the files in the bucket"

  # Find and remove files in the local directory that match names in the bucket
  find "${LOCAL_DIR}" -type f | while read -r local_file; do
    local_filename=$(basename "$local_file")
    if grep -qx "$local_filename" /tmp/bucket_files.txt; then
      echo "Removing $local_file"
      sudo rm -v "$local_file"
      do_log "INFO removing the file $local_file"
      quit_on "removing the file $local_file"
    fi
  done

  # Log the files that were found in the bucket
  files_log=$(cat /tmp/bucket_files.txt)
  do_log "INFO $files_log"

  # Clean up the temporary file
  rm /tmp/bucket_files.txt
  quit_on "removing the temporary file /tmp/bucket_files.txt"

  do_log "INFO STOP do_gcp_remove_files_from_gs_found_in_web_host"
  export EXIT_CODE=0
}
