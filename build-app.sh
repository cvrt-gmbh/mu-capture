#!/bin/bash
#
# Build-Script für MikroskopCapture
# Erstellt eine .app Bundle aus dem Swift Package
#

set -e

APP_NAME="MikroskopCapture"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Building $APP_NAME..."

# Release Build
swift build -c release

echo "📦 Creating app bundle..."

# Erstelle App Bundle Struktur
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Kopiere Executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Kopiere Info.plist
cp "Sources/$APP_NAME/Info.plist" "$CONTENTS_DIR/"

# Kopiere App Icon
if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "$RESOURCES_DIR/"
    echo "🎨 App icon added"
fi

# Erstelle PkgInfo
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Setze Executable-Rechte
chmod +x "$MACOS_DIR/$APP_NAME"

echo "✅ App bundle created: $APP_BUNDLE"
echo ""
echo "📍 Um die App zu installieren:"
echo "   cp -r $APP_BUNDLE /Applications/"
echo ""
echo "🚀 Oder direkt starten:"
echo "   open $APP_BUNDLE"
