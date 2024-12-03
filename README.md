# Bazel rules for Fullstory + Android

> ## ⚠️ This is an experimental ruleset and not ready for usage ⚠️

The rules provided here can be used to integrate the Fullstory SDK into APKs
generated by [`bazelbuild/rules_android`](https://github.com/bazelbuild/rules_android)

## Installation

Not available yet

<!--
### Using Bzlmod

This is available at [the Bazel Central Registry as `fullstory_rules_android`](https://registry.bazel.build/modules/fullstory_rules_android).

### Using WORKSPACE (Bazel 8 or less)

From the release you wish to use:
<https://github.com/fullstorydev/rules_android/releases>
copy the WORKSPACE snippet into your `WORKSPACE` file.
-->

## Usage

### Prerequisites

- This library depends on [`bazelbuild/rules_android`](https://github.com/bazelbuild/rules_android),
  and the current version requires the `--experimental_google_legacy_api` and
  `--experimental_enable_android_migration_apis` flags to be set. We suggest
  setting them in your `.bazelrc` as such:

  ```bazelrc
  common --experimental_google_legacy_api
  common --experimental_enable_android_migration_apis
  ```

### Integrating the SDK

To integrate your APK with the Fullstory SDK, you can use the `fullstory_android_binary`
rule:

```starlark
load("@fullstory_rules_android//android:defs.bzl", "fullstory_android_binary")

fullstory_android_binary(
    name = "app_with_fs",
    app = "//package:android_buinary_target",
)
```

This will take the unsigned APK generated by the given target, integrate it with
the Fullstory SDK, and generate new signed and unsigned APKs.
