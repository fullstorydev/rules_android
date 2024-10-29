"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
# This is all fixed by bzlmod, so we just tolerate it for now.
def rules_android_dependencies():
    http_archive(
        name = "rules_android",
        sha256 = "b1599e4604c1594a1b0754184c5e50f895a68f444d1a5a82b688b2370d990ba0",
        strip_prefix = "rules_android-0.5.1",
        url = "https://github.com/bazelbuild/rules_android/releases/download/v0.5.1/rules_android-v0.5.1.tar.gz",
        patch_args = ["-p1"],
        patches = ["@fullstory_rules_android//:patches/bazelbuild/rules_android/rules_bzl_lib.patch"],
    )
