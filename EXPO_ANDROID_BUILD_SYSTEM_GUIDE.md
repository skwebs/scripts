# Expo Android Build System Guide
### Finance SMS POC (Expo SDK 53 + React Native)

This guide explains the complete Android build workflow using:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/setup-build-system.ps1 | iex
```

This setup automatically configures:

- Development build system
- Release build system
- APK auto-install
- APK output folder opening
- npm scripts
- `.gitignore`
- Keystore template
- Dev/Release app separation

---

# 1. One-Time Setup

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/setup-build-system.ps1 | iex
```

This will automatically create and configure everything.

---

# 2. What Setup Script Creates

## Scripts Folder

Creates:

```text
scripts/
├── dev-build.ps1
└── release-build.ps1
```

---

## Package.json Scripts

Automatically adds:

```json
{
  "scripts": {
    "build:dev": "powershell -ExecutionPolicy Bypass -File ./scripts/dev-build.ps1",
    "build:release": "powershell -ExecutionPolicy Bypass -File ./scripts/release-build.ps1"
  }
}
```

---

## App Config

Creates:

```text
app.config.js
```

for automatic package separation.

---

## Keystore Template

Creates:

```text
android/keystore.properties.example
```

---

## Git Ignore Entries

Automatically adds:

```gitignore
*.keystore
*.jks
android/keystore.properties
```

to prevent uploading secrets.

---

# 3. Build Types

This setup supports:

## Development Build

Purpose:

- Fast coding
- Debugging
- Logs
- Development testing

Build:

```text
assembleDebug
```

APK:

```text
app-debug.apk
```

---

## Release Build

Purpose:

- Production testing
- SMS permission testing
- Play Protect testing
- Real APK behavior

Build:

```text
assembleRelease
```

APK:

```text
app-release.apk
```

---

# 4. App Package Separation

The setup automatically creates:

## Development App

```text
com.skwebs.financesmspoc.dev
```

App name:

```text
Finance SMS POC Dev
```

---

## Release App

```text
com.skwebs.financesmspoc
```

App name:

```text
Finance SMS POC
```

Benefits:

- Both apps stay installed together
- No uninstall required
- No permission cache issue
- Safer testing

---

# 5. Daily Workflow

## Development Build

Run:

```bash
npm run build:dev
```

What happens automatically:

1. Runs Expo prebuild
2. Builds debug APK
3. Installs app via ADB
4. Opens APK folder

APK location:

```text
android/app/build/outputs/apk/debug
```

---

## Release Build

Run:

```bash
npm run build:release
```

What happens automatically:

1. Runs Expo prebuild
2. Cleans old build
3. Builds release APK
4. Installs via ADB
5. Verifies signature
6. Opens APK folder

APK location:

```text
android/app/build/outputs/apk/release
```

---

# 6. Generated Scripts

## `scripts/dev-build.ps1`

Used for:

```bash
npm run build:dev
```

Features:

- Expo prebuild
- Debug APK build
- APK auto-install
- APK folder auto-open

---

## `scripts/release-build.ps1`

Used for:

```bash
npm run build:release
```

Features:

- Expo prebuild
- Release APK build
- APK auto-install
- APK signature verification
- APK folder auto-open

---

# 7. ADB Requirements

Enable:

## USB Debugging

Phone:

```text
Settings
→ Developer Options
→ USB Debugging
→ ON
```

---

## Verify Device

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

# 8. Release Signing (Important)

For production testing, create a signing key.

## Generate Keystore

Run:

```powershell
keytool -genkeypair -v `
-keystore finance-release.keystore `
-alias financekey `
-keyalg RSA `
-keysize 2048 `
-validity 10000
```

---

## Recommended Storage Location

Do NOT keep inside project.

Recommended:

```text
D:\Satish\Secure\AndroidKeys\FinanceSMS\
```

Store:

```text
finance-release.keystore
keystore-info.txt
```

---

# 9. Configure Keystore

Copy:

```text
android/keystore.properties.example
```

Rename to:

```text
android/keystore.properties
```

Update:

```properties
storeFile=D:\\Satish\\Secure\\AndroidKeys\\FinanceSMS\\finance-release.keystore
storePassword=your_password
keyAlias=financekey
keyPassword=your_password
```

---

# 10. Backup Strategy

Keep 3 copies.

## Copy 1

PC storage:

```text
D:\Satish\Secure\AndroidKeys\
```

---

## Copy 2

Encrypted cloud backup:

- Google Drive
- OneDrive

---

## Copy 3

Offline backup:

- USB drive
- External SSD

Never lose keystore.

Without it:

- App updates fail
- Release updates impossible
- Must reinstall app

---

# 11. SMS Permission Notes

Finance apps using:

```text
READ_SMS
RECEIVE_SMS
```

may trigger:

- Play Protect warning
- Restricted permission behavior

For testing:

Prefer:

```text
READ_SMS
```

first.

---

# 12. Play Protect Warning

If blocked:

Use:

```bash
adb install -r app-release.apk
```

instead of file manager install.

Signed release APKs work better.

---

# 13. Project Structure

Recommended:

```text
FinanceSMSPOC/
│
├── android/
│
├── scripts/
│   ├── dev-build.ps1
│   └── release-build.ps1
│
├── docs/
│   └── EXPO_ANDROID_BUILD_SYSTEM_GUIDE.md
│
├── app.config.js
│
├── package.json
│
└── .gitignore
```

---

# 14. Final Workflow

### First Time Setup

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/setup-build-system.ps1 | iex
```

---

### Daily Development

```bash
npm run build:dev
```

---

### Production Testing

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