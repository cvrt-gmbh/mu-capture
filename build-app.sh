#!/bin/bash
#
# Build script for μCapture
# Creates a signed and notarized .app bundle from the Swift Package
#

set -e

APP_NAME="MuCapture"
DISPLAY_NAME="μCapture"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"  # Use ASCII name for Spotlight compatibility
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Code Signing Identity
SIGNING_IDENTITY="Developer ID Application: CAVORT Konzepte GmbH (H8A24BURPN)"
KEYCHAIN_PROFILE="AC_PASSWORD"

# Parse arguments
NOTARIZE=false
for arg in "$@"; do
    case $arg in
        --notarize)
            NOTARIZE=true
            shift
            ;;
    esac
done

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

# Code Signing with Developer ID
echo "Signing app bundle with Developer ID..."
codesign --force --options runtime --sign "$SIGNING_IDENTITY" --timestamp "$APP_BUNDLE"

# Verify signature
echo "Verifying signature..."
codesign --verify --verbose "$APP_BUNDLE"

echo ""
echo "App bundle created and signed: $APP_BUNDLE"

# Notarization (if requested)
if [ "$NOTARIZE" = true ]; then
    echo ""
    echo "Notarizing app..."
    
    # Create zip for notarization
    ZIP_FILE="${APP_NAME}.zip"
    ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_FILE"
    
    # Submit for notarization
    echo "Submitting to Apple notary service..."
    xcrun notarytool submit "$ZIP_FILE" --keychain-profile "$KEYCHAIN_PROFILE" --wait
    
    # Staple the ticket
    echo "Stapling notarization ticket..."
    xcrun stapler staple "$APP_BUNDLE"
    
    # Verify stapling
    xcrun stapler validate "$APP_BUNDLE"
    
    # Clean up zip
    rm "$ZIP_FILE"
    
    echo ""
    echo "Notarization complete! App is ready for distribution."
fi

echo ""
echo "To install the app:"
echo "   cp -r '$APP_BUNDLE' /Applications/"
echo ""
echo "Or launch directly:"
echo "   open '$APP_BUNDLE'"
echo ""
if [ "$NOTARIZE" = false ]; then
    echo "To notarize for distribution:"
    echo "   ./build-app.sh --notarize"
    echo ""
fi
