#!/bin/bash

do_update_my_cnf_on_remote() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}
  do_require_var SECRET_VAL ${SECRET_VAL:-}

  wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' $APP_PATH/$ORG-$APP-cnf/$ORG-$APP/$ENV.env.yaml)

  SSH_USR="debian"
  SERVER="debian@$wpb_fqdn"
  SSH_KEY="~/.ssh/.$ORG/$ORG-$APP-$ENV-$APP.pk"

  MY_CNF_CONTENT=$(
    cat <<EOF
[client]
user=root
password=${SECRET_VAL}
EOF
  )

  echo "$MY_CNF_CONTENT"
  ssh -i $SSH_KEY $SERVER "echo \"$MY_CNF_CONTENT\" > ~/.my.cnf && chmod 600 ~/.my.cnf"

  export EXIT_CODE=$?
}
