Write-Host "Starting Expo Build System Setup..." `
    -ForegroundColor Green

# ==========================================================
# 1. Create scripts folder
# ==========================================================
$scriptDir = "scripts"

if (!(Test-Path $scriptDir)) {

    New-Item `
        -ItemType Directory `
        -Path $scriptDir `
        -Force | Out-Null

    Write-Host `
        "Created scripts folder" `
        -ForegroundColor Green
}

# ==========================================================
# 2. Create dev-build.ps1
# ==========================================================
$devScript = @'
Write-Host `
"Starting Development Build..." `
-ForegroundColor Green

$env:BUILD_TYPE = "dev"

# Auto prebuild if android folder missing
if (!(Test-Path "android")) {

    Write-Host `
    "Android folder missing. Running Expo prebuild..." `
    -ForegroundColor Yellow

    npx expo prebuild --clean

    if ($LASTEXITCODE -ne 0) {

        Write-Host `
        "Expo prebuild failed" `
        -ForegroundColor Red

        exit 1
    }
}

Push-Location android

.\gradlew assembleDebug

if ($LASTEXITCODE -ne 0) {

    Write-Host `
    "Debug build failed" `
    -ForegroundColor Red

    Pop-Location
    exit 1
}

adb install -r `
.\app\build\outputs\apk\debug\app-debug.apk

Write-Host `
"Dev Build Installed Successfully" `
-ForegroundColor Cyan

explorer `
.\app\build\outputs\apk\debug

Pop-Location
'@

Set-Content `
    -Path "scripts\dev-build.ps1" `
    -Value $devScript `
    -Encoding UTF8

Write-Host `
    "Created dev-build.ps1" `
    -ForegroundColor Cyan

# ==========================================================
# 3. Create release-build.ps1
# ==========================================================
$releaseScript = @'
Write-Host `
"Starting Release Build..." `
-ForegroundColor Yellow

$env:BUILD_TYPE = "release"

# Auto prebuild if android folder missing
if (!(Test-Path "android")) {

    Write-Host `
    "Android folder missing. Running Expo prebuild..." `
    -ForegroundColor Yellow

    npx expo prebuild --clean

    if ($LASTEXITCODE -ne 0) {

        Write-Host `
        "Expo prebuild failed" `
        -ForegroundColor Red

        exit 1
    }
}

Push-Location android

.\gradlew clean
.\gradlew assembleRelease

if ($LASTEXITCODE -ne 0) {

    Write-Host `
    "Release build failed" `
    -ForegroundColor Red

    Pop-Location
    exit 1
}

adb install -r `
.\app\build\outputs\apk\release\app-release.apk

Write-Host `
"Release Build Installed Successfully" `
-ForegroundColor Green

explorer `
.\app\build\outputs\apk\release

Pop-Location
'@

Set-Content `
    -Path "scripts\release-build.ps1" `
    -Value $releaseScript `
    -Encoding UTF8

Write-Host `
    "Created release-build.ps1" `
    -ForegroundColor Cyan

# ==========================================================
# 4. Update package.json safely
# ==========================================================
$packagePath = "package.json"

if (!(Test-Path $packagePath)) {

    Write-Host `
        "package.json not found!" `
        -ForegroundColor Red

    exit 1
}

Write-Host `
    "Updating package.json..." `
    -ForegroundColor Yellow

$package =
Get-Content `
    $packagePath -Raw |
ConvertFrom-Json

# Ensure scripts exists
if ($null -eq $package.scripts) {

    $package |
    Add-Member `
        -MemberType NoteProperty `
        -Name scripts `
        -Value ([PSCustomObject]@{})
}

# -----------------------------
# build:dev
# -----------------------------
$devCommand =
"powershell -ExecutionPolicy Bypass -File ./scripts/dev-build.ps1"

