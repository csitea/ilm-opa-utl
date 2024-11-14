#!/bin/bash
#
# create a kind of morphed clone PROJ of the source PROJ specified
# usage:
# ./run -a do_scan_to_list_file
# to "morph" the run.sh into a foo-bar PROJ do:
# SRC_PROJ=run.sh TGT_PROJ=foo-bar ./run -a do_morph_PROJ
# to "morph" the foo-bar into a foo-baz PROJ do:
# SRC_PROJ=foo-bar TGT_PROJ=foo-baz ./run -a do_morph_PROJ
#
do_morph_project() {

  do_require_var TGT_PROJ ${TGT_PROJ:-}
  DEFAULT_SRC_PROJ=$(basename $PROJ_PATH)
  SRC_PROJ=${SRC_PROJ:-$DEFAULT_SRC_PROJ}
  SRC_PROJ_PATH=$APP_PATH/${SRC_PROJ:-$DEFAULT_SRC_PROJ}

  # echo produce the $APP_PATH/$SRC_PROJ.zip
  SRC_PROJ=$SRC_PROJ do_zip_oae_proj
  TGT_ORG=$(echo "${TGT_PROJ}" | cut -d'-' -f1)
  TGT_APP=$(echo "${TGT_PROJ}" | cut -d'-' -f2)

  # mkdir -p $APP_PATH/$TGT_PROJ ; cd $APP_PATH/$TGT_PROJ
  TGT_APP_PATH=$BASE_PATH/$TGT_ORG/$TGT_ORG-$TGT_APP

  test -d $TGT_APP_PATH/$TGT_PROJ && rm -r $TGT_APP_PATH/$TGT_PROJ
  mkdir -p $TGT_APP_PATH/$TGT_PROJ && cd $_

  unzip -o $SRC_PROJ_PATH.zip -d .
  cp -v $SRC_PROJ_PATH/cnf/lst/$SRC_PROJ.include.lst $TGT_APP_PATH/$TGT_PROJ/cnf/lst/$TGT_PROJ.include.lst
  cp -v $SRC_PROJ_PATH/cnf/lst/$SRC_PROJ.exclude.lst $TGT_APP_PATH/$TGT_PROJ/cnf/lst/$TGT_PROJ.exclude.lst

  # Action !!! do search and replace src & tgt PROJ into the new dir
  STR_TO_SRCH=$SRC_PROJ STR_TO_REPL=$TGT_PROJ TGT_PATH=$TGT_APP_PATH/$TGT_PROJ do_morph_path

  # and create the synlink to the run.sh
  cd $TGT_APP_PATH/$TGT_PROJ && ln -sfn src/bash/run/run.sh run

  cd $SRC_PROJ_PATH

  EXIT_CODE="0"
}
