#!/bin/bash
# usage:
# ORG=csi APP=wpb ENV=all ./run -a do_gcp_export_dns_settings
do_gcp_export_dns_settings() {

  REQUIRED_VARS=(HOST_NAME EXIT_CODE RUN_UNIT PROJ_PATH APP_PATH APP_NAME ORG_PATH BASE_PATH PROJ ENV GROUP USER UID GID OS)
  do_require_run_vars "${REQUIRED_VARS[@]}"

  REQUIRED_VARS=(ORG APP ENV)
  do_require_run_vars "${REQUIRED_VARS[@]}"

  # Set up variables based on the provided naming conventions
  PROJECT_ID="${ORG}-${APP}-${ENV}"
  ADMIN_KEY_PATH="${HOME}/.gcp/.$ORG/key-$ORG-$APP-$ENV.json"
  OUTPUT_FILE="${PROJ_PATH}/dns_settings_${PROJECT_ID}.txt"

  # Authenticate with Google Cloud using the admin credential file
  if [[ ! -f "${ADMIN_KEY_PATH}" ]]; then
    do_log "FATAL Error: Admin key file not found at ${ADMIN_KEY_PATH}"
    exit 1
  fi

  do_log "INFO Authenticating with GCP using admin key..."
  gcloud auth activate-service-account --key-file="${ADMIN_KEY_PATH}"
  quit_on "authentication failed"

  # Set the Google Cloud project
  do_log "INFO Setting GCP project to ${PROJECT_ID}..."
  gcloud config set project ${PROJECT_ID}

  # Export DNS settings
  do_log "INFO Exporting DNS settings for project ${PROJECT_ID}..."
  
  # List all DNS managed zones
  do_log "INFO Listing all DNS managed zones:"
  gcloud dns managed-zones list --format="table(name,dnsName,description)" > "${OUTPUT_FILE}"
  quit_on "failed to list DNS managed zones"

  # For each managed zone, export the record sets
  while read -r zone_name _; do
    if [[ "${zone_name}" != "NAME" ]]; then  # Skip the header row
      do_log "INFO Exporting records for zone: ${zone_name}"
      echo -e "\nRecords for zone: ${zone_name}" >> "${OUTPUT_FILE}"
      gcloud dns record-sets list --zone="${zone_name}" --format="table(name,type,ttl,rrdatas[])" >> "${OUTPUT_FILE}"
      quit_on "failed to export records for zone ${zone_name}"
    fi
  done < <(tail -n +2 "${OUTPUT_FILE}")  # Skip the header row

  # Export Cloud DNS policies if any
  do_log "INFO Exporting Cloud DNS policies..."
  echo -e "\nCloud DNS Policies:" >> "${OUTPUT_FILE}"
  gcloud dns policies list --format="table(name,description,enableInboundForwarding,enableLogging)" >> "${OUTPUT_FILE}"
  quit_on "failed to export DNS policies"

  # Clean up authentication
  gcloud auth revoke --all --quiet
  quit_on "failed to revoke authentication"

  do_log "INFO DNS settings exported to ${OUTPUT_FILE}"
  do_log "INFO Script execution completed."
  export EXIT_CODE="0"
}
