# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Official [Typst](https://typst.app/) templates for the ISC bachelor degree programme at HEI Sion (HES-SO Valais), Switzerland. One shared codebase is distributed as **six separate packages** on the Typst Universe registry under `@preview/isc-hei-*`.

## Build commands

Requires: `typst` (≥ 0.14.0), `just`, `pngquant` + `zopflipng` (used by `generate-thumbs`, which `pack` runs).

> `generate-thumbs` renders each `src/*.typ` page 1 **directly with typst** at 120 ppi
> (`--pages 1 --format png --ppi 120`), then `pngquant` + a lossless `zopflipng` pass.
> Ghostscript/ImageMagick are no longer in the chain, so the raster is **byte-for-byte
> reproducible** given the same binaries + installed fonts (typst PNG export embeds no
> timestamp). Cross-machine equivalence still needs the same fonts installed.

The Justfile is split into four recipe groups (`just --list`): **dev** (work against
your live source via symlinks), **pre-release** (build + check the local @preview
artifacts), **universe** (open a release PR against `typst/packages`), and
**active-pr-flow** (refresh a PR that is already open). Packing replaces the dev
symlinks with real dirs; `just dev` self-heals them (and `test-all` / `bump-version`
restore them automatically), so you rarely need to think about it.

```sh
# ── dev ──
# THE dev command: re-link @preview to this repo (self-healing, even after a pack)
# then compile all six examples. Run this any time during development.
just dev

# (other dev recipes, if you want a step on its own)
just test                # compile all six packaged examples from live source
just test-poster         # only the poster layout checks
just compile-all         # compile the six src/ examples straight to examples/*.pdf
# `install-symblinks` is internal plumbing (hidden from the menu): `dev`, `test-all`
# and `bump-version` run it for you, but `just install-symblinks` still works for a
# bare relink (e.g. to refresh the editor live-preview without compiling).
# …or a single template
typst compile src/bachelor_thesis.typ examples/bachelor_thesis.pdf

# ── pre-release ──
# Pack all six packages to @preview (the real artifact; replaces dev symlinks)
just pack

# Verify each template packs EXACTLY its required files (no dangling leaks)
just check-pack

# Pre-publish check: pack the release, run check-pack, then test it
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
  settings.typ           ← shared metrics (heading sizes, spacing), version, keywords, programme-name
  fonts.typ              ← font stacks, ISC-font detection, "fonts not installed" page
  i18n.typ               ← i18n() string resolution + langs (reads ../i18n.json)
  decorations.typ        ← chapter-rule reading-position hairline + the hashed bit-rule (hash-rule)
  content.typ            ← page-title, TOC/figures, bibliography, appendix, abstract-footer, utilities
  code.typ              ← code() source-listing block
  covers.typ             ← front-matter(): per-document-type front matter dispatcher
  project.typ            ← project(): the multi-type document template (orchestrator)
  poster.typ             ← isc-poster() / isc-card() / isc-colbreak()
  pages/cover_*.typ      ← one cover renderer per document type
  pages/honour.typ       ← declaration-of-honour() (thesis; FR/DE/EN), moved in from src/
  assets/                ← SVG logos
src/
  *.typ                  ← runnable demo/example documents (one per template)
  pages/                 ← shared content blocks (abstract, acknowledgements, résumé)
  themes/                ← .tmTheme files for code highlighting
templates/*/typst.toml   ← per-package metadata (name, version, thumbnail)
typst.toml               ← root package version (must stay in sync with templates/)
i18n.json                ← all translated UI strings (fr / en / de)
scripts/                 ← pack, check-pack, template-files (pack allow-list SSOT), dev_link, uninstall, test-*.sh
```

The `scripts/pack` script copies the shared source into each package slot and sets `entrypoint = "isc_templates.typ"`. Each `templates/*/typst.toml` pins the compiler version and declares the template thumbnail.

> Packing is **allow-list driven from a single source of truth**: `scripts/template-files`
> defines `expected_for <template>` — the exact set of files each package must contain.
> `pack` copies the whole tree (minus `.typstignore`), then **prunes** everything not on
> that list, so a template can only ship its required files (the thesis-only
> `signature_placeholder.svg` can no longer leak into the other packages). `scripts/check-pack`
> (`just check-pack`) reads the *same* list, does a real pack into a throwaway dir, and
> reports EXTRA (dangling) / MISSING files — so pack and check cannot drift. It is wired
> into `just test-all`. The shared `lib/`, `src/{fonts,code,pages,themes}` trees are derived
> from the repo with `find`, so adding a file there needs no edit; only per-template figs
> and the example entry point are pinned. **When you add/remove/rename an example asset,
> edit `scripts/template-files` (one place) and run `just check-pack`.**

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

