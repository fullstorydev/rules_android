<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="fullstory_android_binary"></a>

## fullstory_android_binary

<pre>
load("@fullstory_rules_android//android:defs.bzl", "fullstory_android_binary")

fullstory_android_binary(<a href="#fullstory_android_binary-name">name</a>, <a href="#fullstory_android_binary-apk">apk</a>, <a href="#fullstory_android_binary-application_class">application_class</a>, <a href="#fullstory_android_binary-min_sdk_version">min_sdk_version</a>, <a href="#fullstory_android_binary-org_id">org_id</a>)
</pre>

Integrate the Android Fullstory SDK into an Android application.

Example:
```starlark
load("@rullstory_rules_android//android:defs.bzl", "fullstory_android_binary")

fullstory_android_binary(
  name = "example",
  apk = "//package:android_binary_target",
  application_class = "com.example.App",
  org_id = "YourOrganizationId",
  min_sdk_version = 19,
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fullstory_android_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fullstory_android_binary-apk"></a>apk |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="fullstory_android_binary-application_class"></a>application_class |  -   | String | required |  |
| <a id="fullstory_android_binary-min_sdk_version"></a>min_sdk_version |  -   | Integer | optional |  `19`  |
| <a id="fullstory_android_binary-org_id"></a>org_id |  -   | String | required |  |


