# Maintainer: Webarch <contact@webarch.ro>
pkgname=windsurf-next
pkgver=1.7.103_next.619323b3cd
pkgrel=1
pkgdesc="Windsurf-next - Next version of the Windsurf editor"
arch=('x86_64')
url="https://codeium.com"
license=('Custom')
depends=(
    'vulkan-driver'
    'ffmpeg'
    'glibc'
    'libglvnd'
makedepends=('curl' 'jq')
options=('!strip')

pkgver() {
    local api_response
    api_response=$(curl -s "https://windsurf-next.codeium.com/api/update/linux-x64/next/latest")
    echo "$api_response" | jq -r '.windsurfVersion' | sed 's/-/_/g'
}

source=(
    "windsurf-next-$pkgver.tar.gz::https://windsurf-stable.codeiumdata.com/linux-x64/next/619323b3cdd4a88a75f3b5fa39dba02c3b9e14a9/Windsurf-linux-x64-1.7.103+next.619323b3cd.tar.gz"
    "windsurf-next-$pkgver.tar.gz::https://windsurf-stable.codeiumdata.com/linux-x64/next/619323b3cdd4a88a75f3b5fa39dba02c3b9e14a9/Windsurf-linux-x64-1.7.103+next.619323b3cd.tar.gz"
sha256sums=('SKIP')

prepare() {
    local api_response
    api_response=$(curl -s "https://windsurf-next.codeium.com/api/update/linux-x64/next/latest")
    local expected_sha256
    expected_sha256=$(echo "$api_response" | jq -r '.sha256hash')
    echo "Verifying SHA256 hash..."
    echo "$expected_sha256 $srcdir/$pkgname-$pkgver.tar.gz" | sha256sum -c
}

package() {
    cd "$srcdir/Windsurf"
    
    # Create installation directory
    install -dm755 "$pkgdir/opt/$pkgname"
    
    # Copy all files
    cp -a * "$pkgdir/opt/$pkgname/"
    
    # Install shell completions
    if [ -d resources/completions ]; then
        if [ -d resources/completions/bash ]; then
            install -dm755 "$pkgdir/usr/share/bash-completion/completions"
            cp -r resources/completions/bash/* "$pkgdir/usr/share/bash-completion/completions/"
        fi
        if [ -d resources/completions/zsh ]; then
            install -dm755 "$pkgdir/usr/share/zsh/site-functions"
            cp -r resources/completions/zsh/* "$pkgdir/usr/share/zsh/site-functions/"
        fi
    fi

    # Create executable symlink
    install -dm755 "$pkgdir/usr/bin"
    ln -s "/opt/$pkgname/windsurf-next" "$pkgdir/usr/bin/$pkgname"
    
    # Install desktop entry
    install -Dm644 /dev/null "$pkgdir/usr/share/applications/$pkgname.desktop"

    cat > "$pkgdir/usr/share/applications/$pkgname.desktop" << EOF
[Desktop Entry]
Name=Windsurf Next
Comment=Windsurf Editor (Next Version)
Exec=$pkgname
Icon=/opt/$pkgname/resources/app/resources/linux/code-next.png
Terminal=false
Type=Application
Categories=Development;TextEditor;
StartupWMClass=Windsurf - Next
EOF
}
