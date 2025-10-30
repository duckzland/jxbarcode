#!/bin/bash

## ================================================================
## JXBarcode Debian Package Build Script
## ================================================================
##
## This script builds a Debian (.deb) package for JXBarcode and places
## the output in the build/ directory.
##
## Required dependencies:
##   sudo apt install golang gcc libgl1-mesa-dev xorg-dev libxkbcommon-dev dpkg
##
## Note:
## - On Ubuntu, dpkg is typically pre-installed.
##
## ================================================================

set -e

echo_error() {
  echo -e "\033[0;31m- $1\033[0m"
}

echo_success() {
  echo -e "\033[0;32m- $1\033[0m"
}

echo_start() {
  echo -e "\033[1m$1\033[0m"
}

echo_start "Starting Debian package build process..."

# Check if go-winres is installed
if ! command -v dpkg-deb &> /dev/null; then
    echo_error "Command dpkg-deb not found, install with 'apt install dpkg'"
    exit 1
fi

# Check if version.txt exists and read the version
if [ ! -f version.txt ]; then
    echo_error "version.txt not found. Please create a version.txt file with the format 'version=1.0.0'."
    exit 1
fi

version=$(grep '^version=' version.txt | cut -d'=' -f2 | tr -d '[:space:]')
if [[ -z "$version" ]]; then
    echo_error "Version not found in version.txt"
    exit 1
fi

# Define paths
pkg_dir="build/jxbarcode-${version}"
bin_path="${pkg_dir}/usr/bin"
icons_path="${pkg_dir}/usr/share/icons/hicolor"
desktop_path="${pkg_dir}/usr/share/applications"
deb_output="build/jxbarcode_${version}_amd64.deb"

# Production compiling flags
ldflags="-w -s"
gcflags="-l"
tags="production,desktop,no_emoji,no_animations"
cflags="-Os -ffunction-sections -fdata-sections -flto=auto -pipe -pthread"
cldflags="-pthread -Wl,--gc-sections -flto=auto -fwhole-program"

# Create necessary directories
mkdir -p "${pkg_dir}/DEBIAN" \
         "${bin_path}" \
         "${desktop_path}" \
         "${icons_path}/scalable/apps" \
         "${icons_path}/32x32/apps"

# Build the Go binary
CGO_ENABLED=1 \
CGO_CFLAGS="${cflags}" \
CGO_LDFLAGS="${cldflags}" \
go build -tags="${tags}" -ldflags "${ldflags}" -gcflags="${gcflags}" -o "${bin_path}/jxbarcode" .

# Create control file
cat > "${pkg_dir}/DEBIAN/control" <<EOF
Package: jxbarcode
Version: ${version}
Section: base
Priority: optional
Architecture: amd64
Maintainer: JXBarcode <nobody@example.com>
Description: JXBarcode is a barcode generator based on user text input
EOF

# Create desktop entry
cat > "${desktop_path}/jxbarcode.desktop" <<EOF
[Desktop Entry]
Name=JXBarcode
Exec=/usr/bin/jxbarcode
Icon=jxbarcode
Type=Application
Categories=Utility;
Terminal=false
EOF

# Copy assets
cp static/scalable/jxbarcode.svg "${icons_path}/scalable/apps/"
cp static/32x32/jxbarcode.png "${icons_path}/32x32/apps/"

# Build the Debian package
dpkg-deb --build "${pkg_dir}" "${deb_output}" &> /dev/null

if [ $? -ne 0 ]; then
    echo_error "Failed to build the Debian package. Please check for errors above."
    rm -rf "${pkg_dir}"
    exit 1
fi

# Clean up
rm -rf "${pkg_dir}"

echo_success "Debian package successfully created at: ${deb_output}"