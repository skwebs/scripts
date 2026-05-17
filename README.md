# SK Webs Scripts

Reusable scripts for:

- Expo
- React Native
- Android
- PowerShell
- Build automation

---

# Available Scripts

## Expo Android

| Script | Purpose |
|--------|---------|
| `setup-arm64.ps1` | Configure ARM64-only build |
| `setup-build-system.ps1` | Setup dev/release build automation |

---

# Documentation

## Build System

- [Expo Android Build Guide](docs/EXPO_ANDROID_BUILD_GUIDE.md)
- [Build System Guide](docs/BUILD_SYSTEM_GUIDE.md)

## Android Optimization

- [ARM64 Setup Guide](docs/ARM64_SETUP_GUIDE.md)

---

# Quick Start

### ARM64 Setup

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-arm64.ps1 | iex
```

### Build System Setup

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-build-system.ps1 | iex
``` performance
- Optimized for modern Android phones
- Excludes unnecessary CPU architectures

### Trade-offs

Your APK **will not support older 32-bit Android devices**.

Supported architecture:

```txt
arm64-v8a
```

Not included:

```txt
armeabi-v7a
x86
x86_64
```

---

# Repository Structure

```txt
scripts/
├── setup-arm64.ps1
└── setup-arm64.sh
```

---

# Requirements

Before running the script:

- Install Node.js
- Install npm
- Create an Expo project
- Internet connection required

Verify installation:

```bash
node -v
npm -v
npx expo --version
```

---

# Run From Expo Project Root

Run commands from your Expo project folder.

Example:

```txt
my-app/
├── app/
├── app.json
├── package.json
└── node_modules/
```

---

# Automatic Setup (Recommended)

Choose your OS and run **one command**.

---

# Windows

## Quick Install

Open **PowerShell** inside Expo project root.

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/setup-arm64.ps1 | iex
```

---

## Safer Method

Download first and inspect before running.

```powershell
Invoke-WebRequest `
https://raw.githubusercontent.com/skwebs/scripts/main/setup-arm64.ps1 `
-OutFile setup-arm64.ps1

powershell -ExecutionPolicy Bypass -File setup-arm64.ps1
```

---

# Linux

No PowerShell required.

## Using curl

```bash
curl -fsSL https://raw.githubusercontent.com/skwebs/scripts/main/setup-arm64.sh | bash
```

## Using wget

```bash
wget -qO- https://raw.githubusercontent.com/skwebs/scripts/main/setup-arm64.sh | bash
```

---

# macOS

## Using curl

```bash
curl -fsSL https://raw.githubusercontent.com/skwebs/scripts/main/setup-arm64.sh | bash
```

## Using wget

```bash
wget -qO- https://raw.githubusercontent.com/skwebs/scripts/main/setup-arm64.sh | bash
```

---

# Termux (Android)

Install required package:

```bash
pkg update -y
pkg install curl -y
```

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/skwebs/scripts/main/setup-arm64.sh | bash
```

---

# What This Script Changes

The script automatically performs the following steps.

---

## 1. Creates Plugin File

Creates:

```txt
plugins/
└── withArm64Only.js
```

Generated content:

```js
const { withAppBuildGradle } = require("expo/config-plugins");

module.exports = function withArm64Only(config) {
  return withAppBuildGradle(config, (config) => {
    let gradle = config.modResults.contents;

    const splitConfig = `
    splits {
        abi {
            enable = true
            reset()
            include("arm64-v8a")
            universalApk = false
        }
    }
