# #!/bin/bash
# ORG_ID=91026469661 GCP_ACCOUNT=ext-yordan.georgiev@futurice.com orgGCP_BILLING_ACCOUNT_ID=015FE3-BD4862-4B740E ORG=ilm APP=opa ENV=stg ./run -a do_create_gcp_project

do_create_gcp_project() {

  do_log "INFO using the gcloud version: "$(gcloud --version)
  quit_on "gcloud is not installed"

  # Ensure necessary variables are set
  do_require_var ORG $ORG
  do_require_var APP $APP
  do_require_var ENV $ENV
  do_require_var GCP_ACCOUNT ${GCP_ACCOUNT:-}
  gcloud config set account ${GCP_ACCOUNT}
  do_require_var GCP_BILLING_ACCOUNT_ID ${GCP_BILLING_ACCOUNT_ID:-}

  # Setup project ID and name
  export PROJ_ID=${PROJ_ID:-$ORG-$APP-$ENV}
  export PROJ_NAME=${PROJ_NAME:-$PROJ_ID}
  export SERVICE_ACCOUNT="${PROJ_ID}"
  export ORG_ID="${ORG_ID}"
  do_require_var PROJ_ID ${PROJ_ID:-}

  # Log in and set the project
  do_log "INFO Login and set project"
  gcloud auth login --update-adc
  quit_on "Login and set project failed"

  gcloud config set project ${PROJ_ID:-}

  # Create the GCP project
  # do_log "INFO Creating the GCP project"
  # gcloud projects create ${PROJ_ID:-} --name="${PROJ_NAME}"
  # quit_on "Failed to create the GCP project"

  # Enable Organization Policy API
  do_log "INFO Project ${PROJ_ID} enable the org policy service"
  gcloud services enable orgpolicy.googleapis.com --project=${PROJ_ID:-}
  quit_on "Failed to enable org policy service"

  # Temporarily disable key creation policy
  do_log "INFO Temporarily disabling 'iam.disableServiceAccountKeyCreation' constraint"

  mkdir -p "${PROJ_PATH}/dat/tmp/"
  cat > "${PROJ_PATH}/dat/tmp/disable_policy.yaml" <<EOF01
name: organizations/${ORG_ID}/policies/iam.disableServiceAccountKeyCreation
spec:
  rules:
    - enforce: false
EOF01

  gcloud org-policies set-policy "${PROJ_PATH}/dat/tmp/disable_policy.yaml"
  quit_on "Failed to disable 'iam.disableServiceAccountKeyCreation' constraint"

  # Create a service account
  do_log "INFO Creating the service account"
  gcloud iam service-accounts create ${SERVICE_ACCOUNT} --display-name "${SERVICE_ACCOUNT}"
  quit_on "Failed to create the service account"


  gcloud projects add-iam-policy-binding ${PROJ_ID} \
      --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJ_ID}.iam.gserviceaccount.com" \
      --role="roles/storage.admin"

  gcloud projects add-iam-policy-binding ${PROJ_ID} \
      --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJ_ID}.iam.gserviceaccount.com" \
      --role="roles/owner"


  # Create and download the service account key
  do_log "INFO Creating and downloading the service account key"
  mkdir -p ~/.gcp/.${ORG}
  gcloud iam service-accounts keys create ~/.gcp/.${ORG}/key-${SERVICE_ACCOUNT}.json --iam-account ${SERVICE_ACCOUNT}@${PROJ_ID}.iam.gserviceaccount.com
  quit_on "Failed to create and download the service account key"

  # Re-enable key creation policy
  do_log "INFO Re-enabling 'iam.disableServiceAccountKeyCreation' constraint"

  cat > "${PROJ_PATH}/dat/tmp/enable_policy.yaml" <<EOF02
name: organizations/${ORG_ID}/policies/iam.disableServiceAccountKeyCreation
spec:
  rules:
    - enforce: true
EOF02

  gcloud org-policies set-policy "${PROJ_PATH}/dat/tmp/enable_policy.yaml" 
  quit_on "Failed to re-enable 'iam.disableServiceAccountKeyCreation' constraint"

  # Cleanup temporary files
  rm -f "${PROJ_PATH}/dat/tmp/disable_policy.yaml" "${PROJ_PATH}/dat/tmp/enable_policy.yaml"

  do_log "INFO Enabled APIs: Compute Engine, Google Sheets, Cloud DNS, Service Management, Secret Manager, IAM"
  do_log "INFO Service account ${SERVICE_ACCOUNT} created and key saved to ~/.gcp/.${ORG}/key-${SERVICE_ACCOUNT}.json"
  do_log "INFO Remember to add the service account key to the project credentials"

  export EXIT_CODE="0"
}
