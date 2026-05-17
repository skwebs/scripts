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