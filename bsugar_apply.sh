#!/bin/bash

set -x
set -v

# $1: To find
# $2: To replace

find_and_replace () {
  find_string="$1"
  find_replace="$2"

  find . -type f -not -name $(basename ${0}) -a -not -iwholename '*.git*'  -print0 | xargs -0 sed -i 's/'"${find_string}"'/'"${find_replace}"'/g'

}

find_and_replace "com_irontec_zsugarH" "com_btactic_bsugarH"

for nfile in com_irontec_zsugar* ; do

  btactic_file=$(echo $nfile | sed 's/com_irontec_zsugar/com_btactic_bsugar/g')
  mv "${nfile}" "${btactic_file}"

done


# Find and replace design

find_and_replace "zsugar_container" "bsugar-zsugar_container"
find_and_replace "zsugar_container" "bsugar-zsugar_container"
find_and_replace "zsugar_atts" "bsugar-zsugar_atts"
find_and_replace "zsugar_container" "bsugar-zsugar_container"
find_and_replace "zsugar_powered_logo" "bsugar-zsugar_powered_logo"
find_and_replace "zsugar_contactIden" "bsugar-zsugar_contactIden"
find_and_replace "zsugar_atts" "bsugar-zsugar_atts"
find_and_replace "zsugar_atts" "bsugar-zsugar_atts"
find_and_replace "zsugar_logo" "bsugar-zsugar_logo"
find_and_replace "zsuguar_ilogo" "bsugar-zsuguar_ilogo"
find_and_replace "zsugar_blogo" "bsugar-zsugar_blogo"
find_and_replace "zsugar_powered" "bsugar-zsugar_powered"

find_and_replace "ISUGAR-panelIcon" "bsugar-ISUGAR-panelIcon"
find_and_replace "ISUGAR-icon-right" "bsugar-ISUGAR-icon-right"
find_and_replace "ISUGAR-lead" "bsugar-ISUGAR-lead"
find_and_replace "center" "bsugar-center"
find_and_replace "big" "bsugar-big"
find_and_replace "med" "bsugar-med"
find_and_replace "marTop" "bsugar-marTop"
find_and_replace "MoreButtons" "bsugar-MoreButtons"


find_and_replace "zsugar.css" "bsugar-zsugar.css"
mv zsugar.css bsugar-zsugar.css

