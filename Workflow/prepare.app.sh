#!/bin/bash

set -ex

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

xcodebuild -workspace "$WORKING_LOCATION/App.xcworkspace" \
    -scheme "$APPLICATION_NAME" \
    -configuration Release \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    clean build \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    GCC_GENERATE_DEBUGGING_SYMBOLS=YES STRIP_INSTALLED_PRODUCT=NO \
    COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO |
    xcpretty

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

# now read from the Info.plist for CFBundleShortVersionString
CONTROL_VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$TARGET_APP/Info.plist")"

# ==============================================================================

# build agent

"$WORKING_LOCATION/AuxiliaryAgent/build.sh"
cp "$WORKING_LOCATION/AuxiliaryAgent/build/AuxiliaryAgent" "$WORKING_LOCATION/build/AuxiliaryAgent"

# now put the agent into our app
cp "$WORKING_LOCATION/build/AuxiliaryAgent" "$TARGET_APP/AuxiliaryAgent"

# put the fouls into our .app
cd "$TARGET_APP"
unzip "$WORKING_LOCATION/Workflow/fouldecrypt.zip"

# ==============================================================================

# make dpkg layer
cd "$WORKING_LOCATION/build/dpkg"
mkdir ./Applications
cp -r "$TARGET_APP" ./Applications/
cp -r "$WORKING_LOCATION/Workflow/DEBIAN" ./
sed -i '' "s/@@VERSION@@/$CONTROL_VERSION-REL-$TIMESTAMP/g" ./DEBIAN/control

# fix permission
chmod -R 0755 DEBIAN

PKG_NAME="wiki.qaq.iridium.rel.ci.$TIMESTAMP.deb"
dpkg-deb -b . "../$PKG_NAME"

# print done
echo "Package is at $WORKING_LOCATION/build/$PKG_NAME"