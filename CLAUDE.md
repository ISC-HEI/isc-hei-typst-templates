# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Official [Typst](https://typst.app/) templates for the ISC bachelor degree programme at HEI Sion (HES-SO Valais), Switzerland. One shared codebase is distributed as **five separate packages** on the Typst Universe registry under `@preview/isc-hei-*`.

## Build commands

Requires: `typst` (≥ 0.14.2), `just`, `ImageMagick` + `pngquant` (thumbnails only).

```sh
# Compile all five templates to examples/*.pdf
just compile_all

# Compile a single template
typst compile src/bachelor_thesis.typ examples/bachelor_thesis.pdf

# Pack all five packages to @preview (needed before running tests)
just pack_distro_preview

# Full test suite (packs first, then runs scripts/test-*.sh)
just test_all

# Install dev symlinks so local edits are visible without re-packing
just install-symblinks

# Regenerate thumbnails from compiled PDFs (needs ImageMagick + pngquant)
just generate_thumbs
```

## Architecture

### Single-source, multi-package layout

```
isc_templates.typ        ← sole public API; all user-callable functions live here
lib/
  includes.typ           ← shared state, brand color (hei-purple = #E20571), dep imports
  pages/cover_*.typ      ← one cover renderer per document type
  assets/                ← SVG logos
src/
  *.typ                  ← runnable demo/example documents (one per template)
  pages/                 ← shared content blocks (abstract, acknowledgements, résumé)
  themes/                ← .tmTheme files for code highlighting
templates/*/typst.toml   ← per-package metadata (name, version, thumbnail)
typst.toml               ← root package version (must stay in sync with templates/)
i18n.json                ← all translated UI strings (fr / en / de)
scripts/                 ← pack, dev_link, uninstall, test-*.sh helpers
```

The `scripts/pack` script copies the shared source into each package slot and sets `entrypoint = "isc_templates.typ"`. Each `templates/*/typst.toml` pins the compiler version and declares the template thumbnail.

### How `isc_templates.typ` works

Everything is gated on a `doc-type` parameter passed to `project()`:

```
"thesis" | "report" | "document" | "exec-summary" | "tb-assignment"
```

`project()` sets margins, headers, footers, and calls the matching `lib/pages/cover_*.typ`. All other top-level functions (`page-title`, `chapter-rule`, `table-of-contents`, `the-bibliography`, `code`, `todo`, `i18n`, …) are thin wrappers that read the shared state variables declared in `lib/includes.typ`.

### State variables (lib/includes.typ)

Typst `state` objects thread document-wide settings without argument passing:

| Variable | Purpose |
|---|---|
| `global-language` | Active locale (`"fr"` / `"en"` / `"de"`) |
| `global-keywords` | PDF metadata keywords |
| `header-footers-enabled` | Show/hide running headers |
| `global-project-repos` | Repository URL shown on abstract page |
| `blank-page` | Suppress decorations on intentionally blank pages |
| `show-toc-enabled` | Whether `table-of-contents()` renders |

### Internationalisation

All user-visible strings come from `i18n.json`. The `i18n(key)` function resolves them against `global-language` at render time. When adding a new string, add entries for all three languages.

## Version management

Versions must be consistent across:
- `typst.toml` (root)
- `templates/bachelor-thesis/typst.toml`
- `templates/report/typst.toml`
- `templates/document/typst.toml`
- `templates/exec-summary/typst.toml`
- `templates/tb-assignment/typst.toml`

Note: the root `typst.toml` and the template `typst.toml` files may legitimately differ by one patch version (root tracks the last published release; templates track the next).

## Fonts

Run `source src/fonts/install_fonts.sh` once to install Source Sans Pro/3, Fira Code, Inria Sans, and math fonts. Without them, compilation silently falls back to system fonts.
