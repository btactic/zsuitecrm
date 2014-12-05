#!/bin/bash

source ./custom_zimlet_config.sh

check_required () {

  command -v zip >/dev/null 2>&1 || { echo "Please install zip.  Aborting." >&2; exit 1; }

}

clean_and_exit () {
  cd /
  rm -rf ${TMP_DIRECTORY}
  cd "${OLD_PWD}"
  exit ${ERROR_CODE}
}

check_required
ERROR_CODE=0

OLD_PWD="$(pwd)"
TMP_DIRECTORY="/tmp/${ZIMLET_STRING}-tmp-$$"
TMP_RELEASE_DIR="/tmp/${ZIMLET_STRING}-release-$$"
TMP_RELEASE_FILENAME="${TMP_RELEASE_DIR}/${ZIMLET_STRING}.zip"

mkdir ${TMP_DIRECTORY}
mkdir ${TMP_RELEASE_DIR}
cp -r * ${TMP_DIRECTORY}
cd ${TMP_DIRECTORY}
if ./bsugar_apply.sh ; then
  if zip -q -r "${TMP_RELEASE_FILENAME}" * ; then
    echo -e -n "You can find your new zimlet release at: ${TMP_RELEASE_FILENAME}\n"
  else
    echo -e -n "Something went wrong when creating ${TMP_RELEASE_FILENAME}\n"
    ERROR_CODE=1
  fi
else
    echo -e -n "Something went wrong when running: ./bsugar_apply.sh\n"
    ERROR_CODE=2
fi


clean_and_exit




