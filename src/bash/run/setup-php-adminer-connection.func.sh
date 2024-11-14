#!/bin/bash

do_setup_php_adminer_connection() {

  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var ENV ${ENV:-}

  local network_interface_ip=$(ifconfig -a | awk '/flags=4163<UP,BROADCAST,RUNNING,MULTICAST>/ {getline; print $2}' | tail -n 1)

  echo "Interface IP: $network_interface_ip"

  wpb_fqdn=$(yq e '.env.dns.wpb_fqdn' $APP_PATH/$ORG-$APP-cnf/$ORG-$APP/$ENV.env.yaml)

  SSH_USR="debian"
  SERVER="debian@$wpb_fqdn"
  SSH_KEY="~/.ssh/.$ORG/$ORG-$APP-$ENV-$APP.pk"

  # Update the mysql config file to allow remote connections
  CONFIG_UPDATE_CMD="sudo sed -i 's/#bind-address = 0.0.0.0/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/60-galera.cnf && sudo systemctl restart mariadb"

  ssh -o IdentitiesOnly=yes -i $SSH_KEY $SERVER "$CONFIG_UPDATE_CMD"

  # Grant access to the wordpress database for the phpmyadmin user
  MYSQL_CMD="GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress'@'$network_interface_ip' IDENTIFIED BY 'secret'; FLUSH PRIVILEGES;"

  ssh -o IdentitiesOnly=yes -i $SSH_KEY $SERVER "mysql -e \"$MYSQL_CMD\""

  #Open ssh tunnel for the phpmyadmin connection to the remote mysql server
  ssh -o IdentitiesOnly=yes -i $SSH_KEY -L 0.0.0.0:9091:localhost:3306 -N -v $SSH_USR@$wpb_fqdn

  export EXIT_CODE=$?
}
