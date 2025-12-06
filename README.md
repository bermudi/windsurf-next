# Windsurf-Next AUR Package

This is the Arch User Repository (AUR) package for Windsurf-Next, an advanced AI-powered code editor fork of VS Code.

## Automated Updates

This package is automatically updated using GitHub Actions. The system:

1. **Monitors** the Windsurf APT repository every 12 hours for new versions
2. **Detects** version changes automatically
3. **Updates** PKGBUILD and .SRCINFO when a new version is available
4. **Commits** changes and creates GitHub releases with version tags

### How It Works

The automation system uses the Debian APT repository instead of unpredictable tarball URLs:

- **Previous approach**: Download from `https://windsurf-stable.codeiumdata.com/linux-x64/next/{COMMIT_HASH}/Windsurf-linux-x64-{version}.tar.gz`
  - The commit hash made it impossible to predict the next download URL
  
- **Current approach**: Download from APT repository `https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt/`
  - The APT repository has a predictable structure
  - The `Packages` file contains version, checksum, and filename
  - Easy to query and parse programmatically

### Version Format

The package converts between two version formats:

- **APT format**: `1.12.157+next.10ebfa84f4-1764862834`
- **Arch format**: `1.12.157_next.10ebfa84f4`

The conversion:
- Replaces `+` with `_` (underscore)
- Removes the epoch number (after the last `-`)

### Manual Update

To trigger a manual update (if the automatic checks miss something):

1. Go to the [Actions](https://github.com/{your-repo}/windsurf-next/actions) tab
2. Select **"Check for Updates"** workflow
3. Click **"Run workflow"**
4. The workflow will fetch the latest version and update if needed

To update to a specific version manually:

1. Go to the [Actions](https://github.com/{your-repo}/windsurf-next/actions) tab
2. Select **"Update PKGBUILD"** workflow
3. Click **"Run workflow"**
4. Enter the version and SHA256 checksum

### Manual Testing

To test the package locally:

```bash
# Clone the repository
git clone https://aur.archlinux.org/windsurf-next.git
cd windsurf-next

# Build the package
makepkg -si
```

### File Structure

```
windsurf-next/
├── .github/
│   ├── workflows/
│   │   ├── check-updates.yml      # Monitors for new releases (every 12 hours)
│   │   └── update-pkgbuild.yml    # Updates PKGBUILD when triggered
│   └── scripts/
│       ├── fetch-version.sh       # Fetches latest version from APT repo
│       └── update-pkgbuild.sh     # Updates PKGBUILD with new version
├── PKGBUILD                       # Package definition (uses .deb source)
├── .SRCINFO                       # Auto-generated source info
├── windsurf-next.desktop          # Desktop entry
├── windsurf-next-url-handler.desktop  # URL handler
├── ARCHITECTURE.md                # Detailed architecture documentation
└── README.md                      # This file
```

### Installation

Install from AUR:

```bash
# Using an AUR helper
paru -S windsurf-next

# Or manually
git clone https://aur.archlinux.org/windsurf-next.git
cd windsurf-next
makepkg -si
```

### Dependencies

Required:
- vulkan-driver
- ffmpeg
- glibc
- libglvnd
- gtk3
- alsa-lib

Optional:
- bash-completion (for bash completions)
- zsh (for zsh completions)

### Troubleshooting

If the package fails to build:

1. **Check the APT repository**:
   ```bash
   curl -sL "https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt/dists/next/main/binary-amd64/Packages"
   ```

2. **Verify the .deb file**:
   ```bash
   wget --spider "https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt/pool/main/w/windsurf-next/Windsurf-linux-x64-{version}.deb"
   ```

3. **Check SHA256 checksum**:
   ```bash
   echo "{sha256} {filename}" | sha256sum -c
   ```

### Manual Version Check

To check what version is available:

```bash
# Run the fetch-version script
curl -sL https://raw.githubusercontent.com/{your-username}/windsurf-next/main/.github/scripts/fetch-version.sh | bash

# Or directly query the APT repository
curl -sL "https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt/dists/next/main/binary-amd64/Packages" | \
  grep -E "^(Version|Filename|SHA256):" | head -3
```

### Contributing

This is an automated AUR package. Since it's automatically updated, manual changes will likely be overwritten by the GitHub Actions workflow.

If you need to modify the package:
1. Update the relevant files in this repository
2. The automated workflow will incorporate your changes in future updates

### License

This AUR package inherits the Windsurf license (custom). See the upstream project for details.

### Links

- [Windsurf Website](https://windsurf.com)
- [AUR Package](https://aur.archlinux.org/packages/windsurf-next)
- [GitHub Repository](https://github.com/{your-username}/windsurf-next)

### Maintainer

- **Webarch** - contact@webarch.ro
- **Automated Updates** - Powered by GitHub Actions

---

**Note**: This package uses the .deb file from the official Windsurf repository and extracts it for Arch Linux compatibility. This approach ensures reliable updates by leveraging the stable APT repository infrastructure.
