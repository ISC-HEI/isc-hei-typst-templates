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
  #!/usr/bin/env bash
  set -euo pipefail
  ./scripts/show-pkg-mode
  pids=(); declare -A pid_cmd
  run_bg() { echo "  [//] $*"; "$@" & pid=$!; pids+=("$pid"); pid_cmd[$pid]="$*"; }
  echo "── running 6 typst compile jobs in parallel ─────────────────────────"
  run_bg typst compile src/bachelor_thesis.typ examples/bachelor_thesis.pdf
  run_bg typst compile src/report.typ           examples/report.pdf
  run_bg typst compile src/document.typ         examples/document.pdf
  run_bg typst compile src/exec_summary.typ     examples/exec_summary.pdf
  run_bg typst compile src/tb_assignment.typ    examples/tb_assignment.pdf
  run_bg typst compile src/poster.typ           examples/poster.pdf
  echo "── waiting for ${#pids[@]} jobs ─────────────────────────────────────"
  failed=0
  for pid in "${pids[@]}"; do
    wait "$pid" || { echo "error: FAILED: ${pid_cmd[$pid]}" >&2; failed=1; }
  done
  [ "$failed" -eq 0 ] && echo "── all done ──────────────────────────────────────────────────────────"
  exit $failed

# run the full test suite against installed packages (your live source after install-symblinks; no packing)
[group('dev')]
test:
  #!/usr/bin/env bash
  set -euo pipefail
  ./scripts/show-pkg-mode
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
  #!/usr/bin/env bash
  set -euo pipefail
  ./scripts/show-pkg-mode
  ./scripts/test-poster-variants.sh

# ──────────────────────────────────────────────────────────────────────────────
# PRE-RELEASE (Typst Universe) — bump, build, validate and tear down the local
# @preview artifacts. `pack` builds the real artifacts and REPLACES the dev
# symlinks; run `install-symblinks` afterwards to return to local development.
# ──────────────────────────────────────────────────────────────────────────────

# re-installs dev symlinks afterwards so @preview resolves the new version (returns the workspace to dev mode)
# bump version in all typst.toml and src/ imports: 'patch' (0.7.2→0.7.3, default), 'minor' (0.7.2→0.8.0), or explicit 'X.Y.Z'
[group('pre-release')]
bump-version mode='patch': && install-symblinks
  ./scripts/bump-version "{{mode}}"

# regenerate template thumbnails from examples/*.pdf (needs ImageMagick + pngquant)
[group('pre-release')]
generate-thumbs:
  #!/usr/bin/env bash
  set -euo pipefail
  pids=(); declare -A pid_cmd
  run_bg() { echo "  [//] $*"; "$@" & pid=$!; pids+=("$pid"); pid_cmd[$pid]="$*"; }
  echo "── running 6 convert jobs in parallel ───────────────────────────────"
  run_bg convert -density 150 'examples/bachelor_thesis.pdf[0]' -flatten bachelor_thesis_thumb.png
  run_bg convert -density 150 'examples/report.pdf[0]'          -flatten report_thumb.png
  run_bg convert -density 150 'examples/document.pdf[0]'        -flatten document_thumb.png
  run_bg convert -density 150 'examples/exec_summary.pdf[0]'    -flatten exec_summary.png
  run_bg convert -density 150 'examples/tb_assignment.pdf[0]'   -flatten tb_assignment_thumb.png
  run_bg convert -density 150 'examples/poster.pdf[0]'          -flatten poster_thumb.png
  echo "── waiting for ${#pids[@]} jobs ─────────────────────────────────────"
  failed=0
  for pid in "${pids[@]}"; do
    wait "$pid" || { echo "error: FAILED: ${pid_cmd[$pid]}" >&2; failed=1; }
  done
  [ "$failed" -eq 0 ]
  echo "  pngquant --quality 50-80 *.png --ext .png --force"
  pngquant --quality 50-80 *.png --ext .png --force
  echo "── all done ──────────────────────────────────────────────────────────"

# depends on compile-all + generate-thumbs so packed examples and thumbnails are fresh
# pack all templates to @preview as the Universe artifact (replaces dev symlinks)
[group('pre-release')]
pack: compile-all generate-thumbs
  #!/usr/bin/env bash
  set -euo pipefail
  pids=(); declare -A pid_cmd
  run_bg() { echo "  [//] $*"; "$@" & pid=$!; pids+=("$pid"); pid_cmd[$pid]="$*"; }
  echo "── running 6 pack jobs in parallel ──────────────────────────────────"
  run_bg ./scripts/pack "@preview" "bachelor-thesis"
  run_bg ./scripts/pack "@preview" "report"
  run_bg ./scripts/pack "@preview" "document"
  run_bg ./scripts/pack "@preview" "exec-summary"
  run_bg ./scripts/pack "@preview" "tb-assignment"
  run_bg ./scripts/pack "@preview" "poster"
  echo "── waiting for ${#pids[@]} jobs ─────────────────────────────────────"
  failed=0
  for pid in "${pids[@]}"; do
    wait "$pid" || { echo "error: FAILED: ${pid_cmd[$pid]}" >&2; failed=1; }
  done
  [ "$failed" -eq 0 ] && echo "── all done ──────────────────────────────────────────────────────────"
  exit $failed

# pack the release, then test it — run before publishing to Typst Universe
[group('pre-release')]
test-all: pack test

# remove all packed/symlinked templates from @preview
[group('pre-release')]
uninstall:
  ./scripts/uninstall "@preview" "bachelor-thesis"
  ./scripts/uninstall "@preview" "report"
  ./scripts/uninstall "@preview" "document"
  ./scripts/uninstall "@preview" "exec-summary"
  ./scripts/uninstall "@preview" "tb-assignment"
  ./scripts/uninstall "@preview" "poster"

# ──────────────────────────────────────────────────────────────────────────────
# UNIVERSE (Typst Universe) — automate the messy boilerplate of opening a release PR.
# `universe-stage` does everything up to a committed, validated branch; `universe-push`
# is the only step that touches the network for writing. Neither creates the PR — you
# write that yourself via the compare URL printed by `universe-push`.
# Override the fork clone location with: UNIVERSE_CLONE=/path just universe-stage
# ──────────────────────────────────────────────────────────────────────────────

# sparse-clone the fork, base a fresh isc-hei-<ver> branch on upstream/main, pack + validate all six, commit (no push)
[group('universe')]
universe-stage: compile-all generate-thumbs
  ./scripts/universe-stage

# validate the already-packed packages in the fork clone with typst-package-check
[group('universe')]
universe-check:
  ./scripts/universe-check

# push the staged release branch to your fork and print the PR compare URL (only networked-write step)
[group('universe')]
universe-push:
  ./scripts/universe-push

# ──────────────────────────────────────────────────────────────────────────────
# ACTIVE PR FLOW (Typst Universe) — update a PR that is already open (unmerged) when
# you've fixed something at the SAME version. Re-stages the current version and
# FORCE-pushes over the existing branch, so the open PR re-runs CI in place — no new
# PR, no version bump. Use only while the PR is unmerged (published versions are
# immutable — bump + universe-push for those instead).
# ──────────────────────────────────────────────────────────────────────────────

# re-stage the current version, then force-push it over the existing PR branch
[group('active-pr-flow')]
update-pr: universe-stage
  ./scripts/universe-repush
