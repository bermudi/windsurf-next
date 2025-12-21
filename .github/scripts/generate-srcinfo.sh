#!/bin/bash
# Generates .SRCINFO based on the current PKGBUILD contents

set -euo pipefail

PKGBUILD_FILE="PKGBUILD"

if [[ ! -f "$PKGBUILD_FILE" ]]; then
    echo "Error: PKGBUILD not found"
    exit 1
fi

source "$PKGBUILD_FILE"

cat > .SRCINFO <<EOF
pkgbase = $pkgname
	pkgdesc = $pkgdesc
	pkgver = $pkgver
	pkgrel = $pkgrel
	url = $url
	arch = ${arch[0]}
	license = $license
EOF

for dep in "${makedepends[@]}"; do
    echo "\tmakedepends = $dep" >> .SRCINFO
done

for dep in "${depends[@]}"; do
    echo "\tdepends = $dep" >> .SRCINFO
done

for dep in "${optdepends[@]}"; do
    echo "\toptdepends = $dep" >> .SRCINFO
done

echo "\tprovides = ${provides[0]}" >> .SRCINFO
echo "\tconflicts = ${conflicts[0]}" >> .SRCINFO
echo "\toptions = ${options[0]}" >> .SRCINFO

for src in "${source[@]}"; do
    echo "\tsource = $src" >> .SRCINFO
done

for sum in "${sha256sums[@]}"; do
    echo "\tsha256sums = $sum" >> .SRCINFO
done

echo "" >> .SRCINFO
echo "pkgname = $pkgname" >> .SRCINFO

echo ".SRCINFO generated"
cat .SRCINFO
