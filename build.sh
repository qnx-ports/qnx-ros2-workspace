#!/bin/bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

if [ ! -d "$QNX_TARGET" ]; then
    echo "QNX_TARGET is not set. Exiting..."
    exit 1
fi

printenv | grep "QNX"

# Check if specific architecture is requested via export
if [ -n "$CPU" ]; then
    # Use the exported CPU variable
    arch="$CPU"
    echo "Building for $CPU"
else
    echo "No architecture specified, please set CPU to aarch64 or x86_64"
    exit 1
fi

if [ "$arch" == "aarch64" ]; then
    CPUVARDIR=aarch64le
    CPUVAR=aarch64le
elif [ "$arch" == "arm" ]; then
    CPUVARDIR=armle-v7
    CPUVAR=armv7le
elif [ "${arch}" == "x86_64" ]; then
    CPUVARDIR=x86_64
    CPUVAR=x86_64
else
    echo "Invalid architecture. Exiting..."
    exit 1
fi

echo "CPU set to $CPUVAR"
echo "CPUVARDIR set to $CPUVARDIR"

# Set according to where you installed host installation on target
CMAKE_MODULE_PATH="$PWD/platform/modules"

# Check if ROS2_HOST_INSTALLATION_PATH is already set via export
if [ -z "${ROS2_HOST_INSTALLATION_PATH:-}" ]; then
    # Not set via export, use default location
    ROS2_HOST_INSTALLATION_PATH=$QNX_TARGET/$CPUVARDIR/opt/ros/jazzy
    echo "ROS2_HOST_INSTALLATION_PATH not set via export, using default: $ROS2_HOST_INSTALLATION_PATH"
else
    echo "ROS2_HOST_INSTALLATION_PATH set via export: $ROS2_HOST_INSTALLATION_PATH"
fi

# Verify the ROS2 installation exists
if [ -f "$ROS2_HOST_INSTALLATION_PATH/local_setup.bash" ]; then
    echo "Found ROS2 Installation in $ROS2_HOST_INSTALLATION_PATH"
    NUMPY_HEADERS=$QNX_TARGET/$CPUVARDIR/usr/lib/python3.11/site-packages/numpy/core/include
else
    echo "Failed to find ROS2 installation in $ROS2_HOST_INSTALLATION_PATH, please set ROS2_HOST_INSTALLATION_PATH correctly"
    exit 1
fi

# sourcing the ROS base installation setup script for the target architecture
# to configure the ROS cross-compilation environment
. $ROS2_HOST_INSTALLATION_PATH/local_setup.bash

printenv | grep "ROS"
printenv | grep "COLCON"

mkdir -p logs

export CPUVARDIR=${CPUVARDIR}
export CPUVAR=${CPUVAR}
export ARCH=${arch}

colcon build --merge-install --cmake-force-configure \
    --build-base=$PWD/build/$CPUVARDIR \
    --event-handlers console_direct+ \
    --install-base=$PWD/install/$CPUVARDIR \
    --cmake-args \
        -DCMAKE_VERBOSE_MAKEFILE=ON \
        -DCMAKE_TOOLCHAIN_FILE="$PWD/platform/qnx.nto.toolchain.cmake" \
    -DBUILD_TESTING:BOOL="OFF" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_MODULE_PATH=$CMAKE_MODULE_PATH \
        -DROS2_HOST_INSTALLATION_PATH=$ROS2_HOST_INSTALLATION_PATH \
    -DROS_EXTERNAL_DEPS_INSTALL=$ROS2_HOST_INSTALLATION_PATH \
        -Wno-dev --no-warn-unused-cli

rc=$?
if [ $rc -eq 0 ]; then
    echo "$arch Success"
else
    echo "$arch Error: $rc"
    exit $rc
fi

echo " "

exit 0
