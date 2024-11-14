#!/bin/bash

set -x

test -z ${PROJ:-} && PROJ=bas-wpb-inf
test -z ${APPUSER:-} && APPUSER='appusr'
PROJ_DIR=${HOME_INF_PROJ_PATH}
cd ${PROJ_DIR} || exit 1

# spe-2880 - oherwise the CNF_VER git hash fetch will fail ...
git config --global --add safe.directory ${PROJ_DIR}

# /home/appusr/home/runner/work/infra-monitor/infra-monitor/opt/bas/infra-monitor/src/bash/run/run.sh

trap : TERM INT
sleep infinity &
wait
