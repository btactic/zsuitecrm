#!/bin/bash
VERSION="$(head -n 1 VERSION)"
ABOUT_STANZA="$(head -n 1 ABOUT_STANZA)"
ZIMLET_NAME="com_irontec_zsugar"
ZIMLET_BUILD_DIR="${ZIMLET_NAME}_tmpbuilddir"

# Create build directory
if [ ! -d "${ZIMLET_BUILD_DIR}" ] ; then
  cp -a "${ZIMLET_NAME}" "${ZIMLET_BUILD_DIR}"
else
  echo "${ZIMLET_BUILD_DIR} directory should not exist in the first place."
  echo "${ZIMLET_BUILD_DIR} Aborting !!!"
  exit 1
fi

# Replace version
cd "${ZIMLET_BUILD_DIR}"
FILES_TO_REPLACE="com_irontec_zsugar.xml com_irontec_zsugar.properties com_irontec_zsugar_*.properties"

for nfile in ${FILES_TO_REPLACE} ; do
  sed -i 's~@@ABOUT_STANZA@@~'"${ABOUT_STANZA}"'~g' "${nfile}"
  sed -i 's~@@VERSION@@~'"${VERSION}"'~g' "${nfile}"
done

cd ..
# Create zip

cd "${ZIMLET_BUILD_DIR}"
zip -q -r ../${ZIMLET_NAME}.zip *
cd ..
echo 'An installable version of zimlet was created on: '"${ZIMLET_NAME}"'.zip'

rm -rf "${ZIMLET_BUILD_DIR}"

exit 0
