lazyjira_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$lazyjira_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <lazyjira_version> <build_version> [architecture]"
    echo "Example: $0 2.19.2 1 arm64"
    echo "Example: $0 2.19.2 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Upstream tags carry a "v" prefix (e.g. v2.19.2).
UPSTREAM_URL="https://github.com/textfuel/lazyjira/releases/download/v${lazyjira_VERSION}"
UPSTREAM_RAW="https://raw.githubusercontent.com/textfuel/lazyjira/v${lazyjira_VERSION}"

# Upstream documentation shipped in /usr/share/doc/lazyjira. It lives in the
# repository, not in the release tarball, so it is fetched from the tag.
UPSTREAM_DOCS=("Config.md" "Keybindings.md" "Custom_Fields.md")

# Function to map Debian architecture to the lazyjira release asset name.
# Upstream (goreleaser) names its Linux assets after the Go architecture
# spelling, which matches Debian's for the two architectures it publishes, and
# leaves the version out of the asset name. Both are statically linked
# (CGO_ENABLED=0), so they run on every suite we target and need no library
# dependencies.
get_lazyjira_release() {
    local arch=$1
    case "$arch" in
        "amd64") echo "lazyjira_linux_amd64" ;;
        "arm64") echo "lazyjira_linux_arm64" ;;
        *)       echo "" ;;
    esac
}

# The release tarballs contain lazyjira, LICENSE, README.md and CHANGELOG.md
# with no top-level directory, so they are always extracted into a directory we
# create.
download_release() {
    local release=$1

    rm -rf "$release" || true
    rm -f "${release}.tar.gz" || true

    if ! wget -q "${UPSTREAM_URL}/${release}.tar.gz"; then
        echo "❌ Failed to download ${release}.tar.gz"
        return 1
    fi

    mkdir -p "$release"
    if ! tar -xf "${release}.tar.gz" -C "$release"; then
        echo "❌ Failed to extract ${release}.tar.gz"
        return 1
    fi
    rm -f "${release}.tar.gz"

    if [ ! -f "$release/lazyjira" ] || [ ! -f "$release/CHANGELOG.md" ]; then
        echo "❌ Unexpected tarball layout for $release (missing lazyjira binary or CHANGELOG.md)"
        return 1
    fi
    chmod +x "$release/lazyjira"
}

# Fetch the upstream docs once; they do not depend on the target architecture.
fetch_docs() {
    rm -rf docs || true
    mkdir -p docs

    echo "Fetching upstream documentation for v${lazyjira_VERSION}..."
    for doc in "${UPSTREAM_DOCS[@]}"; do
        if ! wget -q "${UPSTREAM_RAW}/docs/${doc}" -O "docs/${doc}" || [ ! -s "docs/${doc}" ]; then
            echo "❌ Failed to download docs/${doc}"
            return 1
        fi
    done
    echo "✅ Documentation fetched"
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local lazyjira_release

    lazyjira_release=$(get_lazyjira_release "$build_arch")
    if [ -z "$lazyjira_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $lazyjira_release"

    if ! download_release "$lazyjira_release"; then
        echo "❌ Failed to prepare lazyjira binary for $build_arch"
        return 1
    fi

    # Upstream ships static Linux binaries for amd64/arm64 only, and both work
    # on every Ubuntu suite we target.
    declare -a arr=("jammy" "noble" "questing" "resolute")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$lazyjira_VERSION-${BUILD_VERSION}~${dist}_${build_arch}_ubu"
        echo "  Building $FULL_VERSION"

        if ! docker build . -f Dockerfile.ubu -t "lazyjira-ubuntu-$dist-$build_arch" \
            --build-arg UBUNTU_DIST="$dist" \
            --build-arg lazyjira_VERSION="$lazyjira_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg LJ_RELEASE="$lazyjira_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "lazyjira-ubuntu-$dist-$build_arch")"
        if ! docker cp "$id:/lazyjira_$FULL_VERSION.deb" - > "./lazyjira_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./lazyjira_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$lazyjira_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

if ! fetch_docs; then
    exit 1
fi

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building lazyjira $lazyjira_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la lazyjira_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
