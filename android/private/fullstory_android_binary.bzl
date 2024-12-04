"implementation of fullstory_android_binary rule"

load("@rules_android//rules:rules.bzl", "ApkInfo")
load("@rules_android//rules:utils.bzl", "get_android_sdk")

def _impl(ctx):
    apk_info = ctx.attr.apk[ApkInfo]
    out_apk = ctx.actions.declare_file(ctx.label.name + ".apk")
    unsigned_apk = ctx.actions.declare_file(ctx.label.name + "_unsigned.apk")

    args = ctx.actions.args()
    args.add("--in", apk_info.unsigned_apk.path)
    args.add("--applicationClass", ctx.attr.application_class)
    args.add("--minSdkVersion", ctx.attr.min_sdk_version)
    args.add("--org", ctx.attr.org_id)
    args.add("--out", unsigned_apk.path)

    ctx.actions.run(
        outputs = [unsigned_apk],
        inputs = [apk_info.unsigned_apk],
        arguments = [args],
        executable = ctx.executable._fullstory_injector,
    )

    _sign_apk(
        ctx,
        out_apk = out_apk,
        in_apk = unsigned_apk,
        signing_keys = apk_info.signing_keys,
        deterministic_signing = False,
        signing_lineage = apk_info.signing_lineage,
        signing_key_rotation_min_sdk = ctx.attr.min_sdk_version,
        v4_signature_file = None,
    )

    return [
        DefaultInfo(
            files = depset([
                out_apk,
            ]),
        ),
        ApkInfo(
            unsigned_apk = unsigned_apk,
            signed_apk = out_apk,
            signing_keys = apk_info.signing_keys,
            signing_lineage = apk_info.signing_lineage,
            signing_min_v3_rotation_api_version = apk_info.signing_min_v3_rotation_api_version,
            # The rest are copied from the incoming source for now.
            deploy_jar = apk_info.deploy_jar,
            coverage_metadata = apk_info.coverage_metadata,
            merged_manifest = apk_info.deploy_jar,  # cannot access merged_manifest, so just drop a file here.
        ),
    ]

# This is mostly borrowed from the internal signing function in rules_android-
# https://github.com/bazelbuild/rules_android/blob/4d719e1b1a9db31c2ea18dc966dbe8be05550b05/rules/apk_packaging.bzl#L312
def _sign_apk(
        ctx,
        out_apk,
        in_apk,
        signing_keys = [],
        deterministic_signing = True,
        signing_lineage = None,
        signing_key_rotation_min_sdk = None,
        v4_signature_file = None,
        toolchain_type = None):
    """Signs an apk."""
    outputs = [out_apk]
    inputs = [in_apk] + signing_keys
    apk_signer = get_android_sdk(ctx).apk_signer

    args = ctx.actions.args()
    args.add("sign")

    if signing_lineage:
        inputs.append(signing_lineage)
        args.add("--lineage", signing_lineage)
    if deterministic_signing:
        # Enable deterministic DSA signing to keep the output of apksigner deterministic.
        # This requires including BouncyCastleProvider as a Security provider, since the standard
        # JDK Security providers do not include support for deterministic DSA signing.
        # Since this adds BouncyCastleProvider to the end of the Provider list, any non-DSA signing
        # algorithms (such as RSA) invoked by apksigner will still use the standard JDK
        # implementations and not Bouncy Castle.
        args.add("--deterministic-dsa-signing", "true")
        args.add("--provider-class", "org.bouncycastle.jce.provider.BouncyCastleProvider")

    for i in range(len(signing_keys)):
        if i > 0:
            args.add("--next-signer")
        args.add("--ks", signing_keys[i])
        args.add("--ks-pass", "pass:android")

    args.add("--v1-signing-enabled", ctx.fragments.android.apk_signing_method_v1)
    args.add("--v1-signer-name", "CERT")
    args.add("--v2-signing-enabled", ctx.fragments.android.apk_signing_method_v2)

    # If the v4 flag is unset, it should not be passed to apk signer. This extra level of control is
    # needed to support environments where older build tools may be used.
    if ctx.fragments.android.apk_signing_method_v4 != None:
        args.add("--v4-signing-enabled", ctx.fragments.android.apk_signing_method_v4)
    if v4_signature_file:
        outputs.append(v4_signature_file)

    if signing_key_rotation_min_sdk:
        args.add("--rotation-min-sdk-version", signing_key_rotation_min_sdk)

    args.add("--out", out_apk)
    args.add(in_apk)

    ctx.actions.run(
        executable = apk_signer,
        outputs = outputs,
        inputs = inputs,
        arguments = [args],
        mnemonic = "ApkSignerTool",
        progress_message = "Signing apk",
        toolchain = toolchain_type,
    )

fullstory_android_binary = rule(
    implementation = _impl,
    attrs = {
        "apk": attr.label(
            mandatory = True,
            providers = [ApkInfo],
        ),
        "application_class": attr.string(mandatory = True),
        "org_id": attr.string(mandatory = True),
        "min_sdk_version": attr.int(default = 19),
        "_fullstory_injector": attr.label(
            default = "//android/private:FullstoryInjector",
            executable = True,
            cfg = "exec",
        ),
    },
    toolchains = ["@rules_android//toolchains/android:toolchain_type", "@rules_android//toolchains/android_sdk:toolchain_type"],
    doc = """Integrate the Android Fullstory SDK into an Android application.

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
""",
    fragments = ["android"],
)