> Doc-type aliases (end of `lib/project.typ`): `thesis`, `report`, `exec-summary`,
> `tb-assignment` are thin `project.with(doc-type: …)` shims so example files write
> `#show: thesis.with(…)` and never pass `doc-type` (the thesis also drops
> `split-chapters`, which already defaults `true`). `project()` stays the canonical
> entry. There is deliberately **no `document` alias** — it would shadow Typst's
> built-in `document` element, so the document example keeps its explicit
> `doc-type: "document"`.

When verifying a refactor that should not change output, render the six examples
to PNG before and after and diff `md5sum`s — PDFs embed timestamps so compare
rasterised pages, not the PDFs themselves.

### Declaration of honour (thesis only)

`lib/pages/honour.typ` is a trilingual (FR/DE/EN, driven by the document language)
declaration-of-honour page. It lives in the **package** (it was the user-facing
`src/pages/honneur.typ`) and is exported as `declaration-of-honour()`, which the
thesis example calls between the résumé and the acknowledgements — the student
never edits the wording. It imports the `lib/` modules directly (NOT the
entrypoint) to dodge the cyclic-import trap. It auto-fills author / title /
academic-year / date from `inc.global-thesis-meta` (populated by `project()`), so
the only field the student sets is `signature:` (an `image(...)`) on `project()`.
A missing signature renders a red placeholder (not a panic) and is flagged by the
completeness check below. The legal wording is a first draft pending institutional
review (esp. the German: `Sitten` vs `Sion`, gendered middot forms).

### Programme name (default `programme:`)

The degree programme is **"Informatique et systèmes de communication"** — note the
lowercase `s` in "systèmes". `lib/settings.typ` factors it into two constants:
`programme-name` (bare) and `programme-name-isc` (`+ " (ISC)"`). Defaults differ by
document type on purpose: `lib/project.typ` (thesis/report/document/tb-assignment)
uses `programme-name` (no suffix); `lib/poster.typ` and
`lib/pages/cover_exec_summary.typ` use `programme-name-isc`. The `src/*.typ` demo
documents pass `programme:` explicitly as a literal string (they're detached from
the package by students), so the spelling must be fixed **in place** there — the
constant can't reach them. Keep the lowercase `s` consistent everywhere.

### Majors (default `major:`)

The five ISC majors are the single source of truth in `lib/settings.typ`:
`majors` is a list of `(fr, en, de)` dicts (**French is canonical**; the value
used to be a free-form string that drifted between covers). `validate-major(m)`
asserts a passed value is one of the known labels (any language; empty allowed)
and is called early in `project()` and `isc-poster()`. `resolve-major(m, lang)`
maps the value to the label for `lang`, so the cover always shows the major in
the document's language — wired into `cover_bachelor.typ`,
`cover_exec_summary.typ` and both poster render sites via `isc.resolve-major`.
The `src/*.typ` demos pass the English label (validated); a French/German doc
renders the FR/DE label automatically.

### Completeness check (thesis cover, drafting aid)

`lib/pages/cover_bachelor.typ` renders a red **"ATTENTION REQUISE"** warning box
(header from the `completeness-warning-header` i18n key, fr/en/de) on the title
page listing unfilled fields: `thesis-id` (empty/placeholder, or not matching
`ISC-XX-YY-N` via regex), `signature` (missing or still the shipped
`signature_placeholder.svg`), `project-repos`, and `keywords`. The same box also
carries the **title/subtitle-too-long** issues (see *Title/subtitle overflow*
below), which are appended unconditionally — independent of the `at-default`
gate, since overflow is a layout problem, not a completeness one. Because they
share the box, `hide-completeness-warning: true` suppresses the overflow warning
on the thesis too (the report, document, exec-summary and poster show a standalone
overflow box; the **tb-assignment** also folds overflow into its own completeness
box — see the next subsection). It stays silent only while **every** field still equals its shipped
placeholder (the `at-default` test); as soon as **any** field diverges from its
placeholder — including being emptied — the box appears and lists whichever
required fields are still incomplete. **Sentinels in that file (`sample-author`,
`sample-thesis-id`, `sample-repo`, `sample-keywords`) must mirror the placeholders
shipped in `src/bachelor_thesis.typ` exactly — `at-default` compares against them
verbatim, so any drift silently disables the gate; update both together.** An
empty (`""`) or removed `project-repos` is no longer fatal: `repo-block()`
(`content.typ`) renders nothing for an empty URL and the no-repo panic in
`project.typ` is gone, so the box flags it like any other field. The box is
positioned in the empty band below the author (`dy: 64mm`) so it never overlaps
the title header. `project()` accepts **`hide-completeness-warning`** (default
`false`): when `true` the box is suppressed even if fields are incomplete, and a
tiny red dot is placed in the bottom-left margin of the **second** cover page
(document page 3, since `cleardoublepage()` forces an odd page) as a discreet
record of the override. The issue list is computed once by a `compute-issues()`
closure reused by both the page-1 box and the page-2 marker.

### Completeness check (tb-assignment cover, drafting aid)

