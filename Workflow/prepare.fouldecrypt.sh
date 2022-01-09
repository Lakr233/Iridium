#!/bin/bash

set -e

cd "$(dirname "$0")"

mkdir -p build
cd build

WORKING_LOCATION="$(pwd)"

FOUL_GIT_URL="https://github.com/NyaMisty/fouldecrypt"
FOUL_GIT_LOC="fouldecrypt"

if [ "$1" == "clean" ]; then
    rm -rf "$FOUL_GIT_LOC"
fi

if [ ! -d "$FOUL_GIT_LOC" ]; then
    git clone --recursive "$FOUL_GIT_URL" "$FOUL_GIT_LOC"
else
    cd "$FOUL_GIT_LOC"
    git reset --hard
    git clean -fdx
    git pull
    git submodule update --init --recursive
fi

cd "$WORKING_LOCATION"
rm -rf build || true
mkdir build

MAKE_THREAD=$(nproc)

# ==============================================================================

cd "$WORKING_LOCATION"
cp -r "$FOUL_GIT_LOC" ./build/fouldecrypt.tfp0 
cd ./build/fouldecrypt.tfp0
git reset --hard
git clean -fdx
sed -i.backup 's/# USE_TFP0 = 1/export USE_TFP0 = 1/g' Makefile
echo "export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc" >> Makefile
make -j "$MAKE_THREAD"
cp "./.theos/obj/debug/fouldecrypt" ../tfp0

cd "$WORKING_LOCATION"
cp -r "$FOUL_GIT_LOC" ./build/fouldecrypt.krw
cd ./build/fouldecrypt.krw
git reset --hard
git clean -fdx
sed -i.backup 's/# USE_LIBKRW = 1/export USE_LIBKRW = 1/g' Makefile
echo "export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc" >> Makefile
make -j "$MAKE_THREAD"
cp "./.theos/obj/debug/fouldecrypt" ../krw

cd "$WORKING_LOCATION"
cp -r "$FOUL_GIT_LOC" ./build/fouldecrypt.kernrw
cd ./build/fouldecrypt.kernrw
git reset --hard
git clean -fdx
sed -i.backup 's/# USE_LIBKERNRW = 1/export USE_LIBKERNRW = 1/g' Makefile
echo "export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc" >> Makefile
make -j "$MAKE_THREAD"
cp "./.theos/obj/debug/fouldecrypt" ../kernrw

# ==============================================================================

cd "$WORKING_LOCATION"
rm -rf product || true
mkdir product

cp ./build/tfp0 ./product/fouldecrypt.tfp0 # /usr/lib/libkrw.0.dylib
cp ./build/krw ./product/fouldecrypt.krw # /usr/lib/libkrw.0.dylib
cp ./build/kernrw ./product/fouldecrypt.kernrw # /usr/lib/libkernrw.0.dylib

cd product
echo "Patching library search path..."

# sorry there is no tfp0 dylib, there is my mistake

# install_name_tool -change tfp0.dylib    "@executable_path/tfp0.dylib" fouldecrypt.tfp0
install_name_tool -change /usr/lib/libkrw.0.dylib    "@executable_path/libkrw.0.dylib" fouldecrypt.krw
install_name_tool -change /usr/lib/libkernrw.0.dylib "@executable_path/libkernrw.0.dylib" fouldecrypt.kernrw

codesign --remove fouldecrypt.tfp0
codesign --remove fouldecrypt.krw
codesign --remove fouldecrypt.kernrw

ldid "-S$WORKING_LOCATION/$FOUL_GIT_LOC/entitlements.plist" fouldecrypt.tfp0
ldid "-S$WORKING_LOCATION/$FOUL_GIT_LOC/entitlements.plist" fouldecrypt.krw
ldid "-S$WORKING_LOCATION/$FOUL_GIT_LOC/entitlements.plist" fouldecrypt.kernrw

# ==============================================================================

# now making our own libkrw and libkernrw

cd "$WORKING_LOCATION"

LIBKRW_GIT_URL="https://github.com/Siguza/libkrw"
LIBKRW_GIT_LOC="libkrw"

if [ "$1" == "clean" ]; then
    rm -rf "$LIBKRW_GIT_LOC"
fi

if [ ! -d "$LIBKRW_GIT_LOC" ]; then
    git clone --recursive "$LIBKRW_GIT_URL" "$LIBKRW_GIT_LOC"
else
    cd "$LIBKRW_GIT_LOC"
    git reset --hard
    git clean -fdx
    git pull
    git submodule update --init --recursive
fi

cd "$WORKING_LOCATION"
cp -r "$LIBKRW_GIT_LOC" ./build/libkrw
cd ./build/libkrw
git reset --hard
git clean -fdx
make -j "$MAKE_THREAD"

cp ./libkrw.0.dylib "$WORKING_LOCATION/product/libkrw.0.dylib"

cd "$WORKING_LOCATION"

LIBKERNRW_GIT_URL="https://github.com/ProcursusTeam/libkernrw"
LIBKERNRW_GIT_LOC="libkernrw"

if [ "$1" == "clean" ]; then
    rm -rf "$LIBKERNRW_GIT_LOC"
fi

if [ ! -d "$LIBKERNRW_GIT_LOC" ]; then
    git clone --recursive "$LIBKERNRW_GIT_URL" "$LIBKERNRW_GIT_LOC"
else
    cd "$LIBKERNRW_GIT_LOC"
    git reset --hard
    git clean -fdx
    git pull
    git submodule update --init --recursive
fi

cd "$WORKING_LOCATION"
cp -r "$LIBKERNRW_GIT_LOC" ./build/libkernrw
cd ./build/libkernrw
git reset --hard
git clean -fdx
make -j "$MAKE_THREAD"

cp ./bin/libkernrw.0.dylib "$WORKING_LOCATION/product/libkernrw.0.dylib"

# for every dylib, we sign it with ldid
for file in "$WORKING_LOCATION/product"/*.dylib; do
    ldid -S "$file"
done

# ==============================================================================

rm -rf build || true

cd "$WORKING_LOCATION"
cd product
zip -r fouldecrypt.zip ./*
mv fouldecrypt.zip ../

cd "$WORKING_LOCATION"
echo ""
echo "Product available at:"
echo "  $(pwd)/product/fouldecrypt.tfp0"
echo "  $(pwd)/product/fouldecrypt.krw"
echo "  $(pwd)/product/fouldecrypt.kernrw"
echo ""
echo "Product zip available at:"
echo "  $(pwd)/fouldecrypt.zip"
echo ""
date