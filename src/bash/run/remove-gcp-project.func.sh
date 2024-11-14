do_remove_gcp_project() {

  # Ensure the gcloud and gsutil are installed and in your PATH.
  do_require_var ORG $ORG
  do_require_var PROJ_ID ${PROJ_ID:-}
  PROJ_NAME=${PROJ_NAME:-$PROJ_ID}
  do_require_var GCP_BILLING_ACCOUNT_ID ${GCP_BILLING_ACCOUNT_ID:-}

  # Login and set project
  gcloud auth login --update-adc
  gcloud config set project ${PROJ_ID:-}

  # Create project
  gcloud projects create ${PROJ_ID:-} --name="${PROJ_NAME}"
  gcloud alpha billing projects link ${PROJ_ID:-} --billing-account=$GCP_BILLING_ACCOUNT_ID
  gcloud config set project ${PROJ_ID:-}
  gcloud auth application-default set-quota-project ${PROJ_ID:-}

  # Ensure gcloud is installed and in your PATH.
  do_require_var PROJ_ID ${PROJ_ID:-}

  # Login
  gcloud auth login --update-adc
  gcloud config set project ${PROJ_ID:-}

  # Optionally list all resources for review before deletion
  # This is a placeholder for resource listing; implement as needed

  # Disable billing for the project
  gcloud beta billing projects unlink ${PROJ_ID:-}

  # Delete the project
  gcloud projects delete ${PROJ_ID:-} --quiet

  echo "Project ${PROJ_ID} and its resources are scheduled for deletion."

  export EXIT_CODE="0"
}
