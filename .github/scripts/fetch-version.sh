#!/bin/bash
# Fetches the latest version info from the APT repository
# Outputs: VERSION FILENAME SHA256

set -euo pipefail

APT_BASE="https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt"
PACKAGES_URL="$APT_BASE/dists/next/main/binary-amd64/Packages"

# Fetch the Packages file
packages_content=$(curl -sL "$PACKAGES_URL")

# Parse required fields
version=$(echo "$packages_content" | grep -m1 "^Version:" | cut -d' ' -f2)
filename=$(echo "$packages_content" | grep -m1 "^Filename:" | cut -d' ' -f2)
sha256=$(echo "$packages_content" | grep -m1 "^SHA256:" | cut -d' ' -f2)

# Convert version to Arch format (replace + with _, remove epoch after -)
# APT: 1.12.157+next.10ebfa84f4-1764862834
# Arch: 1.12.157_next.10ebfa84f4
arch_version=$(echo "$version" | sed 's/+/_/g; s/-[0-9]*$//')

echo "APT_VERSION=$version"
echo "ARCH_VERSION=$arch_version"
echo "FILENAME=$filename"
echo "SHA256=$sha256"
echo "DOWNLOAD_URL=$APT_BASE/$filename"
