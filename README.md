## Windsurf Next AUR Automation

This repository tracks the **windsurf-next** AUR package and automates
the update flow via GitHub Actions.

### Workflows
- `.github/workflows/check-updates.yml` schedules version checks against the
  upstream APT repository and invokes the update workflow when a new build
  is available.
- `.github/workflows/update-pkgbuild.yml` regenerates `PKGBUILD`, updates
  `.SRCINFO`, tags/releases the new version, and pushes changes to AUR.

### Helper scripts
Reusable automation lives under `.github/scripts/`:

| Script | Purpose |
| --- | --- |
| `update-pkgbuild.sh` | Rewrite `PKGBUILD` with the provided Arch version and SHA256. |
| `generate-srcinfo.sh` | Regenerate `.SRCINFO` from the current PKGBUILD. |
| `sync-with-origin.sh` | Hard-reset the workspace to the specified remote ref. |
| `commit-and-tag-release.sh` | Stage files, commit, push, and force-update the release tag. |
| `push-to-aur.sh` | Prepare SSH credentials and push packaging files to the AUR git repo. |
| `fetch-version.sh` | Pull the upstream Packages metadata and emit normalized version data. |
| `fetch-aur-version.sh` | Clone the AUR repo to read the current `pkgver`. |
| `compare-versions.sh` | Compare current vs latest version and emit GitHub Action outputs. |

Scripts can be run locally with the same arguments shown in the workflows,
which makes reproducing CI behavior straightforward. Each script validates
its required inputs and exits non-zero on failure so that the calling job
will stop immediately.

### Development notes
- Run `shellcheck .github/scripts/*.sh` before submitting changes (the
  update workflow enforces this automatically).
- Use `pnpm` for Node tooling and `uv` for Python utilities, per repo policy.
