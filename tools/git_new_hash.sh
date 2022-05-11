#!/bin/bash -e

touch dummy
git add dummy &>/dev/null
git commit --amend --no-edit &>/dev/null

git rm dummy &>/dev/null
git commit --amend --no-edit &>/dev/null

git rev-parse HEAD
