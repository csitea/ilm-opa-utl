#!/bin/bash

do_sync_wui_to_local_host() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}

  YAML_CONF_FILE="$BASE_PATH/$ORG/$ORG-$APP/$ORG-$APP-cnf/$ORG-$APP/$ENV.env.yaml"
  DOMAIN=$(yq -r '.env.dns.tld_domain' $YAML_CONF_FILE)
  fqn_host_name=$(yq -r '.env.dns.wpb_fqdn' $YAML_CONF_FILE)

  # Define variables
  # /home/ysg/.ssh/.$ORG/$ORG-$APP-tst-$APP.pk
  # /home/ysg/.ssh/.kdm/bas-wpb-dev-$APP.pk
  # /home/ysg/.ssh/.kdm/bas-wpb-dev-skk.pub
  export SSH_KEY_PATH="~/.ssh/.$ORG/$ORG-$APP-${ENV}-$APP.pk"     # SSH key path
  export SRC_USER="debian"                                        # Source user
  export SRC_HOST="$fqn_host_name"                                # Source host
  export SRC_DIR="/var/www/html/"                                 # Source directory
  export DEFAULT_TGT_DIR="${APP_PATH}/$ORG-$APP-wui/src/web/html" # Target directory
  export TGT_DIR="${TGT_DIR:-$DEFAULT_TGT_DIR}"

  ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH} ${SRC_USER}@${SRC_HOST} "sudo find /var/www/html/wp-content/plugins -type d -exec chmod -R 0755 {} \;"
  ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH} ${SRC_USER}@${SRC_HOST} "sudo find /var/www/html/wp-content/themes -type d -exec chmod -R 0755 {} \;"

  ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH} ${SRC_USER}@${SRC_HOST} "sudo find /var/www/html/wp-content/plugins -type f -exec chmod -R 0644 {} \;"
  ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH} ${SRC_USER}@${SRC_HOST} "sudo find /var/www/html/wp-content/themes -type f -exec chmod -R 0644 {} \;"

  # Rsync command with SSH options
  rsync -avz -e "ssh -o IdentitiesOnly=yes -i ${SSH_KEY_PATH}" \
    --exclude='wp-config.php' \
    ${SRC_USER}@${SRC_HOST}:${SRC_DIR} ${TGT_DIR} --delete

  export EXIT_CODE=$?

}
