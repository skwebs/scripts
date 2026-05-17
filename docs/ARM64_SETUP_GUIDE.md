[← Back to README](../README.md)

# ARM64 Setup Guide
### Expo SDK 55+ (or Latest) + React Native + Android

This guide explains how to configure **ARM64-only APK builds** for Expo projects using:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-arm64.ps1 | iex
```

This setup automatically configures:

- ARM64-only APK build
- ABI filtering
- Expo build properties
- Android Gradle configuration
- `build:arm64` script
- Smaller APK size
- Better performance

---

# 1. Why ARM64 Only?

Most modern Android devices use:

```text
arm64-v8a
```

Building only ARM64 provides:

### Smaller APK

Removes unnecessary architectures:

```text
armeabi-v7a
x86
x86_64
```

Result:

- smaller APK size
- faster install
- reduced storage usage

---

### Better Performance

ARM64 binaries are:

- faster
- more optimized
- modern Android standard

---

### Ideal For

Good for:

- production APKs
- personal apps
- internal distribution
- APK sharing

Not ideal for:

- Android emulator support
- very old devices

---

# 2. One-Time Setup

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-arm64.ps1 | iex
```

This automatically configures everything.

---

# 3. What Setup Script Creates

## Plugins Folder

Creates:

```text
plugins/
```

---

## ARM64 Plugin

Creates:

```text
plugins/withArm64Only.js
```

This plugin automatically modifies:

```text
android/app/build.gradle
```

during:

```bash
npx expo prebuild
```

to force:

```text
arm64-v8a
```

only.

---

## Installs Dependency

Automatically installs:

```text
expo-build-properties
```

---

## Package.json Script

Automatically adds:

```json
{
  "scripts": {
    "build:arm64":
      "cd android && gradlew.bat clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true"
  }
}
```

---

## App Config Plugin

Automatically updates:

### `app.json`

and adds:

```json
{
  "plugins": [
    "./plugins/withArm64Only"
  ]
}
```

and:

```json
[
  "expo-build-properties",
  {
    "android": {
      "abiFilters": [
        "arm64-v8a"
      ]
    }
  }
]
```

---

# 4. First-Time Setup

After setup completes:

Run:

```bash
npx expo prebuild --clean
```

Why?

Because native Android configuration changed.

Only needed once.

---

# 5. Build ARM64 APK

Run:

```bash
npm run build:arm64
```

What happens:

1. Cleans old build
2. Builds release APK
3. Generates ARM64-only APK

---

# 6. APK Output Location

Generated APK:

```text
android/app/build/outputs/apk/release
```

Example:

```text
app-arm64-v8a-release.apk
```

---

# 7. Verify APK Architecture

Check supported ABI:

```bash
aapt dump badging app-arm64-v8a-release.apk | grep native-code
```

Expected:

```text
native-code: 'arm64-v8a'
```

---

# 8. Common Architectures

### ARM64 (Recommended)

```text
arm64-v8a
```

Modern Android devices.

Recommended.

---

### ARM32

```text
armeabi-v7a
```

Older phones.

Larger APK.

---

### x86

```text
x86
```

Android emulator.

Usually unnecessary.

---

### x86_64

```text
x86_64
```

64-bit emulator.

Usually unnecessary.

---

# 9. Troubleshooting

## APK not generated

Run:

```bash
npx expo prebuild --clean
```

Then:

```bash
npm run build:arm64
```

---

## Plugin not working

Check:

```text
plugins/withArm64Only.js
```

exists.

---

## `expo-build-properties` missing

Install manually:

```bash
npx expo install expo-build-properties
```

---

## Wrong architecture APK generated

Verify:

### `app.json`

contains:

```json
"./plugins/withArm64Only"
```

and:

```json
[
  "expo-build-properties",
  {
    "android": {
      "abiFilters": [
        "arm64-v8a"
      ]
    }
  }
]
```

---

# 10. Recommended Workflow

### One-Time Setup

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-arm64.ps1 | iex
```

Then:

```bash
npx expo prebuild --clean
```

---

### Build APK

```bash
npm run build:arm64
```

---

# 11. Related Documentation

- [Build System Guide](BUILD_SYSTEM_GUIDE.md)
- [Documentation Index](INDEX.md)

---

[← Back to README](../README.md)