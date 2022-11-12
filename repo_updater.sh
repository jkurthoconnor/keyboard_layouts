#!/bin/bash

# ./repo_updater.sh --import_from ../zsa_configurator_assets/ergodox_current --repo .
#                   --import_from argument points to specific version of a keyboard's automatically generated assets
#                   --repo argument points to root of this repo

set -e
set -x

IMPORT_PATH=  # the directory from which to copy
REPO_PATH=   # the destination repository

fatal_error() {
  echo $1
  exit 1
}

while [[ ${#@} -gt 0 ]]; do
  case $1 in
    -r|--repo)
      shift
      REPO_PATH=$1
      ;;
    -i|--import_from)
      shift
      IMPORT_PATH=$1
      ;;
    *)
      fatal_error "Argument \"$1\" is not recognized"
      ;;
  esac
  shift
done

if [[ ! -d $REPO_PATH ]] || [[ ! -d $IMPORT_PATH ]]; then
  fatal_error "Both -r and -i must be set to readable directories."
fi

ASSETS_KEYBRD_DIR=$(basename $IMPORT_PATH)
KEYBRD_NAME=${ASSETS_KEYBRD_DIR%%_*}
SRC_DESTINATION=${REPO_PATH}/${KEYBRD_NAME}
ARCHIVE_DESTINATION=${REPO_PATH}/${KEYBRD_NAME}_archive

read -p "We will copy the files from $IMPORT_PATH into ${ARCHIVE_DESTINATION}, and update the source code in ${SRC_DESTINATION} . Is this correct? (y/N) " response
[[ $response =~ ^[yY] ]] || exit

# standardize the destination filenames by identifying and removing the firmware version
# component from automated filenames
CONFIG_H=$(find ${IMPORT_PATH}/ -type f -name '*config.h')
FIRMWARE_FN_COMPONENT=$(grep FIRMWARE $CONFIG_H | awk -F \" '{print $2}' | sed 's/\//_/')

# make directory in repo to hold assets. Inside DESTINATION_assets, name with keyboardname_identifier_datestring
ARCHIVE_DESTINATION=${ARCHIVE_DESTINATION}/${FIRMWARE_FN_COMPONENT}-$(date +"%Y%m%d_%H%M%S")
mkdir -p $ARCHIVE_DESTINATION

for file in $(ls ${IMPORT_PATH}); do
  # skip archive or zip files
  [[ ${file##*.} =~ (zip|gz)$ ]] && continue 

  origin=${IMPORT_PATH}/$file
  standardized_fn=${file/_$FIRMWARE_FN_COMPONENT}

  if [[ -d ${origin} ]]; then
    origin=${origin}/*
    mkdir -p ${ARCHIVE_DESTINATION}/$file
    mkdir -p ${SRC_DESTINATION}/$standardized_fn
  fi

  cp -v $origin ${ARCHIVE_DESTINATION}/$file
  cp -v $origin ${SRC_DESTINATION}/$standardized_fn
done
