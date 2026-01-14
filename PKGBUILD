# Maintainer: Webarch <contact@webarch.ro>
# Auto-updated by GitHub Actions

pkgname=windsurf-next
pkgver=1.13.109_next.c1893363f1
pkgrel=1
pkgdesc="Windsurf-next - Next version of the Windsurf editor"
arch=('x86_64')
url="https://windsurf.com"
license=('custom')

# APT repository configuration
_apt_base="https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt"
# Upstream version format: 1.12.157+next.10ebfa84f4 (from Packages file)
_upstream_ver="${pkgver//_/+}"
# Deb filename from APT pool
_debfile="Windsurf-linux-x64-${_upstream_ver}.deb"

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
    "${pkgname}-${pkgver}.deb::${_apt_base}/pool/main/w/windsurf-next/${_debfile}"
    'windsurf-next.desktop'
    'windsurf-next-url-handler.desktop'
)

sha256sums=(
    '473c62624414b1ab8395ac0b437bfe06a9f7be3a031c46cd0c25bfff5291f820'
    '82f912789c91da072537934734771b557d310616f433591516b740342db0508f'
    '884775875158639ccf975c991c5c8804b4b766df1eebc4f3a9ed8c47b2782f42'
)

prepare() {
    cd "$srcdir"
    
    # Extract the .deb file (ar archive)
    mkdir -p deb-extract
    cd deb-extract
    ar x "../${pkgname}-${pkgver}.deb"
    
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
    cd "$srcdir/deb-extract/data"
    
    # The deb extracts to usr/share/windsurf-next/
    # Copy all files to /opt for consistency with current package
    install -dm755 "$pkgdir/opt/$pkgname"
    cp -r usr/share/windsurf-next/* "$pkgdir/opt/$pkgname/"
    
    # Create symlink for the executable
    install -dm755 "$pkgdir/usr/bin"
    ln -sf "/opt/$pkgname/$pkgname" "$pkgdir/usr/bin/$pkgname"

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
    
    # Install icon
    install -Dm644 "$pkgdir/opt/$pkgname/resources/app/resources/linux/code-next.png" \
        "$pkgdir/usr/share/pixmaps/$pkgname.png"
    
    # Fix permissions
    chmod 755 "$pkgdir/opt/$pkgname/$pkgname"
    chmod 4755 "$pkgdir/opt/$pkgname/chrome-sandbox"
}
