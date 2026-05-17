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