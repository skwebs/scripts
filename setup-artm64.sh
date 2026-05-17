#!/usr/bin/env bash

set -e

echo "Starting Expo ARM64 setup..."

# ==========================================
# Create plugins folder
# ==========================================
mkdir -p plugins

# ==========================================
# Create plugin file
# ==========================================
cat > plugins/withArm64Only.js <<'EOF'
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

    if (!gradle.includes("splits {")) {
      gradle = gradle.replace(/android\s*\{/, `android {${splitConfig}`);
    }

    config.modResults.contents = gradle;

    return config;
  });
};
EOF

echo "Created plugins/withArm64Only.js"

# ==========================================
# Install dependency
# ==========================================
npx expo install expo-build-properties

# ==========================================
# Update package.json
# ==========================================
node -e "
const fs = require('fs');

const pkg = JSON.parse(
  fs.readFileSync('package.json', 'utf8')
);

pkg.scripts ??= {};

pkg.scripts['build:arm64'] =
'cd android && ./gradlew clean assembleRelease --warning-mode all -Pandroid.bundle.enableArchitectureSpecificApks=true';

fs.writeFileSync(
  'package.json',
  JSON.stringify(pkg, null, 2)
);
"

echo "Updated package.json"

# ==========================================
# Update app.json
# ==========================================
node -e "
const fs = require('fs');

const app = JSON.parse(
  fs.readFileSync('app.json', 'utf8')
);

app.expo ??= {};
app.expo.plugins ??= [];

if (
  !app.expo.plugins.includes(
    './plugins/withArm64Only'
  )
) {
  app.expo.plugins.push(
    './plugins/withArm64Only'
  );
}

const exists = app.expo.plugins.some(
  p =>
    Array.isArray(p) &&
    p[0] === 'expo-build-properties'
);

if (!exists) {
  app.expo.plugins.push([
    'expo-build-properties',
    {
      android: {
        abiFilters: ['arm64-v8a']
      }
    }
  ]);
}

fs.writeFileSync(
  'app.json',
  JSON.stringify(app, null, 2)
);
"

echo "Updated app.json"

echo ""
echo "Expo ARM64 setup completed!"
echo ""
echo "Run:"
echo "npx expo prebuild"
echo "npm run build:arm64"