# Release Process

Releases are automated via GitHub Actions. Pushing a version tag triggers the
[release workflow](.github/workflows/release.yml), which validates the codebase,
builds release artifacts, and publishes a GitHub Release.

## Artifacts produced

| File | Description |
|------|-------------|
| `simple-otp-linux-x64.tar.gz` | Linux x64 release bundle |
| `app-arm64-v8a-release.apk` | Android APK — 64-bit ARM |
| `app-armeabi-v7a-release.apk` | Android APK — 32-bit ARM |
| `app-x86_64-release.apk` | Android APK — x86_64 (emulator/desktop) |

## Steps

### 1. Validate locally

Run the full validation suite before tagging:

```bash
make
```

This runs dependency resolution, code generation, linting (`dart fix` + `flutter
analyze`), and all tests. Fix any failures before proceeding.

### 2. Update the version

Edit `pubspec.yaml` and bump the version number:

```yaml
version: 1.2.3+4
#        ^^^^^  build-name  (shown to users, used as versionName on Android)
#              ^ build-number (integer, used as versionCode on Android)
```

Increment the build-number by 1 for every release. Follow semantic versioning
for the build-name:

- **Patch** (`1.0.x`) — bug fixes, no new features
- **Minor** (`1.x.0`) — new features, backwards compatible
- **Major** (`x.0.0`) — breaking changes or significant rewrites

### 3. Commit the version bump

```bash
git add pubspec.yaml
git commit -m "Bump version to 1.2.3+4"
git push
```

Wait for the [CI build](../../actions/workflows/simple_otp_build.yml) to pass on
`main` before tagging.

### 4. Tag the release

Tags must match `v*` to trigger the release workflow. Use the same version as
`pubspec.yaml`:

```bash
git tag v1.2.3
git push origin v1.2.3
```

### 5. Monitor the workflow

Open the [Actions tab](../../actions/workflows/release.yml) and watch the
**Release** workflow run. It will:

1. Run `make` (deps, codegen, lint, tests)
2. Build the Linux release bundle
3. Build the Android APKs (release, split per ABI)
4. Package and publish a GitHub Release with auto-generated release notes

The workflow takes approximately 5–10 minutes.

### 6. Review the release

Once the workflow completes, open the [Releases page](../../releases) and verify:

- Release notes are accurate (edit them on GitHub if needed)
- All four artifact files are attached
- The release is marked as the latest

## Versioning reference

```
pubspec.yaml version: 1.2.3+4
git tag:              v1.2.3
```

The `+build-number` suffix is not included in the tag — it is internal to the
Android/Flutter build system.

## Troubleshooting

**Workflow fails at `make`** — a test or lint error was introduced after local
validation. Fix on `main`, delete the tag, retag, and push again:

```bash
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3
# fix the issue, commit, push, then re-tag
git tag v1.2.3
git push origin v1.2.3
```

**APKs are unsigned** — the release APKs are built without a signing keystore.
They can be sideloaded but cannot be published to the Google Play Store without
additional signing configuration.
