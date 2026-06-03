#!/bin/bash
# Updates PKGBUILD with new version information
# Usage: ./update-pkgbuild.sh <arch_version> <sha256> <apt_filename>

set -euo pipefail

NEW_VERSION="$1"
NEW_SHA256="$2"
NEW_FILENAME="$3"

# Validate inputs
if [[ ! "$NEW_VERSION" =~ ^[a-zA-Z0-9_.]+$ ]]; then
    echo "Error: Invalid version format: $NEW_VERSION" >&2
    exit 1
fi
if [[ ! "$NEW_SHA256" =~ ^[a-f0-9]{64}$ ]]; then
    echo "Error: Invalid SHA256 format: $NEW_SHA256" >&2
    exit 1
fi
if [[ ! "$NEW_FILENAME" =~ ^pool/main/[a-z]+/[a-z0-9-]+/[A-Za-z0-9._+\-]+\.deb$ ]]; then
    echo "Error: Invalid filename format: $NEW_FILENAME" >&2
    exit 1
fi

PKGBUILD_FILE="PKGBUILD"

if [[ ! -f "$PKGBUILD_FILE" ]]; then
    echo "Error: PKGBUILD not found"
    exit 1
fi

echo "Updating PKGBUILD to version $NEW_VERSION"

# Capture existing source entries so we can preserve hashes for local files
# shellcheck source=PKGBUILD
source "$PKGBUILD_FILE"

if ! declare -p source >/dev/null 2>&1 || ! declare -p sha256sums >/dev/null 2>&1; then
    echo "Error: PKGBUILD must define both source[] and sha256sums[] arrays"
    exit 1
fi

declare -a existing_sources=("${source[@]}")
declare -a existing_sha256sums=("${sha256sums[@]-}")

declare -a local_sources=()
declare -a local_source_sums=()

for idx in "${!existing_sources[@]}"; do
    entry="${existing_sources[$idx]}"
    sum="${existing_sha256sums[$idx]:-}"

    # Remove any "::" rename prefix before checking for local files
    local_path="${entry##*::}"

    if [[ -f "$local_path" ]]; then
        local_sources+=("$entry")

        if [[ -z "$sum" ]]; then
            if [[ -f "$local_path" ]]; then
                sum=$(sha256sum "$local_path" | awk '{print $1}')
            else
                echo "Warning: Local source '$local_path' no longer exists; skipping checksum preservation."
                continue
            fi
        fi

        local_source_sums+=("$sum")
    fi
done

cat > "$PKGBUILD_FILE" <<EOF
# Maintainer: Webarch <contact@webarch.ro>
# Auto-updated by GitHub Actions

pkgname=windsurf-next
pkgver=$NEW_VERSION
pkgrel=1
pkgdesc="Devin Desktop (next channel) - formerly Windsurf Editor"
arch=('x86_64')
url="https://docs.devin.ai"
license=('custom:Proprietary')
EOF

cat >> "$PKGBUILD_FILE" <<'EOF'

# APT repository configuration
_apt_base="https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt"
_upstream_ver="${pkgver//_/+}"
_debfile="Devin-linux-x64-${_upstream_ver}.deb"

depends=(
    'vulkan-driver'
    'ffmpeg'
    'glibc'
    'libglvnd'
    'gtk3'
    'alsa-lib'
)
makedepends=()
optdepends=(
    'bash-completion: for bash shell completions'
    'zsh: for zsh shell completions'
)
provides=("windsurf-next")
conflicts=("windsurf-next")
options=('!strip' '!debug')

