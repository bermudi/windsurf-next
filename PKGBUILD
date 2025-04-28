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
)
makedepends=('curl' 'jq')
options=('!strip')

source=(
    "https://windsurf-stable.codeiumdata.com/linux-x64/next/619323b3cdd4a88a75f3b5fa39dba02c3b9e14a9/Windsurf-linux-x64-1.7.103+next.619323b3cd.tar.gz"
)
sha256sums=('5a3c420584d1b4683d9e381631d8d2d9162026090a9778f59f786308be775ce3')

pkgver() {
    local api_response
    api_response=$(curl -s "https://windsurf-next.codeium.com/api/update/linux-x64/next/latest")
    echo "$api_response" | jq -r '.windsurfVersion' | sed 's/+/_/g'
}
