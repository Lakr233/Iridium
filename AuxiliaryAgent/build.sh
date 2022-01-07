#!/bin/bash

set -ex

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

xcodebuild \
    -workspace "../../App.xcworkspace" \
    -scheme "$PROJECT_NAME" \
    -configuration $CONFIGURATION \
    -archivePath ./build.xcarchive \
    -sdk iphoneos \
    -derivedDataPath ./ \
    ENABLE_BITCODE=NO CODE_SIGNING_ALLOWED=NO \
    clean archive | xcpretty

# look for binary in archive dir and copy to build dir
cp -f "./build.xcarchive/Products/Applications/$PROJECT_NAME.app/$PROJECT_NAME" "$PROJECT_NAME"

# remove the codesign of binary
codesign --remove "$PROJECT_NAME"

# sign binary with ldid
ldid -S../sign.plist "$PROJECT_NAME"

echo "Complied at $(pwd)/$PROJECT_NAME"
