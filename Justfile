root := justfile_directory()

export TYPST_ROOT := root

# `just` (no args) prints this menu, grouped by workflow, in definition order.
# Legend for the descriptions below:
#   ▶            a primary command you run directly (the entry point of a workflow)
#   auto-runs:   recipes this one cascades into first (you don't run those yourself)
#   [run once]   one-time setup
# Building-block helpers that are only ever auto-run are marked [private] and hidden
# here, but stay runnable by name (e.g. `just generate-thumbs`).
[private]
default:
	@just --list --unsorted

# ──────────────────────────────────────────────────────────────────────────────
# LOCAL DEVELOPMENT — work against your live source, nothing gets packed.
# Day-to-day loop: just run `dev`. It re-links @preview to this repo and compiles
# all six examples, and it SELF-HEALS the symlinks — so it works even right after
# a `pack`/`test-all` clobbered them. No more "did my symlinks survive?".
# ──────────────────────────────────────────────────────────────────────────────

# ▶ the dev command: (re)link @preview to live source, then compile all six examples
[group('dev')]
dev: install-symblinks test

# internal plumbing: (re)link @preview to this repo's live source. Not in the menu —
# `dev` runs it, and `test-all` / `bump-version` reuse it to restore dev mode. You can
# still call `just install-symblinks` directly for a relink without the compile.
[private]
install-symblinks:
  ./scripts/dev_link "@preview" "bachelor-thesis"
  ./scripts/dev_link "@preview" "report"
  ./scripts/dev_link "@preview" "document"
  ./scripts/dev_link "@preview" "exec-summary"
  ./scripts/dev_link "@preview" "tb-assignment"
  ./scripts/dev_link "@preview" "poster"

# ▶ compile all six src/ examples → examples/*.pdf (also auto-run by pack)
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

# ▶ compile all six packaged examples against the current @preview (dev source or packed)
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

# ▶ poster-only: check every variant fits a single A1 page
[group('dev')]
test-poster:
  #!/usr/bin/env bash
  set -euo pipefail
  ./scripts/show-pkg-mode
  ./scripts/test-poster-variants.sh

# ──────────────────────────────────────────────────────────────────────────────
# PRE-RELEASE (Typst Universe) — build + validate the local @preview artifacts.
# `pack` builds the real packages and REPLACES the dev symlinks; run `just dev`
# (or `install-symblinks`) afterwards to return to local development. `test-all`
# and `bump-version` already restore the symlinks for you.
# ──────────────────────────────────────────────────────────────────────────────

# ▶ bump version across typst.toml + src/ imports: patch (default) | minor | X.Y.Z  (then restores dev symlinks)
[group('pre-release')]
bump-version mode='patch': && install-symblinks
  ./scripts/bump-version "{{mode}}"

# (helper) regenerate template thumbnails — render src/ page 1 directly with typst (no Ghostscript), then pngquant + zopflipng. Reproducible byte-for-byte; needs typst + pngquant + zopflipng. Auto-run by pack.
[private]
[group('pre-release')]
generate-thumbs:
  #!/usr/bin/env bash
  set -euo pipefail
  # Render <src>.typ page 1 → <out>.png at 120 ppi (no PDF/Ghostscript in the chain,
  # so the raster is deterministic), shrink with pngquant, then a lossless zopflipng
  # pass. Same binaries + fonts ⇒ byte-identical output, no metadata timestamps.
  thumb() {
    local src="$1" out="$2"
    typst compile "src/${src}.typ" --pages 1 --format png --ppi 120 "$out"
    pngquant --quality 50-80 "$out" --ext .png --force
    zopflipng -y "$out" "${out}.tmp" && mv -f "${out}.tmp" "$out"
  }
  pids=(); declare -A pid_cmd
  run_bg() { echo "  [//] thumb $*"; thumb "$@" & pid=$!; pids+=("$pid"); pid_cmd[$pid]="thumb $*"; }
  echo "── rendering 6 thumbnails (typst 120ppi → pngquant → zopflipng) in parallel ──"
  run_bg bachelor_thesis bachelor_thesis_thumb.png
  run_bg report          report_thumb.png
  run_bg document        document_thumb.png
  run_bg exec_summary    exec_summary.png
  run_bg tb_assignment   tb_assignment_thumb.png
  run_bg poster          poster_thumb.png
  echo "── waiting for ${#pids[@]} jobs ─────────────────────────────────────"
  failed=0
  for pid in "${pids[@]}"; do
    wait "$pid" || { echo "error: FAILED: ${pid_cmd[$pid]}" >&2; failed=1; }
  done
  [ "$failed" -eq 0 ]
  echo "── all done ──────────────────────────────────────────────────────────"

# ▶ build all six @preview packages — the real artifact (auto-runs: compile-all, generate-thumbs; replaces dev symlinks)
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

# ▶ verify each template packs ONLY its required files — catches leaks (throwaway pack; dev symlinks untouched)
[group('pre-release')]
check-pack:
  ./scripts/check-pack

# ▶ full pre-publish gate — auto-runs: pack → check-pack → test, then restores dev symlinks
[group('pre-release')]
test-all: pack check-pack test && install-symblinks

# ▶ remove all isc-hei-* packages/symlinks from @preview
[group('pre-release')]
uninstall:
  ./scripts/uninstall "@preview" "bachelor-thesis"
  ./scripts/uninstall "@preview" "report"
  ./scripts/uninstall "@preview" "document"
  ./scripts/uninstall "@preview" "exec-summary"
  ./scripts/uninstall "@preview" "tb-assignment"
  ./scripts/uninstall "@preview" "poster"

# ──────────────────────────────────────────────────────────────────────────────
# UNIVERSE (Typst Universe) — automate the boilerplate of opening a release PR.
# Order: universe-stage → (review) → universe-push, then open the PR from the
# printed compare URL. universe-push is the only step that writes to the network;
# neither creates the PR. Override the fork clone with: UNIVERSE_CLONE=/path just universe-stage
# ──────────────────────────────────────────────────────────────────────────────

# ▶ stage a release: clone fork, base isc-hei-<ver> on upstream/main, pack+validate all six, commit — no push  (auto-runs: compile-all, generate-thumbs)
[group('universe')]
universe-stage: compile-all generate-thumbs
  ./scripts/universe-stage

# (auto-run during staging — by universe-stage, and update-pr through it) re-validate the staged packages with typst-package-check
[group('universe')]
universe-check:
  ./scripts/universe-check

# ▶ push the staged branch to your fork + print the PR compare URL (only step that writes to the network)
[group('universe')]
universe-push:
  ./scripts/universe-push

# ──────────────────────────────────────────────────────────────────────────────
# ACTIVE PR FLOW (Typst Universe) — update an already-open (unmerged) PR after
# fixing something at the SAME version: re-stages and FORCE-pushes over the branch,
# so the PR re-runs CI in place — no new PR, no bump. Published versions are
# immutable: for those, bump-version + universe-push instead.
# ──────────────────────────────────────────────────────────────────────────────

# ▶ refresh an OPEN PR at the same version: re-stage + force-push over its branch  (auto-runs: universe-stage)
[group('active-pr-flow')]
update-pr: universe-stage
  ./scripts/universe-repush
