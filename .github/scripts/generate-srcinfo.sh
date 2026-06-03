#!/bin/bash
# Generates .SRCINFO from PKGBUILD by sourcing it
# Works on any system with bash (no makepkg required)

set -eo pipefail

if [[ ! -f PKGBUILD ]]; then
    echo "Error: PKGBUILD not found" >&2
    exit 1
fi

# shellcheck source=/dev/null
source PKGBUILD

{
    echo "pkgbase = ${pkgname}"
    printf '\tpkgdesc = %s\n' "$pkgdesc"
    printf '\tpkgver = %s\n' "$pkgver"
    printf '\tpkgrel = %s\n' "$pkgrel"
    printf '\turl = %s\n' "$url"

    for v in "${arch[@]}";           do printf '\tarch = %s\n'         "$v"; done
    for v in "${license[@]}";        do printf '\tlicense = %s\n'      "$v"; done
    for v in "${makedepends[@]}";    do printf '\tmakedepends = %s\n'  "$v"; done
    for v in "${depends[@]}";        do printf '\tdepends = %s\n'      "$v"; done
    for v in "${optdepends[@]}";     do printf '\toptdepends = %s\n'   "$v"; done
    for v in "${provides[@]}";       do printf '\tprovides = %s\n'     "$v"; done
    for v in "${conflicts[@]}";      do printf '\tconflicts = %s\n'    "$v"; done
    for v in "${options[@]}";        do printf '\toptions = %s\n'      "$v"; done
    for v in "${source[@]}";         do printf '\tsource = %s\n'       "$v"; done
    for v in "${sha256sums[@]}";     do printf '\tsha256sums = %s\n'   "$v"; done

    echo ""
    echo "pkgname = ${pkgname}"
} > .SRCINFO

echo "Generated .SRCINFO"
