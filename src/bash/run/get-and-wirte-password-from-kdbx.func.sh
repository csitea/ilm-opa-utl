#!/bin/bash

do_get_and_write_password_from_kdbx() {

  # keepassxc-cli should be installed

  do_require_var SSH_KEY_PUB_FPATH ${SSH_KEY_PUB_FPATH:-}
  do_require_var KDBX_SECRET_PATH ${KDBX_SECRET_PATH:-}
  do_require_var KDBX_FPATH ${KDBX_FPATH:-}
  do_require_var WRITE_SECRET_FPATH ${WRITE_SECRET_FPATH:-}

  secret_value=$(keepassxc-cli show --no-password --quiet "$KDBX_FPATH" "$KDBX_SECRET_PATH" --key-file="$SSH_KEY_PUB_FPATH" --attributes=Password)
  echo $secret_value

  echo $secret_value >$WRITE_SECRET_FPATH

  export EXIT_CODE=$?
}
