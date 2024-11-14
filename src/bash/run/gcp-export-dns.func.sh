#!/bin/bash

do_gcp_export_dns() {

  do_require_var  ORG "${ORG:-}"
  do_require_var  APP "${APP:-}"

declare -A env_keys=(
  ["dev"]="~/.gcp/.${ORG:-}/key-${ORG:-}-${APP:-}-dev.json"
  ["prd"]="~/.gcp/.${ORG:-}/key-${ORG:-}-${APP:-}-prd.json"
  ["tst"]="~/.gcp/.${ORG:-}/key-${ORG:-}-${APP:-}-tst.json"
)

for env in "${!env_keys[@]}"; do
  expanded_key_path=$(eval echo ${env_keys[$env]})
  export GOOGLE_APPLICATION_CREDENTIALS="${expanded_key_path}"

  do_log "INFO Exporting DNS configuration for $env environment"
  PROJECT_ID=$(jq -r '.project_id' $GOOGLE_APPLICATION_CREDENTIALS)

  gcloud config set project ${PROJECT_ID:-}
  quit_on "Setting project"

  # List DNS Managed Zones
  gcloud dns managed-zones list --format="json" > ~/dns-managed-zones-${env}.json
  quit_on "Listing DNS Managed Zones"

  # Export DNS Records for each zone
  zones=$(gcloud dns managed-zones list --format="value(name)")
  for zone in $zones; do
    gcloud dns record-sets export ~/dns-records-${zone}-${env}.yaml --zone=$zone
    quit_on "Exporting DNS records for $zone"
  done

  do_log "INFO Export completed for $env environment"

done
  export EXIT_CODE="0"

}
