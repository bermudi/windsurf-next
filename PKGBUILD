pkgname=windsurf-next
pkgver=1.12.158_next.4a23d7e4a1
pkgrel=1
pkgdesc="Windsurf-next - Next version of the Windsurf editor"
arch=('x86_64')
url="https://windsurf.com"
license=('custom')

_apt_base="https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt"
_upstream_ver="${pkgver//_/+}"
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
    "windsurf-next-${pkgver}.deb::${_apt_base}/pool/main/w/windsurf-next/${_debfile}"
    'windsurf-next.desktop'
    'windsurf-next-url-handler.desktop'
)

sha256sums=('d1a1532f13eab19b44e1a56d46e0d5add232b16c6ace75adf89ef1874243fab4'
            '7bcdc177ae93096a04076ddf519b836dddf3a11a49e19bfca80f6bf5e60f91b2)'
            '')

prepare() {
    cd "$srcdir"
    mkdir -p deb-extract
    cd deb-extract
    ar x "../windsurf-next-${pkgver}.deb"
    
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
    
    install -dm755 "$pkgdir/opt/windsurf-next"
    cp -r usr/share/windsurf-next/* "$pkgdir/opt/windsurf-next/"
    
    install -dm755 "$pkgdir/usr/bin"
    ln -sf "/opt/windsurf-next/windsurf-next" "$pkgdir/usr/bin/windsurf-next"

    install -Dm644 "$srcdir/windsurf-next.desktop" "$pkgdir/usr/share/applications/windsurf-next.desktop"
    install -Dm644 "$srcdir/windsurf-next-url-handler.desktop" "$pkgdir/usr/share/applications/windsurf-next-url-handler.desktop"

    if [[ -f "$pkgdir/opt/windsurf-next/resources/completions/bash/windsurf-next" ]]; then
        install -Dm644 "$pkgdir/opt/windsurf-next/resources/completions/bash/windsurf-next" \
            "$pkgdir/usr/share/bash-completion/completions/windsurf-next"
    fi

    if [[ -f "$pkgdir/opt/windsurf-next/resources/completions/zsh/_windsurf-next" ]]; then
        install -Dm644 "$pkgdir/opt/windsurf-next/resources/completions/zsh/_windsurf-next" \
            "$pkgdir/usr/share/zsh/site-functions/_windsurf-next"
    fi

    install -Dm644 "$pkgdir/opt/windsurf-next/resources/app/resources/linux/code-next.png" \
        "$pkgdir/usr/share/pixmaps/windsurf-next.png"

    chmod 755 "$pkgdir/opt/windsurf-next/windsurf-next"
    chmod 4755 "$pkgdir/opt/windsurf-next/chrome-sandbox"
}
