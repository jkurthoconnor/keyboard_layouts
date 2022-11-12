#!/bin/bash
# one-off script to move and rename archives

set -e
set -x

CURRENT_ARCHIVE=$1
DESTINATION=$2

for directory in $(ls $CURRENT_ARCHIVE); do
  dir_path=${CURRENT_ARCHIVE}/$directory
  [[ -d ${dir_path} ]] || continue
  keyboard=${directory%%_*}
  identifier=$(find $dir_path -name '*.md5' | sed 's/\.md5//' | sed -r 's/.*_(.*_.*)/\1/')
  orig_timestamp=${directory#*-}
  new_fn=${identifier}-${orig_timestamp}
  ORIGIN=${CURRENT_ARCHIVE}/$directory
  TARGET=${DESTINATION}/${keyboard}_archive/
  mv ${ORIGIN} ${TARGET}/${new_fn}
done
