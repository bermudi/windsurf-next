# Contributor: Webarch <contact at webarch dot ro>

pkgname=windsurf-next
_api=https://windsurf-next.codeium.com/api/update/linux-x64/next
pkgver=$(curl -Ls "$_api"|grep -oP '"windsurfVersion":"\K[^"]+')
pkgrel=1
pkgdesc='Next version of the Windsurf editor'
arch=('x86_64')
url="https://windsurf.com"
license=('LicenseRef-Windsurf Editor')
_electron=electron
depends=( ripgrep fd xdg-utils $_electron #replacements
 alsa-lib
 dbus
 gnupg
 libnotify
 libsecret
 libxkbfile
 libxss
)
options=(!strip) # for sign of ext
source=(windsurf-next.desktop # .deb should have it
"https://gitlab.archlinux.org/archlinux/packaging/packages/code/-/raw/main/code.sh"
"https://windsurf-stable.codeiumdata.com/linux-x64/next/$(curl -Ls "$_api"|grep -oP '"version":"\K[^"]+')/Windsurf-linux-x64-${pkgver}.tar.gz")

sha256sums=('13b96b1499830a08b51e54d8c3548c0410f0dbb58fcf4767115a902c6bd87c7c'
'5da1525b5fe804b9192c05e1cbf8d751d852e3717fb2787c7ffe98fd5d93e8c1'
$(curl -Ls "$_api"|grep -oP '"sha256hash":"\K[^"]+'))
package() {
  install -d "${pkgdir}"/usr/lib
  # Electron app
  mv Windsurf/resources/app "${pkgdir}"/usr/lib/$pkgname
  # System tools
  _app=/usr/lib/$pkgname
  sed -e "s|code-flags|windsurf-flags|" \
    -e "s|/usr/lib/code/out/cli.js|${_app}/out/cli.js|" \
    -e "s|/usr/lib/code/code.mjs|--app=${_app}|" code.sh > run.sh
  install -Dm755 run.sh "${pkgdir}"/usr/bin/$pkgname
  ln -svf /usr/bin/rg "${pkgdir}"/usr/lib/${pkgname}/node_modules/@vscode/ripgrep/bin/rg
  ln -svf /usr/bin/xdg-open "${pkgdir}"/usr/lib/${pkgname}/node_modules/open/xdg-open
  ln -svf /usr/bin/fd "${pkgdir}"/usr/lib/${pkgname}/extensions/windsurf/bin/fd
  # desktop entry
  install -Dm644 ${pkgname}.desktop "${pkgdir}"/usr/share/applications/${pkgname}.desktop
  # shell completions
  install -Dm644 Windsurf/resources/completions/bash/$pkgname "${pkgdir}"/usr/share/bash-completion/completions/$pkgname
  install -Dm644 Windsurf/resources/completions/zsh/_$pkgname "${pkgdir}"/usr/share/zsh/site-functions/_$pkgname
  # No correct SVG for -next...
  install -d "${pkgdir}"/usr/share/pixmaps
  ln -sf /usr/lib/${pkgname}/resources/linux/code-next.png "${pkgdir}"/usr/share/pixmaps/
}
