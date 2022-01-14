#!/bin/bash

set -e

# cd script dir
cd "$(dirname "$0")" || exit

# delete build dir if exists
if [ -d "build" ]; then
    rm -rf build
fi

# create build dir
mkdir build

# go into build dir 
cd build || exit

CONFIGURATION=Release

# if DEBUG found in second parameter, set CONFIGURATION to Debug
if [ "$1" == "DEBUG" ]; then
    CONFIGURATION=Debug
fi

PROJECT_NAME="AuxiliaryAgent"

TEMP_LOG_FILE="$(mktemp)"
echo "[i] build log will be written to $TEMP_LOG_FILE"

xcodebuild \
    -workspace "../../App.xcworkspace" \
    -scheme "$PROJECT_NAME" \
    -configuration $CONFIGURATION \
    -archivePath ./build.xcarchive \
    -destination "generic/platform=iOS" \
    -derivedDataPath ./ \
    clean archive \
    ARCHS="arm64 arm64e" ONLY_ACTIVE_ARCH="NO" \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \
    GCC_GENERATE_DEBUGGING_SYMBOLS=YES STRIP_INSTALLED_PRODUCT=NO \
    ENABLE_BITCODE=NO \
    COPY_PHASE_STRIP=NO UNSTRIPPED_PRODUCT=NO \
    &> "$TEMP_LOG_FILE"

echo "[i] build passed, removing temp log file..."
rm -f "$TEMP_LOG_FILE"

# look for binary in archive dir and copy to build dir
cp -f "./build.xcarchive/Products/Applications/$PROJECT_NAME.app/$PROJECT_NAME" "$PROJECT_NAME"

# remove the codesign of binary
codesign --remove "$PROJECT_NAME"

# sign binary with ldid
ldid -S../sign.plist "$PROJECT_NAME"

echo "Complied at $(pwd)/$PROJECT_NAME"
