#!/bin/bash

set -e

cd "$(dirname "$0")"
cd ..
WORKING_LOCATION="$(pwd)"
APPLICATION_NAME="iridium"

TIMESTAMP="$(date +%s)"

# ==============================================================================

rm -rf build || true
mkdir build

cd build

# ==============================================================================

echo "[*] starting build..."

xcodebuild -workspace "$WORKING_LOCATION/App.xcworkspace" \
    -scheme "$APPLICATION_NAME" \
    -configuration Release \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    clean build \
    ARCHS="arm64" ONLY_ACTIVE_ARCH="NO" \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    GCC_GENERATE_DEBUGGING_SYMBOLS=YES STRIP_INSTALLED_PRODUCT=NO \
    ENABLE_BITCODE=NO \
    COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    | xcpretty

echo "[i] build passed, removing temp log file..."
rm -f "$TEMP_LOG_FILE"

# copy .app out of DerivedData
DD_APP_PATH="$WORKING_LOCATION/build/DerivedDataApp/Build/Products/Release-iphoneos/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"

# clean the app
codesign --remove "$TARGET_APP"
if [ -e "$TARGET_APP/_CodeSignature" ]; then
    rm -rf "$TARGET_APP/_CodeSignature"
fi
if [ -e "$TARGET_APP/embedded.mobileprovision" ]; then
    rm -rf "$TARGET_APP/embedded.mobileprovision"
fi

# make our sign
ldid -S"$WORKING_LOCATION/Workflow/Entitlements.plist" "$TARGET_APP/$APPLICATION_NAME"

CONTROL_VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$TARGET_APP/Info.plist")"
BUILD_VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$TARGET_APP/Info.plist")"

# ==============================================================================

echo "[*] preparing package layout..."

IPA_LOCATION="$WORKING_LOCATION/build/$APPLICATION_NAME.tipa"

cd "$WORKING_LOCATION/build/"
mkdir ./Payload
cp -r "$TARGET_APP" ./Payload/
zip -r "$IPA_LOCATION" ./Payload

# ==============================================================================

echo "[*] Package available at $IPA_LOCATION"