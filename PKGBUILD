# Maintainer: Webarch <contact@webarch.ro>
# Co-maintainer: bermudi <archlinux.i5beg@dabg.uk>
# Auto-updated by GitHub Actions

pkgname=windsurf-next
pkgver=1.13.106_next.97d7a9c6ff
pkgrel=2
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
    'fd'
    'ripgrep'
    'xdg-utils'
)

makedepends=('curl')

optdepends=(
    'bash-completion: for bash shell completions'
    'zsh: for zsh shell completions'
)

options=('!strip')

source=(
    "${pkgname}-${pkgver}.deb::${_apt_base}/pool/main/w/windsurf-next/${_debfile}"
    'windsurf-next.desktop'
    'windsurf-next-url-handler.desktop'
)

sha256sums=(
    'f7be10c68cb4e8e36d1e7be414d8ae5ce422467d81681b88e3e24f730cd203c8'
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

    local _appdir="$pkgdir/usr/lib/$pkgname"
    local _resources="$_appdir/resources"

    # Move bundled application into /usr/lib per Arch packaging norms
    install -dm755 "$_appdir"
    cp -a usr/share/windsurf-next/. "$_appdir/"

    # Create launcher in PATH
    install -dm755 "$pkgdir/usr/bin"
    ln -sf "../lib/$pkgname/$pkgname" "$pkgdir/usr/bin/$pkgname"

    # Install the desktop entry files
    install -Dm644 "$srcdir/$pkgname.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"
    install -Dm644 "$srcdir/$pkgname-url-handler.desktop" "$pkgdir/usr/share/applications/$pkgname-url-handler.desktop"

    # Install metainfo if provided (upstream uses appdata directory)
    if [[ -d usr/share/appdata ]]; then
        install -dm755 "$pkgdir/usr/share/metainfo"
        for _xml in usr/share/appdata/*.xml; do
            [[ -e "$_xml" ]] || continue
            install -Dm644 "$_xml" "$pkgdir/usr/share/metainfo/$(basename "$_xml")"
        done
    fi
    if [[ -d usr/share/metainfo ]]; then
        install -dm755 "$pkgdir/usr/share/metainfo"
        cp -a usr/share/metainfo/. "$pkgdir/usr/share/metainfo/"
    fi

    # Ship upstream license if present
    local _license_dest="$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    if [[ -f usr/share/doc/$pkgname/copyright ]]; then
        install -Dm644 "usr/share/doc/$pkgname/copyright" "$_license_dest"
    elif [[ -f usr/share/doc/windsurf/copyright ]]; then
        install -Dm644 "usr/share/doc/windsurf/copyright" "$_license_dest"
    fi

    # Install bash completion
    if [[ -f "$_resources/completions/bash/$pkgname" ]]; then
        install -Dm644 "$_resources/completions/bash/$pkgname" \
            "$pkgdir/usr/share/bash-completion/completions/$pkgname"
    fi
    
    # Install zsh completion
    if [[ -f "$_resources/completions/zsh/_$pkgname" ]]; then
        install -Dm644 "$_resources/completions/zsh/_$pkgname" \
            "$pkgdir/usr/share/zsh/site-functions/_$pkgname"
    fi

    # Replace bundled helper binaries with system versions
    if [[ -d "$_resources/app/extensions/windsurf/bin" ]]; then
        ln -sf "/usr/bin/fd" "$_resources/app/extensions/windsurf/bin/fd"
    fi
    if [[ -d "$_resources/app/node_modules/@vscode/ripgrep/bin" ]]; then
        ln -sf "/usr/bin/rg" "$_resources/app/node_modules/@vscode/ripgrep/bin/rg"
    fi
    if [[ -d "$_resources/app/node_modules/open" ]]; then
        ln -sf "/usr/bin/xdg-open" "$_resources/app/node_modules/open/xdg-open"
    fi
    
    # Install icons for desktop environments (hicolor + pixmaps fallback)
    install -Dm644 "$_resources/app/resources/linux/code-next.png" \
        "$pkgdir/usr/share/icons/hicolor/256x256/apps/$pkgname.png"
    install -Dm644 "$_resources/app/resources/linux/code-next.png" \
        "$pkgdir/usr/share/pixmaps/$pkgname.png"

    # Preserve SVG icon if present
    if [[ -f "$_resources/app/out/media/code-iconsvg.svg" ]]; then
        install -Dm644 "$_resources/app/out/media/code-iconsvg.svg" \
            "$pkgdir/usr/share/icons/hicolor/scalable/apps/$pkgname.svg"
    fi
    
    # Fix permissions
    chmod 755 "$_appdir/$pkgname"
    chmod 4755 "$_appdir/chrome-sandbox"
}