if (
    $null -eq
    $package.scripts.PSObject.Properties[
    "build:dev"
    ]
) {

    $package.scripts |
    Add-Member `
        -MemberType NoteProperty `
        -Name "build:dev" `
        -Value $devCommand

    Write-Host `
        "Added build:dev script" `
        -ForegroundColor Green
}
else {

    $package.scripts."build:dev" =
    $devCommand

    Write-Host `
        "Updated build:dev script" `
        -ForegroundColor Cyan
}

# -----------------------------
# build:release
# -----------------------------
$releaseCommand =
"powershell -ExecutionPolicy Bypass -File ./scripts/release-build.ps1"

if (
    $null -eq
    $package.scripts.PSObject.Properties[
    "build:release"
    ]
) {

    $package.scripts |
    Add-Member `
        -MemberType NoteProperty `
        -Name "build:release" `
        -Value $releaseCommand

    Write-Host `
        "Added build:release script" `
        -ForegroundColor Green
}
else {

    $package.scripts."build:release" =
    $releaseCommand

    Write-Host `
        "Updated build:release script" `
        -ForegroundColor Cyan
}

$package |
ConvertTo-Json -Depth 100 |
Set-Content `
    $packagePath `
    -Encoding UTF8

Write-Host `
    "Updated package.json successfully" `
    -ForegroundColor Green

# ==========================================================
# 5. Create app.config.js wrapper
# ==========================================================
$appJsonPath = "app.json"
$appConfigPath = "app.config.js"

if (!(Test-Path $appJsonPath)) {

    Write-Host `
        "app.json not found!" `
        -ForegroundColor Red

    exit 1
}

if (!(Test-Path $appConfigPath)) {

    $appConfig = @'
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
'@

    Set-Content `
        -Path $appConfigPath `
        -Value $appConfig `
        -Encoding UTF8

    Write-Host `
        "Created app.config.js wrapper" `
        -ForegroundColor Green
}

# ==========================================================
# 6. Auto prebuild
# ==========================================================
if (!(Test-Path "android")) {

    Write-Host `
        "Android folder missing. Running Expo prebuild..." `
        -ForegroundColor Yellow

    npx expo prebuild --clean

    if ($LASTEXITCODE -ne 0) {

        Write-Host `
            "Expo prebuild failed" `
            -ForegroundColor Red

        exit 1
    }
}

# ==========================================================
# 7. Create keystore.properties.example
# ==========================================================
$keystorePath =
"android\keystore.properties.example"

$keystoreContent = @'
storeFile=D:\\Satish\\Secure\\AndroidKeys\\FinanceSMS\\finance-release.keystore
storePassword=your_password
keyAlias=financekey
keyPassword=your_password
'@

Set-Content `
    -Path $keystorePath `
    -Value $keystoreContent `
    -Encoding UTF8

Write-Host `
    "Created keystore.properties.example" `
    -ForegroundColor Cyan

# ==========================================================
# 8. Update .gitignore
# ==========================================================
$gitignore = ".gitignore"

$entries = @(
    "*.keystore",
    "*.jks",
    "android/keystore.properties"
)

if (!(Test-Path $gitignore)) {

    New-Item `
        -ItemType File `
        -Path $gitignore `
        -Force | Out-Null
}

$content =
Get-Content `
    $gitignore `
    -ErrorAction SilentlyContinue

foreach ($entry in $entries) {

    if ($content -notcontains $entry) {

        Add-Content `
            -Path $gitignore `
            -Value $entry
    }
}

Write-Host `
    "Updated .gitignore" `
    -ForegroundColor Green

# ==========================================================
# 9. Final Message
# ==========================================================
Write-Host ""
Write-Host `
    "=====================================" `
    -ForegroundColor Green

Write-Host `
    "Expo Build System Setup Complete!" `
    -ForegroundColor Green

Write-Host `
    "=====================================" `
    -ForegroundColor Green

Write-Host ""
Write-Host `
    "Available Commands:" `
    -ForegroundColor Cyan

Write-Host `
    "npm run build:dev" `
    -ForegroundColor White

Write-Host `
    "npm run build:release" `
    -ForegroundColor White