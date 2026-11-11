#!/bin/sh
# Runs an l3build command for xlistings and then for code-link, e.g. 'sh both.sh ctan'.
set -e
cd "$(dirname "$0")"
l3build "$@"
cd code-link
l3build "$@"
