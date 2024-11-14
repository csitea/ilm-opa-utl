#!/bin/bash

do_ssh_key_pair_gen() {


  if ! command -v expect >/dev/null 2>&1; then
    echo "expect is not installed. Installing expect..."
    sudo apt-get update && sudo apt-get install -y expect
  fi

  # id_rsa.sys+bas-wpb-int-creds@flok.fi.pub
  do_require_var ORG ${ORG:-}
  do_require_var APP ${APP:-}
  do_require_var DOMAIN ${DOMAIN:-}

  #/home/ysg/.ssh/.str/id_rsa.sys+ilm-opa-crs@flok.fi.pub
  local GIT_USER_EMAIL="sys+$ORG-$APP-crs@$DOMAIN"

  local FNAME=id_rsa.$GIT_USER_EMAIL

  # Explicitly define the full path using $HOME instead of ~
  local SSH_DIR="$HOME/.ssh/.$ORG"
  mkdir -p "$SSH_DIR"

  # Generate SSH key without passphrase
  expect -c "
    spawn ssh-keygen -t rsa -b 4096 -C \"$GIT_USER_EMAIL\" -f \"$SSH_DIR/$FNAME\"
    expect \"Enter passphrase (empty for no passphrase):\"
    send \"\r\"
    expect \"Enter same passphrase again:\"
    send \"\r\"
    expect eof
    "

  # Setup the correct permissions
  sudo chmod -v 0700 "$SSH_DIR"
  sudo chmod 0400 "$SSH_DIR/$FNAME"
  sudo chmod 0600 "$SSH_DIR/$FNAME.pub"

  # Check that the public & private key are created
  find "$SSH_DIR" | sort | grep "$GIT_USER_EMAIL"

  # Display the public key
  echo -e "cat ~/.ssh/.$ORG/$FNAME.pub\n"
  cat "$SSH_DIR/$FNAME.pub"
  echo -e "$SSH_DIR/$FNAME.pub\n"

  export EXIT_CODE=$?
}
