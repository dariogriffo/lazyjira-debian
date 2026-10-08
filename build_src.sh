#!/bin/bash
set -euo pipefail

lazyjira_VERSION=$1
BUILD_VERSION=$2

if [ -z "$lazyjira_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <lazyjira_version> <build_version>"
    echo "Example: $0 2.19.2 1"
    exit 1
fi

PACKAGE_NAME="lazyjira"
ORIG_TARBALL="${PACKAGE_NAME}_${lazyjira_VERSION}.orig.tar.gz"
BUILD_DIR="${PACKAGE_NAME}-${lazyjira_VERSION}"

echo "Creating Debian/Ubuntu source packages for lazyjira ${lazyjira_VERSION}-${BUILD_VERSION}..."

# Download upstream source tarball (shared .orig.tar.gz across all distributions).
# Upstream tags carry a "v" prefix, but GitHub strips it from the archive's top
# level directory, so the archive already extracts as lazyjira-<version>/ and is
# used byte-for-byte with no repacking.
if [ ! -f "$ORIG_TARBALL" ]; then
    echo "Downloading upstream source from GitHub..."
    wget -q "https://github.com/textfuel/lazyjira/archive/refs/tags/v${lazyjira_VERSION}.tar.gz" -O "$ORIG_TARBALL"
    echo "  Downloaded $ORIG_TARBALL"
else
    echo "  Using existing $ORIG_TARBALL"
fi

build_source_package() {
    local dist=$1
    local FULL_VERSION="${lazyjira_VERSION}-${BUILD_VERSION}~${dist}"

    echo "  Building source package for ${dist} (${FULL_VERSION})..."

    # Clean and recreate build directory from orig tarball
    rm -rf "$BUILD_DIR"
    tar -xf "$ORIG_TARBALL"
    # GitHub archives extract as lazyjira-0.x.y/ which matches our BUILD_DIR

    # Copy Debian packaging directory
    cp -r debian "$BUILD_DIR/"

    # Generate distribution-specific changelog (overwrites placeholder)
    cat > "$BUILD_DIR/debian/changelog" << EOC
lazyjira (${FULL_VERSION}) ${dist}; urgency=medium

  * New upstream release ${lazyjira_VERSION}.

 -- Dario Griffo <dariogriffo@gmail.com>  $(date -R)
EOC

    # Build source package (.dsc + .debian.tar.xz); reuses existing .orig.tar.gz
    dpkg-source -b "$BUILD_DIR"

    rm -rf "$BUILD_DIR"
    echo "    ${FULL_VERSION}"
}

echo ""
echo "Building Debian source packages..."
DEBIAN_DISTS=("bookworm" "trixie" "forky" "sid")
for dist in "${DEBIAN_DISTS[@]}"; do
    build_source_package "$dist"
done

echo ""
echo "Building Ubuntu source packages..."
UBUNTU_DISTS=("jammy" "noble" "questing" "resolute")
for dist in "${UBUNTU_DISTS[@]}"; do
    build_source_package "$dist"
done

echo ""
echo "Source packages created successfully!"
echo ""
echo "Generated files:"
ls -la "${PACKAGE_NAME}_"*.dsc "${PACKAGE_NAME}_"*.orig.tar.gz "${PACKAGE_NAME}_"*.debian.tar.xz 2>/dev/null || true
