[← Back to README](../README.md)

# Expo Android Build System Guide
### Expo SDK 55+ (or Latest) + React Native + Expo Router

This guide explains the complete Android build workflow using:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-build-system.ps1 | iex
```

This setup automatically configures:

- Development build system
- Release build system
- APK auto-install
- APK output folder opening
- npm scripts
- `.gitignore`
- `app.config.js` wrapper
- Keystore template
- Dev/Release app separation
- Expo SDK 55+ compatible setup

---

# 1. Why Two Builds?

For Expo Android projects, keeping separate builds is recommended.

## Development Build

Used for:

- Fast coding
- Debugging
- Logs
- Development testing

Build type:

```bash
assembleDebug
```

APK:

```text
app-debug.apk
```

---

## Release Build

Used for:

- Production testing
- Real device testing
- Permission testing
- Play Protect testing
- Final APK verification

Build type:

```bash
assembleRelease
```

APK:

```text
app-release.apk
```

---

# 2. Recommended Project Structure

```text
YourExpoProject/
│
├── android/
│
├── scripts/
│   ├── dev-build.ps1
│   └── release-build.ps1
│
├── app.json
├── app.config.js
│
├── package.json
│
└── .gitignore
```

---

# 3. App Configuration (Recommended)

Use both:

```text
app.json
app.config.js
```

together.

### Why?

This is the recommended setup for Expo SDK 55+.

- `app.json` → static config
- `app.config.js` → dynamic overrides

Benefits:

- safer Expo upgrades
- no config duplication
- plugins stay intact
- Expo Router compatibility
- safer `expo prebuild`

---

## app.config.js

Create:

```js
const appJson = require("./app.json");

module.exports = ({ config }) => {
  const isRelease =
    process.env.BUILD_TYPE === "release";

  return {
    ...appJson.expo,

    name: isRelease
      ? appJson.expo.name
      : `${appJson.expo.name} Dev`,

    slug: appJson.expo.slug,

    android: {
      ...appJson.expo.android,

      package: isRelease
        ? appJson.expo.android.package
        : `${appJson.expo.android.package}.dev`
    }
  };
};
```

---

## What Happens?

### Development App

Package:

```text
com.yourapp.dev
```

App Name:

```text
Your App Dev
```

---

### Release App

Package:

```text
com.yourapp
```

App Name:

```text
Your App
```

Benefits:

- both apps stay installed together
- no uninstall required
- easier testing
- permission isolation

---

# 4. First-Time Setup (Important)

After setup completes:

Run once:

```bash
npx expo prebuild --clean
```

Why?

Package switching requires native regeneration.

Only needed once.

---

# 5. Keystore (Release Signing)

## Why Needed?

Without signing:

- Play Protect warnings increase
- app updates fail
- Android trust is lower
- production testing becomes inaccurate

---

## Generate Keystore (One Time)

Run:

```powershell
keytool -genkeypair -v `
-keystore release.keystore `
-alias releasekey `
-keyalg RSA `
-keysize 2048 `
-validity 10000
```

Example:

```text
Name: Your Name
Organization: Your Organization
Country: IN
```

---

# 6. Best Place to Store Keystore

Do NOT keep inside project.

Recommended:

```text
D:\Secure\AndroidKeys\
```

Example:

```text
D:\Secure\AndroidKeys\MyApp\
```

Store:

```text
release.keystore
keystore-info.txt
```

---

# 7. Configure Keystore

Setup automatically creates:

```text
android/keystore.properties.example
```

Copy and rename:

```text
android/keystore.properties
```

Update values:

```properties
storeFile=D:\\Secure\\AndroidKeys\\MyApp\\release.keystore
storePassword=your_password
keyAlias=releasekey
keyPassword=your_password
```

---

# 8. Git Ignore Protection

Add:

```gitignore
*.keystore
*.jks
android/keystore.properties
```

Never upload signing keys to GitHub.

---

# 9. Development Build Script

Generated automatically:

## `scripts/dev-build.ps1`

Features:

