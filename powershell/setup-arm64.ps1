Write-Host "Starting Expo ARM64 setup..." -ForegroundColor Green

# ==========================================================
# 1. Create plugins folder
# ==========================================================
$pluginDir = "plugins"

if (!(Test-Path $pluginDir)) {
    New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
    Write-Host "Created plugins folder" -ForegroundColor Green
}

# ==========================================================
# 2. Create plugins/withArm64Only.js
# ==========================================================
$pluginContent = @'
const { withAppBuildGradle } = require("expo/config-plugins");

module.exports = function withArm64Only(config) {
  return withAppBuildGradle(config, (config) => {
    let gradle = config.modResults.contents;

    const splitConfig = `
    splits {
        abi {
            enable = true
            reset()
            include("arm64-v8a")
            universalApk = false
        }
    }
`;

    // Add splits inside android {}
    if (!gradle.includes("splits {")) {
      gradle = gradle.replace(/android\s*\{/, `android {${splitConfig}`);
    }

    config.modResults.contents = gradle;

    return config;
  });
};
'@

$pluginPath = "plugins\withArm64Only.js"

Set-Content `
    -Path $pluginPath `
    -Value $pluginContent `
    -Encoding UTF8

Write-Host "Created plugins/withArm64Only.js" -ForegroundColor Cyan

# ==========================================================
# 3. Install expo-build-properties
# ==========================================================
Write-Host "Installing expo-build-properties..." -ForegroundColor Yellow

npx expo install expo-build-properties

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install expo-build-properties" -ForegroundColor Red
    exit 1
}

# ==========================================================
# 4. Update package.json
# ==========================================================
$packagePath = "package.json"

if (!(Test-Path $packagePath)) {
    Write-Host "package.json not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Updating package.json..." -ForegroundColor Yellow

$package = Get-Content $packagePath -Raw | ConvertFrom-Json

# Ensure scripts exists
if ($null -eq $package.scripts) {
    $package | Add-Member `
        -MemberType NoteProperty `
        -Name scripts `
        -Value ([PSCustomObject]@{})
}

# Add/Update build:arm64
$buildCommand = "cd android && gradlew.bat clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true"

if ($package.scripts.PSObject.Properties["build:arm64"]) {
    $package.scripts."build:arm64" = $buildCommand
} else {
    $package.scripts | Add-Member `
        -MemberType NoteProperty `
        -Name "build:arm64" `
        -Value $buildCommand
}

$package | ConvertTo-Json -Depth 100 | Set-Content $packagePath -Encoding UTF8

Write-Host "Updated package.json" -ForegroundColor Green

# ==========================================================
# 5. Update app.json
# ==========================================================
$appJsonPath = "app.json"

if (!(Test-Path $appJsonPath)) {
    Write-Host "app.json not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Updating app.json..." -ForegroundColor Yellow

$appJson = Get-Content $appJsonPath -Raw | ConvertFrom-Json

# Ensure expo exists
if ($null -eq $appJson.expo) {
    Write-Host "Invalid app.json: expo key missing" -ForegroundColor Red
    exit 1
}

# Ensure plugins array exists
if ($null -eq $appJson.expo.plugins) {
    $appJson.expo | Add-Member `
        -MemberType NoteProperty `
        -Name plugins `
        -Value @()
}

# Convert plugins to array for safe modification
$plugins = @($appJson.expo.plugins)

# ----------------------------------------------------------
# Add "./plugins/withArm64Only"
# ----------------------------------------------------------
if ($plugins -notcontains "./plugins/withArm64Only") {
    $plugins += "./plugins/withArm64Only"
    Write-Host "Added withArm64Only plugin" -ForegroundColor Green
}

# ----------------------------------------------------------
# Add expo-build-properties plugin
# ----------------------------------------------------------
$hasExpoBuildProperties = $false

foreach ($plugin in $plugins) {
    if ($plugin -is [System.Array]) {
        if ($plugin.Count -gt 0 -and $plugin[0] -eq "expo-build-properties") {
            $hasExpoBuildProperties = $true
            break
        }
    }
}

if (-not $hasExpoBuildProperties) {
    $expoBuildPlugin = @(
        "expo-build-properties",
        @{
            android = @{
                abiFilters = @(
                    "arm64-v8a"
                )
            }
        }
    )

    $plugins += ,$expoBuildPlugin

    Write-Host "Added expo-build-properties plugin" -ForegroundColor Green
}

$appJson.expo.plugins = $plugins

$appJson `
| ConvertTo-Json -Depth 100 `
| Set-Content $appJsonPath -Encoding UTF8

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "Expo ARM64 setup completed!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Run build command:" -ForegroundColor Cyan
Write-Host "npm run build:arm64" -ForegroundColor White