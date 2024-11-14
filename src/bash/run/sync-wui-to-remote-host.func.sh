#!/bin/bash

do_sync_wui_to_remote_host() {

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

  # Adjust the regex to match both http and https protocols
  find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
    "s|https?://$old_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
    "s|https?://$dev_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
    "s|https?://$tst_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
    "s|https?://$prd_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  find "$SRC_DIR" -not -path '*.git*' -type f -exec perl -pi -e \
    "s|https?://$all_wpb_fqdn|https://$cur_wpb_fqdn|g" {} +
  # Define variables
  #  ~/.ssh/.$ORG/$ORG-$APP-tst-$APP.pk
  # ~/.ssh/.str/bas-wpb-dev-$APP.pk
  # ~/.ssh/.str/bas-wpb-dev-wpb.pub
  export SSH_KEY_PATH="~/.ssh/.$ORG/$ORG-$APP-${ENV}-$APP.pk" # SSH key path
  export TGT_USER="debian"                                    # Source user
  # https://bas.wpb.dev.gcp.ilmatarbrain.com/
  export TGT_HOST=$cur_wpb_fqdn                                    # Source host
  export TGT_DIR="/var/www/html"                                   # Source directory
  export DEFAULT_SRC_DIR="${APP_PATH}/$ORG-$APP-wui/src/web/html/" # Target directory
  export SRC_DIR="${SRC_DIR:-$DEFAULT_SRC_DIR}"

  ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH} ${TGT_USER}@${TGT_HOST} "sudo chmod -R 755 ${TGT_DIR} && sudo chown -R ${TGT_USER}:${TGT_USER} ${TGT_DIR}"

  # Dry run of rsync command for safety
  rsync -avz --temp-dir="/home/$TGT_USER" -e "ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH}" --exclude='.git/' --exclude='wp-config.php' ${SRC_DIR} ${TGT_USER}@${TGT_HOST}:${TGT_DIR} --delete

  ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH} ${TGT_USER}@${TGT_HOST} "sudo chmod -R 755 ${TGT_DIR} && sudo chown -R www-data:www-data ${TGT_DIR}"
  export EXIT_CODE=$?

}
