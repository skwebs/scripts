# Expo Android Build System Guide
### Expo SDK 55+ (or Latest) + React Native + Expo Router

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
- `app.config.js` wrapper
- Keystore template
- Dev/Release app separation
- Expo SDK 55+ compatible setup

---

# 1. One-Time Setup

Run:

```powershell
irm https://raw.githubusercontent.com/skwebs/scripts/main/setup-build-system.ps1 | iex
```

This automatically creates everything needed.

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

## `app.config.js` Wrapper

If `app.json` exists, setup creates:

```text
app.config.js
```

This is a **wrapper around `app.json`**.

### Important

This does **NOT** replace:

```text
app.json
```

Both files exist together.

Recommended structure:

```text
app.json
app.config.js
```

### Why?

This is the ideal Expo setup.

- `app.json` → static config
- `app.config.js` → dynamic overrides

Safer for:

- Expo SDK upgrades
- Expo Router
- plugins
- permissions
- splash screen
- icons
- prebuild workflow

---

# 3. How `app.json` + `app.config.js` Work Together

### `app.json`

Stores static configuration:

```json
{
  "expo": {
    "name": "Finance SMS POC",
    "slug": "finance-sms-poc",

    "android": {
      "package": "com.skwebs.financesmspoc"
    }
  }
}
```

---

### `app.config.js`

Only changes dynamic values.

Automatically switches:

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