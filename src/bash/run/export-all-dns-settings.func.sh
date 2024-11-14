#!/bin/env bash
do_export_all_dns_settings() {

  # Define the project keys and corresponding projects
  declare -A projects
  projects=(
    ["key-$ORG-$APP-$ENV.json"]="$ORG-$APP-$ENV")

  # Base directory for service account keys
  KEY_DIR="$HOME/.gcp/.str"

  # Loop over each key file and export DNS settings
  for key_file in "${!projects[@]}"; do
    project_id="${projects[$key_file]}"

    # Activate the service account
    gcloud auth activate-service-account --key-file="$KEY_DIR/$key_file"

    # Set the project
    gcloud config set project "$project_id"

    # List all managed zones in the project
    echo "Exporting DNS settings for project: $project_id"
    gcloud dns managed-zones list --format="json" >"${project_id}_dns_zones.json"

    # List all DNS records in each managed zone
    managed_zones=$(gcloud dns managed-zones list --format="value(name)")
    for zone in $managed_zones; do
      echo "Exporting DNS records for zone: $zone in project: $project_id"
      gcloud dns record-sets list --zone="$zone" --format="json" >"${project_id}_${zone}_dns_records.json"
    done
  done

  echo "DNS settings export completed."
  export EXIT_CODE="0"
}
