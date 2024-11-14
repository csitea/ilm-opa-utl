#!/bin/bash
#------------------------------------------------------------------------------------
# Do MySQL dump from remote server.
#
# Usage:
# DAYS=<<DAYS>> BUCKET_NAME=<<DUMP_FPATH>> ORG=bas APP=opa ENV=dev ./run -a do_remove_old_gcp_s3_files
#------------------------------------------------------------------------------------

do_remove_old_gcp_s3_files() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}
  do_require_var BUCKET_NAME "${BUCKET_NAME:-}"
  DAYS=${DAYS:-30} # Default to 30 days if not specified

  SERVICE_ACCOUNT_KEY_PATH="$HOME/.gcp/.$ORG/key-$ORG-$APP-$ENV.json"
  CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  gcloud auth activate-service-account --key-file="$SERVICE_ACCOUNT_KEY_PATH"
  test $? -eq 0 || return 1

  TARGET_DATE=$(date -u -d "$DAYS days ago" +"%s" 2>/dev/null || date -u -v-"$DAYS"d +"%s")

  file_processed=false # Flag to check if any files have been processed

  gsutil ls -l gs://${BUCKET_NAME}/ | grep 'gs://' | while read -r line; do
    CREATION_DATE=$(echo $line | awk '{print $2}')
    FILE_NAME=$(echo $line | awk '{print $3}')

    # Convert creation date to epoch for comparison
    FILE_CREATION_DATE_EPOCH=$(date -u -d "$CREATION_DATE" +"%s" 2>/dev/null || date -u -jf "%Y-%m-%dT%H:%M:%SZ" "$CREATION_DATE" +"%s")

    if [[ "$FILE_CREATION_DATE_EPOCH" -le "$TARGET_DATE" ]]; then
      if gsutil rm "$FILE_NAME"; then
        echo "Deleted $FILE_NAME"
        file_processed=true # Set the flag to true if any file is deleted
      else
        echo "Failed to delete $FILE_NAME"
        return 1 # Exit with status 1 on failure to delete a file
      fi
    else
      echo "Keeping $FILE_NAME"
    fi

  done

  # If no files were processed for deletion, still exit successfully
  if [[ "$file_processed" == false ]]; then
    echo "No older files found to delete or no files met deletion criteria."
  fi

  export EXIT_CODE="0" # Return zero upon successful completion or if no files needed deletion
}
