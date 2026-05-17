# Finance SMS POC – Complete Android Build & Release Guide (Expo SDK 53 + React Native)

This guide explains the complete workflow for:

- Development Build (Fast Testing)
- Release Build (Production Testing)
- Signed APK Generation
- PowerShell Scripts
- ADB Installation
- SMS Permission Issues
- Play Protect Issues
- Expo Prebuild Safety
- Keystore Management

---

# 1. Why Two Builds?

For a finance SMS app, keep two builds:

## Development Build
Used for:

- Fast development
- Debugging
- Logs
- Hot reload
- Coding/testing

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

- Real-world testing
- SMS permission behavior
- Play Protect testing
- Production testing

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
FinanceSMSPOC/
│
├── android/
│
├── scripts/
│   ├── dev-build.ps1
│   └── release-build.ps1
│
├── app.config.js
│
├── package.json
│
└── .gitignore
```

---

# 3. App Configuration (Recommended)

Instead of static `app.json`, use:

## app.config.js

Create:

```js
export default ({ config }) => {
  const isRelease =
    process.env.BUILD_TYPE === "release";

  return {
    ...config,

    name: isRelease
      ? "Finance SMS POC"
      : "Finance SMS POC Dev",

    android: {
      package: isRelease
        ? "com.skwebs.financesmspoc"
        : "com.skwebs.financesmspoc.dev",

      permissions: [
        "READ_SMS",
        "RECEIVE_SMS",
        "READ_PHONE_STATE",
        "RECEIVE_BOOT_COMPLETED"
      ],

      adaptiveIcon: {
        backgroundColor: "#E6F4FE",
        foregroundImage:
          "./assets/images/android-icon-foreground.png",
        backgroundImage:
          "./assets/images/android-icon-background.png",
        monochromeImage:
          "./assets/images/android-icon-monochrome.png"
      },

      predictiveBackGestureEnabled: false
    },

    plugins: [
      "expo-router",
      [
        "expo-splash-screen",
        {
          backgroundColor: "#208AEF",
          android: {
            image:
              "./assets/images/splash-icon.png",
            imageWidth: 76
          }
        }
      ]
    ],

    experiments: {
      typedRoutes: true,
      reactCompiler: true
    }
  };
};
```

---

## Why?

This allows:

### Development App

```text
com.skwebs.financesmspoc.dev
```

### Release App

```text
com.skwebs.financesmspoc
```

Both apps can stay installed together.

No uninstall required.

---

# 4. Keystore (Release Signing)

## Why Needed?

Without signing:

- Play Protect warns more
- Updates fail
- Android trust is lower
- Production testing is inaccurate

---

## Generate Keystore (One Time)

Run:

```powershell
keytool -genkeypair -v `
-keystore finance-release.keystore `
-alias financekey `
-keyalg RSA `
-keysize 2048 `
-validity 10000
```

Example details:

```text
Name: Satish Kumar Sharma
Organization: SK Webs
City: Mithapur
State: Bihar
Country: IN
```

---

# 5. Best Place to Store Keystore

Do NOT keep inside project.

Use:

```text
D:\Satish\Secure\AndroidKeys\FinanceSMS\
```

Store:

```text
finance-release.keystore
keystore-info.txt
```

---

## Example `keystore-info.txt`

```text
File Name:
finance-release.keystore

Alias:
financekey

Created:
17-05-2026

Package:
com.skwebs.financesmspoc
```

---

# 6. Backup Strategy

Keep 3 copies.

## Copy 1 — Main

```text
D:\Satish\Secure\AndroidKeys\
```

---

## Copy 2 — Cloud Backup

Encrypted ZIP on:

- Google Drive
- OneDrive

Use password protection.

---

## Copy 3 — Offline Backup

USB / SSD backup.

---

# 7. Android Keystore Properties

Create:

```text
android/keystore.properties
```

Add:

```properties
storeFile=D:\\Satish\\Secure\\AndroidKeys\\FinanceSMS\\finance-release.keystore
storePassword=your_password
keyAlias=financekey
keyPassword=your_password
```

---

# 8. Git Ignore

Add:

## `.gitignore`

```gitignore
*.keystore
*.jks
android/keystore.properties
```

Never upload keys to GitHub.

---

# 9. Development Build Script

Create:

## `scripts/dev-build.ps1`

```powershell
Write-Host "Starting Development Build..." `
-ForegroundColor Green

$env:BUILD_TYPE = "dev"

npx expo prebuild

cd android

.\gradlew assembleDebug

adb install -r `
.\app\build\outputs\apk\debug\app-debug.apk

Write-Host `
"Dev Build Installed Successfully" `
-ForegroundColor Cyan

explorer `
.\app\build\outputs\apk\debug
```

---

## Run Dev Build

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

Create:

## `scripts/release-build.ps1`

```powershell
Write-Host `
"Starting Release Build..." `
-ForegroundColor Yellow

$env:BUILD_TYPE = "release"

npx expo prebuild

cd android

.\gradlew clean

.\gradlew assembleRelease

adb install -r `
.\app\build\outputs\apk\release\
app-release.apk

Write-Host `
"Release Build Installed Successfully" `
-ForegroundColor Green

keytool -printcert `
-jarfile `
.\app\build\outputs\apk\release\
app-release.apk

explorer `
.\app\build\outputs\apk\release
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

Add:

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
adb uninstall com.skwebs.financesmspoc
```

---

# 13. SMS Permission Issue

### Problem

Allow button disabled.

Reason:

Android treats:

```text
READ_SMS
RECEIVE_SMS
```

as restricted permissions.

Especially for:

- finance apps
- OTP apps
- bank SMS readers

---

## Fixes

### Install via ADB

Better than file manager.

```bash
adb install -r app-release.apk
```

---

### Use Proper Signing

Always use signed release APK.

---

### Remove RECEIVE_SMS Temporarily

For testing:

```json
"permissions": [
  "READ_SMS"
]
```

Many finance apps only read inbox.

No instant SMS required.

---

# 14. Play Protect Warning

If Play Protect says:

```text
Blocked by Play Protect
```

Reason:

Your app:

- Reads SMS
- Is financial
- Is sideloaded

Google flags it.

---

## Reduce Risk

### Use signed APK

### Install using:

```bash
adb install -r app-release.apk
```

### Keep only:

```text
READ_SMS
```

until needed.

---

# 15. Daily Workflow

## During Coding

Run:

```bash
npm run build:dev
```

This gives:

- debug build
- fast install
- easy testing

---

## Before Real Testing

Run:

```bash
npm run build:release
```

This tests:

- SMS permission
- Play Protect
- production behavior

---

# 16. Important Notes

### Never lose keystore

Without it:

You cannot update app.

Users must uninstall.

---

### Never upload keystore to GitHub

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