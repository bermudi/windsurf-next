# Maintainer: Webarch <contact@webarch.ro>
# Contributor: Your Name <your email> (Update if you maintain it)
# Generated on: 2025-04-28 21:35:03 UTC

pkgname=windsurf-next
pkgver=1.7.103_next.619323b3cd
pkgrel=1
pkgdesc="Windsurf-next - Next version of the Windsurf editor"
arch=('x86_64')
url="https://codeium.com"
license=('Custom') # Consider adding license file to source and package()
depends=(
    'vulkan-driver'
    'ffmpeg'
    'glibc'
    'libglvnd'
    'gtk3' # Often needed for GUI apps
    'alsa-lib' # Often needed for audio
)
makedepends=('curl' 'jq') # jq needed only if pkgver() is used actively
optdepends=(
    # Add optional dependencies if any
)
provides=("$pkgname")
conflicts=("$pkgname")
options=('!strip')

# Use a variable for the downloaded filename for clarity
_pkgfilename="windsurf-next_1.7.103_next.619323b3cd_linux-x64"

source=(
    # Download the main binary, renaming it using :: syntax
    "$_pkgfilename::https://windsurf-stable.codeiumdata.com/linux-x64/next/619323b3cdd4a88a75f3b5fa39dba02c3b9e14a9/Windsurf-linux-x64-1.7.103+next.619323b3cd.tar.gz"
    # Include the local .desktop file
    'windsurf-next.desktop'
    # Example: Add license file if available 'LICENSE::URL_TO_LICENSE'
)
sha256sums=('5a3c420584d1b4683d9e381631d8d2d9162026090a9778f59f786308be775ce3'
              '0561a3546b31291d43138b1f51e9696d889b37d0e88966c9bd32307d4536f91a'
              # Add SHA256 for license file if added 'LICENSE_SHA256'
              )

# Optional pkgver() function for checking version at build time (makepkg -o)
# pkgver() {
#     local api_response=$(curl -s "https://windsurf-next.codeium.com/api/update/linux-x64/next/latest")
#     echo "$api_response" | jq -r '.windsurfVersion' | sed 's/+/_/g'
# }

package() {
    cd "$srcdir"

    # Install the main application binary
    # Installs to /opt/$pkgname/$pkgname (e.g., /opt/windsurf-next/windsurf-next)
    install -Dm755 "$_pkgfilename" "$pkgdir/opt/$pkgname/$pkgname"

    # Install the desktop entry file
    install -Dm644 "$pkgname.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"

    # Install the icon (if it needs to be explicitly installed, not handled by app)
    # Requires icon file in source array and matching sha256sum
    # Example: Assuming icon is at top level of source after download/extraction
    # install -Dm644 "icon-filename.png" "$pkgdir/usr/share/icons/hicolor/128x128/apps/$pkgname.png"
    # The current .desktop file points to an icon within /opt/ - assuming the app provides it there.

    # Install License file (if sourced)
    # install -Dm644 "LICENSE_FILENAME_IN_SOURCE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
