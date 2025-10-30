#!/bin/bash
## ================================================================
## JXBarcode RPM Package Build Script
## ================================================================
## This script builds a RPM (.rpm) package for JXBarcode and places
## the output in the build/ directory.
##
## Required dependencies:
##   sudo apt install golang gcc libgl1-mesa-dev xorg-dev libxkbcommon-dev rpm
##
## WARNING:
##   This script builds an RPM package on a Debian-based system.
##   While functional, it has not been thoroughly tested in this environment.
##   For best results and to avoid potential issues with linked library compatibility,
##   it is strongly recommended to build RPMs on an RPM-based distribution (e.g., Fedora, CentOS, RHEL).
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

echo_start "Starting RPM package build process..."

# Check version.txt
if [ ! -f version.txt ]; then
    echo_error "version.txt not found"
    exit 1
fi

version=$(grep '^version=' version.txt | cut -d'=' -f2 | tr -d '[:space:]')
if [[ -z "$version" ]]; then
    echo_error "Version not found in version.txt"
    exit 1
fi

# Build flags
ldflags="-w -s"
gcflags="-l"
tags="production,desktop,no_emoji,no_animations"
cflags="-Os -ffunction-sections -fdata-sections -flto=auto -pipe -pthread"
cldflags="-pthread -Wl,--gc-sections -flto=auto -fwhole-program"

# Paths
build_root="build"
rpm_root="${build_root}/rpmbuild"
pkg_root="${build_root}/pkgroot"
bin_path="${pkg_root}/usr/bin"
desktop_path="${pkg_root}/usr/share/applications"
icons_path="${pkg_root}/usr/share/icons/hicolor"

mkdir -p "${bin_path}" "${desktop_path}" \
         "${icons_path}/scalable/apps" \
         "${icons_path}/32x32/apps" \
         "${icons_path}/256x256/apps"

# Build binary
CGO_ENABLED=1 \
CGO_CFLAGS="${cflags}" \
CGO_LDFLAGS="${cldflags}" \
go build -tags="${tags}" -ldflags="${ldflags}" -gcflags="${gcflags}" -o "${pkg_root}/jxbarcode" .

# Copy assets
cp static/scalable/jxbarcode.svg "${icons_path}/scalable/apps/"
cp static/32x32/jxbarcode.png "${icons_path}/32x32/apps/"
cp static/256x256/jxbarcode.png "${icons_path}/256x256/apps/"

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

# Create RPM layout
mkdir -p "${rpm_root}/SPECS" "${rpm_root}/BUILD" "${rpm_root}/RPMS" "${rpm_root}/SOURCES"

# Create tarball source
tar czf "${rpm_root}/SOURCES/jxbarcode-${version}.tar.gz" -C "${pkg_root}" .

# Create .spec file
cat > "${rpm_root}/SPECS/jxbarcode.spec" <<EOF
Name:           jxbarcode
Version:        ${version}
Release:        1
Summary:        Barcode generator
License:        MIT
Source0:        jxbarcode-${version}.tar.gz
BuildArch:      x86_64

%description
JXBarcode generates barcode from user text input

%prep
%setup -q -c -T
tar -xzf %{SOURCE0}

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps
mkdir -p %{buildroot}/usr/share/icons/hicolor/32x32/apps
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps

cp jxbarcode %{buildroot}/usr/bin/jxbarcode
cp usr/share/applications/jxbarcode.desktop %{buildroot}/usr/share/applications/
cp usr/share/icons/hicolor/scalable/apps/jxbarcode.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/
cp usr/share/icons/hicolor/32x32/apps/jxbarcode.png %{buildroot}/usr/share/icons/hicolor/32x32/apps/
cp usr/share/icons/hicolor/256x256/apps/jxbarcode.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/

%files
/usr/bin/jxbarcode
/usr/share/applications/jxbarcode.desktop
/usr/share/icons/hicolor/scalable/apps/jxbarcode.svg
/usr/share/icons/hicolor/32x32/apps/jxbarcode.png
/usr/share/icons/hicolor/256x256/apps/jxbarcode.png
EOF

# Build RPM
rpmbuild --define "_topdir $(pwd)/${rpm_root}" -bb "${rpm_root}/SPECS/jxbarcode.spec"

if [ $? -ne 0 ]; then
    echo_error "Failed to build the RPM package. Please check for errors above."
    rm -rf "${pkg_root}" "${rpm_root}"
    exit 1
fi

# Move RPM to build/
rpm_file=$(find "${rpm_root}/RPMS" -name "*.rpm" | head -n 1)
mv "$rpm_file" "${build_root}/jxbarcode_${version}_amd64.rpm"

# Clean up temp folders
rm -rf "${pkg_root}" "${rpm_root}"

echo_success "RPM package successfully created at: ${build_root}/jxbarcode_${version}_amd64.rpm"