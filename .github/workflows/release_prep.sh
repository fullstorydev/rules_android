#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
PREFIX="rules_android-${TAG:1}"
ARCHIVE="rules_android-$TAG.tar.gz"

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
## Using Bzlmod

1. Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "fullstory_rules_android", version = "${TAG:1}")
\`\`\`

## Using WORKSPACE (Bazel 8 or less)

Paste this snippet into your \`WORKSPACE.bazel\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "fullstory_rules_android",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/fullstorydev/rules_android/releases/download/${TAG}/${ARCHIVE}",
)

load("@fullstory_rules_android//android:dependencies.bzl", fullstory_rules_android_dependencies = "rules_android_dependencies")
fullstory_rules_android_dependencies()

# Set up bazelbuild/rules_android requirements, if you haven't already.
load("@rules_android//:prereqs.bzl", "rules_android_prereqs")
rules_android_prereqs()

load("@rules_android//:defs.bzl", "rules_android_workspace")
rules_android_workspace()
EOF

awk 'f;/--SNIP--/{f=1}' e2e/smoke/WORKSPACE.bazel
echo "\`\`\`" 
