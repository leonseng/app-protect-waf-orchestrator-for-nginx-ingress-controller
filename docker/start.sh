#!/usr/bin/env bash

set -e

GITHUB_REPO=$(echo $GITHUB_REPO_URL | awk -F'github.com/' '{print $2}')
REG_TOKEN=$(curl -X POST -H "Authorization: token ${GITHUB_PERSONAL_ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/repos/${GITHUB_REPO}/actions/runners/registration-token | jq .token --raw-output)

./config.sh \
  --url $GITHUB_REPO_URL \
  --token $REG_TOKEN \
  --unattended \
  --disableupdate

./run.sh
