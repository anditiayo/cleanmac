#!/bin/bash
set -e

APP_NAME="CleanMac"
DMG_NAME="CleanMac-Installer.dmg"
RELEASE_DIR=".build/release"
STAGING_DIR="/tmp/cleanmac_dmg_staging"

echo "🔨 Building $APP_NAME in release mode..."
swift build -c release

echo "📦 Preparing staging directory..."
rm -rf "$STAGING_DIR" "$DMG_NAME"
mkdir -p "$STAGING_DIR"

echo "📂 Packaging $APP_NAME.app..."
mkdir -p "$STAGING_DIR/$APP_NAME.app/Contents/MacOS"
mkdir -p "$STAGING_DIR/$APP_NAME.app/Contents/Resources"
cp "$RELEASE_DIR/$APP_NAME" "$STAGING_DIR/$APP_NAME.app/Contents/MacOS/"
cp "Resources/AppIcon.icns" "$STAGING_DIR/$APP_NAME.app/Contents/Resources/" 2>/dev/null || true
cp "Resources/AppIcon.png" "$STAGING_DIR/$APP_NAME.app/Contents/Resources/" 2>/dev/null || true
cp "Resources/Credits.rtf" "$STAGING_DIR/$APP_NAME.app/Contents/Resources/" 2>/dev/null || true
cp "CleanMac.app/Contents/Info.plist" "$STAGING_DIR/$APP_NAME.app/Contents/"

# Create symlink to /Applications for standard drag-and-drop installer
ln -s /Applications "$STAGING_DIR/Applications"

echo "💿 Creating DMG disk image..."
hdiutil create -volname "$APP_NAME Installer" \
               -srcfolder "$STAGING_DIR" \
               -ov \
               -format UDZO \
               "$DMG_NAME"

rm -rf "$STAGING_DIR"
echo "✅ DMG successfully created: $DMG_NAME"
ls -lh "$DMG_NAME"

