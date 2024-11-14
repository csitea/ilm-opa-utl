#!/bin/bash

do_gcp_project_apis_enable() {

  # Ensure gcloud is installed and in PATH
  command -v gcloud &>/dev/null || { echo "gcloud is not installed"; exit 1; }
  command -v gsutil &>/dev/null || { echo "gsutil is not installed"; exit 1; }

  do_log "INFO using the gcloud version: $(gcloud --version)"
  
  # Ensure necessary variables are set
  do_require_var ORG $ORG
  do_require_var APP $APP
  do_require_var ENV $ENV
  
  # Project and billing variables
  PROJ_ID=${PROJ_ID:-$ORG-$APP-$ENV}
  do_require_var PROJ_ID ${PROJ_ID:-}
  PROJ_NAME=${PROJ_NAME:-$PROJ_ID}
  do_require_var GCP_BILLING_ACCOUNT_ID ${GCP_BILLING_ACCOUNT_ID:-}

  do_log "INFO Login and set project"
  gcloud auth login --update-adc || quit_on "Login failed"

  gcloud auth application-default set-quota-project "${PROJ_ID:-}" || quit_on "Setting quota project failed"

  gcloud config set project "${PROJ_ID:-}" || quit_on "Setting project failed"


  do_log "INFO Enabling necessary APIs"
  gcloud services enable \
    cloudresourcemanager.googleapis.com \
    compute.googleapis.com \
    sheets.googleapis.com \
    dns.googleapis.com \
    servicemanagement.googleapis.com \
    secretmanager.googleapis.com \
    iam.googleapis.com \
    cloudfunctions.googleapis.com \
    cloudscheduler.googleapis.com \
    storage.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    cloudapis.googleapis.com --project "${PROJ_ID:-}" || quit_on "API enabling failed"


  do_log "INFO Service account created and key saved"
  export EXIT_CODE="0"
}
