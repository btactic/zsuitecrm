#!/bin/bash

set -x
set -v

NEW_ZIMLET_PREFIX="bsugar-"


# $1: To find

find_and_replace_with_prefix () {
  local find_string="$1"

  find_and_replace "${find_string}" "${NEW_ZIMLET_PREFIX}${find_string}"

}


# $1: To find
# $2: To replace

find_and_replace () {
  local find_string="$1"
  local find_replace="$2"

  find . -type f -not -name $(basename ${0}) -a -not -iwholename '*.git*'  -print0 | xargs -0 sed -i 's/'"${find_string}"'/'"${find_replace}"'/g'

}

find_and_replace "com_irontec_zsugarH" "com_btactic_bsugarH"

for nfile in com_irontec_zsugar* ; do

  btactic_file=$(echo $nfile | sed 's/com_irontec_zsugar/com_btactic_bsugar/g')
  mv "${nfile}" "${btactic_file}"

done


# Find and replace design

find_and_replace_with_prefix "zsugar_container"
find_and_replace_with_prefix "zsugar_atts"
find_and_replace_with_prefix "zsugar_contactIden"
find_and_replace_with_prefix "zsugar_logo"
find_and_replace_with_prefix "zsuguar_ilogo"
find_and_replace_with_prefix "zsugar_blogo"
find_and_replace_with_prefix "zsugar_powered"

find_and_replace_with_prefix "ISUGAR-panelIcon"
find_and_replace_with_prefix "ISUGAR-icon-right"
find_and_replace_with_prefix "ISUGAR-lead"


find_and_replace_with_prefix "zsugar.css"
mv "zsugar.css" "${NEW_ZIMLET_PREFIX}zsugar.css"

