#!/bin/bash
#
# Build script for μCapture
# Creates a .app bundle from the Swift Package
#

set -e

APP_NAME="MuCapture"
DISPLAY_NAME="μCapture"
BUILD_DIR=".build/release"
APP_BUNDLE="$DISPLAY_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building $DISPLAY_NAME..."

# Release Build
swift build -c release

echo "Creating app bundle..."

# Create App Bundle structure
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$RESOURCES_DIR/Fonts"

# Copy Executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

# Copy Info.plist
cp "Sources/$APP_NAME/Info.plist" "$CONTENTS_DIR/"

# Copy App Icon
if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "$RESOURCES_DIR/"
    echo "App icon added"
fi

# Copy bundled fonts
if [ -d "Resources/Fonts" ]; then
    cp Resources/Fonts/*.ttf "$RESOURCES_DIR/Fonts/" 2>/dev/null || true
    echo "Fonts bundled"
fi

# Create PkgInfo
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Set executable permissions
chmod +x "$MACOS_DIR/$APP_NAME"

# Code Signing (Ad-hoc) - prevents "app is damaged" on other Macs
echo "Signing app bundle..."
codesign --force --deep --sign - "$APP_BUNDLE"

# Remove quarantine attribute (for local builds)
xattr -cr "$APP_BUNDLE" 2>/dev/null || true

echo "App bundle created and signed: $APP_BUNDLE"
echo ""
echo "To install the app:"
echo "   cp -r '$APP_BUNDLE' /Applications/"
echo ""
echo "Or launch directly:"
echo "   open '$APP_BUNDLE'"
echo ""
echo "If 'damaged' appears on another Mac:"
echo "   xattr -cr /path/to/$APP_BUNDLE"
echo "   or: Right-click -> Open (on first launch)"