- Expo prebuild
- Debug APK build
- APK auto-install
- APK folder auto-open
- Error handling
- Safe folder navigation

Generated workflow:

```powershell
$env:BUILD_TYPE = "dev"

npx expo prebuild

Push-Location android

.\gradlew assembleDebug

adb install -r `
.\app\build\outputs\apk\debug\app-debug.apk

explorer `
.\app\build\outputs\apk\debug

Pop-Location
```

---

## Run Development Build

```bash
npm run build:dev
```

or

```powershell
powershell -ExecutionPolicy Bypass `
-File .\scripts\dev-build.ps1
```

---

# 10. Release Build Script

Generated automatically:

## `scripts/release-build.ps1`

Features:

- Expo prebuild
- Release APK build
- APK auto-install
- APK signature verification
- APK folder auto-open
- Error handling
- Safe folder navigation

Generated workflow:

```powershell
$env:BUILD_TYPE = "release"

npx expo prebuild

Push-Location android

.\gradlew clean

.\gradlew assembleRelease

adb install -r `
.\app\build\outputs\apk\release\app-release.apk

keytool -printcert `
-jarfile `
.\app\build\outputs\apk\release\app-release.apk

explorer `
.\app\build\outputs\apk\release

Pop-Location
```

---

## Run Release Build

```bash
npm run build:release
```

or

```powershell
powershell -ExecutionPolicy Bypass `
-File .\scripts\release-build.ps1
```

---

# 11. Package.json Scripts

Setup automatically adds:

```json
{
  "scripts": {
    "build:dev":
      "powershell -ExecutionPolicy Bypass -File ./scripts/dev-build.ps1",

    "build:release":
      "powershell -ExecutionPolicy Bypass -File ./scripts/release-build.ps1"
  }
}
```

---

# 12. ADB Installation

## Check Device

Run:

```bash
adb devices
```

Expected:

```text
List of devices attached
XXXXXXXX device
```

---

## Install Debug APK

```bash
adb install -r app-debug.apk
```

---

## Install Release APK

```bash
adb install -r app-release.apk
```

---

## Uninstall App

```bash
adb uninstall com.yourapp
```

---

# 13. Backup Strategy

Keep 3 copies of keystore.

## Copy 1 — Main Storage

```text
D:\Secure\AndroidKeys\
```

---

## Copy 2 — Cloud Backup

Encrypted backup:

- Google Drive
- OneDrive

---

## Copy 3 — Offline Backup

- USB drive
- External SSD

Never lose keystore.

Without it:

- app updates fail
- release updates impossible
- users must reinstall app

---

# 14. Daily Workflow

## During Coding

Run:

```bash
npm run build:dev
```

Provides:

- debug build
- fast install
- fast testing

---

## Before Production Testing

Run:

```bash
npm run build:release
```

Provides:

- release APK
- production behavior
- permission testing
- Play Protect testing
- signature verification

---

# 15. Final Recommended Workflow

## One-Time Setup

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-build-system.ps1 | iex
```

Then run once:

```bash
npx expo prebuild --clean
```

---

## Development

```bash
npm run build:dev
```

---

## Production Testing

```bash
npm run build:release
```

Everything becomes automatic:

- Expo prebuild
- APK build
- APK install
- APK folder open
- Signature verification
- Dev/Release separation
- Safe Expo SDK 55+ workflow
- `app.json + app.config.js` compatibility

---

## Related Documentation

- [ARM64 Setup Guide](ARM64_SETUP_GUIDE.md)
- [Documentation Index](INDEX.md)

---

[← Back to README](../README.md)ub

Always ignore:

```gitignore
*.keystore
```

---

### Keep release and dev package separate

Recommended:

```text
com.skwebs.financesmspoc.dev
com.skwebs.financesmspoc
```

---

# Final Recommended Workflow

### Development

```bash
npm run build:dev
```

### Production Testing

```bash
npm run build:release
```

Everything becomes automatic:

- Expo prebuild
- APK build
- Install APK
- Verify signature
- Open APK folder