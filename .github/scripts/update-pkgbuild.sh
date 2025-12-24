#!/bin/bash
# Updates PKGBUILD with new version information
# Usage: ./update-pkgbuild.sh <arch_version> <sha256>

set -euo pipefail

NEW_VERSION="$1"
NEW_SHA256="$2"

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

# Generate new PKGBUILD with embedded content
cat > "$PKGBUILD_FILE" << EOF
# Maintainer: Webarch <contact@webarch.ro>
# Auto-updated by GitHub Actions

pkgname=windsurf-next
pkgver=$NEW_VERSION
pkgrel=1
pkgdesc="Windsurf-next - Next version of the Windsurf editor"
arch=('x86_64')
url="https://windsurf.com"
license=('custom')

# APT repository configuration
_apt_base="https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt"
# Upstream version format: 1.12.157+next.10ebfa84f4 (from Packages file)
_upstream_ver="\${pkgver//_/+}"
# Deb filename from APT pool
_debfile="Windsurf-linux-x64-\${_upstream_ver}.deb"

depends=(
    'vulkan-driver'
    'ffmpeg'
    'glibc'
    'libglvnd'
    'gtk3'
    'alsa-lib'
)
makedepends=('curl')
optdepends=(
    'bash-completion: for bash shell completions'
    'zsh: for zsh shell completions'
)
provides=("windsurf-next")
conflicts=("windsurf-next")
options=('!strip')

source=(
    "\${pkgname}-\${pkgver}.deb::\${_apt_base}/pool/main/w/windsurf-next/\${_debfile}"
EOF

if ((${#local_sources[@]} > 0)); then
    for entry in "${local_sources[@]}"; do
        printf "    '%s'\n" "$entry" >> "$PKGBUILD_FILE"
    done
fi

cat >> "$PKGBUILD_FILE" <<EOF
)

sha256sums=('$NEW_SHA256'
EOF

if ((${#local_source_sums[@]} > 0)); then
    for sum in "${local_source_sums[@]}"; do
        printf "            '%s'\n" "$sum" >> "$PKGBUILD_FILE"
    done
fi

cat >> "$PKGBUILD_FILE" <<'EOF'
)

prepare() {
    cd "\$srcdir"
    
    # Extract the .deb file (ar archive)
    mkdir -p deb-extract
    cd deb-extract
    ar x "../\${pkgname}-\${pkgver}.deb"
    
    # Extract the data archive (contains the actual files)
    mkdir -p data
    # Handle both .tar.xz and .tar.zst formats
    if [[ -f data.tar.xz ]]; then
        tar -xf data.tar.xz -C data
    elif [[ -f data.tar.zst ]]; then
        tar -xf data.tar.zst -C data
    elif [[ -f data.tar.gz ]]; then
        tar -xf data.tar.gz -C data
    fi
}

package() {
    cd "\$srcdir/deb-extract/data"
    
    # The deb extracts to usr/share/windsurf-next/
    # Copy all files to /opt for consistency with current package
    install -dm755 "\$pkgdir/opt/\$pkgname"
    cp -r usr/share/windsurf-next/* "\$pkgdir/opt/\$pkgname/"
    
    # Create symlink for the executable
    install -dm755 "\$pkgdir/usr/bin"
    ln -sf "/opt/\$pkgname/\$pkgname" "\$pkgdir/usr/bin/\$pkgname"

    # Install the desktop entry files
    install -Dm644 "\$srcdir/\$pkgname.desktop" "\$pkgdir/usr/share/applications/\$pkgname.desktop"
    install -Dm644 "\$srcdir/\$pkgname-url-handler.desktop" "\$pkgdir/usr/share/applications/\$pkgname-url-handler.desktop"

    # Install bash completion
    if [[ -f "\$pkgdir/opt/\$pkgname/resources/completions/bash/\$pkgname" ]]; then
        install -Dm644 "\$pkgdir/opt/\$pkgname/resources/completions/bash/\$pkgname" \\
            "\$pkgdir/usr/share/bash-completion/completions/\$pkgname"
    fi
    
    # Install zsh completion
    if [[ -f "\$pkgdir/opt/\$pkgname/resources/completions/zsh/_\$pkgname" ]]; then
        install -Dm644 "\$pkgdir/opt/\$pkgname/resources/completions/zsh/_\$pkgname" \\
            "\$pkgdir/usr/share/zsh/site-functions/_\$pkgname"
    fi
    
    # Install icon
    install -Dm644 "\$pkgdir/opt/\$pkgname/resources/app/resources/linux/code-next.png" \\
        "\$pkgdir/usr/share/pixmaps/\$pkgname.png"
    
    # Fix permissions
    chmod 755 "\$pkgdir/opt/\$pkgname/\$pkgname"
    chmod 4755 "\$pkgdir/opt/\$pkgname/chrome-sandbox"
}
EOF

echo "Updated PKGBUILD to version $NEW_VERSION"