`lib/pages/cover_assignment.typ` mirrors the thesis gate with its own
`compute-issues()`: silent while **every** tracked field still carries its shipped
placeholder (`at-default`); as soon as **any** is touched it flags whichever of
`id` (placeholder, or not matching the `ISC-XX-YY-N` regex), `student`,
`supervisor` and the milestone **dates** are still incomplete. The dates
(`date-attribution`, `date-start`, `date-submission`, `date-exhibition-hei`,
`date-exhibition-monthey`) are compared **as a group** against their shipped
datetimes and flagged with one line. The title/subtitle-too-long issues are
appended unconditionally, and the merged red box — rendered between Table 1 and
Table 2 with the `completeness-warning-header` ("ATTENTION REQUISE"), not the
`layout-warning-header` — is absorbed by Table 2's `1fr` rows, so even the worst
case (long title + subtitle + every field flagged) stays on the existing two
pages. **Sentinels in that file (`sample-student`, `sample-id`,
`sample-supervisor`, `sample-dates`) must mirror the placeholders shipped in
`src/tb_assignment.typ` exactly — `at-default` compares against them verbatim, so
any drift silently disables the gate; update both together.** Unlike the thesis
there is no `hide-completeness-warning` opt-out. Caveat: a cohort that
legitimately keeps the shipped milestone dates still sees the dates flagged once
another field is touched — it is a drafting reminder, not a hard error.

### Title/subtitle overflow warning (all six document types)

`lib/overflow.typ` flags titles/subtitles that wrap onto too many lines and would
break a cover layout. It **measures** (not character-counts — that can't account
for glyph widths, smallcaps, or FR/EN/DE word lengths).

**One shared reference, for cross-document consistency.** A student reuses the same
title across the thesis, report, poster, exec-summary, etc. If each cover counted
lines at its *own* width/font, the same title could be flagged on the narrow thesis
cover yet pass on the huge A1 poster — confusing. So the verdict is always measured
against ONE reference cover: the **bachelor thesis** (the narrowest/strictest
layout) — `_ref-width = 151mm`, title `24pt/660`, subtitle `12pt`, font **pinned**
to `body-font` so the measurement is identical regardless of which document's
context runs it. A title that fits the thesis fits every cover, so the warning is
identical on all six documents. Two library knobs in `lib/settings.typ`:
**`max-title-lines`** and **`max-subtitle-lines`**, interpreted *at the reference*
(1 title line ≈ 35–45 chars; 2 subtitle lines ≈ 140 chars).

`exceeds-lines(style, body, width, max-lines)` (must run in `context`) compares the
wrapped height to a probe of exactly `max-lines` forced lines in the same styling —
no fragile height÷leading math. `title-too-long()` / `subtitle-too-long()` apply it
to the reference; `title-overflow-issues(title, subtitle:, lang:)` returns the
i18n'd list; `overflow-warning-box()` renders the red box (completeness-box visual,
with a `scale` factor for the A1 poster, and a `lang` override for the poster which
bypasses `project()`'s `global-language` state). `summary-too-long()` is an
exec-summary-only check that **measures** whether the blurb, wrapped at the exec box
width, is taller than its 3cm box (same measure-don't-count philosophy as the
title/subtitle; geometry constants `_summary-box-{width,height}` live in overflow.typ
and mirror the cover render). An over-length summary is flagged in the same box
instead of panicking. i18n keys:
`layout-warning-header` (a generic "content may overflow" header — the box now carries
title/subtitle/summary), `completeness-warning-header`, `title-too-long`,
`subtitle-too-long`, `summary-too-long` (fr/en/de).

Per-cover the verdict is the same; only **where the box renders** differs. Each call
sits in a plain `context {}` — **never `layout()`**, which is a real block that
shifts the fr-spaced covers even when it renders nothing (so a no-overflow render
stays byte-identical):
- **thesis** — appended to `compute-issues()`, shown in the "ATTENTION REQUISE" box.
- **report / document** — in-flow box below the title (absorbed by the flexible
  spacing); runs only when `show-cover: true` (the compact inline header is unchecked).
- **exec-summary** — banner above the title; has its own `subtitle:` (rendered under
  the title inside the 6em block, wired from `covers.typ`). Also flags an over-length
  `summary` here (the old hard `panic` for length is gone; an empty summary still panics).
- **tb-assignment** — folded into `compute-issues()` (like the thesis) and shown in
  the "ATTENTION REQUISE" box between Table 1 and Table 2; checks the `subtitle` too.
- **poster** — placed in the page **foreground** (an overlay, NOT in the flow) so the
  warning never pushes content onto a second A1 page; passes `lang:` explicitly.

Because the shipped example titles must clear the strict (1-line) reference, the
exec-summary / tb-assignment / poster sample titles are kept short; lengthening one
past ~45 chars will make every document show the warning.

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
| `global-thesis-meta` | Dict (`title`, `author`, `academic-year`, `date`, `signature`) forwarded to the declaration-of-honour page (`lib/pages/honour.typ`) |

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
