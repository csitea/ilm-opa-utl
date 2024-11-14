#!/bin/bash

MODULE='conf-validator'

test -z ${PROJ:-} && PROJ=${MODULE:-}

CNF_PROJ_PATH=$(echo $CNF_PROJ_PATH | perl -ne "s|/home/$APPUSR||g;print")
BASE_PATH=$(echo $BASE_PATH | perl -ne "s|/home/$APPUSR||g;print")

venv_path="$CNF_PROJ_PATH/src/python/$MODULE/.venv"
home_venv_path="$HOME_CNF_PROJ_PATH/src/python/$MODULE/.venv"
venv_path="$CNF_PROJ_PATH/src/python/$MODULE/.venv"

cd $CNF_PROJ_PATH/src/python/$MODULE && poetry install

# echo running find $home_venv_path \| tail -n 10
# find $home_venv_path | tail -n 10
# todo remove me ^^^^

# test -d $venv_path && sudo rm -r $venv_path
# do not use this one ^^^^!!! Big GOTCHA !!!
cp -r $home_venv_path $venv_path
perl -pi -e "s|/home/$APPUSR||g" $venv_path/bin/activate

# if it points to PROJ_PATH it will always be broken
echo "source $CNF_PROJ_PATH/src/python/$MODULE/.venv/bin/activate" >>~/.bashrc
echo "source $CNF_PROJ_PATH/src/python/$MODULE/.venv/bin/activate" >>~/.profile
# cd "$PROJ_PATH/src/python/$MODULE && poetry install"

echo "cd $CNF_PROJ_PATH" >>~/.bashrc

trap : TERM INT
sleep infinity &
wait
