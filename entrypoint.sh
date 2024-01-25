#!/bin/bash

set -ex

DEST_DIR="${HOME}/dest_repo"
DEST_URL="https://x-access-token:${INPUT_DESTINATION_TOKEN}@github.com/${INPUT_DESTINATION_REPO}.git"
GITHUB_WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"

echo "Cloning Git repo"
git clone --depth=1 --single-branch --branch ${INPUT_GITHUB_IO_BRANCH} \
  ${DEST_URL} \
  ${DEST_DIR}

git config --global --add safe.directory /github/workspace
echo "Building Hugo"
hugo ${INPUT_HUGO_ARGS}

sleep 10

echo "after sleep; ls -alst"
ls -alst

echo "Clean dest repo"
find "${DEST_DIR}" -type f -not -path "${DEST_DIR}/.git/*" -delete

echo "Copy public to dest repo"
cp -R ./public/* ${DEST_DIR}

echo "cd into DEST_DIR"
cd ${DEST_DIR}
echo "Listing files"
ls -alst
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
echo "git status"
git status
git add --all
git commit -m "auto: $(date -R)" || \
  echo 'No changes, skipping publish!!!'
git status
git push origin ${INPUT_GITHUB_IO_BRANCH}
echo "FINISHED $?"