source=(
EOF

# Extract the pool directory from the filename to handle future path changes
_pool_dir=$(dirname "$NEW_FILENAME")
cat >> "$PKGBUILD_FILE" <<EOF
    "\${pkgname}-\${pkgver}.deb::\${_apt_base}/${_pool_dir}/\${_debfile}"
EOF

if ((${#local_sources[@]} > 0)); then
    for entry in "${local_sources[@]}"; do
        printf "    '%s'\n" "$entry" >> "$PKGBUILD_FILE"
    done
fi

cat >> "$PKGBUILD_FILE" <<'EOF'
)

sha256sums=(
EOF

printf "    '%s'\n" "$NEW_SHA256" >> "$PKGBUILD_FILE"

if ((${#local_source_sums[@]} > 0)); then
    for sum in "${local_source_sums[@]}"; do
        printf "    '%s'\n" "$sum" >> "$PKGBUILD_FILE"
    done
fi

cat >> "$PKGBUILD_FILE" <<'PKGEOF'

)

prepare() {
    cd "$srcdir"

    # Clean up any previous extraction
    rm -rf deb-extract

    # Extract the .deb file (ar archive)
    mkdir -p deb-extract
    cd deb-extract
    ar x "../${pkgname}-${pkgver}.deb"

    # Extract the data archive (contains the actual files)
    mkdir -p data
    if [[ -f data.tar.xz ]]; then
        tar -xf data.tar.xz -C data
    elif [[ -f data.tar.zst ]]; then
        tar -xf data.tar.zst -C data
    elif [[ -f data.tar.gz ]]; then
        tar -xf data.tar.gz -C data
    fi
}

package() {
    cd "$srcdir/deb-extract/data"

    # The deb installs to usr/share/{devin-desktop-next,windsurf-next}/
    # Find the actual install directory
    local _installdir
    for _candidate in "usr/share/devin-desktop-next" "usr/share/windsurf-next"; do
        if [[ -d "$_candidate" ]]; then
            _installdir="$_candidate"
            break
        fi
    done

    if [[ -z "$_installdir" ]]; then
        _installdir=$(find usr/share -maxdepth 1 -type d -not -path "usr/share" | head -1)
    fi

    # Copy all files to /opt
    if [[ -z "$_installdir" || ! -d "$_installdir" ]]; then
        echo "Error: Installation directory not found!" >&2
        return 1
    fi
    install -dm755 "$pkgdir/opt/$pkgname"
    cp -a "$_installdir"/. "$pkgdir/opt/$pkgname/"

    # Create symlink for the executable
    # The binary may be named differently (devin-desktop-next vs windsurf-next)
    install -dm755 "$pkgdir/usr/bin"
    if [[ -f "$pkgdir/opt/$pkgname/$pkgname" ]]; then
        ln -sf "/opt/$pkgname/$pkgname" "$pkgdir/usr/bin/$pkgname"
    else
        # Binary has a different name (e.g. devin-desktop-next)
        local _bin
        _bin=$(find "$pkgdir/opt/$pkgname" -maxdepth 1 -type f -name 'devin-*' -executable | head -1)
        : "${_bin:=$(find "$pkgdir/opt/$pkgname" -maxdepth 1 -type f -name 'windsurf-*' -executable | head -1)}"
        _binname=$(basename "$_bin")
        if [[ -z "$_binname" ]]; then
            echo "Error: Could not find executable in $pkgdir/opt/$pkgname" >&2
            return 1
        fi
        # Symlink in /opt so /opt/windsurf-next/windsurf-next works
        ln -sf "$_binname" "$pkgdir/opt/$pkgname/$pkgname"
        # Symlink in /usr/bin
        ln -sf "/opt/$pkgname/$pkgname" "$pkgdir/usr/bin/$pkgname"
    fi

    # Install the desktop entry files
    install -Dm644 "$srcdir/$pkgname.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"
    install -Dm644 "$srcdir/$pkgname-url-handler.desktop" "$pkgdir/usr/share/applications/$pkgname-url-handler.desktop"

    # Install bash completion
    if [[ -f "$pkgdir/opt/$pkgname/resources/completions/bash/$pkgname" ]]; then
        install -Dm644 "$pkgdir/opt/$pkgname/resources/completions/bash/$pkgname" \
            "$pkgdir/usr/share/bash-completion/completions/$pkgname"
    fi

    # Install zsh completion
    if [[ -f "$pkgdir/opt/$pkgname/resources/completions/zsh/_$pkgname" ]]; then
        install -Dm644 "$pkgdir/opt/$pkgname/resources/completions/zsh/_$pkgname" \
            "$pkgdir/usr/share/zsh/site-functions/_$pkgname"
    fi

    # Install icon - try both old and new naming conventions
    local _icon
    for _icon in "code-next.png" "devin-next.png" "code.png"; do
        if [[ -f "$pkgdir/opt/$pkgname/resources/app/resources/linux/$_icon" ]]; then
            install -Dm644 "$pkgdir/opt/$pkgname/resources/app/resources/linux/$_icon" \
                "$pkgdir/usr/share/pixmaps/$pkgname.png"
            break
        fi
    done

    # Fix permissions
    local _main_bin
    for _main_bin in "$pkgdir/opt/$pkgname/$pkgname" "$pkgdir/opt/$pkgname/devin-desktop-next"; do
        if [[ -f "$_main_bin" ]]; then
            chmod 755 "$_main_bin"
        fi
    done
    if [[ -f "$pkgdir/opt/$pkgname/chrome-sandbox" ]]; then
        chmod 4755 "$pkgdir/opt/$pkgname/chrome-sandbox"
    fi
}
PKGEOF

echo "Updated PKGBUILD to version $NEW_VERSION"
