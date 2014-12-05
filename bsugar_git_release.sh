#!/bin/bash

source ./custom_zimlet_config.sh

check_required () {

  command -v git >/dev/null 2>&1 || { echo "Please install git.  Aborting." >&2; exit 1; }

}

check_git_is_clean () {

  if [[ ! -z $(git status -s) ]] ; then
    echo -e -n "git status is not empty. Aborting\n"
    exit 1
  fi

}

clean_and_exit () {
  git checkout -- .
  git checkout ${CURRENT_GIT_BRANCH}
  git branch -D ${TMP_GIT_BRANCH}
}

check_required
check_git_is_clean
ERROR_CODE=0
CURRENT_GIT_BRANCH="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"
TMP_GIT_BRANCH="${CURRENT_GIT_BRANCH}-tmp-$$"
MERGE_BRANCH="${ORIGINAL_ZIMLET_SUBSTRING}_${ZIMLET_SUBSTRING}" # Compulsory branch syntax

git checkout -b ${TMP_GIT_BRANCH}

if git merge ${MERGE_BRANCH} ; then
  if ! ./bsugar_release.sh ; then
    echo -e -n "Something went wrong when running: ./bsugar_release.sh\n"
    echo -e -n "You are on your own on this branch: $(git rev-parse --symbolic-full-name --abbrev-ref HEAD)\n"
    ERROR_CODE=2
    exit ${ERROR_CODE}
  fi
else
  echo -e -n "Something went wrong when trying to merge: ${MERGE_BRANCH}\n"
  echo -e -n "You are on your own on this branch: $(git rev-parse --symbolic-full-name --abbrev-ref HEAD)\n"
  ERROR_CODE=3
  exit ${ERROR_CODE}
fi

clean_and_exit




