#!/bin/bash
# Usage:
# deploy from dev to prod
# ORG=ilm APP=opa SRC_ENV=dev TGT_ENV=prd ./run -a do_deploy_app_to_environment
# deploy from tst to prod
# ORG=ilm APP=opa SRC_ENV=tst TGT_ENV=prd ./run -a do_deploy_app_to_environment
# deploy from dev to tst
# ORG=ilm APP=opa SRC_ENV=dev TGT_ENV=tst ./run -a do_deploy_app_to_environment
do_deploy_app_to_environment() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var SRC_ENV ${SRC_ENV:-}
  do_require_var TGT_ENV ${TGT_ENV:-}

  export REPO="csitea/"$ORG"-"$APP"-wui"
  export SRC_ENV="${SRC_ENV:-}" # or "tst", "all"
  export GIT_BRANCH="${GIT_BRANCH:-master}"
  export TGT_ENV="${TGT_ENV:-all}" # or "tst", "all"
  export SRC_REPO_BRANCH="${SRC_REPO_BRANCH:-master}"

  # push the source code to the github repo from the src env
  do_log "INFO pushing the source code to the github repo from the src env"
  # backup the db to s3
  do_log "INFO backing up the db to s3"
  gh workflow run "push-wordpress-src-code-backup-db-to-s3.yml" \
    --repo "$REPO" \
    --ref "$GIT_BRANCH" \
    -f git_msg="$GIT_MSG" \
    -f env="$SRC_ENV" \
    -f src_repo_branch="$SRC_REPO_BRANCH" &
  quit_on "backing up the db to s3"


  # sync the source code to the target environment
  do_log "INFO syncing the source code to the target environment"
  gh workflow run "sync-github-word-press-source-code-to-server.yml" \
    --repo "$REPO" \
    --ref "$GIT_BRANCH" \
    -f env="$TGT_ENV" \
    -f src_repo_branch="$GIT_BRANCH"
  quit_on "syncing the source code to the target environment"
  sleep 60

  # restore the db from the s3 bucket
  do_log "INFO restoring the db from the s3 bucket"
  gh workflow run "restore-wordpress-db-from-gcp-s3.yml" \
    --repo "$REPO" \
    --ref "$GIT_BRANCH" \
    -f src_env="$SRC_ENV" \
    -f tgt_env="$TGT_ENV" \
    -f src_repo_branch="$GIT_BRANCH"
  quit_on "restoring the db from the s3 bucket"

  export EXIT_CODE="0"
}
