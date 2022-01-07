#!/bin/bash

set -e

cd "$(dirname "$0")"
WORKING_LOCATION="$(pwd)"

GIT_URL="https://github.com/NyaMisty/fouldecrypt"
GIT_LOC="fouldecrypt"

if [ ! -d "$GIT_LOC" ]; then
    git clone --recursive "$GIT_URL" "$GIT_LOC"
else
    cd "$GIT_LOC"
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
cp -r "$GIT_LOC" ./build/fouldecrypt.tfp0 
cd ./build/fouldecrypt.tfp0
git reset --hard
git clean -fdx
sed -i.backup 's/# USE_LIBKRW = 1/export USE_LIBKRW = 1/g' Makefile
echo "export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc" >> Makefile
make -j "$MAKE_THREAD"
cp "./.theos/obj/debug/fouldecrypt" ../tfp0

cd "$WORKING_LOCATION"
cp -r "$GIT_LOC" ./build/fouldecrypt.krw
cd ./build/fouldecrypt.krw
git reset --hard
git clean -fdx
sed -i.backup 's/# USE_LIBKRW = 1/export USE_LIBKRW = 1/g' Makefile
echo "export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc" >> Makefile
make -j "$MAKE_THREAD"
cp "./.theos/obj/debug/fouldecrypt" ../krw

cd "$WORKING_LOCATION"
cp -r "$GIT_LOC" ./build/fouldecrypt.kernrw
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

cp ./build/tfp0 ./product/fouldecrypt.tfp0
cp ./build/krw ./product/fouldecrypt.krw
cp ./build/kernrw ./product/fouldecrypt.kernrw

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