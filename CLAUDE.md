# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Official [Typst](https://typst.app/) templates for the ISC bachelor degree programme at HEI Sion (HES-SO Valais), Switzerland. One shared codebase is distributed as **six separate packages** on the Typst Universe registry under `@preview/isc-hei-*`.

## Build commands

Requires: `typst` (≥ 0.14.2), `just`, `ImageMagick` + `pngquant` (used by `generate-thumbs`, which `pack` runs).

The Justfile is split into four recipe groups (`just --list`): **dev** (work against
your live source via symlinks), **pre-release** (build + check the local @preview
artifacts), **universe** (open a release PR against `typst/packages`), and
**active-pr-flow** (refresh a PR that is already open). Packing replaces the dev
symlinks, so re-run `just install-symblinks` to return to local work afterwards.

```sh
# ── dev ──
# Install dev symlinks so @preview points at this repo (run once)
just install-symblinks

# Compile all six examples to examples/*.pdf
just compile-all
# …or a single template
typst compile src/bachelor_thesis.typ examples/bachelor_thesis.pdf

# Run the full test suite against your live source (no packing)
just test
# …or only the poster layout checks
just test-poster

# ── pre-release ──
# Pack all six packages to @preview (the real artifact; replaces dev symlinks)
just pack

# Pre-publish check: pack the release, then test it
just test-all

# Bump the version across all typst.toml + src/ imports (patch | minor | X.Y.Z)
just bump-version

# Regenerate thumbnails from examples/*.pdf (needs ImageMagick + pngquant)
just generate-thumbs

# Remove all packed/symlinked templates from @preview
just uninstall

# ── universe (open a release PR) ──
# Sparse-clone the fork, base isc-hei-<ver> on upstream/main, pack + validate all six, commit (no push)
just universe-stage
# Re-validate the already-packed packages in the fork clone
just universe-check
# Push the staged branch to the fork and print the PR compare URL (only networked-write step; you write the PR)
just universe-push

# ── active-pr-flow (update an unmerged PR at the SAME version) ──
# Re-stage the current version, then force-push over the existing PR branch (CI re-runs in place; no new PR, no bump)
just update-pr
```

> Universe release flow: `universe-stage` → review → `universe-push`, then open the PR
> from the printed compare URL. The fork clone lives at `~/git/typst-packages` (override
> with `UNIVERSE_CLONE=/path`); the scripts are `scripts/universe-{common,stage,check,push,repush}`.
> If CI flags something on an *unmerged* PR, fix the source and run `just update-pr` to
> rebuild + force-push the same version. A *merged* version is immutable — bump instead.

## Architecture

### Single-source, multi-package layout

```
isc_templates.typ        ← public API: a thin façade that re-exports the lib/ modules
lib/
  includes.typ           ← shared state, brand color (hei-purple = #E20571), dep imports
  settings.typ           ← shared metrics (heading sizes, spacing), version, keywords
  fonts.typ              ← font stacks, ISC-font detection, "fonts not installed" page
  i18n.typ               ← i18n() string resolution + langs (reads ../i18n.json)
  decorations.typ        ← chapter-rule ornaments + the hashed bit-rule (hash-rule)
  content.typ            ← page-title, TOC/figures, bibliography, appendix, abstract-footer, utilities
  code.typ              ← code() source-listing block
  covers.typ             ← front-matter(): per-document-type front matter dispatcher
  project.typ            ← project(): the multi-type document template (orchestrator)
  poster.typ             ← isc-poster() / isc-card() / isc-colbreak()
  pages/cover_*.typ      ← one cover renderer per document type
  assets/                ← SVG logos
src/
  *.typ                  ← runnable demo/example documents (one per template)
  pages/                 ← shared content blocks (abstract, acknowledgements, résumé, honneur = bilingual declaration of honour)
  themes/                ← .tmTheme files for code highlighting
templates/*/typst.toml   ← per-package metadata (name, version, thumbnail)
typst.toml               ← root package version (must stay in sync with templates/)
i18n.json                ← all translated UI strings (fr / en / de)
scripts/                 ← pack, dev_link, uninstall, test-*.sh helpers
```

The `scripts/pack` script copies the shared source into each package slot and sets `entrypoint = "isc_templates.typ"`. Each `templates/*/typst.toml` pins the compiler version and declares the template thumbnail.

### How the public API is assembled

