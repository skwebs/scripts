[← Back to README](../README.md)

# Expo Android Build Guide
### Expo SDK 55+ (or Latest)

This guide provides a quick overview of Android build setup for Expo projects.

For detailed setup, see:

- [Build System Guide](BUILD_SYSTEM_GUIDE.md)
- [ARM64 Setup Guide](ARM64_SETUP_GUIDE.md)

---

# Available Setup Scripts

## 1. Build System Setup

Automates:

- Development build
- Release build
- APK auto-install
- ADB integration
- `app.json + app.config.js` setup
- Keystore template
- Dev/Release app separation

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-build-system.ps1 | iex
```

Documentation:

```text
docs/BUILD_SYSTEM_GUIDE.md
```

---

## 2. ARM64 APK Setup

Optimizes Android APK builds for:

```text
arm64-v8a
```

Benefits:

- Smaller APK size
- Better performance
- Modern Android compatibility

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-arm64.ps1 | iex
```

Documentation:

```text
docs/ARM64_SETUP_GUIDE.md
```

---

# Recommended Workflow

## Step 1 — Setup Build System

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-build-system.ps1 | iex
```

---

## Step 2 — Clean Native (One Time)

Run once:

```bash
npx expo prebuild --clean
```

---

## Step 3 — Optional ARM64 Optimization

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/powershell/setup-arm64.ps1 | iex
```

---

## Step 4 — Development Build

Run:

```bash
npm run build:dev
```

---

## Step 5 — Release Build

Run:

```bash
npm run build:release
```

---

# Recommended Documentation Order

1. `EXPO_ANDROID_BUILD_GUIDE.md` ← start here
2. `BUILD_SYSTEM_GUIDE.md`
3. `ARM64_SETUP_GUIDE.md`

---

## Related Documentation

- [Build System Guide](BUILD_SYSTEM_GUIDE.md)
- [ARM64 Setup Guide](ARM64_SETUP_GUIDE.md)
- [Documentation Index](INDEX.md)

---

[← Back to README](../README.md)Automatically switches:

### Development

```text
Finance SMS POC Dev
com.skwebs.financesmspoc.dev
```

---

### Release

```text
Finance SMS POC
com.skwebs.financesmspoc
```

Benefits:

- Both apps stay installed together
- No uninstall required
- No permission cache issue
- Safer production testing

---

# 4. Build Types

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

# 5. First-Time Setup (Important)

After setup script completes:

Run once:

```bash
npx expo prebuild --clean
```

Why?

Because package name switching requires native regeneration.

Only needed once.

---

# 6. Daily Workflow

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
4. Installs app via ADB
5. Verifies APK signature
6. Opens APK folder

APK location:

```text
android/app/build/outputs/apk/release
```

---

# 7. Generated Scripts

## `scripts/dev-build.ps1`

Used for:

```bash
npm run build:dev
```

Features:

- Expo prebuild
- Debug APK build
- Auto install APK
- APK folder auto-open
- Error handling
- Safe folder navigation

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
- Error handling
- Safe folder navigation

---

# 8. ADB Requirements

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

# 9. Release Signing (Important)

For proper release testing, create a signing key.

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

# 10. Configure Keystore

Setup creates:

```text
android/keystore.properties.example
```

Copy and rename:

```text
android/keystore.properties
```

Update values:

```properties
storeFile=D:\\Satish\\Secure\\AndroidKeys\\FinanceSMS\\finance-release.keystore
storePassword=your_password
keyAlias=financekey
keyPassword=your_password
```

---

# 11. Git Ignore Protection

Setup automatically adds:

```gitignore
*.keystore
*.jks
android/keystore.properties
```

This prevents secret upload to GitHub.

---

# 12. Backup Strategy

Keep 3 copies.

## Copy 1 — Main

PC storage:

```text
D:\Satish\Secure\AndroidKeys\
```

---

## Copy 2 — Cloud Backup

Encrypted backup:

- Google Drive
- OneDrive

---

## Copy 3 — Offline Backup

- USB Drive
- External SSD

Never lose keystore.

Without it:

- App updates fail
- Release updates impossible
- Users must reinstall app

---

# 13. SMS Permission Notes

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

# 14. Play Protect Warning

If app gets blocked:

Prefer installation using:

```bash
adb install -r app-release.apk
```

instead of file manager install.

Signed release APKs behave better.

---

# 15. Verify Dynamic Config

Check current config:

### Development

```bash
npx expo config
```

Should show:

```text
com.yourapp.dev
```

---

### Release

PowerShell:

```powershell
$env:BUILD_TYPE="release"
npx expo config
```

Should show production package.

---

# 16. Recommended Project Structure

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
├── app.json
├── app.config.js
│
├── package.json
│
└── .gitignore
```

---

# 17. Final Workflow

## First Time Setup

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/setup-build-system.ps1 | iex
```

Then run once:

```bash
npx expo prebuild --clean
```

---

## Daily Development

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
- Expo SDK 55+ safe
- `app.json + app.config.js` safe workflow