#!/bin/bash

##########################################################################################
# MaxRegnerOS WebOS v1.1 - Build Script
# Creates flashable Magisk module zip
##########################################################################################

MODULE_NAME="MaxRegnerOS_WebOS_v1.1"
VERSION="1.1"
BUILD_DATE=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="build"
OUTPUT_FILE="${MODULE_NAME}_${BUILD_DATE}.zip"

echo "Building MaxRegnerOS WebOS v${VERSION}..."
echo "Build Date: ${BUILD_DATE}"

# Create build directory
mkdir -p "$OUTPUT_DIR"

# Set executable permissions
chmod +x install.sh
chmod +x uninstall.sh
chmod +x post-fs-data.sh
chmod +x service.sh
chmod +x system/bin/webos_engine
chmod +x system/bin/chromium_webview
chmod +x system/bin/maxregner_launcher
chmod +x META-INF/com/google/android/update-binary

# Create zip file
echo "Creating zip file: ${OUTPUT_FILE}"
zip -r9 "$OUTPUT_DIR/$OUTPUT_FILE" \
    module.prop \
    install.sh \
    uninstall.sh \
    post-fs-data.sh \
    service.sh \
    system/ \
    META-INF/ \
    -x "*.git*" "build.sh" "README.md" "*.log"

# Calculate file size
FILE_SIZE=$(du -h "$OUTPUT_DIR/$OUTPUT_FILE" | cut -f1)

echo ""
echo "✓ Build completed successfully!"
echo "✓ Output: $OUTPUT_DIR/$OUTPUT_FILE"
echo "✓ Size: $FILE_SIZE"
echo ""
echo "Installation Instructions:"
echo "1. Copy $OUTPUT_FILE to your device"
echo "2. Boot into TWRP recovery"
echo "3. Flash the zip file"
echo "4. Reboot system"
echo ""
echo "Or install via Magisk Manager:"
echo "1. Open Magisk Manager"
echo "2. Go to Modules > Install from storage"
echo "3. Select $OUTPUT_FILE"
echo "4. Reboot when prompted"

# Verify zip integrity
echo ""
echo "Verifying zip integrity..."
if unzip -t "$OUTPUT_DIR/$OUTPUT_FILE" >/dev/null 2>&1; then
    echo "✓ Zip file integrity verified"
else
    echo "✗ Zip file integrity check failed"
    exit 1
fi

echo ""
echo "MaxRegnerOS WebOS v${VERSION} build completed!"
echo "Ready for installation on Samsung Galaxy Z Flip5 (b5q)"

