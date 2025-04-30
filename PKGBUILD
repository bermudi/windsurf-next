# Maintainer: Webarch <contact@webarch.ro>
# Generated on: 2025-04-30 23:15:20 UTC

pkgname=windsurf-next
pkgver=1.7.104_next.71eeb18eee
pkgrel=1
pkgdesc="Windsurf-next - Next version of the Windsurf editor"
arch=('x86_64')
url="https://windsurf.com"
license=('Custom')
depends=(
    'vulkan-driver'
    'ffmpeg'
    'glibc'
    'libglvnd'
    'gtk3'
    'alsa-lib'
)
makedepends=('curl' 'jq')
optdepends=(
    'bash-completion: for bash shell completions'
    'zsh: for zsh shell completions'
)
provides=("$pkgname")
conflicts=("$pkgname")
options=('!strip')

# Use a variable for the downloaded filename for clarity
_pkgfilename="windsurf-next_1.7.104_next.71eeb18eee_linux-x64"

source=(
    # Download the main binary, renaming it using :: syntax
    "$_pkgfilename::https://windsurf-stable.codeiumdata.com/linux-x64/next/71eeb18eeed7897bea630fcaba7d37c49c78b05e/Windsurf-linux-x64-1.7.104+next.71eeb18eee.tar.gz"
    # Include the local .desktop file
    'windsurf-next.desktop'
)
sha256sums=('b0f09817851d49a595a9be62b6dad10df62881a900cbce1ccd5e0bd5f1675c61'
            '0561a3546b31291d43138b1f51e9696d889b37d0e88966c9bd32307d4536f91a'
           )

package() {
    cd "$srcdir"

    # Extract the tarball to a temporary directory
    mkdir -p windsurf-extract
    tar -xzf "$_pkgfilename" -C windsurf-extract --strip-components=1
    
    # Create the target directory in /opt
    install -dm755 "$pkgdir/opt/$pkgname"
    
    # Copy all files to the target directory
    cp -r windsurf-extract/* "$pkgdir/opt/$pkgname/"
    
    # Create symlink for the executable
    install -dm755 "$pkgdir/usr/bin"
    ln -sf "/opt/$pkgname/$pkgname" "$pkgdir/usr/bin/$pkgname"

    # Install the desktop entry file
    install -Dm644 "$pkgname.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"

    # Install bash completion
    install -Dm644 "windsurf-extract/resources/completions/bash/$pkgname" "$pkgdir/usr/share/bash-completion/completions/$pkgname"
    
    # Install zsh completion
    install -Dm644 "windsurf-extract/resources/completions/zsh/_$pkgname" "$pkgdir/usr/share/zsh/site-functions/_$pkgname"
    
    # Install icon
    install -Dm644 "windsurf-extract/resources/app/resources/linux/code-next.png" "$pkgdir/usr/share/pixmaps/$pkgname.png"
    
    # Fix permissions
    chmod 755 "$pkgdir/opt/$pkgname/$pkgname"
    chmod 4755 "$pkgdir/opt/$pkgname/chrome-sandbox"
}