`isc_templates.typ` is the package entrypoint but contains no logic — it only
`#import ": *"`s each `lib/` module and re-exports their bindings, so
`#import "@preview/isc-hei-*": *` in a user document keeps exposing the same
names (`project`, `isc-poster`, `page-title`, `code`, `i18n`, `hes`, …).

> Path gotcha: `toml()`/`json()`/`image()`/`import`/`bibliography()` paths resolve
> relative to the **file** that contains them. Code that moved into `lib/` therefore
> uses `../` to reach the package root (e.g. `../typst.toml`, `../i18n.json`,
> `../src/themes/`). `../` lands on the package root in both the dev-symlink layout
> (`_dev/isc-hei-*/lib/…`) and the packed layout (`…/0.7.x/lib/…`), since `lib/` is a
> subdirectory of the root in both. Assets are addressed as `assets/…` from inside `lib/`.

> Cyclic-import gotcha: `lib/pages/cover_*.typ` import the entrypoint back
> (`#import "/isc_templates.typ" as isc`). `covers.typ` must therefore import those
> cover modules **lazily inside each branch of `front-matter()`**, not at module load,
> or Typst raises a load-time `cyclic import`.

### How `project()` works

Everything is gated on a `doc-type` parameter passed to `project()`:

```
"thesis" | "report" | "document" | "exec-summary" | "tb-assignment"
```

`project()` (in `lib/project.typ`) is the orchestrator: it sets fonts, margins,
running headers/footers, caption styling and code styling shared by every
document type, then delegates the per-type front matter to
`front-matter()` in `lib/covers.typ`, which selects and feeds the matching
`lib/pages/cover_*.typ`. The other user-callable functions live in their topical
module (`content.typ`, `decorations.typ`, `code.typ`, …) and read the shared
state variables declared in `lib/includes.typ`.

When verifying a refactor that should not change output, render the six examples
to PNG before and after and diff `md5sum`s — PDFs embed timestamps so compare
rasterised pages, not the PDFs themselves.

### Declaration of honour (thesis only)

`src/pages/honneur.typ` is a bilingual (FR/EN, driven by the document language)
declaration-of-honour page, `#include`d in `src/bachelor_thesis.typ` between the
résumé and the acknowledgements. It auto-fills author / title / academic-year /
date from `inc.global-thesis-meta` (populated by `project()`), so the only fields
the student must set are `date:` and `signature:` (an `image(...)`) on `project()`
— they never edit `honneur.typ`. A missing signature renders a red placeholder
(not a panic) and is flagged by the completeness check below.

### Completeness check (thesis cover, drafting aid)

`lib/pages/cover_bachelor.typ` renders a red "DOCUMENT INCOMPLET / INCOMPLETE
DOCUMENT" warning box on the title page listing unfilled fields: `thesis-id`
(empty/placeholder, or not matching `ISC-XX-YY-N` via regex), `signature`
(missing or still the shipped `signature_placeholder.svg`), `project-repos`, and
`keywords`. It stays silent while the document is still pristine — detected by the
author still equalling the sample `"James Gosling"`. **Sentinels in that file
(`sample-author`, `sample-thesis-id`, `sample-repo`, `sample-keywords`) mirror the
placeholders shipped in `src/bachelor_thesis.typ`; update both together.**

### Fonts-not-installed guard

`isc-fonts-available()` (lib/fonts.typ) is a Source-Sans-only proxy: it compares
the rendered width of `"MMMMMMMMMM"` in Source Sans vs. the always-bundled
Libertinus Serif; equal widths ⇒ fonts absent. Fira Code / Inria Sans are *not*
tested. When it fails, `_missing-fonts-page(paper:)` renders instead of the
document. It is wired into **both** entry points: `project()` (lib/project.typ,
covers thesis/report/document/exec-summary/tb-assignment) and `isc-poster()`
(lib/poster.typ, `paper: "a1"`). Both place the guard as the `else` of a
`context if not isc-fonts-available() { … } else { … }` so the document's own
`set page` rules only run in the else branch.

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
| `global-thesis-meta` | Dict (`title`, `author`, `academic-year`, `date`, `signature`) forwarded to the declaration-of-honour page (`src/pages/honneur.typ`) |

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
- `templates/poster/typst.toml`

Note: the root `typst.toml` and the template `typst.toml` files may legitimately differ by one patch version (root tracks the last published release; templates track the next).

## Fonts

Run `source src/fonts/install_fonts.sh` once to install Source Sans Pro/3, Fira Code, Inria Sans, and math fonts. Without them, compilation silently falls back to system fonts.
