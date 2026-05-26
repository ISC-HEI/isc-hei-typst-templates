root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# <!-- # generate manual
# doc:
# 	typst compile docs/manual.typ docs/manual.pdf

# # run test suite
# test *args:
# 	typst-test run {{ args }}

# # update test cases
# update *args:
# 	typst-test update {{ args }} -->

# install dev symlinks for all templates
install-symblinks:
  ./scripts/dev_link "@preview" "bachelor-thesis"
  ./scripts/dev_link "@preview" "report"
  ./scripts/dev_link "@preview" "document"
  ./scripts/dev_link "@preview" "exec-summary"
  ./scripts/dev_link "@preview" "tb-assignment"

# compile all src/ documents in parallel
compile-all:
  typst compile src/bachelor_thesis.typ examples/bachelor_thesis.pdf
  typst compile src/report.typ examples/report.pdf
  typst compile src/document.typ examples/document.pdf
  typst compile src/exec_summary.typ examples/exec_summary.pdf
  typst compile src/tb_assignment.typ examples/tb_assignment.pdf

[private]
remove target:
  ./scripts/uninstall "{{target}}" "bachelor-thesis"
  ./scripts/uninstall "{{target}}" "report"
  ./scripts/uninstall "{{target}}" "document"
  ./scripts/uninstall "{{target}}" "exec-summary"
  ./scripts/uninstall "{{target}}" "tb-assignment"

# uninstalls the library from the "@local" prefix
# uninstall: (remove "@local")

# pack all templates to a target prefix
pack_distro target:  
  ./scripts/pack "{{target}}" "bachelor-thesis"
  ./scripts/pack "{{target}}" "report"
  ./scripts/pack "{{target}}" "document"
  ./scripts/pack "{{target}}" "exec-summary"
  ./scripts/pack "{{target}}" "tb-assignment"

# pack all templates to @preview
pack_distro_preview : (pack_distro "@preview")

# uninstall all templates from @preview
uninstall: (remove "@preview")

# pack then run all test scripts
test-all: pack_distro_preview
  ./scripts/test-thesis.sh
  ./scripts/test-report.sh
  ./scripts/test-document.sh
  ./scripts/test-execsummary.sh
  ./scripts/test-tb-assignment.sh

# bump version in all typst.toml and src/ imports: 'patch' (0.7.2→0.7.3, default), 'minor' (0.7.2→0.8.0), or explicit 'X.Y.Z'
bump-version mode='patch':
  ./scripts/bump-version "{{mode}}"

# generate thumbnails from examples
generate-thumbs:
  convert -density 150 'examples/bachelor_thesis.pdf[0]' -flatten bachelor_thesis_thumb.png
  convert -density 150 'examples/report.pdf[0]' -flatten report_thumb.png
  convert -density 150 'examples/document.pdf[0]' -flatten document_thumb.png
  convert -density 150 'examples/exec_summary.pdf[0]' -flatten exec_summary.png
  convert -density 150 'examples/tb_assignment.pdf[0]' -flatten tb_assignment_thumb.png
  pngquant --quality 50-80 *.png --ext .png --force