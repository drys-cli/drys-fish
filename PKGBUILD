# Maintainer: Haris Gušić <harisgusic.dev@gmail.com>
pkgname=tem-fish
pkgver=0.0.0
pkgrel=1
epoch=
pkgdesc="Fish extension for tem"
arch=('x86_64')
license=('unknown')
groups=()
# TODO depends on fish?
depends=('tem')
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=("git+https://github.com/tem-cli/$pkgname")
noextract=()
md5sums=('SKIP')
validpgpkeys=()

package() {
	cd "$srcdir/$pkgname"
	make install PREFIX=/usr DESTDIR="$pkgdir"
}
