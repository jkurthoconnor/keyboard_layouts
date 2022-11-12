#!/bin/bash

# ./repo_updater.sh --assets ../zsa_configurator_assets/ergodox_current --repo .
#                   --assets argument points to specific version of a keyboard's automatically generated assets
#                   --repo argument points to root of this repo

set -e
set -x

ASSETS_PATH=  # the directory from which to copy
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
    -a|--assets)
      shift
      ASSETS_PATH=$1
      ;;
    *)
      fatal_error "Argument \"$1\" is not recognized"
      ;;
  esac
  shift
done

if [[ ! -d $REPO_PATH ]] || [[ ! -d $ASSETS_PATH ]]; then
  fatal_error "Both -r and -a must be set to readable directories."
fi

ASSETS_KEYBOARD_DIR=$(basename $ASSETS_PATH)
DESTINATION=${REPO_PATH}/${ASSETS_KEYBOARD_DIR%%_*}

read -p "We will copy the files from $ASSETS_PATH into ${DESTINATION}/ . Is this correct? (y/N) " response
[[ $response =~ ^[yY] ]] || exit

# standardize the destination filenames by identifying and removing the firmware version
# component from automated filenames
CONFIG_H=$(find ${ASSETS_PATH}/ -type f -name '*config.h')
FIRMWARE_FN_COMPONENT=$(grep FIRMWARE $CONFIG_H | awk -F \" '{print $2}' | sed 's/\//_/')

for file in $(ls ${ASSETS_PATH}); do
  # skip archive or zip files
  [[ ${file##*.} =~ (zip|gz)$ ]] && continue 

  origin=${ASSETS_PATH}/$file
  standardized_fn=${file/_$FIRMWARE_FN_COMPONENT}
  if [[ -d ${origin} ]]; then
    origin=${origin}/*
  fi

  cp -v $origin ${DESTINATION}/$standardized_fn
done
