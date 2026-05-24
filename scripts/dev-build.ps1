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
