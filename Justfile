root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# ──────────────────────────────────────────────────────────────────────────────
# LOCAL DEVELOPMENT — work against your live source, nothing gets packed.
# ──────────────────────────────────────────────────────────────────────────────

# install dev symlinks so the @preview packages point at this repo (run once)
[group('dev')]
install-symblinks:
  ./scripts/dev_link "@preview" "bachelor-thesis"
  ./scripts/dev_link "@preview" "report"
  ./scripts/dev_link "@preview" "document"
  ./scripts/dev_link "@preview" "exec-summary"
  ./scripts/dev_link "@preview" "tb-assignment"
  ./scripts/dev_link "@preview" "poster"

# compile every src/ example to examples/*.pdf
[group('dev')]
compile-all:
  typst compile src/bachelor_thesis.typ examples/bachelor_thesis.pdf
  typst compile src/report.typ examples/report.pdf
  typst compile src/document.typ examples/document.pdf
  typst compile src/exec_summary.typ examples/exec_summary.pdf
  typst compile src/tb_assignment.typ examples/tb_assignment.pdf
  typst compile src/poster.typ examples/poster.pdf

# run the full test suite against installed packages (your live source after install-symblinks; no packing)
[group('dev')]
test:
  ./scripts/test-thesis.sh
  ./scripts/test-report.sh
  ./scripts/test-document.sh
  ./scripts/test-execsummary.sh
  ./scripts/test-tb-assignment.sh
  ./scripts/test-poster.sh
  ./scripts/test-poster-variants.sh

# run only the poster layout checks (every variant must fit one A1 page)
[group('dev')]
test-poster:
  ./scripts/test-poster-variants.sh

# ──────────────────────────────────────────────────────────────────────────────
# RELEASE (Typst Universe) — `pack` builds the real artifacts and REPLACES the dev
# symlinks; run `install-symblinks` afterwards to return to local development.
# ──────────────────────────────────────────────────────────────────────────────

# re-installs dev symlinks afterwards so @preview resolves the new version (returns the workspace to dev mode)
# bump version in all typst.toml and src/ imports: 'patch' (0.7.2→0.7.3, default), 'minor' (0.7.2→0.8.0), or explicit 'X.Y.Z'
[group('release')]
bump-version mode='patch': && install-symblinks
  ./scripts/bump-version "{{mode}}"

# regenerate template thumbnails from examples/*.pdf (needs ImageMagick + pngquant)
[group('release')]
generate-thumbs:
  convert -density 150 'examples/bachelor_thesis.pdf[0]' -flatten bachelor_thesis_thumb.png
  convert -density 150 'examples/report.pdf[0]' -flatten report_thumb.png
  convert -density 150 'examples/document.pdf[0]' -flatten document_thumb.png
  convert -density 150 'examples/exec_summary.pdf[0]' -flatten exec_summary.png
  convert -density 150 'examples/tb_assignment.pdf[0]' -flatten tb_assignment_thumb.png
  convert -density 150 'examples/poster.pdf[0]' -flatten poster_thumb.png
  pngquant --quality 50-80 *.png --ext .png --force

# depends on compile-all + generate-thumbs so packed examples and thumbnails are fresh
# pack all templates to @preview as the Universe artifact (replaces dev symlinks)
[group('release')]
pack: compile-all generate-thumbs
  ./scripts/pack "@preview" "bachelor-thesis"
  ./scripts/pack "@preview" "report"
  ./scripts/pack "@preview" "document"
  ./scripts/pack "@preview" "exec-summary"
  ./scripts/pack "@preview" "tb-assignment"
  ./scripts/pack "@preview" "poster"

# pack the release, then test it — run before publishing to Typst Universe
[group('release')]
test-all: pack test

# ──────────────────────────────────────────────────────────────────────────────
# PUBLISH (Typst Universe) — automate the messy boilerplate of opening a release PR.
# `universe-stage` does everything up to a committed, validated branch; `universe-push`
# is the only step that touches the network for writing. Neither creates the PR — you
# write that yourself via the compare URL printed by `universe-push`.
# Override the fork clone location with: UNIVERSE_CLONE=/path just universe-stage
# ──────────────────────────────────────────────────────────────────────────────

# sparse-clone the fork, base a fresh isc-hei-<ver> branch on upstream/main, pack + validate all six, commit (no push)
[group('release')]
universe-stage: compile-all generate-thumbs
  ./scripts/universe-stage

# validate the already-packed packages in the fork clone with typst-package-check
[group('release')]
universe-check:
  ./scripts/universe-check

# push the staged release branch to your fork and print the PR compare URL (only networked-write step)
[group('release')]
universe-push:
  ./scripts/universe-push

# remove all packed/symlinked templates from @preview
[group('release')]
uninstall:
  ./scripts/uninstall "@preview" "bachelor-thesis"
  ./scripts/uninstall "@preview" "report"
  ./scripts/uninstall "@preview" "document"
  ./scripts/uninstall "@preview" "exec-summary"
  ./scripts/uninstall "@preview" "tb-assignment"
  ./scripts/uninstall "@preview" "poster"
