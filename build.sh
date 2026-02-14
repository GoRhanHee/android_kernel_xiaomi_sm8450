#!/bin/bash

# Import KernelSU-Next
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/dev/kernel/setup.sh" | bash -

# Define toolchain variables
CLANG_DIR=$PWD/toolchain/clang-r574158
PATH=$CLANG_DIR/bin:$PATH

# Check if toolchain exists
    echo "-----------------------------------------------"
    echo "Toolchain not found! Downloading..."
    echo "-----------------------------------------------"
    rm -rf $CLANG_DIR
    mkdir -p $CLANG_DIR
    pushd $CLANG_DIR > /dev/null
    curl -LJOk -o clang.tar.gz https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r536225.tar.gz
    tar xf clang.tar.gz
    rm clang.tar.gz
    echo "Cleaning up..."
    popd > /dev/null

# Setting 
export ANDROID_BUILD_TOP=$(pwd)
export ARCH=arm64

# Cooking Kernel Source
mkdir out

MAKE_ARGS="
LLVM=1 \
LLVM_IAS=1 \
ARCH=arm64 \
O=out
"

make ${MAKE_ARGS} -j24 gorhanhee_defconfig gorhanhee.config || exit 1
make ${MAKE_ARGS} -j24 || exit 1

# Cooking boot.img
mkdir prebuilts/output
chmod +x ${ANDROID_BUILD_TOP}/prebuilts/*
cd ${ANDROID_BUILD_TOP}/prebuilts

unzip -jo ${ANDROID_BUILD_TOP}/prebuilts/${DEVICE}/boot.zip boot.img -d ${ANDROID_BUILD_TOP}/prebuilts/
./magiskboot unpack boot.img
cp ${ANDROID_BUILD_TOP}/out/arch/arm64/boot/Image ${ANDROID_BUILD_TOP}/prebuilts/kernel
./magiskboot repack boot.img
cp ${ANDROID_BUILD_TOP}/prebuilts/new-boot.img ${ANDROID_BUILD_TOP}/prebuilts/output/boot.img