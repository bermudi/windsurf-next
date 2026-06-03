# Maintainer: Webarch <contact@webarch.ro>
# Auto-updated by GitHub Actions

pkgname=windsurf-next
pkgver=3.0.1012_next.a335ac3d8c
pkgrel=1
pkgdesc="Devin Desktop (next channel) - formerly Windsurf Editor"
arch=('x86_64')
url="https://docs.devin.ai"
license=('custom')

# CDN download configuration
# Source: https://docs.devin.ai/desktop/releases-next
# The build hash is a 40-char identifier from the releases page, not derivable from version.
_build_hash="a335ac3d8c6b04d563d8bd757cadc86d305e3b12"
_cdn_base="https://windsurf-stable.codeiumdata.com/linux-x64-deb/next"
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
makedepends=('curl')
optdepends=(
    'bash-completion: for bash shell completions'
    'zsh: for zsh shell completions'
)
provides=("windsurf-next")
conflicts=("windsurf-next")
options=('!strip')

source=(
    "${pkgname}-${pkgver}.deb::${_cdn_base}/${_build_hash}/${_debfile}"
    'windsurf-next.desktop'
    'windsurf-next-url-handler.desktop'
)

sha256sums=(
    'a548d49146bd80e5ffc58e0fb81a6c0e2d0e4f1e0a45f5c390c5c368a9211f91'
    'f15127ef9ff42b2eddf5e0b476a27a0f65e3813de911c9154a577746b47e8188'
    'c2845c4efacb3eb7f0c5756ec9b2f68f3b24af11cc2db6965a4e5f4e744cf539'
)

prepare() {
    cd "$srcdir"
    
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
    
    # The deb extracts to usr/share/{windsurf-next,devin-next}/
    # Find the actual install directory
    local _installdir
    for _candidate in "usr/share/windsurf-next" "usr/share/devin-desktop-next"; do
        if [[ -d "$_candidate" ]]; then
            _installdir="$_candidate"
            break
        fi
    done

    if [[ -z "$_installdir" ]]; then
        _installdir=$(find usr/share -maxdepth 1 -type d -not -path "usr/share" | head -1)
    fi

    # Copy all files to /opt
    install -dm755 "$pkgdir/opt/$pkgname"
    cp -r "$_installdir"/* "$pkgdir/opt/$pkgname/"
    
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
        if [[ -n "$_binname" ]]; then
            # Symlink in /opt so /opt/windsurf-next/windsurf-next works
            ln -sf "$_binname" "$pkgdir/opt/$pkgname/$pkgname"
            # Symlink in /usr/bin
            ln -sf "/opt/$pkgname/$pkgname" "$pkgdir/usr/bin/$pkgname"
        fi
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
    # The main binary may not be named $pkgname
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