`;

    if (!gradle.includes("splits {")) {
      gradle = gradle.replace(
        /android\s*\{/,
        `android {${splitConfig}`
      );
    }

    config.modResults.contents = gradle;

    return config;
  });
};
```

---

## 2. Installs Dependency

Automatically installs:

```bash
npx expo install expo-build-properties
```

---

## 3. Updates `package.json`

Adds:

```json
"build:arm64": "npx expo prebuild --clean && cd android && gradlew.bat clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true"
```

Example:

```json
{
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "build:arm64": "npx expo prebuild --clean && cd android && gradlew.bat clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true"
  }
}
```

---

## 4. Updates `app.json`

Adds:

```json
{
  "expo": {
    "plugins": [
      "./plugins/withArm64Only",
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
    ]
  }
}
```

---

# Build APK

After installation:

## Step 1: Generate Native Android Project

If `android/` folder does not exist:

```bash
npx expo prebuild
```

---

## Step 2: Build APK

### Windows

```bash
npm run build:arm64
```

### Linux / macOS

```bash
cd android
./gradlew clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true
```

APK output:

```txt
android/app/build/outputs/apk/release/
```

---

# Manual Setup

If you do not want to run scripts automatically, follow these steps.

---

## Step 1: Install Package

Run:

```bash
npx expo install expo-build-properties
```

---

## Step 2: Create Plugin Folder

Create:

```txt
plugins/
```

Inside it create:

```txt
plugins/withArm64Only.js
```

Paste:

```js
const { withAppBuildGradle } = require("expo/config-plugins");

module.exports = function withArm64Only(config) {
  return withAppBuildGradle(config, (config) => {
    let gradle = config.modResults.contents;

    const splitConfig = `
    splits {
        abi {
            enable = true
            reset()
            include("arm64-v8a")
            universalApk = false
        }
    }
`;

    if (!gradle.includes("splits {")) {
      gradle = gradle.replace(
        /android\s*\{/,
        `android {${splitConfig}`
      );
    }

    config.modResults.contents = gradle;

    return config;
  });
};
```

---

## Step 3: Update `app.json`

Add inside `expo.plugins`.

Example:

```json
{
  "expo": {
    "plugins": [
      "./plugins/withArm64Only",
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
    ]
  }
}
```

---

## Step 4: Update `package.json`

Inside `scripts`, add:

```json
"build:arm64": "npx expo prebuild --clean && cd android && gradlew.bat clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true"
```

Example:

```json
{
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "build:arm64": "npx expo prebuild --clean && cd android && gradlew.bat clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true"
  }
}
```

---

## Step 5: Generate Android Folder

If missing:

```bash
npx expo prebuild
```

---

## Step 6: Build APK

### Windows

```bash
npm run build:arm64
```

### Linux / macOS

```bash
cd android
./gradlew clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true
```

---

# Verify APK Architecture

To confirm APK contains only ARM64:

```bash
unzip -l app-release.apk | grep lib/
```

Expected:

```txt
lib/arm64-v8a/
```

Should NOT contain:

```txt
armeabi-v7a
x86
x86_64
```

---

# Troubleshooting

## `app.json not found`

Run command from Expo project root.

Correct:

```txt
my-app/
├── app.json
├── package.json
└── plugins/
```

---

## `package.json not found`

You are not inside Expo root folder.

Run:

```bash
pwd
```

or on Windows:

```powershell
pwd
```

---

## `gradlew not found`

Generate native project:

```bash
npx expo prebuild
```

---

## `expo-build-properties install failed`

Install manually:

```bash
npx expo install expo-build-properties
```

---

## Build command failed

Clean project:

```bash
rm -rf android
npx expo prebuild
```

Then rebuild.

---

# FAQ

### Does this work with Expo SDK 53+?

Yes.

---

### Does this work with Expo prebuild?

Yes.

---

### Does this support EAS Build?

Yes, but mainly useful for local native builds.

---

### Can I still generate AAB?

Yes. This only changes Android ABI filtering.

---

### Can I run the script multiple times?

Yes.

The script prevents duplicate entries.

---

# Contributing

Pull requests are welcome.

Feel free to improve:

- Plugin logic
- Cross-platform compatibility
- Build optimizations
- Documentation

---

# License

MIT