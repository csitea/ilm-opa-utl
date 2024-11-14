#!/bin/bash
do_set_captcha_secrets_to_remote() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}
  do_require_var SRC_CAPTCHA_V3_SECRET_KEY ${SRC_CAPTCHA_V3_SECRET_KEY:-}
  do_require_var SRC_CAPTCHA_V3_SITE_KEY ${SRC_CAPTCHA_V3_SITE_KEY:-}
  do_require_var TGT_CAPTCHA_V3_SECRET_KEY ${TGT_CAPTCHA_V3_SECRET_KEY:-}
  do_require_var TGT_CAPTCHA_V3_SITE_KEY ${TGT_CAPTCHA_V3_SITE_KEY:-}

  wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' $APP_PATH/$ORG-$APP-cnf/$ORG-$APP/$ENV.env.yaml)

  SSH_USR="debian"
  SERVER="debian@$wpb_fqdn"
  SSH_KEY="~/.ssh/.$ORG/$ORG-$APP-$ENV-$APP.pk"

  # edit the db
  ssh -i $SSH_KEY $SERVER "wp search-replace \
    "$SRC_CAPTCHA_V3_SITE_KEY" "$TGT_CAPTCHA_V3_SITE_KEY" \
    --path="/var/www/html" --precise --all-tables"
  ssh -i $SSH_KEY $SERVER "wp search-replace \
    "$SRC_CAPTCHA_V3_SECRET_KEY" "$TGT_CAPTCHA_V3_SECRET_KEY" \
    --path="/var/www/html" --precise --all-tables"

  export EXIT_CODE=$?
}
