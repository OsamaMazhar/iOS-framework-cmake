#!/bin/bash

# Define variables
OUT_DIR="path/to/folder/nlopt_ios/framework"
LIB_NAME="nlopt"
FW_PATH="$OUT_DIR/$LIB_NAME.framework"
INFO_PLIST="$FW_PATH/Info.plist"
OUT_DYLIB="$FW_PATH/$LIB_NAME"
DYLIB_DEVICE="path/to/file/nlopt_ios/install_device/lib/libnlopt.dylib"
DYLIB_SIMULATOR="path/to/file/nlopt_ios/install_simulator/lib/libnlopt.dylib"
HEADERS_DIR="path/to/folder/nlopt_ios/install/include"
CODESIGN_IDENTITY="YOUR Codesign ID"

# Step 1: Create framework directory
mkdir -p "$FW_PATH"

# Step 2: Create Info.plist file
cat <<EOF > "$INFO_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$LIB_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>com.your_bundle_identifier.$LIB_NAME</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$LIB_NAME</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1.0.0</string>
</dict>
</plist>
EOF

# Step 3: Combine dylibs into one universal binary
if [[ -f "$DYLIB_DEVICE" && -f "$DYLIB_SIMULATOR" ]]; then
    lipo -create "$DYLIB_DEVICE" "$DYLIB_SIMULATOR" -output "$OUT_DYLIB"
else
    echo "Error: One or both of the dylib files do not exist."
    exit 1
fi

# Step 4: Adjust the install name
install_name_tool -id "@rpath/$LIB_NAME.framework/$LIB_NAME" "$OUT_DYLIB"

# Step 5: Copy headers into the framework
mkdir -p "$FW_PATH/Headers"
cp "$HEADERS_DIR"/nlopt*.h "$FW_PATH/Headers/"

# Step 6: Create module.modulemap for Swift support
mkdir -p "$FW_PATH/Modules"
cat <<EOF > "$FW_PATH/Modules/module.modulemap"
framework module $LIB_NAME {
    umbrella header "nlopt.h"

    export *
    module * { export * }
}
EOF

# Step 7: Code sign the framework
codesign --force --sign "$CODESIGN_IDENTITY" --timestamp=none "$FW_PATH"

echo "Framework creation complete at $FW_PATH"