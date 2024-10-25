#!/usr/bin/env bash
set -euxo pipefail

DIR=${1:-.}

cd ${DIR}
bazel mod deps --lockfile_mode=update