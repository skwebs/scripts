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

keytool -printcert `
-jarfile `
.\app\build\outputs\apk\release\app-release.apk

explorer `
.\app\build\outputs\apk\release

Pop-Location
