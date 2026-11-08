#!/bin/bash
set -e

echo "🔨 Building CleanMac..."
swift build -c release

echo "📦 Packaging CleanMac.app..."
mkdir -p CleanMac.app/Contents/MacOS CleanMac.app/Contents/Resources
cp .build/release/CleanMac CleanMac.app/Contents/MacOS/

# Copy AppIcon if available
if [ -f Resources/AppIcon.icns ]; then
    cp Resources/AppIcon.icns CleanMac.app/Contents/Resources/
fi
if [ -f Resources/Credits.rtf ]; then
    cp Resources/Credits.rtf CleanMac.app/Contents/Resources/
fi

cat << 'EOF' > CleanMac.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>CleanMac</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.cleanmac.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>CleanMac</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSDesktopFolderUsageDescription</key>
    <string>CleanMac memerlukan izin untuk menganalisis file besar di folder Desktop.</string>
    <key>NSDocumentsFolderUsageDescription</key>
    <string>CleanMac memerlukan izin untuk menganalisis file besar di folder Dokumen.</string>
    <key>NSDownloadsFolderUsageDescription</key>
    <string>CleanMac memerlukan izin untuk menganalisis file dan installer di folder Unduhan.</string>
</dict>
</plist>
EOF

echo "🚀 Launching CleanMac.app..."
open CleanMac.app
echo "✅ CleanMac is now running!"
