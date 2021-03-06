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

rm -rf dpkg || true
mkdir dpkg

# ==============================================================================

echo "[*] starting build..."

TEMP_LOG_FILE="$(mktemp)"
echo "[i] build log will be written to $TEMP_LOG_FILE"

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
    &> "$TEMP_LOG_FILE"

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

# build agent

echo "[*] building agent..."

"$WORKING_LOCATION/AuxiliaryAgent/build.sh"
cp "$WORKING_LOCATION/AuxiliaryAgent/build/AuxiliaryAgent" "$WORKING_LOCATION/build/AuxiliaryAgent"

# now put the agent into our app
cp "$WORKING_LOCATION/build/AuxiliaryAgent" "$TARGET_APP/AuxiliaryAgent"

# put the fouls into our .app
cd "$TARGET_APP"
unzip "$WORKING_LOCATION/Workflow/fouldecrypt.zip"

# ==============================================================================

echo "[*] preparing package layout..."

# make dpkg layer
cd "$WORKING_LOCATION/build/dpkg"
mkdir ./Applications
cp -r "$TARGET_APP" ./Applications/
cp -r "$WORKING_LOCATION/Workflow/DEBIAN" ./
sed -i '' "s/@@VERSION@@/$CONTROL_VERSION.$BUILD_VERSION-REL-$TIMESTAMP/g" ./DEBIAN/control

# fix permission
cd "$WORKING_LOCATION/build/dpkg"
chmod -R 0755 DEBIAN

echo "[*] verifying binary architectures..."

cd "$WORKING_LOCATION/build/dpkg"
FILE_LIST=$(find . -type f)

# we have identified that arm64e binary not working on iOS 13
while read -r FILE; do
    FILE_INFO=$(file "$FILE")
    if [[ $FILE_INFO == *"Mach-O"* ]]; then
        if [[ $(lipo -info "$FILE") == *"arm64 arm64e"* ]]; then
            lipo -thin arm64 -output "$FILE" "$FILE"
        fi
        LIPO_INFO=$(lipo -info "$FILE")
        if [[ $LIPO_INFO == *"arm64e"* ]]; then
            echo "[!] $FILE containing arm64e architecture"
            exit 1
        fi
    fi
done <<< "$FILE_LIST"

echo "[*] packaging..."

cd "$WORKING_LOCATION/build/dpkg"
PKG_NAME="wiki.qaq.iridium.rel.ci.$TIMESTAMP.deb"
dpkg-deb -b . "../$PKG_NAME"

# print done
echo "Package is at $WORKING_LOCATION/build/$PKG_NAME"