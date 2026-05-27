# Building and deployment notes

This file explains how to to build locally and deploy to Typst app and Typst templates.

Since v0.2.0, the build process is based on [`just`](https://github.com/casey/just)

## Toolchain & dependencies

To build, test and deploy new releases I'm using [just](https://github.com/casey/just), which is really nice!

`ImageMagick` (with `pngquant`) is used for creating the thumbnails:

```bash
sudo apt install imagemagick pngquant
```

#### Installing a recent `just`

The `just` shipped by `apt` is too old (Ubuntu ships 1.21.0). Install the latest
prebuilt binary into `~/.local/bin` (which must be ahead of `/usr/bin` on your
`PATH`, so it shadows any apt-installed version):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
```

Verify with `just --version` (should report ≥ 1.51.0). Re-run the same one-liner
to upgrade later. If you previously installed it via apt, you can optionally
remove the stale copy with `sudo apt remove just`.

## Development process

For the sake of simplicity from a developer's perspective, there's a single repository on this side, containing a singe source folder for all the document types. When building, the repos is split and handled differently from Typst perspective. All the heavy-lifting for this is made using `just`.

The Justfile is split into two workflows, surfaced as recipe groups in `just --list`:

- **`dev`** — work against your live source via symlinks; nothing gets packed.
- **`release`** — build and check the artifacts published to the Typst Universe.

:warning: Packing **replaces the dev symlinks**, so re-run `just install-symblinks` to return to local work afterwards.

### Working on the template (`dev`)

:warning: If running on Mac, you might have to adapt the shell used in `scripts/package` (uncomment the second line).

To develop new features in the template, install the dev symlinks so the `@preview` packages point at this repo (run once):

```bash
just install-symblinks
```

Once done, you can work on any of the document and compile it with

```bash
typst watch src/bachelor_thesis.typ
```

for instance. The six examples can be compiled in one go to `examples/*.pdf` with `just compile-all`.

Run the full test suite against your live source (no packing) with `just test`, or only the poster layout checks (every variant must fit one A1 page) with `just test-poster`.

### Testing local deployment (`release`)

When sufficiently confident that it seems to work, it's time to test a `preview` version as created by `typst`.

To deploy locally for `typst` command-line

```bash
just pack
```

This packs all six packages to `@preview` as the real Universe artifact (it depends on `compile-all` + `generate-thumbs`, so packed examples and thumbnails are fresh). Note that it replaces the dev symlinks, so re-run `just install-symblinks` afterwards to return to local development. The templates can be tested as needed by creating a local sample using:

```bash
typst init @preview/isc-hei-report:0.7.9
```

Then go the directory, try to compile with `typst watch report.typ`.

For convenience, `just test-all` packs the release and then runs the full test suite against it. It allows a quick check for errors before deploying to the universe.

To remove all packed/symlinked templates from `@preview`, use `just uninstall`.

### Bumping the version

Versions must stay consistent across the root `typst.toml` and every `templates/*/typst.toml`. Bump them all (and the `src/` imports) in one shot:

```bash
just bump-version          # patch:  0.7.9 → 0.7.10 (default)
just bump-version minor    # minor:  0.7.9 → 0.8.0
just bump-version 1.0.0    # explicit X.Y.Z
```

It re-installs the dev symlinks afterwards so `@preview` resolves the new version.

## Deploying to Typst universe

- Fork the [Typst universe repos](https://github.com/typst/packages/tree/main)
- Clone the fork it into `DEST_TO_REPOS`, and then pack each template into it with `./scripts/pack DEST_TO_REPOS/packages/preview <template>`, where `<template>` is each of `bachelor-thesis`, `report`, `document`, `exec-summary`, `tb-assignment`, and `poster`.
- Lint for kebab-case only (at least publicly accessible functions)
- Test using `typst-package-check` from <https://github.com/typst/package-check>, using `typst-package-check check @preview/isc-hei-bthesis:0.5.0` from the `packages` directory *inside* of the cloned Typst universe repos.
- From github, create PR as usual. A template creates automatically the PR text with update etc... If changes are required by CI/CD, push to local repository. It updates the PR automatically.

### Forking issues

If the forked repository is still "ahead" of the forked branch, make this:

```bash
git fetch upstream
git checkout main
git reset --hard upstream/main
git push origin main --force
```

### Thumbnails & image quantization

Template thumbnails are regenerated from `examples/*.pdf` with `just generate-thumbs` (this is also pulled in automatically by `just pack`). It rasterises the first page of each example and runs `pngquant` to keep the template size on the Universe small. To re-quantize images by hand:

```bash
pngquant --quality 50-80 *.png --ext .png --force
```