"implementation of fullstory_android_binary rule"

load("@rules_android//rules:rules.bzl", "ApkInfo")

def _impl(ctx):
    return [
        DefaultInfo(
            files = depset(),
        ),
        ctx.attr.apk[ApkInfo],
    ]

fullstory_android_binary = rule(
    implementation = _impl,
    attrs = {
        "apk": attr.label(
            mandatory = True,
            providers = [ApkInfo],
        ),
    },
    doc = """Integrate the Android Fullstory SDK into an Android application.

Example:
```starlark
load("@rullstory_rules_android//android:defs.bzl", "fullstory_android_binary")

fullstory_android_binary(
  name = "example",
  apk = "//package:android_binary_target",
)
```
""",
)
